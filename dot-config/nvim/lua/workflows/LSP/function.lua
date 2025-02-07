local virtual_text_config = {
	prefix = " ",
}
local virtual_text_enabled = true

function ToggleVirtualText()
	virtual_text_enabled = not virtual_text_enabled

	vim.diagnostic.config({
		virtual_text = virtual_text_enabled and virtual_text_config or false,
		underline = true,
		signs = false, -- sign column에 아이콘 표시
		update_in_insert = false, -- 입력 모드 중 업데이트 비활성화
		severity_sort = true, -- 심각도에 따라 정렬
	})
end

-- MEMO:: for keymaps
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local T = {} -- Telescope
local tele = require("telescope.builtin")

T.diagnostic_local = function()
	tele.diagnostics({
		bufnr = 0, -- 현재 버퍼로 제한
		line_width = 200, -- 어차피 현재 파일일이다.
	})
end

T.diagnostic_global = function()
	tele.diagnostics({
		bufnr = nil, -- 모든 버퍼
		line_width = 200, --diagnostic line은 필요 없고 파일만 구분되면 돼
	})
end

return T
