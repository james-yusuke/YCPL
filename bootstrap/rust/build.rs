use std::{env, path::PathBuf, process::Command};
fn main() {
    for key in ["LLVM_CONFIG", "LLVM_BINDIR", "LLVM_DIR", "CXX"] {
        println!("cargo:rerun-if-env-changed={key}");
    }
    let mut candidates = Vec::new();
    if let Ok(p) = env::var("LLVM_CONFIG") {
        candidates.push(PathBuf::from(p));
    } else {
        if let Ok(p) = env::var("LLVM_BINDIR") {
            candidates.push(PathBuf::from(p).join("llvm-config"));
        }
        if let Ok(p) = env::var("LLVM_DIR") {
            candidates.push(PathBuf::from(p).join("../../../bin/llvm-config"));
        }
        candidates.extend(
            [
                "/opt/homebrew/opt/llvm@22/bin/llvm-config",
                "/usr/local/opt/llvm@22/bin/llvm-config",
                "/usr/lib/llvm-22/bin/llvm-config",
                "llvm-config-22",
                "llvm-config",
            ]
            .map(PathBuf::from),
        );
    }
    let config = candidates
        .into_iter()
        .find(|p| {
            Command::new(p)
                .arg("--version")
                .output()
                .is_ok_and(|o| o.status.success())
        })
        .expect("LLVM 22 not found; set LLVM_CONFIG");
    let query = |args: &[&str]| {
        let o = Command::new(&config)
            .args(args)
            .output()
            .expect("llvm-config failed");
        assert!(
            o.status.success(),
            "llvm-config failed: {}",
            String::from_utf8_lossy(&o.stderr)
        );
        String::from_utf8(o.stdout).unwrap().trim().to_owned()
    };
    assert!(
        query(&["--version"]).starts_with("22."),
        "Rust bootstrap requires LLVM 22; set LLVM_CONFIG"
    );
    let mut b = cxx_build::bridge("src/bridge.rs");
    b.file("src/llvm_bridge.cc")
        .include("include")
        .flag("-isystem")
        .flag(query(&["--includedir"]))
        .std("c++20");
    for f in shlex::split(&query(&["--cxxflags"])).expect("invalid llvm-config flags") {
        if !f.starts_with("-std=") && !f.starts_with("-I") && f != "-fno-exceptions" {
            b.flag(&f);
        }
    }
    b.compile("ycpl_rust_llvm_bridge");
    println!("cargo:rustc-link-search=native={}", query(&["--libdir"]));
    println!("cargo:rustc-link-arg=-Wl,-rpath,{}", query(&["--libdir"]));
    for flag in shlex::split(&query(&[
        "--link-shared",
        "--libs",
        "--system-libs",
        "core",
        "native",
        "nativecodegen",
        "support",
    ]))
    .unwrap()
    {
        if let Some(lib) = flag.strip_prefix("-l") {
            println!("cargo:rustc-link-lib={lib}");
        } else if let Some(dir) = flag.strip_prefix("-L") {
            println!("cargo:rustc-link-search=native={dir}");
        } else {
            println!("cargo:rustc-link-arg={flag}");
        }
    }
    for f in [
        "src/bridge.rs",
        "src/llvm_bridge.cc",
        "include/llvm_bridge.h",
    ] {
        println!("cargo:rerun-if-changed={f}");
    }
}
