local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Global-Note
wk_map({
	["<Space>n"] = {
		group = "Note",
		order = { "g", "l", "t" },
		["g"] = {
			function()
				local gn = require("global-note")
				gn.close_all_notes()
				gn.toggle_note() -- default_note aka. global
			end,
			desc = "open Local Note",
			mode = { "n", "v" },
		},
		["l"] = {
			function()
				local gn = require("global-note")
				gn.close_all_notes()
				gn.toggle_note("project_local")
			end,
			desc = "open Local Note",
			mode = { "n", "v" },
		},
		["t"] = {
			function()
				local gn = require("global-note")
				gn.close_all_notes()
				gn.toggle_note("project_local_todo")
			end,
			desc = "open Local Todo",
			mode = { "n", "v" },
		},
	},
})
