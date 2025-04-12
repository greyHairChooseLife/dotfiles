local map = vim.keymap.set
local opt = { noremap = true, silent = true }

local telescope = require("telescope.builtin")
local utils = require("utils")

map("n", "K", function()
	vim.lsp.buf.hover({

		border = utils.borders.documentation_left,
		-- title = "Hover",
		focusable = true,
		max_width = 120, -- 최대 너비 제한
		max_height = 200, -- 최대 높이 제한
	})
end, opt)

map("n", "dn", function()
	vim.diagnostic.jump({ count = 1, float = false })
end, opt)
map("n", "dp", function()
	vim.diagnostic.jump({ count = -1, float = false })
end, opt)
map("n", "dK", vim.diagnostic.open_float, opt)

-- MEMO:: `<C-l>`: show autocompletion menu to prefilter (i.e. `:warning:`)

map("n", ",..d", function()
	telescope.diagnostics({
		bufnr = 0, -- 현재 버퍼로 제한
		line_width = 200, -- 어차피 현재 파일일이다.
	})
end, opt)
map("n", ",.d", function()
	telescope.diagnostics({
		bufnr = nil, -- 모든 버퍼
		line_width = 0, -- diagnostic line은 필요 없고 파일만 구분되면 돼
	})
end, opt)

map("n", "gD", vim.lsp.buf.declaration, opt)
map("n", "gd", function()
	telescope.lsp_definitions({
		jump_type = "never", -- 항상 preview 띄우기
		show_line = false, -- 결과 텍스트 표시
		trim_text = false, -- 텍스트 트림 비활성화
	})
end, opt)
map("n", "gy", function()
	telescope.lsp_type_definition({
		jump_type = "never", -- 항상 preview 띄우기
		show_line = false, -- 결과 텍스트 표시
		trim_text = false, -- 텍스트 트림 비활성화
	})
end, opt)
map("n", "gi", function()
	telescope.lsp_implementation({
		jump_type = "never", -- 항상 preview 띄우기
		show_line = false, -- 결과 텍스트 표시
		trim_text = false, -- 텍스트 트림 비활성화
	})
end, opt)
map("n", "gR", function()
	telescope.lsp_references({
		show_line = false, -- 결과 텍스트 표시
		include_declaration = true,
		include_current_line = false, --> false: ()커서가 위치한 요소도 결과에)포함, ture: 제외
	})
end, opt)
map("n", "gI", function()
	telescope.lsp_incoming_calls({
		show_line = false, -- 결과 텍스트 표시
	})
end, opt)
map("n", "gO", function()
	telescope.lsp_outgoing_calls({
		show_line = false, -- 결과 텍스트 표시
	})
end, opt)

local wk_map = require("utils").wk_map
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
