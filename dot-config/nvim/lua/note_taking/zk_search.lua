local M = {}

local notebook = vim.env.ZK_NOTEBOOK_DIR or (vim.env.HOME .. "/Documents/zk")
local metadata_path = notebook .. "/.zk/metadata.json"

-- metadata.json 읽기
local function read_metadata()
    local f = io.open(metadata_path, "r")
    if not f then return { tags = {}, areas = {}, types = {}, paths = {} } end
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    return ok and data or { tags = {}, areas = {}, types = {}, paths = {} }
end

-- active_filters → zk list 인수 변환
-- tag/type/area 필터는 zk CLI 미지원(OR) 또는 미지원(type/area) → 모두 post-filter
local function build_zk_args(filters)
    local args = { "list", "--quiet", "--exclude", "docs", "--format", "{{abs-path}}\t{{title}}\t{{filename-stem}}" }

    -- tags AND만 zk 네이티브: --tag A --tag B (교집합)
    for _, t in ipairs(filters.tags_and) do
        args[#args + 1] = "--tag"
        args[#args + 1] = t
    end

    -- date filters
    if filters.created_after  then args[#args + 1] = "--created-after";  args[#args + 1] = filters.created_after  end
    if filters.created_before then args[#args + 1] = "--created-before"; args[#args + 1] = filters.created_before end
    if filters.modified_after  then args[#args + 1] = "--modified-after";  args[#args + 1] = filters.modified_after  end
    if filters.modified_before then args[#args + 1] = "--modified-before"; args[#args + 1] = filters.modified_before end

    -- path OR: positional args (zk list <path>... → OR 동작)
    for _, p in ipairs(filters.paths) do
        args[#args + 1] = p
    end

    -- path NOT: --exclude
    for _, p in ipairs(filters.paths_not or {}) do
        args[#args + 1] = "--exclude"
        args[#args + 1] = p
    end

    return args
end

-- frontmatter에서 type/area/tags 읽기 (post-filter용)
local function read_frontmatter(path)
    local f = io.open(path, "r")
    if not f then return {} end
    local result = {}
    local in_fm = false
    local line_count = 0
    for line in f:lines() do
        line_count = line_count + 1
        if line_count == 1 and line == "---" then
            in_fm = true
        elseif in_fm then
            if line == "---" then break end
            local key, val = line:match("^(%w+):%s*(.+)$")
            if key then result[key] = val:match('^"(.*)"$') or val end
        end
        if line_count > 20 then break end
    end
    f:close()
    return result
end

-- 리스트에 값이 있는지 확인
local function list_has(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

-- 리스트에서 값 제거
local function list_remove(list, value)
    for i, v in ipairs(list) do
        if v == value then table.remove(list, i); return end
    end
end

-- tags 문자열에서 개별 태그 파싱 (frontmatter tags: [a, b, c] 형태)
local function parse_tags(tags_str)
    local tags = {}
    -- "tag1tag2tag3" 형태 (zk가 붙여서 반환) 또는 "[tag1, tag2]" 형태 모두 처리
    local cleaned = tags_str:gsub("^%[", ""):gsub("%]$", "")
    for t in cleaned:gmatch("[^,]+") do
        local trimmed = t:match("^%s*(.-)%s*$")
        if trimmed ~= "" then tags[#tags + 1] = trimmed end
    end
    return tags
end

-- post-filter: tag OR/AND/NOT, type OR/AND/NOT, area OR/AND/NOT 적용
local function post_filter(items, filters)
    local need = #filters.tags_or > 0 or #filters.tags_not > 0
             or #filters.types_or > 0 or #filters.types_not > 0
             or #filters.areas_or > 0 or #filters.areas_not > 0
    if not need then return items end

    local result = {}
    for _, item in ipairs(items) do
        local fm = read_frontmatter(item.file)
        local item_type = fm.type or ""
        local item_area = fm.area or ""
        local item_tag_list = parse_tags(fm.tags or "")

        -- tags OR: item이 OR 목록 중 하나라도 가지면 통과
        if #filters.tags_or > 0 then
            local match = false
            for _, t in ipairs(filters.tags_or) do
                if list_has(item_tag_list, t) then match = true; break end
            end
            if not match then goto continue end
        end

        -- tags NOT: item이 NOT 목록 중 하나라도 가지면 제외
        for _, t in ipairs(filters.tags_not) do
            if list_has(item_tag_list, t) then goto continue end
        end

        -- type OR / NOT
        if #filters.types_or > 0 and not list_has(filters.types_or, item_type) then goto continue end
        if list_has(filters.types_not, item_type) then goto continue end

        -- area OR / NOT
        if #filters.areas_or > 0 and not list_has(filters.areas_or, item_area) then goto continue end
        if list_has(filters.areas_not, item_area) then goto continue end

        result[#result + 1] = item
        ::continue::
    end
    return result
end

-- active_filters → 타이틀 문자열
local function build_title(filters)
    local parts = {}
    local function add(prefix, list) if #list > 0 then parts[#parts + 1] = prefix .. table.concat(list, "|") end end
    add("tag:",    filters.tags_or)
    add("tag&:",   filters.tags_and)
    add("tag!:",   filters.tags_not)
    add("type:",   filters.types_or)
    add("type!:",  filters.types_not)
    add("area:",   filters.areas_or)
    add("area!:",  filters.areas_not)
    add("path:",   filters.paths)
    add("path!:",  filters.paths_not or {})
    if filters.created_after  then parts[#parts + 1] = "created>:" .. filters.created_after  end
    if filters.created_before then parts[#parts + 1] = "created<:" .. filters.created_before end
    if filters.modified_after  then parts[#parts + 1] = "updated>:" .. filters.modified_after  end
    if filters.modified_before then parts[#parts + 1] = "updated<:" .. filters.modified_before end
    if #parts == 0 then return "zk notes" end
    return "zk [" .. table.concat(parts, "  ") .. "]"
end

-- zk list 동기 실행 → snacks picker items (table 반환)
local function run_zk(filters)
    local args = build_zk_args(filters)
    local cmd = "zk " .. table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
    local raw = vim.fn.system("cd " .. vim.fn.shellescape(notebook) .. " && " .. cmd)
    local items = {}
    for line in raw:gmatch("[^\n]+") do
        local path, title, stem = line:match("^(.+)\t(.+)\t(.+)$")
        if path then
            items[#items + 1] = { text = title, file = path, title = title, stem = stem }
        end
    end
    return post_filter(items, filters)
end

-- 날짜 후보 목록
local date_presets = {
    "today", "yesterday", "3 days ago", "last week",
    "last 2 weeks", "last month", "last 3 months", "this year",
    "Manual input...",
}

local function ask_date(cb)
    vim.ui.select({ "created", "updated" }, { prompt = "필드 선택:" }, function(field)
        if not field then return end
        vim.ui.select({ "after", "before" }, { prompt = "방향 선택:" }, function(direction)
            if not direction then return end
            vim.ui.select(date_presets, {
                prompt = direction .. " (예: last week, 2026-03-01, yesterday):",
            }, function(choice)
                if not choice then return end
                if choice == "Manual input..." then
                    vim.ui.input({
                        prompt = direction .. " date (e.g. 'last friday', '2026-03-01', '3 days ago'): ",
                    }, function(input)
                        if not input or input == "" then return end
                        cb(field, direction, input)
                    end)
                else
                    cb(field, direction, choice)
                end
            end)
        end)
    end)
end

-- 메인 검색 picker
-- opts: { mode = "open"|"insert_link"|"grep", sel_buf, sel_start_row, sel_start_col, sel_end_row, sel_end_col, selected_text }
function M.open(source_buf, initial_filters, opts)
    local meta = read_metadata()

    -- 필터 상태 (재열기 시 기존 필터 유지)
    local filters = initial_filters or {
        tags_or = {}, tags_and = {}, tags_not = {},
        types_or = {}, types_not = {},
        areas_or = {}, areas_not = {},
        paths = {}, paths_not = {},
        created_after = nil, created_before = nil,
        modified_after = nil, modified_before = nil,
    }

    opts = opts or {}
    local picker_ref = nil

    local function refresh_picker()
        if picker_ref and not picker_ref.closed then
            picker_ref.title = build_title(filters)
            picker_ref:refresh()
        else
            M.open(source_buf, filters, opts)
        end
    end

    -- 필터 선택 (vim.ui.select 반복 방식)
    -- 선택 시 상태 순환 → 다시 목록 표시 → ">>> 확정" 또는 Esc 시 메인 picker 갱신
    -- has_and=true: tag용 [A]nd→[O]r→[N]ot→[ ]none 순환 (4단계)
    -- has_and=false: type/area용 [O]r→[N]ot→[ ]none 순환 (3단계)
    local function make_filter_action(candidates_fn, or_list, and_list, not_list, label, has_and)
        return function(picker)
            picker_ref = picker

            local candidates = candidates_fn()
            if #candidates == 0 then
                vim.notify("후보가 없습니다", vim.log.levels.INFO)
                return
            end

            -- [A]/[O]/[N]/[ ] prefix는 모두 3자 + 공백 = 4자
            local function get_state(c)
                if has_and and list_has(and_list, c) then return "and_" end
                if list_has(or_list,  c) then return "or_"  end
                if list_has(not_list, c) then return "not_" end
                return "none_"
            end

            local state_label = { ["and_"] = "[A]", ["or_"] = "[O]", ["not_"] = "[N]", ["none_"] = "[ ]" }
            -- 순환 순서: [ ]→[A]→[O]→[N]→[ ] (tag), [ ]→[O]→[N]→[ ] (type/area)
            local state_cycle = has_and
                and { ["none_"] = "and_", ["and_"] = "or_", ["or_"] = "not_", ["not_"] = "none_" }
                or  { ["none_"] = "or_",  ["or_"]  = "not_", ["not_"] = "none_" }

            local function cycle_state(c)
                local next_st = state_cycle[get_state(c)] or "or_"
                list_remove(or_list, c)
                if has_and then list_remove(and_list, c) end
                list_remove(not_list, c)
                if next_st == "or_"  then or_list[#or_list + 1]   = c
                elseif next_st == "and_" then and_list[#and_list + 1] = c
                elseif next_st == "not_" then not_list[#not_list + 1] = c
                end
            end

            local function open_select()
                vim.schedule(function()
                    local hint = has_and and "[ ]→[A]→[O]→[N]" or "[ ]→[O]→[N]"
                    local display = { ">>> 확정" }
                    for _, c in ipairs(candidates) do
                        display[#display + 1] = (state_label[get_state(c)] or "[ ]") .. " " .. c
                    end
                    vim.ui.select(display, { prompt = label .. "  " .. hint .. "  (선택→순환, 확정):" }, function(choice)
                        if not choice or choice == ">>> 확정" then
                            refresh_picker()
                            return
                        end
                        local raw = choice:sub(5)  -- "[X] value" → 5번째부터
                        cycle_state(raw)
                        open_select()
                    end)
                end)
            end

            open_select()
        end
    end

    -- path 계층 탐색 action (OR/NOT/NONE 순환, vim.ui.select 반복 방식)
    local function path_action(picker)
        picker_ref = picker
        local root_order = { "inbox", "resource", "project", "area", "archive" }
        local ordered = {}

        -- "current": source_buf 파일의 디렉토리 (notebook 기준 상대경로)
        local current_dir = nil
        if source_buf then
            local buf_path = vim.api.nvim_buf_get_name(source_buf)
            if buf_path ~= "" and buf_path:sub(1, #notebook) == notebook then
                local rel = vim.fn.fnamemodify(buf_path, ":h"):sub(#notebook + 2)
                if rel ~= "" then
                    current_dir = rel
                    ordered[#ordered + 1] = "current  (" .. rel .. ")"
                end
            end
        end

        for _, root in ipairs(root_order) do
            if vim.fn.isdirectory(notebook .. "/" .. root) == 1 then
                ordered[#ordered + 1] = root
                local subs = {}
                local handle = vim.uv.fs_scandir(notebook .. "/" .. root)
                if handle then
                    while true do
                        local name, ftype = vim.uv.fs_scandir_next(handle)
                        if not name then break end
                        if ftype == "directory" and not name:match("^%.") then
                            subs[#subs + 1] = name
                        end
                    end
                end
                table.sort(subs)
                for _, sub in ipairs(subs) do
                    ordered[#ordered + 1] = root .. "/" .. sub
                end
            end
        end

        local path_label = { or_ = "[O]", not_ = "[N]", none_ = "[ ]" }
        local path_cycle = { none_ = "or_", or_ = "not_", not_ = "none_" }

        -- display key → 실제 필터 값 매핑 ("current (...)" → current_dir)
        local function resolve_path(d)
            if current_dir and d:match("^current  %(") then return current_dir end
            return d
        end

        local function get_path_state(d)
            local p = resolve_path(d)
            if list_has(filters.paths,     p) then return "or_"  end
            if list_has(filters.paths_not, p) then return "not_" end
            return "none_"
        end

        local function cycle_path(d)
            local p = resolve_path(d)
            local next_st = path_cycle[get_path_state(d)] or "or_"
            list_remove(filters.paths,     p)
            list_remove(filters.paths_not, p)
            if next_st == "or_"  then filters.paths[#filters.paths + 1]         = p
            elseif next_st == "not_" then filters.paths_not[#filters.paths_not + 1] = p
            end
        end

        local function open_path_select()
            vim.schedule(function()
                local display = { ">>> 확정" }
                for _, d in ipairs(ordered) do
                    if current_dir and d:match("^current  %(") then
                        display[#display + 1] = "    " .. d
                    else
                        display[#display + 1] = (path_label[get_path_state(d)] or "[ ]") .. " " .. d
                    end
                end
                vim.ui.select(display, { prompt = "Path  [ ]→[O]r→[N]ot  (선택→순환, 확정):" }, function(choice)
                    if not choice or choice == ">>> 확정" then
                        refresh_picker()
                        return
                    end
                    local raw = choice:sub(5)
                    cycle_path(raw)
                    open_path_select()
                end)
            end)
        end

        open_path_select()
    end

    -- 현재 편집 파일 태그 토글 action
    local function current_tags_action(picker)
        picker_ref = picker
        if not source_buf then
            vim.notify("편집 중인 노트가 없습니다", vim.log.levels.INFO)
            return
        end
        local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
        local tags = {}
        local in_fm = false
        for _, line in ipairs(lines) do
            if line == "---" then
                if not in_fm then in_fm = true else break end
            elseif in_fm then
                local raw = line:match("^tags:%s*%[(.-)%]")
                if raw then
                    for tag in raw:gmatch("[^,]+") do
                        local t = tag:match("^%s*(.-)%s*$")
                        if t ~= "" then tags[#tags + 1] = t end
                    end
                end
            end
        end
        if #tags == 0 then
            vim.notify("현재 노트에 태그가 없습니다", vim.log.levels.INFO)
            return
        end
        local display = {}
        for _, t in ipairs(tags) do
            display[#display + 1] = (list_has(filters.tags_or, t) and "[+] " or "    ") .. t
        end
        vim.schedule(function()
            vim.ui.select(display, { prompt = "현재 노트 태그 (OR 토글):" }, function(choice)
                if not choice then return end
                local raw = choice:gsub("^%[.%] ", ""):gsub("^%s+", "")
                if list_has(filters.tags_or, raw) then
                    list_remove(filters.tags_or, raw)
                else
                    filters.tags_or[#filters.tags_or + 1] = raw
                end
                refresh_picker()
            end)
        end)
    end

    -- 날짜 필터 action
    local function date_action(picker)
        picker_ref = picker
        vim.schedule(function()
            ask_date(function(field, direction, value)
                local key = (field == "created" and "created" or "modified") .. "_" .. direction
                filters[key] = value
                refresh_picker()
            end)
        end)
    end

    local is_grep = opts.mode == "grep"

    -- grep 모드: zk list로 필터된 파일에서 rg로 내용 검색 (live)
    local function grep_finder(popts, ctx)
        local files = run_zk(filters)
        if #files == 0 then return {} end
        local search = (ctx and ctx.filter and ctx.filter.search) or ""
        if search == "" then return {} end
        local rg_args = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case",
            search, "--",
        }
        for _, item in ipairs(files) do
            rg_args[#rg_args + 1] = item.file
        end
        local raw = vim.fn.system(table.concat(vim.tbl_map(vim.fn.shellescape, rg_args), " "))
        local items = {}
        for line in raw:gmatch("[^\n]+") do
            local path, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
            if path then
                local stem = vim.fn.fnamemodify(path, ":t:r")
                items[#items + 1] = {
                    text = text,
                    file = path,
                    pos  = { tonumber(lnum), tonumber(col) - 1 },
                    stem = stem,
                }
            end
        end
        return items
    end

    -- finder: zk list 동기 실행 후 table 반환
    local function finder(popts, ctx)
        return run_zk(filters)
    end

    -- picker 열기
    require("snacks").picker({
        title = build_title(filters),
        finder = is_grep and grep_finder or finder,
        live = is_grep,
        auto_close = false,
        format = is_grep and "file" or function(item, _)
            return {
                { item.title or item.text, "SnacksPickerLabel" },
                { "  " .. (item.stem or ""), "SnacksPickerComment" },
            }
        end,
        preview = "file",
        confirm = function(picker, item)
            picker:close()
            if not item then return end
            if opts.mode == "insert_link" then
                local stem = item.stem or vim.fn.fnamemodify(item.file, ":t:r")
                local link
                if opts.selected_text then
                    link = "[[" .. stem .. "|" .. opts.selected_text .. "]]"
                else
                    link = "[[" .. stem .. "]]"
                end
                vim.api.nvim_buf_set_text(
                    opts.sel_buf, opts.sel_start_row, opts.sel_start_col,
                    opts.sel_end_row, opts.sel_end_col, { link }
                )
                if not opts.selected_text then
                    vim.api.nvim_win_set_cursor(0, { opts.sel_start_row + 1, opts.sel_start_col + #link })
                end
                vim.api.nvim_buf_call(opts.sel_buf, function() vim.cmd("w") end)
            else
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
            end
            -- Reapply foldmethod to fix folds broken by opening buffers.
            -- Borrowed from snacks.picker's built-in jump action (snacks/picker/actions.lua:156-161).
            if vim.wo.foldmethod == "expr" then
                vim.schedule(function() vim.opt.foldmethod = "expr" end)
            end
        end,
        actions = {
            zk_tag  = make_filter_action(function() return meta.tags or {} end,  filters.tags_or,  filters.tags_and,  filters.tags_not,  "tag",  true),
            zk_type = make_filter_action(function() return meta.types or {} end, filters.types_or, filters.types_and, filters.types_not, "type", false),
            zk_area = make_filter_action(function() return meta.areas or {} end, filters.areas_or, filters.areas_and, filters.areas_not, "area", false),
            zk_path     = path_action,
            zk_cur_tags = current_tags_action,
            zk_date     = date_action,
            zk_yank = function(picker)
                local item = picker:current()
                if not item then return end
                local name = item.stem or vim.fn.fnamemodify(item.file, ":t:r")
                vim.fn.setreg("+", name)
                vim.notify("Yanked: " .. name, vim.log.levels.INFO)
            end,
            zk_clear    = function(picker)
                picker_ref = picker
                local title = build_title(filters)
                if title == "zk notes" then
                    vim.notify("적용된 필터 없음", vim.log.levels.INFO)
                    return
                end
                vim.schedule(function()
                    vim.ui.select({ "yes", "no" }, {
                        prompt = "필터 초기화? 현재: " .. title,
                    }, function(choice)
                        if choice ~= "yes" then return end
                        -- 테이블 재할당하면 액션 클로저 참조가 끊어짐 → 내용만 비움
                        local function clear(t) while #t > 0 do table.remove(t) end end
                        clear(filters.tags_or);  clear(filters.tags_and);  clear(filters.tags_not)
                        clear(filters.types_or); clear(filters.types_not)
                        clear(filters.areas_or); clear(filters.areas_not)
                        clear(filters.paths); clear(filters.paths_not)
                        filters.created_after, filters.created_before = nil, nil
                        filters.modified_after, filters.modified_before = nil, nil
                        refresh_picker()
                    end)
                end)
            end,
        },
        win = {
            input = {
                keys = {
                    ["<M-1>"] = { "zk_tag",      mode = { "i", "n" } },
                    ["<M-2>"] = { "zk_type",     mode = { "i", "n" } },
                    ["<M-3>"] = { "zk_area",     mode = { "i", "n" } },
                    ["<M-4>"] = { "zk_path",     mode = { "i", "n" } },
                    ["<M-5>"] = { "zk_cur_tags", mode = { "i", "n" } },
                    ["<M-6>"] = { "zk_date",     mode = { "i", "n" } },
                    ["<M-0>"] = { "zk_clear",    mode = { "i", "n" } },
                    ["<C-y>"] = { "zk_yank",     mode = { "i", "n" } },
                },
            },
        },
    })
end

-- 노트 내용 검색 (grep 모드)
function M.grep_notes()
    local source_buf = vim.api.nvim_get_current_buf()
    M.open(source_buf, nil, { mode = "grep" })
end

-- 링크 삽입: 기존 검색 picker를 insert_link 모드로 열기
-- normal mode: 커서 위치에 [[stem]] 삽입
-- visual mode: 선택 텍스트를 [[stem|alias]]로 교체
function M.insert_link(is_visual)
    local sel_buf = vim.api.nvim_get_current_buf()
    local opts = { mode = "insert_link", sel_buf = sel_buf }

    if is_visual then
        -- visual mode가 아직 살아있는 상태에서 yank → 현재 선택 텍스트 + 마크 업데이트
        vim.cmd('noau normal! "vy"')
        local yanked = vim.fn.getreg("v")
        vim.fn.setreg("v", {})

        local start_pos = vim.api.nvim_buf_get_mark(sel_buf, "<")
        local end_pos   = vim.api.nvim_buf_get_mark(sel_buf, ">")
        if start_pos[1] == 0 then
            is_visual = false
        else
            opts.sel_start_row = start_pos[1] - 1
            opts.sel_start_col = start_pos[2]
            opts.sel_end_row   = end_pos[1] - 1

            -- linewise visual (V): end col = 2147483647 → 줄 끝으로 clamp
            local end_line = vim.api.nvim_buf_get_lines(sel_buf, end_pos[1] - 1, end_pos[1], true)[1] or ""
            local raw_col = end_pos[2]
            if raw_col >= #end_line then
                opts.sel_end_col = #end_line
            else
                opts.sel_end_col = raw_col
                    + #vim.fn.strcharpart(vim.fn.strpart(end_line, raw_col), 0, 1)
            end

            opts.selected_text = yanked:gsub("\n", " ")
        end
    end

    if not is_visual then
        local cursor = vim.api.nvim_win_get_cursor(0)
        opts.sel_start_row = cursor[1] - 1
        opts.sel_start_col = cursor[2]
        opts.sel_end_row   = opts.sel_start_row
        opts.sel_end_col   = opts.sel_start_col
    end

    M.open(sel_buf, nil, opts)
end


-- 최근 수정 노트 picker
function M.open_recent()
    local raw = vim.fn.system(
        "cd " .. vim.fn.shellescape(notebook) .. " && zk list --quiet --exclude docs --sort modified- --limit 10 --format '{{abs-path}}\t{{title}}\t{{filename-stem}}'"
    )
    local items = {}
    for line in raw:gmatch("[^\n]+") do
        local path, title, stem = line:match("^(.+)\t(.+)\t(.+)$")
        if path then
            items[#items + 1] = { text = title, file = path, title = title, stem = stem }
        end
    end

    require("snacks").picker({
        title = "zk recent",
        finder = function() return items end,
        format = function(item, _)
            return {
                { item.title or item.text, "SnacksPickerLabel" },
                { "  " .. (item.stem or ""), "SnacksPickerComment" },
            }
        end,
        preview = "file",
        confirm = function(picker, item)
            picker:close()
            if item and item.file then
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                -- Borrowed from snacks.picker's built-in jump action (snacks/picker/actions.lua:156-161).
                if vim.wo.foldmethod == "expr" then
                    vim.schedule(function() vim.opt.foldmethod = "expr" end)
                end
            end
        end,
    })
end

return M
