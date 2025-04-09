local M = require("lualine.component"):extend()

M.processing = false
M.spinner_index = 1

local spinner_symbols = {
	"=                       ",
	"==                      ",
	" ==                     ",
	"  ==                    ",
	"   ==                   ",
	"    ==                  ",
	"     ==                 ",
	"      ==                ",
	"       ==               ",
	"        ==              ",
	"         ==             ",
	"          ==            ",
	"           ==           ",
	"            ==          ",
	"             ==         ",
	"              ==        ",
	"               ==       ",
	"                ==      ",
	"                 ==     ",
	"                  ==    ",
	"                   ==   ",
	"                    ==  ",
	"                     == ",
	"                      ==",
	"                       =",
}

local spinner_symbols_len = #spinner_symbols

-- Initializer
function M:init(options)
	M.super.init(self, options)

	local group = vim.api.nvim_create_augroup("CodeCompanionHooks_spinner_active", { clear = true })

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = { "CodeCompanionRequestStarted", "CodeCompanionRequestFinished" },
		group = group,
		callback = function(args)
			if args.match == "CodeCompanionRequestStarted" then
				self.processing = true
			elseif args.match == "CodeCompanionRequestFinished" then
				self.processing = false
			end
		end,
	})
end

function M:update_status()
	if self.processing then
		self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
		return spinner_symbols[self.spinner_index]
	else
		return "          - R.E.A.D.Y - " -- Return a placeholder when not processing
	end
end

return M
