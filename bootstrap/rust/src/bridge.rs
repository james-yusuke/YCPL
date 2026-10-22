//! The only Rust/C++ boundary. All language decisions belong to Rust.
#[cxx::bridge(namespace = "ycpl::rust_seed")]
pub mod ffi {
    unsafe extern "C++" {
        include!("llvm_bridge.h");
        type Session;
        fn new_session(name: &str) -> UniquePtr<Session>;
        fn type_create(
            self: Pin<&mut Session>,
            kind: u8,
            n: u64,
            args: &[u64],
            name: &str,
        ) -> Result<u64>;
        fn type_body(self: Pin<&mut Session>, typ: u64, fields: &[u64]) -> Result<()>;
        fn type_size(self: &Session, typ: u64) -> Result<u64>;
        fn constant(
            self: Pin<&mut Session>,
            kind: u8,
            typ: u64,
            bits: u64,
            real: f64,
            text: &str,
        ) -> Result<u64>;
        fn function(self: Pin<&mut Session>, name: &str, typ: u64) -> Result<u64>;
        fn parameter(self: Pin<&mut Session>, function: u64, index: u32) -> Result<u64>;
        fn block(self: Pin<&mut Session>, function: u64, name: &str) -> Result<u64>;
        fn position(self: Pin<&mut Session>, block: u64) -> Result<()>;
        fn terminated(self: &Session) -> bool;
        fn instruction(
            self: Pin<&mut Session>,
            op: &str,
            typ: u64,
            args: &[u64],
            name: &str,
            aux: u64,
        ) -> Result<u64>;
        fn ir(self: &Session) -> Result<String>;
    }
}
