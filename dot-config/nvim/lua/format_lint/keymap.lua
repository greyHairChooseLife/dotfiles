local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Json Format
wk_map({
	[","] = {
		order = { "j" },
		["j"] = { Format_json_with_jq, desc = "format to JSON with jq", mode = "v" },
	},
})
