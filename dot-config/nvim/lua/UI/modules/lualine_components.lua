-- Lualine components and configuration
local M = {}

-- Colors follow the day/night palette (UI/palette.lua). The module is reloaded
-- by UI/theme.lua on a theme switch, so every table below is rebuilt then.
local p = require("UI.palette").get()

M.colors = {
    warp = p.warp,
    real_blue = p.blue_flag,
    blue = p.blue3,
    git_add = p.git_add,
    git_change = p.git_change,
    git_delete = p.warp,
    greenbg = p.green,
    purple = p.purple,
    orange = p.orange,
    orange_deep = p.orange_deep,
    wwhite = p.fg_soft2,
    white = p.on_accent,
    bblack = p.bg_note,
    black = p.black,
    term_chip = p.bg_term_chip,
    term_chip_fg = p.fg_term_chip,
    grey = p.bg_tree,
    bg = p.bg_bar, -- statusline / inactive surface
    bar_accent = p.bar_accent, -- active section anchor
    fg_on_chip = p.fg_on_chip,
    bg2 = p.bg_note, -- this is note bg color
    active_qf = p.red_active,
    qf_bg = p.bg_qf,
    nvimTree = p.bg_tree,
    active_oil = p.oil_tag,
    oil_bg = p.bg_oil,
    purple1 = p.purple_bright,
    red2 = p.red_crimson,
    search = p.search_bg,
    sepNC = p.fg_dim,
}

-- Section colors for every mode. Missing mode entries make lualine fall back to
-- the mapped section of `normal` (z -> a, x -> c), and `normal.a` is
-- orange-on-orange, which makes the `lualine_z` components (location, progress)
-- invisible in visual/insert mode.
local function mode_sections()
    return {
        a = { fg = M.colors.bar_accent, bg = M.colors.bar_accent },
        b = { fg = M.colors.bar_accent, bg = M.colors.bg },
        c = { fg = M.colors.bar_accent, bg = M.colors.bg },
        x = { fg = M.colors.bar_accent, bg = M.colors.bar_accent },
        y = { fg = M.colors.bar_accent, bg = M.colors.bg },
        z = { fg = M.colors.bg, bg = M.colors.bar_accent },
    }
end

M.theme = {
    normal = mode_sections(),
    insert = mode_sections(),
    visual = mode_sections(),
    replace = mode_sections(),
    command = mode_sections(),
    terminal = mode_sections(),
    inactive = {
        a = { fg = M.colors.wwhite, bg = M.colors.bg },
        b = { fg = M.colors.wwhite, bg = M.colors.bg },
        c = { fg = M.colors.bar_accent, bg = M.colors.bg },
        x = { fg = M.colors.bar_accent, bg = M.colors.bg },
        y = { fg = M.colors.bar_accent, bg = M.colors.bg },
        z = { fg = M.colors.wwhite, bg = M.colors.bg },
    },
}

function M.search_counter()
    local sc = vim.fn.searchcount({ maxcount = 9999 })
    -- 검색이 활성화(total > 0)되어 있고 하이라이트가 켜져있을 때만 표시합니다.
    if sc.total > 0 and vim.v.hlsearch == 1 then return string.format("search: %d/%d", sc.current, sc.total) end
    return ""
end

function M.get_git_branch()
    -- 현재 디렉토리가 Git 저장소인지 확인
    local git_dir = vim.fn.finddir(".git", ".;")
    if git_dir == "" then
        return "no git" -- Git 저장소가 아니면 빈 문자열 반환
    end

    -- 현재 Git 브랜치를 가져옴
    local handle = io.popen("git branch --show-current 2>/dev/null")
    if not handle then return "git error" end

    local branch = handle:read("*a")
    if not branch then
        handle:close()
        return "git error"
    end

    handle:close()

    -- 줄바꿈 제거하고 브랜치 이름 반환
    return " " .. branch:gsub("%s+", "")
end

function M.get_cwd()
    -- 현재 작업 디렉토리를 가져옴
    local cwd = vim.fn.getcwd()
    if not cwd or cwd == "" then return "no cwd" end

    -- 홈 디렉토리를 가져옴
    local home = vim.fn.expand("~")

    -- cwd가 홈 디렉토리 내에 있으면 ~로 표시
    if cwd:sub(1, #home) == home then cwd = "~" .. cwd:sub(#home + 1) end

    return cwd
end

function M.harpoon_length()
    local items = require("warp").count()
    return (items and items ~= 0) and ("󰀱  " .. items) or ""
end

function M.winfix_status() return vim.wo.winfixwidth and vim.wo.winfixheight and "" or "" end

--- Is the buffer shown in the drawn window part of the warp list?
--- lualine draws every statusline inside `nvim_win_call`, so `%` is the window
--- being drawn, not the focused one.
function M.is_warp_buf()
    local ok, warp = pcall(require, "warp")
    if not ok then return false end
    return warp.get_item_by_buf(vim.fn.bufnr("%")) ~= nil
end

--- Two components with static colors: one for warp buffers, one for the rest.
--- Do not use a `color` function for per-window colors. lualine keeps one
--- highlight group per component and re-defines it on every draw, so the last
--- drawn window's colors apply to every other window sharing that group, which
--- turns the inactive statuslines of the whole tab red.
---@param component table component spec without `cond` and `color`
---@param warp_color table color for buffers in the warp list
---@param normal_color table color for all other buffers
function M.warp_variants(component, warp_color, normal_color)
    local function variant(cond, color) return vim.tbl_extend("keep", { cond = cond, color = color }, component) end
    return {
        variant(M.is_warp_buf, warp_color),
        variant(function() return not M.is_warp_buf() end, normal_color),
    }
end

--- Buffer name for the statusline.
--- Long names are middle truncated (extension kept) so that the right side of
--- the bar (line:col, progress) is not pushed out of a narrow window.
---@param reserve number columns kept free for the rest of the statusline
function M.filename(reserve)
    local name = vim.fn.expand("%:t")
    if name == "" then name = "New" end

    local max = math.max(12, vim.api.nvim_win_get_width(0) - reserve)
    if vim.fn.strdisplaywidth(name) <= max then return name end

    local ext = name:match("%.[%w_%-]+$") or ""
    local keep = max - vim.fn.strdisplaywidth(ext) - 1
    if keep < 4 then return vim.fn.strcharpart(name, 0, math.max(4, max - 1)) .. "…" end
    return vim.fn.strcharpart(name, 0, keep) .. "…" .. ext
end

function M.register_recording()
    local register = vim.fn.reg_recording()
    if #register > 0 then
        return "<rec> ... @" .. register
    else
        return ""
    end
end

function M.jump_pending()
    if vim.g.jump_pending then
        return "`mark"
    else
        return ""
    end
end

function M.fill_color(color)
    return {
        {
            function() return "" end,
            draw_empty = true,
            color = { bg = color, fg = color },
            -- color = { fg = color, bg = color },
        },
    }
end

function M.fill_color2(fgColor, bgColor, left, right, padding)
    return {
        {
            function()
                local total_width = vim.api.nvim_win_get_width(0) -- Current window width
                local leftLen = #left() -- Estimate for lualine_a (adjust based on content)
                local rightLen = #right() -- Estimate for lualine_z (adjust based on content)
                local filler_width = math.max(0, total_width - leftLen - rightLen - padding + 1)
                -- Snacks.debug.inspect('t' .. total_width .. 'a' .. a_width .. 'z' .. z_width .. 'fil' .. filler_width)
                return string.rep(" ", filler_width)
            end,
            color = { fg = fgColor, bg = bgColor },
        },
    }
end

-- Custom sections for different filetypes
M.my_terminal = {
    filetypes = { "terminal" },
    sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.term_chip, fg = M.colors.term_chip_fg, gui = "bold,italic" },
                padding = { left = 1, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.term_chip_fg, fg = M.colors.term_chip, gui = "italic" },
                padding = { left = 1, right = 5 },
            },
        },
    },
}

M.my_quickfix = {
    filetypes = { "qf" },
    sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.active_qf, fg = M.colors.white, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.active_qf, fg = M.colors.white, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
        lualine_b = M.fill_color(M.colors.qf_bg),
    },
}

M.my_nvimTree = {
    filetypes = { "NvimTree" },
    sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 2, right = 2 },
            },
        },
        lualine_b = M.fill_color2(M.colors.orange, M.colors.orange, M.get_git_branch, M.harpoon_length, 6),
        lualine_z = {
            {
                M.harpoon_length,
                color = { bg = M.colors.warp, fg = M.colors.bblack, gui = "bold,italic" },
                padding = { left = 2, right = 2 },
                -- separator = { left = "  " },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.nvimTree, fg = M.colors.orange, gui = "bold,italic" },
                padding = { left = 2, right = 2 },
                separator = { right = "  " },
            },
        },
        lualine_b = M.fill_color2(M.colors.grey, M.colors.grey, M.get_git_branch, M.harpoon_length, 6),
        lualine_x = {
            {
                M.harpoon_length,
                color = { bg = M.colors.nvimTree, fg = M.colors.warp, gui = "bold,italic" },
                padding = { left = 2, right = 2 },
            },
        },
    },
}

M.my_fugitive = {
    filetypes = { "fugitive" },
    sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 3, right = 3 },
                separator = { right = "" },
            },
        },
        lualine_b = M.fill_color2(M.colors.bg2, M.colors.bg2, M.get_git_branch, function() return "- fugitive -" end, 11),
        lualine_z = {
            {
                function() return "- fugitive -" end,
                color = { fg = M.colors.orange, bg = M.colors.bg2 },
                padding = { left = 2, right = 2 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { fg = M.colors.orange, bg = M.colors.bg2, gui = "bold" },
                padding = { left = 1, right = 5 },
                -- separator = { right = "" },
            },
        },
        lualine_b = M.fill_color(M.colors.bg2),
    },
}

M.my_oil = {
    filetypes = { "oil" },
    sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.active_oil, fg = M.colors.bblack, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.active_oil, fg = M.colors.bblack, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
                -- separator = { right = " " },
            },
        },
        lualine_b = M.fill_color(M.colors.oil_bg),
    },
}

local function codecompanion_current_model_name()
    local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
    if not chat then return nil end

    return chat.settings.model
end

local function codecompanion_adapter_name()
    local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
    if not chat then return nil end

    -- REF: for debugging
    -- print(vim.inspect(chat))

    local win_len = vim.api.nvim_win_get_width(0)
    local spinner_len = 24
    local adapter_name = (chat.adapter and chat.adapter.formatted_name) or ""
    local model_name = chat.settings.model or ""

    local padding_len = win_len - #adapter_name - #model_name - spinner_len - 15

    return "(" .. adapter_name .. ")" .. string.rep(" ", math.max(0, padding_len))
end

M.my_codecompanion = {
    filetypes = { "codecompanion" },
    sections = {
        lualine_a = {
            {
                codecompanion_current_model_name,
                color = { fg = M.colors.orange, bg = M.colors.bg2, gui = "italic" },
                padding = { left = 2, right = 0 },
            },
            {
                codecompanion_adapter_name,
                color = { fg = M.colors.orange_deep, bg = M.colors.bg2, gui = "italic" },
                padding = { left = 1, right = 5 },
            },
            {
                require("AI.codecompanion.utils.lualine_component.active"),
                color = { fg = M.colors.orange, bg = M.colors.bg2 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                codecompanion_current_model_name,
                color = { fg = M.colors.orange, bg = M.colors.bg2, gui = "italic" },
                padding = { left = 2, right = 0 },
            },
            {
                codecompanion_adapter_name,
                color = { fg = M.colors.orange_deep, bg = M.colors.bg2, gui = "italic" },
                padding = { left = 1, right = 5 },
            },
            {
                require("AI.codecompanion.utils.lualine_component.inactive"),
                color = { fg = M.colors.orange, bg = M.colors.bg2 },
            },
        },
    },
}

return M
