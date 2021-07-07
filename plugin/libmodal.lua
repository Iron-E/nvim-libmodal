local g = vim.g

if g.loaded_libmodal then return end
g.loaded_libmodal = true

g.libmodalTimeouts = g.libmodalTimeouts or vim.go.timeout

-- The default highlight groups (for colors) are specified below.
-- Change these default colors by defining or linking the corresponding highlight group.
vim.cmd
[[
	highlight default link LibmodalPrompt ModeMsg
	highlight default link LibmodalStar StatusLine
]]
