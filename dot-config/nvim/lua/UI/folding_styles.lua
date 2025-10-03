_G.markdown_fold_text = function(foldstart, foldend, foldlevel)
  local line_start_icon
  if foldlevel == 1 then
    line_start_icon = " 󱞪 "
  elseif foldlevel == 2 then
    line_start_icon = " 󱞪 "
  elseif foldlevel == 3 then
    line_start_icon = "    󱞪 "
  elseif foldlevel == 4 then
    line_start_icon = "       󱞪 "
  end
  local line_end_icon = ""
  local line_icon = "░"
  local total_width
  if foldlevel == 1 then
    total_width = 100
  elseif foldlevel == 2 then
    total_width = 100
  elseif foldlevel == 3 then
    total_width = 99
  elseif foldlevel == 4 then
    total_width = 97
  end
  local line_icon_fill = string.rep(line_icon, total_width - #line_start_icon / 2)
  local line_fill = line_start_icon .. line_icon_fill .. line_end_icon

  local line_count = foldend - foldstart + 1
  -- local count_text = " 󰡏 " .. line_count -- 󰜴
  local count_text = " " .. line_count -- 󰜴

  local win_width = vim.fn.winwidth(0)
  local padding = string.rep(" ", math.max(0, win_width - total_width))

  -- 최종 폴드 텍스트 구성
  return line_fill .. count_text .. padding
end

_G.markdown_fold_expr = function(lnum)
  local prev_line = vim.fn.getline(lnum - 1) -- 헤더라인은 살려야지
  local curr_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)
  local next2_line = vim.fn.getline(lnum + 2)
  local last_line = vim.fn.line("$")

  local is_lv2_header = string.match(prev_line, "^##%s")
  local is_lv3_header = string.match(prev_line, "^###%s")
  local is_lv4_header = string.match(prev_line, "^####%s")
  local is_lv5_header = string.match(prev_line, "^#####%s")

  if is_lv2_header then
    return "1"
  end
  if is_lv3_header then
    return "2"
  end
  if is_lv4_header then
    return "3"
  end
  if is_lv5_header then
    return "4"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^###%s") then
    return "1"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^####%s") then
    return "2"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^#####%s") then
    return "3"
  end
  -- if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next2_line, "^##%s") then
  if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next_line, "^##%s") then
    return "0"
  end

  -- 무엇에도 해당하지 않는 경우 prev_line의 foldlevel을 그대로 사용
  return "="
end

_G.codecompanion_fold_text = function(foldstart, foldend, foldlevel)
  local line_start_icon
  if foldlevel == 1 then
    line_start_icon = "  "
  elseif foldlevel == 2 then
    line_start_icon = "  󱞪  "
  elseif foldlevel == 3 then
    line_start_icon = "    󱞪  "
  elseif foldlevel == 4 then
    line_start_icon = "      󱞪  "
  end
  local line_count = foldend - foldstart + 1

  -- 최종 폴드 텍스트 구성
  return line_start_icon .. line_count .. "  "
end

_G.codecompanion_fold_expr = function(lnum)
  local prev_line = vim.fn.getline(lnum - 1) -- 헤더라인은 살려야지
  local curr_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)
  local last_line = vim.fn.line("$")

  local is_lv2_header = string.match(prev_line, "^##%s")
  local is_lv3_header = string.match(prev_line, "^###%s")
  local is_lv4_header = string.match(prev_line, "^####%s")
  local is_lv5_header = string.match(prev_line, "^#####%s")
  local is_lv6_header = string.match(prev_line, "^#####%s")

  if is_lv2_header then
    return "1"
  end
  if is_lv3_header then
    return "2"
  end
  if is_lv4_header then
    return "3"
  end
  if is_lv5_header then
    return "4"
  end
  if is_lv6_header then
    return "5"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^###%s") then
    return "1"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^####%s") then
    return "2"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^#####%s") then
    return "3"
  end
  if string.match(curr_line, "^%s*$") and string.match(next_line, "^######%s") then
    return "4"
  end
  -- if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next2_line, "^##%s") then
  if curr_line == last_line or string.match(curr_line, "^%s*$") and string.match(next_line, "^##%s") then
    return "0"
  end

  -- 무엇에도 해당하지 않는 경우 prev_line의 foldlevel을 그대로 사용
  return "="
end
