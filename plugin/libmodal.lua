local exe = vim.api.nvim_command
local g = vim.g
local go = vim.go

if g.loaded_libmodal then return end
g.loaded_libmodal = true

if g.libmodalTimeouts == nil then
	g.libmodalTimeouts = go.timeout
end

--[[/* User Configuration */]]

-- The default highlight groups (for colors) are specified below.
-- Change these default colors by defining or linking the corresponding highlight group.
exe
[[
	highlight default link LibmodalPrompt ModeMsg
	highlight default link LibmodalStar StatusLine
]]
