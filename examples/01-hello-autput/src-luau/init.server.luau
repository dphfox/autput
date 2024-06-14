--!nocheck
-- See src/main.rs for an introduction to this example.

local autput = require(script.Parent.autput)
local example_wasm_loader = require(script.Parent.target_luau.example_wasm)

local wasm_env = { func_list = {} }
local finish_autput_init = autput.init(wasm_env)
local example_wasm_module = example_wasm_loader({env = wasm_env})
finish_autput_init(example_wasm_module)

example_wasm_module.func_list.main()