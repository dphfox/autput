#[cfg(not(target_arch = "wasm32"))]
compile_error!("This project must target WebAssembly to compile correctly.");

use log::{debug, error, info, trace, warn};

fn main() {
	autput::connect();
	trace!("This is a trace message.");
	debug!("This is a debug message.");
	info!("This is an info message.");
	warn!("This is a warning message.");
	error!("This is an error message.");
	panic!("This is a panic.");
}
