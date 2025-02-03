local last_closed_buffer = nil

-- 윈도우가 종료될 때 실행되는 함수
local function save_last_closed_buffer()
	local buf = vim.api.nvim_get_current_buf() -- 현재 버퍼 ID 가져오기
	local bufname = vim.api.nvim_buf_get_name(buf) -- 현재 버퍼의 파일 경로 가져오기
	local buftype = vim.bo[buf].buftype -- 버퍼 타입 확인

	-- 버퍼가 정상적인 파일을 나타내는 경우만 저장
	if bufname ~= "" and buftype == "" then
		last_closed_buffer = bufname
	else
		last_closed_buffer = nil
	end
end

-- 마지막 저장된 버퍼를 새 창에서 열기
local function restore_last_closed_buffer()
	if last_closed_buffer then
		vim.cmd("vnew " .. vim.fn.fnameescape(last_closed_buffer)) -- `:vnew`로 복구

		-- 만약 현재 탭에 두개의 윈도우만 있다면 print로 알림
		if #vim.api.nvim_list_wins() == 2 then
			ReloadLayout()
		end

		last_closed_buffer = nil -- 복구 후 저장된 버퍼 초기화
	else
		print("🚫 저장된 종료 버퍼가 없습니다.")
	end
end

-- 오토커맨드 설정: 윈도우가 닫힐 때 실행
vim.api.nvim_create_autocmd("WinClosed", {
	callback = save_last_closed_buffer,
})

-- 키맵 설정: <leader>r 로 복구 실행
vim.keymap.set("n", "<leader>r", restore_last_closed_buffer, { noremap = true })
