local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: zk
local function zk_new_note(is_visual)
    local notebook = vim.env.ZK_NOTEBOOK_DIR or (vim.env.HOME .. "/Documents/zk")
    local types = { "fleeting", "master", "troubleshoot", "reference", "study", "cheatsheet", "plan", "index", "journal", "meeting" }
    local para_roots = { "inbox", "project", "area", "resource", "archive" }
    local has_subdirs = { project = true, area = true, archive = true }

    -- visual mode: 선택 텍스트와 범위를 미리 저장
    local selected_text = nil
    local sel_buf, sel_start_row, sel_start_col, sel_end_row, sel_end_col
    if is_visual then
        selected_text = require("utils").get_visual_text(true)
        sel_buf = vim.api.nvim_get_current_buf()
        -- '<, '> 마크로 선택 범위 확보 (0-indexed)
        local start_pos = vim.api.nvim_buf_get_mark(sel_buf, "<")
        local end_pos = vim.api.nvim_buf_get_mark(sel_buf, ">")
        -- 마크가 유효하지 않으면 (line 0) visual 텍스트만 title로 사용, 링크 삽입 불가
        if start_pos[1] == 0 or end_pos[1] == 0 then
            sel_buf = nil
        else
            sel_start_row = start_pos[1] - 1
            sel_start_col = start_pos[2]
            sel_end_row = end_pos[1] - 1
            -- end col은 마지막 문자 다음 위치
            sel_end_col = end_pos[2]
                + #vim.fn.strcharpart(vim.fn.strpart(vim.api.nvim_buf_get_lines(sel_buf, end_pos[1] - 1, end_pos[1], true)[1], end_pos[2]), 0, 1)
        end
    end

    local function open_vsplit(path)
        local total_width = vim.o.columns
        local new_width = math.floor(total_width * 0.65)
        vim.cmd("vsplit " .. vim.fn.fnameescape(path))
        vim.api.nvim_win_set_width(0, new_width)
    end

    local function create_note(note_type, area, dir, title)
        local abs_dir = notebook .. "/" .. dir
        if vim.fn.isdirectory(abs_dir) == 0 then vim.fn.mkdir(abs_dir, "p") end
        local opts = {
            template = note_type .. ".md",
            dir = dir,
            title = title ~= "" and title or "untitled",
            extra = { type = note_type, area = area },
            edit = false,
        }
        require("zk.api").new(nil, opts, function(err, res)
            assert(not err, tostring(err))
            vim.schedule(function()
                if is_visual and sel_buf then
                    local stem = vim.fn.fnamemodify(res.path, ":t:r")
                    local alias = selected_text or stem
                    local link = "[[" .. stem .. "|" .. alias .. "]]"
                    vim.api.nvim_buf_set_text(sel_buf, sel_start_row, sel_start_col, sel_end_row, sel_end_col, { link })
                end
                open_vsplit(res.path)
            end)
        end)
    end

    local function ask_title(note_type, area, dir)
        if is_visual then
            -- 선택 텍스트가 title이므로 입력 불필요
            create_note(note_type, area, dir, selected_text or "untitled")
        else
            vim.ui.input({ prompt = "Title (empty = untitled): " }, function(title)
                if title == nil then return end
                create_note(note_type, area, dir, title)
            end)
        end
    end

    local function ask_subdir(note_type, area, root)
        local root_path = notebook .. "/" .. root
        local subdirs = {}
        local handle = vim.uv.fs_scandir(root_path)
        if handle then
            while true do
                local name, ftype = vim.uv.fs_scandir_next(handle)
                if not name then break end
                if ftype == "directory" and not name:match("^%.") then subdirs[#subdirs + 1] = name end
            end
        end
        table.sort(subdirs)
        subdirs[#subdirs + 1] = "+ Create New..."

        vim.ui.select(subdirs, { prompt = "디렉토리 선택:" }, function(choice)
            if not choice then return end
            if choice == "+ Create New..." then
                vim.ui.input({ prompt = "새 디렉토리 이름: " }, function(name)
                    if not name or name == "" then return end
                    ask_title(note_type, area, root .. "/" .. name)
                end)
            else
                ask_title(note_type, area, root .. "/" .. choice)
            end
        end)
    end

    -- 현재 버퍼의 디렉토리를 notebook 상대경로로 변환
    local current_dir = nil
    local buf_path = vim.api.nvim_buf_get_name(sel_buf or vim.api.nvim_get_current_buf())
    if buf_path ~= "" then
        local buf_dir = vim.fn.fnamemodify(buf_path, ":h")
        if buf_dir:sub(1, #notebook) == notebook then
            local rel = buf_dir:sub(#notebook + 2) -- leading "/" 제거
            if rel ~= "" then current_dir = rel end
        end
    end

    local location_items = {}
    local display_to_raw = {}

    if current_dir then
        local label = "* current (" .. current_dir .. ")"
        location_items[#location_items + 1] = label
        display_to_raw[label] = current_dir
    end

    for _, r in ipairs(para_roots) do
        local display_name = r:gsub("^%l", string.upper)
        location_items[#location_items + 1] = display_name
        display_to_raw[display_name] = r
    end

    -- metadata.json에서 areas 목록 읽기
    local metadata_path = notebook .. "/.zk/metadata.json"
    local meta_areas = {}
    local f = io.open(metadata_path, "r")
    if f then
        local ok, meta = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if ok and meta and meta.areas then meta_areas = meta.areas end
    end
    local area_items = {}
    for _, a in ipairs(meta_areas) do
        area_items[#area_items + 1] = a
    end
    area_items[#area_items + 1] = "+ New area..."

    vim.ui.select(area_items, { prompt = "Area (empty = personal):" }, function(area_choice)
        if area_choice == nil then return end
        local function continue_with_area(area)
            vim.ui.select(types, { prompt = "Note type:" }, function(note_type)
                if not note_type then return end
                vim.ui.select(location_items, { prompt = "위치 선택:" }, function(choice)
                    if not choice then return end
                    local raw = display_to_raw[choice] or choice
                    if has_subdirs[raw] then
                        ask_subdir(note_type, area, raw)
                    else
                        ask_title(note_type, area, raw)
                    end
                end)
            end)
        end

        if area_choice == "+ New area..." then
            vim.ui.input({ prompt = "새 area 이름 (비우면 personal): " }, function(name)
                if name == nil then return end
                continue_with_area(name ~= "" and name or "personal")
            end)
        else
            continue_with_area(area_choice)
        end
    end)
end

wk_map({
    ["<Space>z"] = {
        group = "Zk",
        order = { "n", "f", "w", "o", "b", "l" },
        ["n"] = {
            function()
                local m = vim.fn.mode()
                local is_visual = m == "v" or m == "V" or m == "\22"
                zk_new_note(is_visual)
            end,
            desc = "새 노트 생성",
            mode = { "n", "v" },
        },
        ["f"] = {
            function()
                local source_buf = vim.api.nvim_get_current_buf()
                require("note_taking.zk_search").open(source_buf)
            end,
            desc = "노트 검색",
            mode = "n",
        },
        ["w"] = {
            function() require("note_taking.zk_search").grep_notes() end,
            desc = "노트 내용 검색",
            mode = "n",
        },
        ["o"] = {
            function() require("note_taking.zk_search").open_recent() end,
            desc = "최근 노트 열기",
            mode = "n",
        },
        ["b"] = {
            "<cmd>ZkBacklinks<CR>",
            desc = "백링크 검색",
            mode = "n",
        },
        ["l"] = {
            function()
                local is_visual = vim.fn.mode() == "v" or vim.fn.mode() == "V"
                require("note_taking.zk_search").insert_link(is_visual)
            end,
            desc = "링크 삽입",
            mode = { "n", "v" },
        },
    },
})

-- MEMO:: Global-Note
wk_map({
    ["<Space>n"] = {
        group = "Note",
        order = { "r", "t", "T", "g" },
        ["g"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note() -- default_note aka. global
            end,
            desc = "open Global Note",
            mode = { "n", "v" },
        },
        ["r"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("project_local")
            end,
            desc = "open Local README.md",
            mode = { "n", "v" },
        },
        ["t"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("project_local_todo")
            end,
            desc = "open Local TODO.md",
            mode = { "n", "v" },
        },
        ["T"] = {
            function()
                local gn = require("global-note")
                gn.close_all_notes()
                gn.toggle_note("global_todo")
            end,
            desc = "open Global TODO.md",
            mode = { "n", "v" },
        },
    },
})
