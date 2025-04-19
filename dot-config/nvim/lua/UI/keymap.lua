local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Window Size
local window_size = require("UI.modules.window_size")
wk_map({
	[",w"] = {
		group = "Window Size",
		order = { "f", "A", "U" },
		["f"] = {
			function()
				window_size.toggleWinFix()
			end,
			desc = "fix (toggle)",
			mode = "n",
		},
		["A"] = {
			function()
				window_size.toggleAllWinFix()
			end,
			desc = "fix all",
			mode = "n",
		},
		["U"] = {
			function()
				window_size.unfixAllWindows()
			end,
			desc = "unfix all",
			mode = "n",
		},
	},
})

-- MEMO:: Etc
wk_map({
	["<Space>u"] = {
		group = "UI",
		order = { "i", "d" },
		["i"] = { "<cmd>IBLToggle<CR>", desc = "IBL-toggle", mode = "n" },
		["v"] = { ToggleVirtualText, desc = "virtual text toggle", mode = { "n" } },
		["r"] = { "<cmd>RenderMarkdown buf_toggle<CR>", desc = "  rendering toggle", mode = { "n" } },
	},
})
