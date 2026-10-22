mod ast;
mod bridge;
mod codegen;
mod lexer;
mod llvm;
mod parser;
mod project;
#[cfg(test)]
mod tests;
use std::os::unix::process::ExitStatusExt;
use std::{
    env, fs,
    path::{Path, PathBuf},
    process::{Command, ExitCode},
};
fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../..")
}
fn env_path(name: &str) -> Option<PathBuf> {
    env::var_os(name)
        .filter(|s| !s.is_empty())
        .map(PathBuf::from)
}
fn asset(name: &str) -> Option<PathBuf> {
    let cwd = env::current_dir().ok()?;
    let exe = env::current_exe().ok()?;
    let mut candidates = vec![
        cwd.join(name),
        cwd.join("../..").join(name),
        root().join(name),
    ];
    if let Some(r) = env_path("RUNFILES_DIR") {
        candidates.push(r.join("_main").join(name));
    }
    if let Some(r) = env_path("TEST_SRCDIR") {
        candidates.push(
            r.join(env::var("TEST_WORKSPACE").unwrap_or("_main".into()))
                .join(name),
        );
    }
    candidates.push(PathBuf::from(format!(
        "{}.runfiles/_main/{name}",
        exe.display()
    )));
    candidates.into_iter().find(|p| p.exists())
}
fn llvm_config() -> PathBuf {
    if let Some(p) = env_path("LLVM_CONFIG") {
        return p;
    }
    if let Some(d) = env_path("LLVM_BINDIR") {
        return d.join("llvm-config");
    }
    if let Some(d) = env_path("LLVM_DIR") {
        return d.join("../../../bin/llvm-config");
    }
    for p in [
        "/opt/homebrew/opt/llvm@22/bin/llvm-config",
        "/usr/local/opt/llvm@22/bin/llvm-config",
        "/usr/lib/llvm-22/bin/llvm-config",
    ] {
        if Path::new(p).exists() {
            return p.into();
        }
    }
    "llvm-config".into()
}
fn query(args: &[&str]) -> std::result::Result<String, String> {
    let o = Command::new(llvm_config())
        .args(args)
        .output()
        .map_err(|e| format!("llvm-config: {e}"))?;
    if !o.status.success() {
        return Err(String::from_utf8_lossy(&o.stderr).into_owned());
    }
    Ok(String::from_utf8_lossy(&o.stdout).trim().to_owned())
}
fn tool(key: &str, name: &str) -> PathBuf {
    if let Some(p) = env_path(key) {
        return p;
    }
    if let Some(d) = env_path("LLVM_BINDIR") {
        return d.join(name);
    }
    query(&["--bindir"])
        .map(|d| PathBuf::from(d).join(name))
        .unwrap_or_else(|_| name.into())
}
fn run(mut c: Command) -> std::result::Result<(), String> {
    let desc = format!("{c:?}");
    let s = c.status().map_err(|e| format!("{desc}: {e}"))?;
    if !s.success() {
        return Err(format!("command failed ({s}): {desc}"));
    }
    Ok(())
}
fn build(
    out: &Path,
    ir: &str,
    keep: bool,
    link_llvm: bool,
) -> std::result::Result<PathBuf, String> {
    let ll = out.join("merged.ll");
    let obj = out.join("merged.o");
    let bin = out.join("merged");
    let runtime_obj = out.join("yc_runtime.o");
    let mut c = Command::new(tool("LLC", "llc"));
    c.args(["-filetype=obj", "-relocation-model=pic"])
        .arg(&ll)
        .arg("-o")
        .arg(&obj);
    run(c)?;
    let runtime = if let Some(lib) = env_path("YCPL_RUNTIME_LIB") {
        if !lib.is_file() {
            return Err(format!("runtime library not found: {}", lib.display()));
        }
        lib
    } else {
        let source = env_path("YCPL_RUNTIME_SRC")
            .or_else(|| asset("bootstrap/cpp/runtime/yc_runtime.c"))
            .ok_or("YCPL runtime not found; set YCPL_RUNTIME_LIB or YCPL_RUNTIME_SRC")?;
        let mut c = Command::new(tool("CLANG", "clang"));
        c.args(["-std=c11", "-D_POSIX_C_SOURCE=200809L", "-c"])
            .arg(source)
            .arg("-o")
            .arg(&runtime_obj);
        run(c)?;
        runtime_obj.clone()
    };
    let mut c = Command::new(tool("CLANG", "clang"));
    c.arg(&obj).arg(runtime).arg("-o").arg(&bin).arg("-lm");
    if let Ok(flags) = env::var("LINKFLAGS") {
        c.args(shlex::split(&flags).ok_or("invalid LINKFLAGS quoting")?);
    }
    if link_llvm || ir.contains("@LLVM") {
        let flags = query(&[
            "--link-shared",
            "--ldflags",
            "--libs",
            "--system-libs",
            "core",
            "native",
            "nativecodegen",
            "support",
        ])?;
        c.args(shlex::split(&flags).ok_or("invalid llvm-config flags")?);
        c.arg(format!("-Wl,-rpath,{}", query(&["--libdir"])?));
    }
    run(c)?;
    if !keep {
        let _ = fs::remove_file(&obj);
        let _ = fs::remove_file(&runtime_obj);
    }
    Ok(bin)
}
fn help() {
    println!(
        "usage: ycc-bootstrap-rust <build|build-ir|run|debug|lex|parse|check|resolve|help> [options] [file.yc | project]\noptions: -o <directory> --keep-obj --link-llvm -- <program arguments>"
    );
}
fn cli() -> std::result::Result<i32, String> {
    let args = env::args_os().skip(1).collect::<Vec<_>>();
    if args.is_empty() {
        help();
        return Ok(1);
    }
    let mut mode = "build".to_owned();
    let mut inputs = Vec::new();
    let mut output = None;
    let mut keep = false;
    let mut link = false;
    let mut run_args = Vec::new();
    let mut i = 0;
    while i < args.len() {
        let s = args[i].to_str().unwrap_or("");
        match s {
            "help" | "--help" | "-h" => {
                help();
                return Ok(0);
            }
            "build" | "build-ir" | "run" | "debug" | "lex" | "parse" | "check" | "resolve" => {
                mode = s.into()
            }
            "ll" | "ir" => mode = "build-ir".into(),
            "-o" | "--output" => {
                i += 1;
                output = Some(PathBuf::from(
                    args.get(i).ok_or("-o requires an output directory")?,
                ));
            }
            "--keep-obj" => keep = true,
            "--link-llvm" => link = true,
            "--" => {
                run_args.extend_from_slice(&args[i + 1..]);
                break;
            }
            _ if s.starts_with('-') => return Err(format!("unknown option: {s}")),
            _ => inputs.push(PathBuf::from(&args[i])),
        }
        i += 1;
    }
    let version = query(&["--version"])?;
    if !version.starts_with("22.") {
        return Err(format!(
            "Rust bootstrap requires LLVM 22; llvm-config reports {version}"
        ));
    }
    let stl = env_path("YCPL_STL_ROOT")
        .or_else(|| asset("stl"))
        .ok_or("standard library not found; set YCPL_STL_ROOT")?;
    if mode == "lex" {
        for file in &inputs {
            let source = fs::read_to_string(file).map_err(|e| e.to_string())?;
            for token in lexer::lex(file, &source).map_err(|e| e.to_string())? {
                println!("{}:{} {:?}", token.span.line, token.span.col, token.text);
            }
        }
        return Ok(0);
    }
    let p = project::Project::load(&inputs, stl).map_err(|e| e.to_string())?;
    if mode == "parse" {
        for f in &p.files {
            println!(
                "parse ok: {} decls={} stmts={} exprs={}",
                f.path.display(),
                f.declarations.len(),
                f.stmts.len(),
                f.exprs.len()
            );
        }
        return Ok(0);
    }
    let ir = codegen::emit(&p).map_err(|e| e.to_string())?;
    if mode == "check" || mode == "resolve" {
        println!("{mode} ok: files={}", p.files.len());
        return Ok(0);
    }
    if mode == "debug" {
        println!("{:#?}", p.files);
        println!("{ir}");
    }
    let out = output.unwrap_or(p.output);
    fs::create_dir_all(&out).map_err(|e| e.to_string())?;
    fs::write(out.join("merged.ll"), &ir).map_err(|e| e.to_string())?;
    if inputs.len() == 1 && inputs[0].is_file() {
        let stem = inputs[0].file_stem().ok_or("missing source stem")?;
        fs::write(out.join(stem).with_extension("ll"), &ir).map_err(|e| e.to_string())?;
    }
    println!("Wrote IR to \"{}\"", out.join("merged.ll").display());
    if mode == "build" || mode == "run" {
        let bin = build(&out, &ir, keep, link)?;
        println!("Wrote binary to \"{}\"", bin.display());
        if mode == "run" {
            let bin = fs::canonicalize(bin).map_err(|e| e.to_string())?;
            let s = Command::new(bin)
                .args(run_args)
                .status()
                .map_err(|e| e.to_string())?;
            return Ok(s.code().unwrap_or_else(|| 128 + s.signal().unwrap_or(1)));
        }
    }
    Ok(0)
}
fn main() -> ExitCode {
    match cli() {
        Ok(code) => ExitCode::from(code.clamp(0, 255) as u8),
        Err(e) => {
            eprintln!("{e}");
            ExitCode::FAILURE
        }
    }
}
