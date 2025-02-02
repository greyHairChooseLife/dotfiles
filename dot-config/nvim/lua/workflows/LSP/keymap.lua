local map = vim.keymap.set
local opt = { noremap = true, silent = true }

local telescope = require("telescope.builtin")

map("n", "K", vim.lsp.buf.hover, opt)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opt)
map("n", "<leader>re", vim.lsp.buf.rename, opt)
map("n", "<leader>rs", "<cmd>LspRestart<CR>", opt)

map("n", "dn", vim.diagnostic.goto_next, opt)
map("n", "dp", vim.diagnostic.goto_prev, opt)
map("n", "dK", vim.diagnostic.open_float, opt)

-- MEMO:: `<C-l>`: show autocompletion menu to prefilter (i.e. `:warning:`)
map("n", ",.d", function()
	telescope.diagnostics({
		bufnr = 0, -- 현재 버퍼로 제한
		line_width = 200, -- 어차피 현재 파일일이다.
	})
end, opt)
map("n", ",.D", function()
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

map("n", "d<Space>", ToggleVirtualText, opt)
