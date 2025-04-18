local wk_map = require("utils").wk_map

-- MEMO:: All Groups
wk_map({
	["<leader>"] = {
		group = "External",
	},
	["<Space>"] = {
		group = "Internal",
	},
	[","] = {
		group = "on the fly",
	},
})

-- MEMO:: Git
wk_map({ ["<leader>g"] = { group = "󰊢  Git" } })
wk_map({
	-- git log
	["<leader>gl"] = {
		group = "Log",
		order = { "<Space>", "a", "r", "f" },
		["<Space>"] = { "<cmd>GV<CR>", desc = "(default)", mode = "n" },
		["a"] = { "<cmd>GV --all<CR>", desc = "all", mode = "n" },
		["r"] = { "<cmd>GV reflog<CR>", desc = "reflog", mode = "n" },
		["f"] = { "<cmd>GV!<CR>", desc = "current File", mode = "n" },
	},
})
wk_map({
	-- git review
	["<leader>gr"] = {
		group = "Review",
		order = { "w", "s", "<Space>", "f", "a", "F" },
		["w"] = { "<cmd>DiffviewOpen<CR>", desc = "working on", mode = { "n" } },
		["s"] = { "<cmd>DiffviewOpen --staged<CR>", desc = "staged", mode = { "n" } },
		["<Space>"] = {
			function()
				local mode = vim.fn.mode()
				if mode == "n" then
					vim.cmd("DiffviewFileHistory")
				else
					DiffviewOpenWithVisualHash()
				end
			end,
			desc = "normal or visual-selected",
			mode = { "n", "v" },
		},
		["f"] = { "<cmd>DiffviewFileHistory %<CR>", desc = "file", mode = { "n" } },
		["a"] = { "<cmd>DiffviewFileHistory --all<CR>", desc = "all", mode = { "n" } },
		["F"] = { "<cmd>DiffviewFileHistory --reverse --range=HEAD...FETCH_HEAD<CR>", desc = "fetched", mode = { "n" } },
		["r"] = {
			function()
				vim.fn.feedkeys(":DiffviewFileHistory --range=", "n")
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "c", false)
			end,
			desc = "range select",
			mode = { "n" },
		},
	},
})

-- MEMO:: Session
wk_map({
	["<leader>s"] = {
		group = "󱫥  Session",
		order = { "s", "l" },
		["s"] = { "<cmd>SessionSave<CR>", desc = "save", mode = "n" },
		["v"] = { "<cmd>SessionSearch<CR>", desc = "view", mode = "n" },
	},
})

-- MEMO:: Run Command
wk_map({
	["<leader>r"] = {
		group = "  Run Command",
		order = { "r", "R", "u" },
		["u"] = {
			function()
				RunBufferWithSh({ selected = true, underline = true })
			end,
			desc = "underline",
			mode = "v",
		},
		["r"] = {
			function()
				local mode = vim.api.nvim_get_mode().mode
				if mode == "n" then
					RunBufferWithSh()
				else
					RunBufferWithSh({ selected = true })
				end
			end,
			desc = "run on buffer",
			mode = { "n", "v" },
		},
		["R"] = {
			function()
				local mode = vim.api.nvim_get_mode().mode
				if mode == "n" then
					RunBufferWithSh({ cover = true })
				else
					RunBufferWithSh({ selected = true, cover = true })
				end
			end,
			desc = "run on buffer and cover ",
			mode = { "n", "v" },
		},
	},
})

-- DEPRECATED:: 2025-04-11
-- MEMO:: Avante.nvim
-- wk_map({
-- 	["<leader>a"] = {
-- 		group = "Avante",
-- 		order = { "a", "c", "f", "t" },
-- 		["a"] = { "<cmd>AvanteAsk<CR>", desc = "ask", mode = { "n", "v" } },
-- 		["c"] = { "", desc = "current buffer(file) into/outof ctx", mode = { "n" } },
-- 		["t"] = {
-- 			function()
-- 				require("utils").save_cursor_position()
-- 				vim.cmd("AvanteToggle")
-- 				require("utils").restore_cursor_position()
-- 			end,
-- 			desc = "toggle",
-- 			mode = { "n", "v" },
-- 		},
-- 		["f"] = { "<cmd>AvanteFocus<CR>", desc = "focus", mode = { "n", "v" } },
-- 	},
-- })
-- local apf = require("workflows.AI.avante_prefill_function")
-- wk_map({
-- 	["<leader>ae"] = {
-- 		group = "Prefill",
-- 		order = { "1", "2", "3", "4", "5", "6", "7" },
-- 		["1"] = { apf.prefill_4, desc = "코드 설명", mode = { "n", "v" } },
-- 		["2"] = { apf.prefill_1, desc = "코드 리뷰", mode = { "n", "v" } },
-- 		["3"] = { apf.prefill_6, desc = "버그 해결", mode = { "n", "v" } },
-- 		["4"] = { apf.prefill_3, desc = "diagnostics 설명", mode = { "n", "v" } },
-- 		["5"] = { apf.prefill_2, desc = "코드 최적화", mode = { "n", "v" } },
-- 		["6"] = { apf.prefill_5, desc = "docstring 추가", mode = { "n", "v" } },
-- 		["7"] = { apf.prefill_7, desc = "테스트 작성", mode = { "n", "v" } },
-- 	},
-- })

-- MEMO:: Directory
wk_map({
	["<Space>d"] = {
		group = "Directory  - NvimTree",
		order = { "f", "t" },
		["f"] = { "<cmd>NvimTreeFocus<CR>", desc = "focus", mode = "n" },
		["t"] = { ToggleTree, desc = "toggle ", mode = "n" },
	},
})

-- MEMO:: (Syntax) Tree
wk_map({
	["<Space>t"] = {
		group = "Tree       - Aerial",
		order = { "f", "t" },
		["f"] = {
			function()
				vim.cmd("norm ^ww")
				vim.cmd("AerialOpen")
			end,
			desc = "focus",
			mode = "n",
		},
		["t"] = {
			function()
				vim.cmd("AerialToggle")
				vim.cmd("wincmd p")
			end,
			desc = "toggle ",
			mode = "n",
		},
	},
})

-- MEMO:: Global-Note
wk_map({
	["<Space>n"] = {
		group = "Note",
		order = { "g", "l" },
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
	},
})

-- MEMO:: UI
wk_map({
	["<Space>u"] = {
		group = "UI",
		order = { "i", "d" },
		["i"] = { "<cmd>IBLToggle<CR>", desc = "IBL-toggle", mode = "n" },
		["d"] = {
			function()
				vim.cmd("Gitsigns toggle_word_diff")
				vim.cmd("Gitsigns toggle_linehl")
			end,
			desc = "diff preview",
			mode = "n",
		},
		["v"] = { ToggleVirtualText, desc = "virtual text toggle", mode = { "n" } },
		["r"] = { "<cmd>RenderMarkdown buf_toggle<CR>", desc = "  rendering toggle", mode = { "n" } },
	},
})

-- MEMO:: QuickFix
wk_map({
	["<Space>q"] = {
		group = "Quick Fix",
		order = { "f", "t", "n", "p" },
		["f"] = { "<cmd>copen<CR>", desc = "focus", mode = "n" },
		["t"] = { QF_ToggleList, desc = "toggle", mode = "n" },
		["n"] = { QF_next, desc = "next", mode = "n" },
		["p"] = { QF_prev, desc = "prev", mode = "n" },
	},
})
vim.keymap.set("n", "qn", QF_next)
vim.keymap.set("n", "qp", QF_prev)

-- MEMO:: Telescope
local builtin = require("telescope.builtin")
wk_map({
	[",."] = {
		group = "Telescope",
		order = { "R", "H", "N", "T" },
		["R"] = { builtin.resume, desc = "resume", mode = "n" },
		["H"] = { builtin.help_tags, desc = "help doc", mode = "n" },
		["N"] = { "<cmd>Noice telescope<CR>", desc = "noice Log", mode = "n" },
		["T"] = { "<cmd>TodoTelescope<CR>", desc = "todo Tags", mode = "n" },
	},
})
wk_map({
	[",.."] = {
		group = "expand",
		["T"] = {
			function()
				local dir_path = vim.fn.expand("%:p:h") -- 상대경로
				local file_path = vim.fn.expand("%:t") -- 파일명
				vim.cmd(string.format("TodoTelescope cwd=%s default_text=%s", dir_path, file_path))
				vim.cmd("normal! a ")
			end,
			desc = "todo Tags current",
			mode = "n",
		},
	},
})

-- MEMO:: On The Fly
wk_map({
	[","] = {
		order = { "r", "R", "C" },
		["r"] = { ReloadLayout, desc = "reload layout", mode = "n" },
		["R"] = {
			function()
				ReloadLayout(true)
			end,
			desc = "reload layout force",
			mode = "n",
		},
		["C"] = {
			function()
				local word = vim.fn.expand("<cword>")
				vim.api.nvim_feedkeys(":%s/" .. word .. "//g", "n", false)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true), "n", false)
			end,
			desc = "change",
			mode = "n",
		},
	},
})
