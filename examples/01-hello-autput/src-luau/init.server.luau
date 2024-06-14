--!nocheck
-- See src/main.rs for an introduction to this example.

local example_wasm_loader = require(script.Parent.target_luau.example_wasm)

local extern_fns = {}

local wasm_env = { func_list = extern_fns }
local example_wasm_module = example_wasm_loader({env = wasm_env})

example_wasm_module.func_list.main()