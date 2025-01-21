-- DEPRECATED:: 2024-01-17, tmux 이후로 keymap이 겹쳐서 안쓴다. 기능을 대체한 것은 아님
-- >>>>>>>>>
-- 삭제된 단어들을 저장할 Lua 테이블
local deleted_words = {}

-- 단어를 삭제하고 테이블에 저장하는 함수
function DeleteAndStore()
	vim.cmd("normal! b") -- 커서를 단어의 시작으로 이동
	local word = vim.fn.expand("<cword>") -- 현재 단어를 가져옴
	table.insert(deleted_words, 1, word) -- 테이블 맨 앞에 단어 추가
	vim.cmd("normal! diw") -- 단어 삭제
end

-- 삭제된 단어들을 순차적으로 붙여넣는 함수
function PasteFromHistory()
	if #deleted_words > 0 then
		local word = table.remove(deleted_words, 1) -- 가장 최근에 추가된 단어 가져오기
		vim.api.nvim_put({ word }, "c", true, true) -- 현재 커서 위치에 단어 삽입
	end
end
-- <<<<<<<<<<

local function temp_test()
	vim.ui.select({ "one", "two" }, {
		prompt = "Select tabs or spaces:",
		format_item = function(item)
			return "I'd like to choose " .. item
		end,
	}, function(choice)
		print("choice: ", choice)
	end)
end

vim.keymap.set("n", "<leader>q", temp_test, { noremap = true, silent = true })
