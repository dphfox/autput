--!strict
--Licensed under BSD3 from Autput, (c) Daniel P H Fox 2025

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS ------------------------------------------------------------
--------------------------------------------------------------------------------

-- Type aliases for convenience and documentation
type ptr_const_u8 = number
type u32 = number
type u8 = number

-- Passed to Wasynth when initialising a WebAssembly module.
-- Autput injects some of its own members into this environment, but otherwise
-- does not care about the rest of the contents.
type WasmEnvironment = {
	func_list: {
		[string]: (...any) -> (...any)
	}
}

-- Returned by Wasynth when initialising a WebAssembly module.
-- Autput expects certain members to be present.
type WasmModule = {
	rt: {
		load: {
			string: (
				memory: WasmMemory, 
				ptr: ptr_const_u8, 
				len: u32
			) -> string
		}
	},
	memory_list: {
		memory: WasmMemory
	}
}

-- An entry in the `memory_list` dictionary returned by Wasynth.
-- Autput doesn't care about its specific type - it's treated opaquely.
type WasmMemory = unknown

-- The internal state used by Autput's Luau-side API.
-- This is not shared between WASM modules.
type ApiState = {
	-- This module provides the low level FFI that the API functions use.
	module: WasmModule,
	log_fn: LogFn
}

-- The public API surface exposed by Autput after initialisation.
-- The API state is expected to be encapsulated as upvalues in closures.
export type Api = {
	-- Change where Rust logs are sent to, returning the old handler. This does
	-- not affect panic handling.
	replace_log_fn: (
		new_log_fn: LogFn
	) -> LogFn,
}


export type LogLevel = "error" | "warn" | "info" | "debug" | "trace"
export type LogFn = (
	log_level: LogLevel,
	message: string
) -> ()

--------------------------------------------------------------------------------
-- CONSTANTS -------------------------------------------------------------------
--------------------------------------------------------------------------------

local LOG_LEVELS: {LogLevel} = {
	"error",
	"warn",
	"info",
	"debug",
	"trace"
}

local STD_LOG: LogFn =
	if typeof(warn) == "function" then
		function(log_level, message)
			if log_level == "error" or log_level == "warn" then
				warn(message)
			else
				print(message)
			end
		end
	else
		function(_, message)
			print(message)
		end

--------------------------------------------------------------------------------
-- FOREIGN FUNCTION INTERFACE --------------------------------------------------
--------------------------------------------------------------------------------

local extern_fn = {}

function extern_fn.log(
	api_state: ApiState,
	level_ord: u8,
	ptr: ptr_const_u8,
	len: u32
): ()
	local message = api_state.module.rt.load.string(
		api_state.module.memory_list.memory, 
		ptr, 
		len
	)
	local log_level = LOG_LEVELS[level_ord] or error(
		`[autput] unknown log level{level_ord} for: {message}`, 0
	)
	api_state.log_fn(log_level :: LogLevel, message)
end

function extern_fn.panic(
	api_state: ApiState,
	ptr: ptr_const_u8,
	len: u32
): ()
	local message = api_state.module.rt.load.string(
		api_state.module.memory_list.memory, 
		ptr, 
		len
	)
	error(message, 0)
end

--------------------------------------------------------------------------------
-- LUAU SIDE API ---------------------------------------------------------------
--------------------------------------------------------------------------------

local api_fn = {}

-- See the `Api` type for user-facing documentation.
function api_fn.replace_log_fn(
	api_state: ApiState,
	new_log_fn: LogFn
): LogFn
	local old_log_fn = api_state.log_fn
	api_state.log_fn = new_log_fn
	return old_log_fn
end

--------------------------------------------------------------------------------
-- INITIALISATION --------------------------------------------------------------
--------------------------------------------------------------------------------

local autput = {}

-- Autput needs to register its own extern functions into the WASM environment, 
-- and it needs to obtain a reference to the WASM module so that it can invoke 
-- functions that exist in the WASM runtime. Once both have been received, you 
-- will receive an `Api` that you can use with the provided module.
function autput.init(
	env: WasmEnvironment
)
	local api_state: ApiState? = nil
	for fn_name, fn in pairs(extern_fn) do
		env.func_list["autput_"..fn_name] = function(...)
			if api_state == nil then
				print("[autput] api not initialised yet on luau side - cannot handle incoming data")
				return
			end
			return fn(api_state, ...)
		end
	end
	return function(
		module: WasmModule
	): Api
		assert(api_state == nil, "[autput] only one module allowed per environment")
		api_state = {
			module = module,
			log_fn = STD_LOG
		}
		local api = {}
		for fn_name, fn in pairs(api_fn) do
			api[fn_name] = function(...)
				return fn(api_state, ...)
			end
		end
		return api :: any
	end
end

return autput
