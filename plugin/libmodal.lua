if vim.g.loaded_libmodal then return end
vim.g.loaded_libmodal = true

vim.g.libmodalTimeouts = vim.g.libmodalTimeouts or vim.go.timeout

-- The default highlight groups (for colors) are specified below.
-- Change these default colors by defining or linking the corresponding highlight group.
vim.cmd
[[
	highlight default link LibmodalPrompt ModeMsg
	highlight default link LibmodalStar StatusLine
]]
