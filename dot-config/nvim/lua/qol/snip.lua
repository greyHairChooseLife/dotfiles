local map = vim.keymap.set
local opt = { noremap = true, silent = true }

map("i", ",t", function() -- 2025-01-20
  vim.api.nvim_put({ "- [ ] " }, "c", false, true)
end, opt)

-- 날짜 찍기
map("i", ",d", function() -- 2025-01-20
  local date_text = vim.fn.system('date "+%Y-%m-%d"'):gsub("\n$", "")
  vim.api.nvim_put({ date_text }, "c", false, true)
end, opt)

map("i", ",D", function() -- 2025-09-09 (화) 10:42
  local days = { Sun = "일", Mon = "월", Tue = "화", Wed = "수", Thu = "목", Fri = "금", Sat = "토" }
  local eng_day = vim.fn.system('date "+%a"'):gsub("\n$", "")
  local kor_day = "(" .. (days[eng_day] or eng_day) .. ")"
  local date_text = vim.fn.system('date "+%Y-%m-%d"'):gsub("\n$", "")
  local time_text = vim.fn.system('date "+%H:%M"'):gsub("\n$", "")
  vim.api.nvim_put({ date_text .. " " .. kor_day .. " " .. time_text }, "c", false, true)
end, opt)

local function Insert_comment(comment)
  vim.cmd("normal! ^")
  local current_line, indent_level = unpack(vim.api.nvim_win_get_cursor(0))
  local is_cursor_char_blank = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]:sub(
    indent_level + 1, indent_level + 1) == " "

  if is_cursor_char_blank then
    indent_level = indent_level + 1
  end
  local indent_word = string.rep(" ", indent_level)

  vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, false, { indent_word })
  vim.api.nvim_put({ comment }, "c", true, false)
  require("Comment.api").comment.linewise.current()
  vim.cmd("startinsert!")
end

map("i", ",,T", function() Insert_comment("TODO:: ") end)
map("i", ",,P", function() Insert_comment("PSEUDO_CODE:: ") end)
map("i", ",,M", function() Insert_comment("MEMO:: ") end)
map("i", ",,W", function() Insert_comment("WARN:: ") end)
map("i", ",,B", function() Insert_comment("BUG:: ") end)
map("i", ",,db", function()
  local comment_text_start = "START_debug:"
  local comment_text_end = "END___debug:"
  Insert_comment(comment_text_start)
  vim.cmd("normal! o")
  Insert_comment(comment_text_end)
  vim.api.nvim_input("<Esc>O<Esc>cc")
end)
map("i", ",,dp", function()
  local date = vim.fn.system('date "+%Y-%m-%d"'):gsub("\n$", "")
  local text = string.format("DEPRECATED:: %s", date)
  Insert_comment(text)
  vim.api.nvim_input("<Esc>o")
end)
