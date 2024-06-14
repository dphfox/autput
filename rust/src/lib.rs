use std::{panic, cell::RefCell};

use log::{Level, LevelFilter, Log, SetLoggerError};

pub const LOG_LEVEL_FILTER: LevelFilter = log::STATIC_MAX_LEVEL;

extern "C" {
	fn autput_log(
		level: u8,
		ptr: *const u8,
		len: u32
	);

	fn autput_panic(
		ptr: *const u8,
		len: u32
	);
}

fn set_panic_hook() {
	panic::set_hook(
		Box::new(|panic| {
			let message = format!("{panic:?}");
			unsafe {
				autput_panic(
					message.as_ptr(),
					message.len() as u32
				);
			}
		})
	)
}

pub fn connect_with(
	logger: Autput
) {
	self::set_panic_hook();
	logger.connect().expect("Error while connecting Autput logger (don't call connect() more than once - have you tried connect_once() instead?)");
}

pub fn connect_once_with<T: FnOnce() -> Autput>(
	make_logger: T
) {
	thread_local! {
		static CONNECTED: RefCell<bool> = RefCell::new(false);
	}
	CONNECTED.with_borrow_mut(|is_connected| {
		if *is_connected {
			return;
		}
		connect_with(make_logger());
		*is_connected = true;
	})
}

pub fn connect() {
	connect_with(Autput::default())
}

pub fn connect_once() {
	connect_once_with(Autput::default)
}

pub struct Autput {
	pub max_level: LevelFilter
}

impl Autput {
	fn connect(self) -> Result<(), SetLoggerError> {
		log::set_max_level(self.max_level);
		log::set_boxed_logger(Box::new(self))
	}
}

impl Default for Autput {
	fn default() -> Self {
		Self {
			max_level: LevelFilter::Info
		}
	}
}

impl Log for Autput {
	fn enabled(&self, metadata: &log::Metadata) -> bool {
		metadata.level() <= self.max_level
	}

	fn log(&self, record: &log::Record) {
		if !self.enabled(record.metadata()) {
			return;
		}
		let level_string = format!("{:<5}", record.level().to_string());
		let target = if !record.target().is_empty() {
			record.target()
		} else {
			record.module_path().unwrap_or_default()
		};
		let message = format!("{} [{}] {}", level_string, target, record.args());
		unsafe {
			autput_log(
				record.level() as u8,
				message.as_ptr(),
				message.len() as u32
			);
		}
	}

	fn flush(&self) {}
}