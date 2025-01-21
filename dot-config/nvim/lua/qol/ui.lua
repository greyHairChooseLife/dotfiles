function MyTabLine()
	local s = ""
	-- local sep = '%#TabLineSelBorder#' -- 탭 구분자
	local sep = "%#TabLineSelBorder# " -- 탭 구분자
	local max_width = 20 -- 탭의 최대 너비

	for i = 1, vim.fn.tabpagenr("$") do
		local tabname = vim.fn.gettabvar(i, "tabname", "Tab " .. i)

		-- 탭 이름이 최대 너비보다 길 경우 잘라냄
		if #tabname > max_width then
			tabname = string.sub(tabname, 1, max_width - 3) .. "..."
		end

		-- 탭 이름을 가운데 정렬
		local padding = math.max(0, (max_width - #tabname) / 2)
		tabname = string.rep(" ", padding) .. tabname .. string.rep(" ", max_width - #tabname - padding)

		if i == vim.fn.tabpagenr() then
			-- active tab
			if tabname:find("GV") then
				s = s
					.. "%"
					.. i
					.. "T"
					.. "%#TabLineGVBg#"
					.. "%#TabLineGVBg#"
					.. tabname
					.. "%#TabLineGVBorder#"
					.. "%#TabLineFill#"
			elseif tabname:find("sp:") or tabname:find("mv:") then
				s = s
					.. "%"
					.. i
					.. "T"
					.. "%#TabLineTempBg#"
					.. "%#TabLineTempBg#"
					.. tabname
					.. "%#TabLineTempBorder#"
					.. "%#TabLineFill#"
			elseif tabname:find("") then
				s = s
					.. "%"
					.. i
					.. "T"
					.. "%#TabLineGVBg#"
					.. "%#TabLineGVBg#"
					.. tabname
					.. "%#TabLineGVBorder#"
					.. "%#TabLineFill#"
			elseif tabname:find("Oil") then
				s = s
					.. "%"
					.. i
					.. "T"
					.. "%#TabLineOilBg#"
					.. "%#TabLineOilBg#"
					.. tabname
					.. "%#TabLineOilBorder#"
					.. "%#TabLineFill#"
			else
				s = s
					.. "%"
					.. i
					.. "T"
					.. "%#TabLineSelBg#"
					.. "%#TabLineSelBg#"
					.. tabname
					.. "%#TabLineSelBorder#"
					.. "%#TabLineFill#"
			end
		else
			-- inactive tab
			s = s .. "%" .. i .. "T" .. "%#TabLineNotSel#" .. " " .. tabname .. " "
		end

		if i < vim.fn.tabpagenr("$") + 1 then
			s = s .. sep
		end
	end

	s = s .. "%#TabLineFill#" .. "%="

	return s
end

-- tabline 설정
vim.o.tabline = "%!v:lua.MyTabLine()"
