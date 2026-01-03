-- Lualine components and configuration
local M = {}

M.colors = {
    warp = "#f1502f",
    real_blue = "#0020fc",
    blue = "#61afef",
    git_add = "#40cd52",
    git_change = "#ffcc00",
    git_delete = "#f1502f",
    greenbg = "#98c379",
    purple = "#c678dd",
    orange = "#FF8C00",
    orange_deep = "#cd853f",
    wwhite = "#abb2bf",
    white = "#ffffff",
    bblack = "#282c34",
    black = "#000000",
    terminal_bg = "#0c0c0c",
    grey = "#333342",
    bg = "#24283b",
    bg2 = "#242024", -- this is note bg color
    active_qf = "#db4b4b",
    qf_bg = "#201010",
    nvimTree = "#333342",
    active_oil = "#BDB80B",
    oil_bg = "#1A1601",
    purple1 = "#A020F0",
    red2 = "#DC143C",
    search = "#ffff00",
    sepNC = "#5F5F5F",
}

M.theme = {
    normal = {
        a = { fg = M.colors.orange, bg = M.colors.orange },
        b = { fg = M.colors.orange, bg = M.colors.bg },
        c = { fg = M.colors.orange, bg = M.colors.bg },
        x = { fg = M.colors.orange, bg = M.colors.orange },
        y = { fg = M.colors.orange, bg = M.colors.bg },
        z = { fg = M.colors.bg, bg = M.colors.orange },
    },
    inactive = {
        a = { fg = M.colors.wwhite, bg = M.colors.bg },
        b = { fg = M.colors.wwhite, bg = M.colors.bg },
        c = { fg = M.colors.orange, bg = M.colors.bg },
        x = { fg = M.colors.orange, bg = M.colors.bg },
        y = { fg = M.colors.orange, bg = M.colors.bg },
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

function M.register_recording()
    local register = vim.fn.reg_recording()
    if #register > 0 then
        return "<rec> ... @" .. register
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
                color = { bg = M.colors.white, fg = M.colors.terminal_bg, gui = "bold,italic" },
                padding = { left = 1, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.terminal_bg, fg = M.colors.white, gui = "italic" },
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
        lualine_b = M.fill_color2("#242024", "#242024", M.get_git_branch, function() return "- fugitive -" end, 11),
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
        lualine_b = M.fill_color("#242024"),
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
    local adapter_name = chat.adapter.formatted_name
    local model_name = chat.settings.model

    local padding_len = win_len - #adapter_name - #model_name - spinner_len - 15

    return "(" .. adapter_name .. ")" .. string.rep(" ", padding_len)
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

M.my_sidekick = {
    filetypes = { "sidekick_terminal" },
    sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 1, right = 1 },
            },
        },
        lualine_b = {
            {
                M.get_cwd,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 1, right = 1 },
            },
        },
        lualine_c = M.fill_color2(M.colors.black, M.colors.black, M.get_git_branch, M.get_cwd, 19),
        lualine_x = {
            {
                function()
                    local status = require("sidekick.status").cli()
                    return "  ✖️  ✖️ " .. (#status > 1 and #status or "")
                end,
                cond = function() return #require("sidekick.status").cli() > 0 end,
                color = function() return { fg = M.colors.orange, bg = M.colors.black } end,
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 1, right = 1 },
            },
        },
        lualine_b = {
            {
                M.get_cwd,
                color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
                padding = { left = 1, right = 1 },
            },
        },
        lualine_c = M.fill_color2(M.colors.black, M.colors.black, M.get_git_branch, M.get_cwd, 35),
        lualine_z = {
            {
                function()
                    local status = require("sidekick.status").cli()
                    return " (claude code) ✖️  (neovim) ✖️ (tmux)" .. (#status > 1 and #status or "")
                end,
                cond = function() return #require("sidekick.status").cli() > 0 end,
                color = function() return { fg = M.colors.wwhite, bg = M.colors.black } end,
            },
        },
    },
}

return M
