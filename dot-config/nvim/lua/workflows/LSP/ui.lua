-- REF: https://neovim.io/doc/user/deprecated.html
-- TODO: deprecated 된것들 좀 바꾸자.

local utils = require("utils")

-- Diagnostic settings
vim.diagnostic.config({
	virtual_text = false,
	-- virtual_text = {
	-- 	prefix = " ",
	-- },
	virtual_lines = false,
	signs = {
		priority = 1,
	}, -- sign column에 아이콘 표시

	underline = false,
	update_in_insert = true, -- 입력 모드 중 업데이트 비활성화
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

-- DEPRECATED:: 2025-04-01
-- 'lua/workflows/LSP/keymap.lua' 위치로 옮겼다. hover를 실행하는 키맵에서 직접 config 지정하는 방식
-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
-- 	-- border = "none",
-- 	border = utils.borders.documentation_left,
-- 	-- title = "Hover",
-- 	focusable = true,
-- 	max_width = 120, -- 최대 너비 제한
-- 	max_height = 150, -- 최대 높이 제한
-- })

-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "none" }) -- blink.cmp에서 정의
