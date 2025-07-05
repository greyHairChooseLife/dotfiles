function MyTabLine()
	local s = ""
	-- local sep = '%#TabLineSelBorder#' -- 탭 구분자
	local sep = "%#TabLineSelBorder# " -- 탭 구분자
	local max_width = 20 -- 탭의 최대 너비

	for i = 1, vim.fn.tabpagenr("$") do
		local tabname = vim.fn.gettabvar(i, "tabname", "Tab " .. i)

		-- userdata를 문자열로 변환
		if type(tabname) ~= "string" then
			tabname = (tostring(tabname) or "Tab ") .. i
		end

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

function MyTabLine_width_fixed()
	local s = ""
	local sep = "%#TabLineSelBorder# " -- 탭 구분자
	local max_width = 20 -- 탭 최대 너비

	for i = 1, vim.fn.tabpagenr("$") do
		local tabname = vim.fn.gettabvar(i, "tabname", "Tab " .. i)

		-- userdata를 문자열로 변환
		if type(tabname) ~= "string" then
			tabname = (tostring(tabname) or "Tab ") .. i
		end

		-- 탭 이름 길이 조정
		if #tabname > max_width then
			tabname = string.sub(tabname, 1, max_width - 3) .. "..."
		end

		-- 패딩 정수로 고정 (소수점 오류 방지)
		local padding = math.floor((max_width - #tabname) / 2)
		tabname = string.rep(" ", padding) .. tabname .. string.rep(" ", max_width - #tabname - padding)

		local tab_format = "%" .. i .. "T" .. " " .. tabname .. " " -- 기본 포맷

		if i == vim.fn.tabpagenr() then
			-- 현재 활성 탭
			if tabname:find("GV") then
				s = s .. "%#TabLineGVBg#" .. tab_format .. "%#TabLineGVBorder#"
			elseif tabname:find("sp:") or tabname:find("mv:") then
				s = s .. "%#TabLineTempBg#" .. tab_format .. "%#TabLineTempBorder#"
			elseif tabname:find("") then
				s = s .. "%#TabLineGVBg#" .. tab_format .. "%#TabLineGVBorder#"
			elseif tabname:find("Oil") then
				s = s .. "%#TabLineOilBg#" .. tab_format .. "%#TabLineOilBorder#"
			else
				s = s .. "%#TabLineSelBg#" .. tab_format .. "%#TabLineSelBorder#"
			end
		else
			-- 비활성 탭
			s = s .. "%#TabLineNotSel#" .. tab_format
		end

		if i < vim.fn.tabpagenr("$") + 1 then
			s = s .. sep
		end
	end

	s = s .. "%#TabLineFill#" .. "%="

	return s
end

function MyTabLine_width_flexible(MinimalLength, MaximumLength)
	local s = ""
	local sep = "%#TabLineSelBorder# " -- 탭 구분자

	for i = 1, vim.fn.tabpagenr("$") do
		local tabname = vim.fn.gettabvar(i, "tabname", "Tab " .. i)

		-- userdata를 문자열로 변환
		if type(tabname) ~= "string" then
			tabname = (tostring(tabname) or "Tab ") .. i
		end

		-- Convert empty string or nil to nil
		if MinimalLength == "" or MinimalLength == 0 then
			MinimalLength = nil
		end
		if MaximumLength == "" or MaximumLength == 0 then
			MaximumLength = nil
		end

		-- 최대 길이 제한
		if MaximumLength and #tabname > MaximumLength then
			tabname = string.sub(tabname, 1, MaximumLength - 3) .. "..."
		end

		-- 최소 길이 패딩
		if MinimalLength and #tabname < MinimalLength then
			local padding = MinimalLength - #tabname - 4 -- 기본 패딩 제외
			tabname = string.rep(" ", padding / 2) .. tabname .. string.rep(" ", padding / 2)
		end

		-- 기본 좌우 패딩
		tabname = "  " .. tabname .. "  "

		local tab_format = "%" .. i .. "T" .. " " .. tabname .. " " -- 기본 포맷

		if i == vim.fn.tabpagenr() then
			-- 현재 활성 탭
			if tabname:find("GV") then
				s = s .. "%#TabLineGVBg#" .. tab_format .. "%#TabLineGVBorder#"
			elseif tabname:find("sp:") or tabname:find("mv:") then
				s = s .. "%#TabLineTempBg#" .. tab_format .. "%#TabLineTempBorder#"
			elseif tabname:find("") then
				s = s .. "%#TabLineGVBg#" .. tab_format .. "%#TabLineGVBorder#"
			elseif tabname:find("Oil") then
				s = s .. "%#TabLineOilBg#" .. tab_format .. "%#TabLineOilBorder#"
			else
				s = s .. "%#TabLineSelBg#" .. tab_format .. "%#TabLineSelBorder#"
			end
		else
			-- 비활성 탭
			s = s .. "%#TabLineNotSel#" .. tab_format
		end

		if i < vim.fn.tabpagenr("$") + 1 then
			s = s .. sep
		end
	end

	s = s .. "%#TabLineFill#" .. "%="

	return s
end

-- tabline 설정
-- vim.o.tabline = "%!v:lua.MyTabLine()"
-- vim.o.tabline = "%!v:lua.MyTabLine_width_fixed()"
vim.o.tabline = "%!v:lua.MyTabLine_width_flexible(15, 45)"
