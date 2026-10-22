//! Regression tests for the Rust frontend and the checked LLVM boundary.
use crate::{ast::Ty, codegen, lexer, llvm::Llvm, parser, project::Project};
use std::{fs, os::unix::fs::symlink, path::Path, process::Command};

fn project(source: &str) -> (tempfile::TempDir, Project) {
    let dir = tempfile::tempdir().unwrap();
    let path = dir.path().join("input.yc");
    fs::write(&path, source).unwrap();
    let p = Project::load(&[path], crate::asset("stl").unwrap()).unwrap();
    (dir, p)
}

#[test]
fn llvm_rejects_foreign_stale_and_wrong_kind_handles() {
    let first = Llvm::new().unwrap();
    let second = Llvm::new().unwrap();
    let t = first.typ(1, 32, &[], "").unwrap();
    assert!(second.constant(0, t, 1, 0.0, "").is_err());
    let v = first.constant(0, t, 1, 0.0, "").unwrap();
    assert!(
        first
            .session
            .borrow_mut()
            .pin_mut()
            .constant(0, v.0, 0, 0.0, "")
            .is_err()
    );
    drop(first);
    assert!(second.size(t).is_err());
    assert!(second.ir().is_ok());
}

#[test]
fn llvm_checks_function_and_aggregate_boundaries() {
    let l = Llvm::new().unwrap();
    let int = l.typ(1, 32, &[], "").unwrap();
    let ft = l.typ(7, 0, &[int], "").unwrap();
    let a = l.func("a", ft).unwrap();
    let b = l.func("b", ft).unwrap();
    let entry = l.block(a, "entry").unwrap();
    let foreign = l.block(b, "entry").unwrap();
    l.position(entry).unwrap();
    assert!(l.op("br", None, &[foreign.0], "", 0).is_err());
    let st = l.typ(5, 0, &[], "Pair").unwrap();
    l.body(st, &[int, int]).unwrap();
    let zero = l.constant(2, st, 0, 0.0, "").unwrap();
    assert!(l.op("extract", None, &[zero.0], "", 2).is_err());
    // Incomplete functions must never be serialized as usable LLVM IR.
    assert!(l.ir().unwrap_err().contains("verification failed"));
}

#[test]
fn llvm_layout_matches_native_aggregate_alignment() {
    let l = Llvm::new().unwrap();
    let i32 = l.typ(1, 32, &[], "").unwrap();
    let i64 = l.typ(1, 64, &[], "").unwrap();
    let pair = l.typ(5, 0, &[], "AlignedPair").unwrap();
    l.body(pair, &[i32, i64]).unwrap();
    assert_eq!(l.size(pair).unwrap(), 16);
    assert!(l.ir().unwrap().contains("target datalayout ="));
}

#[test]
fn lexer_preserves_locations_and_scientific_numbers() {
    let tokens = lexer::lex(
        Path::new("input.yc"),
        "// comment\n1e3 0xff 2.5e-2 \"日本語\"",
    )
    .unwrap();
    assert_eq!((tokens[1].span.line, tokens[1].span.col), (2, 1));
    assert_eq!(tokens[1].kind, 2);
    assert_eq!(tokens[2].text, "0xff");
    assert_eq!(tokens[3].kind, 2);
    assert_eq!(lexer::decode(&tokens[4].text, false), "日本語");
    let err = lexer::lex(Path::new("input.yc"), "\n  1e+").unwrap_err();
    assert_eq!((err.span.line, err.span.col), (2, 3));
}

#[test]
fn malformed_source_has_a_location_and_does_not_panic() {
    for source in [
        "fn main() { println(1, }",
        "fn f(\n",
        "struct S {",
        "fn main() { x := 'ab' }",
    ] {
        let err = parser::parse(Path::new("broken.yc"), source).unwrap_err();
        assert!(err.span.line > 0 && err.span.col > 0);
        assert!(err.to_string().starts_with("broken.yc:"));
    }
    for source in [
        "fn main() { len() }",
        "fn main() { v := Vec<i32>{} v.reserve() }",
    ] {
        let (_dir, p) = project(source);
        assert!(codegen::emit(&p).unwrap_err().message.contains("argument"));
    }
}

#[test]
fn aliases_are_dynamic_and_cycles_are_reported() {
    let mut source = String::from("type T0 = i32\n");
    for i in 1..256 {
        source.push_str(&format!("type T{i} = T{}\n", i - 1));
    }
    source.push_str("fn main() { x: T255 := 42 println(x) }");
    let (_dir, p) = project(&source);
    assert!(codegen::emit(&p).is_ok());
    let (_dir, p) = project("type A = B\ntype B = A\nfn main() { x: A := 1 }");
    assert!(
        codegen::emit(&p)
            .unwrap_err()
            .message
            .contains("cyclic type alias")
    );
    assert_eq!(Ty::named("i64"), Ty::I64);
    let (_dir, p) = project("struct Empty {}\nfn main() { value := Empty{} }");
    assert!(codegen::emit(&p).is_ok());
    for source in [
        "struct S { value S }\nfn main() {}",
        "fn main() {}\nfn main() {}",
    ] {
        let (_dir, p) = project(source);
        assert!(codegen::emit(&p).is_err());
    }
}

#[test]
fn project_scan_is_deterministic_and_stops_symlink_cycles() {
    let dir = tempfile::tempdir().unwrap();
    fs::write(dir.path().join("z.yc"), "fn z() {} ").unwrap();
    fs::write(dir.path().join("a.yc"), "fn main() {} ").unwrap();
    symlink(dir.path(), dir.path().join("cycle")).unwrap();
    let stl = crate::asset("stl").unwrap();
    let p = Project::load(&[dir.path().into()], stl.clone()).unwrap();
    let q = Project::load(&[dir.path().into()], stl).unwrap();
    assert_eq!(p.files.len(), 2);
    assert!(p.files[0].path.ends_with("a.yc"));
    assert_eq!(codegen::emit(&p).unwrap(), codegen::emit(&q).unwrap());
}

#[test]
fn imports_enforce_type_visibility() {
    let dir = tempfile::tempdir().unwrap();
    fs::write(
        dir.path().join("hidden.yc"),
        "module hidden\nstruct Secret { value i32 }\npub struct Visible { value i32 }",
    )
    .unwrap();
    let input = dir.path().join("input.yc");
    fs::write(
        &input,
        "import \"hidden\" as h\nfn main() { s: Secret := none }",
    )
    .unwrap();
    let p = Project::load(std::slice::from_ref(&input), crate::asset("stl").unwrap()).unwrap();
    assert!(
        codegen::emit(&p)
            .unwrap_err()
            .message
            .contains("unknown type: Secret")
    );
    fs::write(
        &input,
        "import \"hidden\" as h\nfn main() { s: h.Visible := Visible{value: 1} println(s.value) }",
    )
    .unwrap();
    let p = Project::load(&[input], crate::asset("stl").unwrap()).unwrap();
    assert!(codegen::emit(&p).is_ok());
}

#[test]
fn native_ownership_variadic_abi_and_paths_with_spaces() {
    let (dir, p) = project(
        r#"
import "std/text" as text
struct Row { value string }
struct AlignedPair { small i32 wide i64 }
extern fn c_printf(format string, args... any) i32 as "printf"
fn make_rows() Vec<Row> {
    rows := Vec<Row>{capacity: 1}
    rows.push(Row{value: text.concat("old", " value")})
    first := &rows[0]
    first.value = text.concat("new", " value")
    rows.push(Row{value: "second"})
    return rows
}
fn source() string {
    println("once")
    return "new"
}
fn main() {
    pairs := Vec<AlignedPair>{capacity: 1}
    pairs.push(AlignedPair{small: 1, wide: 10000000000})
    pairs.push(AlignedPair{small: 2, wide: 20000000000})
    println(sizeof(AlignedPair), pairs[0].wide, pairs[1].wide)
    allocated := new(AlignedPair)
    allocated.small = 3
    allocated.wide = 30000000000
    println(allocated.small, allocated.wide)
    rows := make_rows()
    i := 0
    println(rows[i++].value)
    println(i)
    narrow: byte := 7
    f: float := 1.5
    c_printf("%d %d %.1f\n", true, narrow, f)
    println(source().concat(" value"))
}
"#,
    );
    let ir = codegen::emit(&p).unwrap();
    let out = dir.path().join("directory with spaces $(literal)");
    fs::create_dir(&out).unwrap();
    fs::write(out.join("merged.ll"), &ir).unwrap();
    let bin = crate::build(&out, &ir, true, false).unwrap();
    let result = Command::new(bin).output().unwrap();
    assert!(result.status.success(), "{:?}", result);
    assert_eq!(
        String::from_utf8(result.stdout).unwrap(),
        "16 10000000000 20000000000\n3 30000000000\nnew value\n1\n1 7 1.5\nonce\nnew value\n"
    );
}
