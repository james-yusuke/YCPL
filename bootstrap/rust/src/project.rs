use crate::{ast::*, parser};
use std::os::unix::fs::MetadataExt;
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::{Path, PathBuf},
};
#[derive(Debug)]
pub struct Project {
    pub files: Vec<File>,
    pub imports: Vec<BTreeMap<String, usize>>,
    pub output: PathBuf,
    pub stl: PathBuf,
    pub source_roots: Vec<PathBuf>,
}
fn io_error(p: &Path, e: impl std::fmt::Display) -> Error {
    Error {
        file: p.into(),
        span: Span { line: 1, col: 1 },
        message: e.to_string(),
    }
}
fn scan(p: &Path, seen: &mut BTreeSet<(u64, u64)>, out: &mut Vec<PathBuf>) -> Result<()> {
    let meta = fs::metadata(p).map_err(|e| io_error(p, e))?;
    if !seen.insert((meta.dev(), meta.ino())) {
        return Ok(());
    }
    if meta.is_file() {
        if p.extension().is_some_and(|s| s == "yc") {
            out.push(p.to_path_buf());
        }
    } else if meta.is_dir() {
        let mut entries = fs::read_dir(p)
            .map_err(|e| io_error(p, e))?
            .map(|e| e.map(|e| e.path()))
            .collect::<std::io::Result<Vec<_>>>()
            .map_err(|e| io_error(p, e))?;
        entries.sort();
        for e in entries {
            scan(&e, seen, out)?;
        }
    }
    Ok(())
}
impl Project {
    pub fn load(inputs: &[PathBuf], stl: PathBuf) -> Result<Self> {
        let first = inputs
            .first()
            .cloned()
            .unwrap_or_else(|| PathBuf::from("."));
        let mut root = if first.is_dir() {
            first.clone()
        } else {
            first.parent().unwrap_or(Path::new(".")).into()
        };
        let mut config = None;
        if first.is_dir() || inputs.is_empty() {
            let mut search = root.clone();
            loop {
                let p = search.join("YCPL.json");
                if p.exists() {
                    let s = fs::read_to_string(&p).map_err(|e| io_error(&p, e))?;
                    config = Some(
                        serde_json::from_str::<serde_json::Value>(&s)
                            .map_err(|e| io_error(&p, e))?,
                    );
                    root = search;
                    break;
                }
                if !search.pop() {
                    break;
                }
            }
        }
        let mut roots = Vec::new();
        let mut sources = Vec::new();
        let mut seen = BTreeSet::new();
        let mut output = PathBuf::from("build");
        if let Some(c) = config {
            if let Some(s) = c.get("output").and_then(|s| s.as_str()) {
                output = root.join(s);
            }
            let dirs = c
                .get("src")
                .and_then(|s| s.as_array())
                .ok_or_else(|| io_error(&root, "YCPL.json requires a src array"))?;
            for dir in dirs {
                let d = root.join(
                    dir.as_str()
                        .ok_or_else(|| io_error(&root, "src entries must be strings"))?,
                );
                roots.push(d.clone());
                scan(&d, &mut seen, &mut sources)?;
            }
        } else {
            for input in if inputs.is_empty() {
                std::slice::from_ref(&first)
            } else {
                inputs
            } {
                roots.push(if input.is_dir() {
                    input.clone()
                } else {
                    input.parent().unwrap_or(Path::new(".")).into()
                });
                scan(input, &mut seen, &mut sources)?;
            }
        }
        sources.sort();
        if sources.is_empty() {
            return Err(io_error(&root, "No .yc source files found"));
        }
        let mut p = Self {
            files: Vec::new(),
            imports: Vec::new(),
            output,
            stl,
            source_roots: roots,
        };
        let mut loaded = BTreeMap::new();
        for source in sources {
            p.add(&source, &mut loaded)?;
        }
        Ok(p)
    }
    fn add(&mut self, path: &Path, loaded: &mut BTreeMap<PathBuf, usize>) -> Result<usize> {
        let canonical = fs::canonicalize(path).map_err(|e| io_error(path, e))?;
        if let Some(&i) = loaded.get(&canonical) {
            return Ok(i);
        }
        let s = fs::read_to_string(path).map_err(|e| io_error(path, e))?;
        let mut f = parser::parse(path, &s)?;
        if f.module.is_empty() {
            f.module = path.file_stem().unwrap().to_string_lossy().into_owned();
        }
        let imports = f.imports.clone();
        let id = self.files.len();
        loaded.insert(canonical, id);
        self.files.push(f);
        self.imports.push(BTreeMap::new());
        for (import, alias) in imports {
            let mut candidates = Vec::new();
            if import.starts_with('.') {
                candidates.push(path.parent().unwrap_or(Path::new(".")).join(&import));
            } else {
                candidates.push(path.parent().unwrap_or(Path::new(".")).join(&import));
                for root in &self.source_roots {
                    candidates.push(root.join(&import));
                }
                candidates.push(self.stl.join(&import));
            }
            let found = candidates
                .into_iter()
                .flat_map(|p| [p.with_extension("yc"), p.join("index.yc")])
                .find(|p| p.is_file())
                .ok_or_else(|| io_error(path, format!("Cannot resolve import '{import}'")))?;
            let dep = self.add(&found, loaded)?;
            self.imports[id].insert(alias, dep);
        }
        Ok(id)
    }
}
