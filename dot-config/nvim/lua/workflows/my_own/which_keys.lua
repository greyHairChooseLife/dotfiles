local wk_map = require("utils").wk_map

-- MEMO:: All Groups
wk_map({
	["<leader>"] = {
		group = "External",
	},
	["<leader>g"] = {
		group = "Git",
		["g"] = { "<cmd>G<CR>", desc = "fugitive", mode = "n" },
	},
	["<Space>"] = {
		group = "Internal",
	},
	[","] = {
		group = "on the fly",
	},
	[",c"] = {
		group = "command",
	},
})

-- MEMO:: Log (Git)
wk_map({
	["<leader>gl"] = {
		group = "Log",
		order = { "<Space>", "a", "r", "f" },
		["<Space>"] = { "<cmd>GV<CR>", desc = "(default)", mode = "n" },
		["a"] = { "<cmd>GV --all<CR>", desc = "all", mode = "n" },
		["r"] = { "<cmd>GV reflog<CR>", desc = "reflog", mode = "n" },
		["f"] = { "<cmd>GV!<CR>", desc = "current File", mode = "n" },
	},
})

-- MEMO:: Review (Git)
wk_map({
	["<leader>gr"] = {
		group = "Review",
		order = { "w", "s", "<Space>", "f", "a", "F" },
		["w"] = { "<cmd>DiffviewOpen<CR>", desc = "working on", mode = { "n" } },
		["s"] = { "<cmd>DiffviewOpen --staged<CR>", desc = "staged", mode = { "n" } },
		["<Space>"] = { "<cmd>DiffviewFileHistory<CR>", desc = "(default)", mode = { "n" } },
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
wk_map({
	["<leader>gr"] = {
		group = "Review",
		order = { "<Space>" },
		["<Space>"] = { DiffviewOpenWithVisualHash, desc = "(default)", mode = { "v" } },
	},
})

-- MEMO:: Session
wk_map({
	["<leader>s"] = {
		group = "Session",
		order = { "s", "l" },
		["s"] = { "<cmd>SessionSave<CR>", desc = "save", mode = "n" },
		["v"] = { "<cmd>SessionSearch<CR>", desc = "view", mode = "n" },
	},
})

-- MEMO:: Avante.nvim
wk_map({
	["<leader>a"] = {
		group = "Avante",
		order = { "a", "c", "f", "t" },
		["a"] = { "<cmd>AvanteAsk<CR>", desc = "ask", mode = { "n", "v" } },
		["c"] = { "", desc = "current buffer(file) into/outof ctx", mode = { "n" } },
		["t"] = {
			function()
				require("utils").save_cursor_position()
				vim.cmd("AvanteToggle")
				require("utils").restore_cursor_position()
			end,
			desc = "toggle",
			mode = { "n", "v" },
		},
		["f"] = { "<cmd>AvanteFocus<CR>", desc = "focus", mode = { "n", "v" } },
	},
})
local apf = require("workflows.AI.avante_prefill_function")
wk_map({
	["<leader>ae"] = {
		group = "Prefill",
		order = { "1", "2", "3", "4", "5", "6", "7" },
		["1"] = { apf.prefill_4, desc = "코드 설명", mode = { "n", "v" } },
		["2"] = { apf.prefill_1, desc = "코드 리뷰", mode = { "n", "v" } },
		["3"] = { apf.prefill_6, desc = "버그 해결", mode = { "n", "v" } },
		["4"] = { apf.prefill_3, desc = "diagnostics 설명", mode = { "n", "v" } },
		["5"] = { apf.prefill_2, desc = "코드 최적화", mode = { "n", "v" } },
		["6"] = { apf.prefill_5, desc = "docstring 추가", mode = { "n", "v" } },
		["7"] = { apf.prefill_7, desc = "테스트 작성", mode = { "n", "v" } },
	},
})

-- MEMO:: Copilot
wk_map({
	["<leader>c"] = {
		group = "Copilot",
		order = { "f", "t", "C", "p" },
		["f"] = { ChatWithCopilotOpen_Buffer, desc = "focus buffer", mode = { "n" } },
		["t"] = { Toggle_ChatWithCopilot, desc = "toggle", mode = { "n" } },
		["C"] = { "<cmd>CopilotChatCommit<CR>", desc = "write commitm msg", mode = { "n" } },
		["p"] = { "<cmd>CopilotChatPrompts<CR>", desc = "prompts", mode = { "n" } },
	},
})
wk_map({
	["<leader>c"] = {
		group = "Copilot..",
		order = { "f" },
		["f"] = { ChatWithCopilotOpen_Visual, desc = "focus visual", mode = { "v" } },
	},
})
wk_map({
	["<leader>ce"] = {
		group = "Prefill",
		order = { "1", "2", "3", "4", "5", "6", "7" },
		["1"] = { "<cmd>CopilotChatExplain<CR>", desc = "코드 설명", mode = { "n", "v" } },
		["2"] = { "<cmd>CopilotChatReview<CR>", desc = "코드 리뷰", mode = { "n", "v" } },
		["3"] = { "<cmd>CopilotChatFix<CR>", desc = "버그 해결", mode = { "n", "v" } },
		["4"] = { "<cmd>CopilotChatBetterNamings<CR>", desc = "변수명 개선", mode = { "n", "v" } },
		["5"] = { "<cmd>CopilotChatOptimize<CR>", desc = "코드 최적화", mode = { "n", "v" } },
		["6"] = { "<cmd>CopilotChatDocs<CR>", desc = "docstring 추가", mode = { "n", "v" } },
		["7"] = { "<cmd>CopilotChatTests<CR>", desc = "테스트 작성", mode = { "n", "v" } },
	},
})

-- MEMO:: Directory
wk_map({
	["<Space>d"] = {
		group = "Directory  - NvimTree",
		order = { "f", "t" },
		["f"] = { "<cmd>NvimTreeFocus<CR>", desc = "focus", mode = "n" },
		["t"] = { ToggleTree, desc = "toggle ", mode = "n" },
	},
})

-- MEMO:: LSP
wk_map({
	["<Space>l"] = {
		group = "LSP",
		order = { "d", "D", "c", "v" },
		["d"] = { require("workflows.LSP.function").diagnostic_local, desc = "diagnostic (local)", mode = { "n" } },
		["D"] = { require("workflows.LSP.function").diagnostic_global, desc = "diagnostic (global)", mode = { "n" } },
		["y"] = { CopyDiagnosticsAtLine, desc = "copy diagnostics at line", mode = { "n", "v" } },
		["c"] = { vim.lsp.buf.code_action, desc = "code action", mode = { "n", "v" } },
		["v"] = { ToggleVirtualText, desc = "virtual text toggle", mode = { "n" } },
	},
})
wk_map({
	["<Space>lr"] = {
		group = "expand",
		order = { "n", "e" },
		["n"] = { vim.lsp.buf.rename, desc = "reName ", mode = "n" },
		["e"] = { "<cmd>LspRestart<CR>", desc = "rEstart", mode = "n" },
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
		["g"] = { "<cmd>GlobalNote<CR>", desc = "open Global Note", mode = { "n", "v" } },
		["l"] = { "<cmd>LocalNote<CR>", desc = "open Local Note", mode = { "n", "v" } },
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
	},
})

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

-- MEMO:: QuickFix
wk_map({
	[",q"] = {
		group = "QuickFix",
		order = { "f", "t", "n", "p" },
		["f"] = { "<cmd>copen<CR>", desc = "focus", mode = "n" },
		["t"] = { QF_ToggleList, desc = "toggle", mode = "n" },
		["n"] = { QF_next, desc = "next", mode = "n" },
		["p"] = { QF_prev, desc = "prev", mode = "n" },
	},
})

-- MEMO:: On The Fly
wk_map({
	[",w"] = {
		group = "expand",
		order = { "f", "u", "t", "a" },
		["f"] = { FixWindowSize, desc = "window fix", mode = "n" },
		["u"] = { UnfixWindowSize, desc = "window fix undo", mode = "n" },
		["t"] = { ToggleWinFix, desc = "window fix toggle", mode = "n" },
		["a"] = { ToggleAllWinFix, desc = "window fix all", mode = "n" },
	},
})
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
wk_map({
	[",v"] = {
		group = "expand",
		["d"] = { VDiffSplitOnTab, desc = "vertical diff", mode = "n" },
	},
})
wk_map({
	[",vf"] = {
		group = "expand",
		["d"] = {
			function()
				vim.fn.feedkeys(":vert diffsplit ", "n")
			end,
			desc = "vertical File diff",
			mode = "n",
		},
	},
})
wk_map({
	[",s"] = {
		group = "expand",
		order = { "v", "x", "t" },
		["v"] = { "<cmd>vs<CR>", desc = "split vertical", mode = "n" },
		["x"] = { "<cmd>sp | wincmd w<CR>", desc = "split horizontal", mode = "n" },
		["t"] = { SplitTabModifyTabname, desc = "split to tab", mode = "n" },
	},
})
wk_map({
	[",m"] = {
		group = "expand",
		["t"] = { MoveTabModifyTabname, desc = "move to tab", mode = "n" },
	},
})
wk_map({
	[",c"] = {
		group = "expand",
		["r"] = { RunBufferWithSh, desc = "command run", mode = "n" },
	},
})
wk_map({
	[",cc"] = {
		group = "expand",
		["r"] = { RunBufferWithShCover, desc = "command cover run", mode = "n" },
	},
})
wk_map({
	[",c"] = {
		group = "expand",
		["r"] = { RunSelectedLinesWithSh, desc = "command run", mode = "v" },
	},
})
wk_map({
	[",cc"] = {
		group = "expand",
		["r"] = { RunSelectedLinesWithShCover, desc = "command cover run", mode = "v" },
	},
})
