--[[
	This file demonstrates how `Var`s work in Modes and Prompts.
]]

--- WARN: do not import this in your code! it is not part of the public API.
local Vars = require 'libmodal.utils.Vars'

--- Check the value of the local var
--- @param var any
--- @param val unknown the value to check is equal to
local function assert_local_eq(var, val)
	assert(var:get_local() == val, 'assertion: the global value equals ' .. vim.inspect(val))
end

--- Check the value of the global var
--- @param var any
--- @param val unknown the value to check is equal to
local function assert_global_eq(var, val)
	assert(var:get_global() == val, 'assertion: the global value equals ' .. vim.inspect(val))
end

--- Check the value of the scoped var
--- @param var any
--- @param val unknown the value to check is equal to
--- @param scope 'global'|'local'
local function assert_eq(var, val, scope)
	assert(var:get() == val, 'assertion: the value equals ' .. vim.inspect(val))
	local fn = scope == 'local' and  assert_local_eq  or assert_global_eq
	fn(var, val)
end

--- check the value of all vars
--- @param var any
--- @param val unknown the value to check is equal to
local function assert_all_eq(var, val)
	assert_eq(var, val, 'local')
	assert_global_eq(var, val)
end

local mode_name = 'Foo'
local var_name = 'Bar'

--- WARN: do not use this function in your code! It is not part of the public API.
local foo = Vars.new(mode_name, var_name)

-- 1. baseline

assert_all_eq(foo, nil)

-- 2. without local value, `:get` and `:set` use globals

local global_value = true

foo:set(global_value)

assert_eq(foo, global_value, 'global')
assert_local_eq(foo, nil)

-- 3. set local value

foo:set_local(global_value)

assert_all_eq(foo, global_value)

-- 4. with local value, `:get` and `:set` use locals

local local_value = false

foo:set(local_value)

assert_eq(foo, local_value, 'local')
assert_global_eq(foo, global_value)

-- Finally, unset all so the test can be run again

foo:set_global(nil)
foo:set_local(nil)

assert_all_eq(foo, nil)
