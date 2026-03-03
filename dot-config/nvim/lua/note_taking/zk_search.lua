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

-- 디렉토리 트리를 계층적으로 스캔 (숨김 제외, docs/ 제외)
local function scan_dirs(base, prefix, result)
    prefix = prefix or ""
    result = result or {}
    local handle = vim.uv.fs_scandir(base)
    if not handle then return result end
    local entries = {}
    while true do
        local name, ftype = vim.uv.fs_scandir_next(handle)
        if not name then break end
        if ftype == "directory" and not name:match("^%.") and name ~= "docs" then
            entries[#entries + 1] = name
        end
    end
    table.sort(entries)
    for _, name in ipairs(entries) do
        local rel = prefix == "" and name or (prefix .. "/" .. name)
        result[#result + 1] = rel
        scan_dirs(base .. "/" .. name, rel, result)
    end
    return result
end

-- active_filters → zk list 인수 변환
-- type/area 필터는 zk CLI 미지원 → post-filter로 처리
local function build_zk_args(filters)
    local args = { "list", "--quiet", "--format", "{{abs-path}}\t{{title}}\t{{filename-stem}}" }

    -- tags OR (zk 네이티브 지원)
    if #filters.tags_or > 0 then
        args[#args + 1] = "--tag"
        args[#args + 1] = table.concat(filters.tags_or, ",")
    end

    -- path AND
    for _, p in ipairs(filters.paths) do
        args[#args + 1] = "--path"
        args[#args + 1] = p
    end

    -- date filters
    if filters.created_after then
        args[#args + 1] = "--created-after"
        args[#args + 1] = filters.created_after
    end
    if filters.created_before then
        args[#args + 1] = "--created-before"
        args[#args + 1] = filters.created_before
    end
    if filters.modified_after then
        args[#args + 1] = "--modified-after"
        args[#args + 1] = filters.modified_after
    end
    if filters.modified_before then
        args[#args + 1] = "--modified-before"
        args[#args + 1] = filters.modified_before
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
        if line_count > 20 then break end -- frontmatter는 앞부분에만 있음
    end
    f:close()
    return result
end

-- post-filter: type/area/tags_not 적용
local function post_filter(items, filters)
    if #filters.types_or == 0 and #filters.types_not == 0
        and #filters.areas_or == 0 and #filters.areas_not == 0
        and #filters.tags_not == 0 then
        return items
    end
    local result = {}
    for _, item in ipairs(items) do
        local fm = read_frontmatter(item.file)
        local item_type = fm.type or ""
        local item_area = fm.area or ""
        local item_tags = fm.tags or ""

        -- type OR filter
        if #filters.types_or > 0 then
            local match = false
            for _, t in ipairs(filters.types_or) do
                if item_type == t then match = true; break end
            end
            if not match then goto continue end
        end

        -- type NOT filter
        for _, t in ipairs(filters.types_not) do
            if item_type == t then goto continue end
        end

        -- area OR filter
        if #filters.areas_or > 0 then
            local match = false
            for _, a in ipairs(filters.areas_or) do
                if item_area == a then match = true; break end
            end
            if not match then goto continue end
        end

        -- area NOT filter
        for _, a in ipairs(filters.areas_not) do
            if item_area == a then goto continue end
        end

        -- tags NOT filter
        for _, t in ipairs(filters.tags_not) do
            if item_tags:find(t, 1, true) then goto continue end
        end

        result[#result + 1] = item
        ::continue::
    end
    return result
end

-- active_filters → 타이틀 문자열
local function build_title(filters)
    local parts = {}
    if #filters.tags_or > 0 then
        parts[#parts + 1] = "tag:" .. table.concat(filters.tags_or, "|")
    end
    if #filters.tags_not > 0 then
        parts[#parts + 1] = "tag!:" .. table.concat(filters.tags_not, "|")
    end
    if #filters.types_or > 0 then
        parts[#parts + 1] = "type:" .. table.concat(filters.types_or, "|")
    end
    if #filters.types_not > 0 then
        parts[#parts + 1] = "type!:" .. table.concat(filters.types_not, "|")
    end
    if #filters.areas_or > 0 then
        parts[#parts + 1] = "area:" .. table.concat(filters.areas_or, "|")
    end
    if #filters.areas_not > 0 then
        parts[#parts + 1] = "area!:" .. table.concat(filters.areas_not, "|")
    end
    if #filters.paths > 0 then
        parts[#parts + 1] = "path:" .. table.concat(filters.paths, "&")
    end
    if filters.created_after then parts[#parts + 1] = "created>:" .. filters.created_after end
    if filters.created_before then parts[#parts + 1] = "created<:" .. filters.created_before end
    if filters.modified_after then parts[#parts + 1] = "updated>:" .. filters.modified_after end
    if filters.modified_before then parts[#parts + 1] = "updated<:" .. filters.modified_before end
    if #parts == 0 then return "zk notes" end
    return "zk [" .. table.concat(parts, "  ") .. "]"
end

-- 리스트에서 값 토글 (있으면 제거, 없으면 추가). 변경 여부 반환
local function toggle_value(list, value)
    for i, v in ipairs(list) do
        if v == value then
            table.remove(list, i)
            return true
        end
    end
    list[#list + 1] = value
    return true
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
            items[#items + 1] = {
                text = title .. "  " .. stem,
                file = path,
                title = title,
                stem = stem,
            }
        end
    end
    return post_filter(items, filters)
end

-- 날짜 후보 목록
local date_presets = {
    "today",
    "yesterday",
    "3 days ago",
    "last week",
    "last 2 weeks",
    "last month",
    "last 3 months",
    "this year",
    "Manual input...",
}

local function ask_date(prompt, cb)
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
function M.open(source_buf)
    local meta = read_metadata()

    -- 필터 상태
    local filters = {
        tags_or = {},
        tags_not = {},
        types_or = {},
        types_not = {},
        areas_or = {},
        areas_not = {},
        paths = {},
        created_after = nil,
        created_before = nil,
        modified_after = nil,
        modified_before = nil,
    }

    local picker_ref = nil

    local function refresh_picker()
        if picker_ref then
            picker_ref:set_title(build_title(filters))
            picker_ref:refresh()
        end
    end

    -- picker action 생성 헬퍼
    local function make_select_action(candidates_fn, or_list, not_list, is_not)
        return function(picker)
            picker_ref = picker
            local candidates = candidates_fn()
            if #candidates == 0 then
                vim.notify("후보가 없습니다", vim.log.levels.INFO)
                return
            end
            vim.ui.select(candidates, { prompt = (is_not and "[NOT] " or "") .. "선택:" }, function(choice)
                if not choice then return end
                local target = is_not and not_list or or_list
                toggle_value(target, choice)
                refresh_picker()
            end)
        end
    end

    -- path 계층 탐색 action
    local function path_action(picker)
        picker_ref = picker
        local all_dirs = scan_dirs(notebook)
        if #all_dirs == 0 then return end

        -- 이미 추가된 항목은 "[✓] " prefix
        local display = {}
        for _, d in ipairs(all_dirs) do
            local active = false
            for _, p in ipairs(filters.paths) do
                if p == d then active = true; break end
            end
            display[#display + 1] = (active and "[+] " or "    ") .. d
        end

        vim.ui.select(display, { prompt = "Path (AND):" }, function(choice)
            if not choice then return end
            local raw = choice:gsub("^%[%+%] ", ""):gsub("^%s+", "")
            toggle_value(filters.paths, raw)
            refresh_picker()
        end)
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
        -- 이미 필터에 있는 태그 표시
        local display = {}
        for _, t in ipairs(tags) do
            local active = false
            for _, v in ipairs(filters.tags_or) do
                if v == t then active = true; break end
            end
            display[#display + 1] = (active and "[+] " or "    ") .. t
        end
        vim.ui.select(display, { prompt = "현재 노트 태그 토글:" }, function(choice)
            if not choice then return end
            local raw = choice:gsub("^%[%+%] ", ""):gsub("^%s+", "")
            toggle_value(filters.tags_or, raw)
            refresh_picker()
        end)
    end

    -- 날짜 필터 action
    local function date_action(picker)
        picker_ref = picker
        ask_date("날짜 필터", function(field, direction, value)
            local key = (field == "created" and "created" or "modified") .. "_" .. direction
            filters[key] = value
            refresh_picker()
        end)
    end

    -- finder: zk list 동기 실행 후 table 반환
    local function finder(opts, ctx)
        return run_zk(filters)
    end

    -- picker 열기
    local snacks = require("snacks")
    snacks.picker({
        title = build_title(filters),
        finder = finder,
        format = function(item, _)
            local text = item.title or item.text
            local stem = item.stem or ""
            return {
                { text, "SnacksPickerLabel" },
                { "  " .. stem, "SnacksPickerComment" },
            }
        end,
        preview = "file",
        confirm = function(picker, item)
            picker:close()
            if item and item.file then
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
            end
        end,
        actions = {
            zk_tag_or    = make_select_action(function() return meta.tags or {} end, filters.tags_or, nil, false),
            zk_type_or   = make_select_action(function() return meta.types or {} end, filters.types_or, nil, false),
            zk_area_or   = make_select_action(function() return meta.areas or {} end, filters.areas_or, nil, false),
            zk_tag_not   = make_select_action(function() return meta.tags or {} end, nil, filters.tags_not, true),
            zk_type_not  = make_select_action(function() return meta.types or {} end, nil, filters.types_not, true),
            zk_area_not  = make_select_action(function() return meta.areas or {} end, nil, filters.areas_not, true),
            zk_path      = path_action,
            zk_cur_tags  = current_tags_action,
            zk_date      = date_action,
            zk_clear     = function(picker)
                picker_ref = picker
                filters.tags_or, filters.tags_not = {}, {}
                filters.types_or, filters.types_not = {}, {}
                filters.areas_or, filters.areas_not = {}, {}
                filters.paths = {}
                filters.created_after, filters.created_before = nil, nil
                filters.modified_after, filters.modified_before = nil, nil
                refresh_picker()
            end,
        },
        win = {
            input = {
                keys = {
                    ["<M-1>"] = { "zk_tag_or",   mode = { "i", "n" } },
                    ["<M-2>"] = { "zk_type_or",  mode = { "i", "n" } },
                    ["<M-3>"] = { "zk_area_or",  mode = { "i", "n" } },
                    ["<M-4>"] = { "zk_cur_tags", mode = { "i", "n" } },
                    ["<M-5>"] = { "zk_path",     mode = { "i", "n" } },
                    ["<M-6>"] = { "zk_date",     mode = { "i", "n" } },
                    ["<M-!>"] = { "zk_tag_not",  mode = { "i", "n" } },
                    ["<M-@>"] = { "zk_type_not", mode = { "i", "n" } },
                    ["<M-#>"] = { "zk_area_not", mode = { "i", "n" } },
                    ["<M-0>"] = { "zk_clear",    mode = { "i", "n" } },
                },
            },
        },
    })
end

return M
