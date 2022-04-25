if vim.g.loaded_libmodal then return end
vim.g.loaded_libmodal = true

vim.g.libmodalTimeouts = vim.g.libmodalTimeouts or vim.go.timeout

-- The default highlight groups (for colors) are specified below.
-- Change these default colors by defining or linking the corresponding highlight group.
vim.api.nvim_set_hl(0, 'LibmodalPrompt', {default = true, link = 'ModeMsg'})
vim.api.nvim_set_hl(0, 'LibmodalStar', {default = true, link = 'StatusLine'})
