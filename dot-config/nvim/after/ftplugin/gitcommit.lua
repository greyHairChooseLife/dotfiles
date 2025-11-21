-- 시작시 윈도우를 최우측에 두고, 커서를 최상단에 위치
vim.cmd("WinShift far_right")
vim.api.nvim_win_set_width(0, 85)
vim.defer_fn(function() vim.cmd("normal gg") end, 10)

-- KEYMAP
local map = vim.keymap.set
local opt = { buffer = true, silent = true }

map("n", "gq", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" }) -- 현재 버퍼의 내용을 빈 문자열로 덮어씌워 커밋 메시지가 저장되지 않도록 합니다.
    vim.cmd("wq")
end, opt)
