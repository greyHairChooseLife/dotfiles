local utils = require("utils")

-- Diagnostic settings
vim.diagnostic.config({
	virtual_text = {
		prefix = " ",
	}, -- 진단 메시지를 줄 안에 표시
	virtual_lines = true,

	underline = true,
	signs = false, -- sign column에 아이콘 표시
	update_in_insert = false, -- 입력 모드 중 업데이트 비활성화
	severity_sort = true, -- 심각도에 따라 정렬
	float = {
		-- border = "single",
		border = utils.borders.diagnostics,
		max_width = 120, -- 최대 너비 제한
	},
})

local diag_signs = utils.icons.diagnostics
for type, icon in pairs(diag_signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	-- border = "none",
	border = utils.borders.documentation_left,
	-- title = "Hover",
	focusable = true, -- 포커스 비활성화
	max_width = 120, -- 최대 너비 제한
	max_height = 150, -- 최대 높이 제한
})

-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "none" }) -- blink.cmp에서 정의
