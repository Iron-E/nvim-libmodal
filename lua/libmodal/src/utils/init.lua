--[[
	/*
	 * MODULE
	 */
--]]

local utils       = {}
utils.api         = require('libmodal/src/utils/api')
utils.DateTime    = require('libmodal/src/utils/DateTime')
utils.Indicator   = require('libmodal/src/utils/Indicator')
utils.strings     = require('libmodal/src/utils/strings')
utils.vars        = require('libmodal/src/utils/vars')
utils.WindowState = require('libmodal/src/utils/WindowState')

--[[
	/*
	 * FUNCTIONS
	 */
--]]

function utils.showError(pcallErr)
	utils.api.nvim_bell()
	utils.api.nvim_show_err( 'vim-libmodal error',
		utils.api.nvim_get_vvar('throwpoint')
		.. '\n' ..
		utils.api.nvim_get_vvar('exception')
		.. '\n' ..
		pcallErr
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return utils
