-- Lualine components and configuration
local M = {}

M.colors = {
    normalBG = "#24283b", -- normal bg color
    -- git
    gitAdd = "#40cd52",
    gitChange = "#ffcc00",
    gitDelete = "#f1502f",
    -- colors
    black1 = "#000000",
    black2 = "#282c34",
    black3 = "#333342",
    black4 = "#8b8378",
    black5 = "#abb2bf",
    white1 = "#ffffff",
    blue1 = "#0020fc",
    blue2 = "#61afef",
    green1 = "#98c379",
    orange1 = "#FF8C00",
    orange2 = "#cd853f",
    purple1 = "#A020F0",
    purple2 = "#c678dd",
    red1 = "#DC143C",
    yellow1 = "#ffff00",
    -- plugin specific
    warpBG = "#f1502f",
    termBG = "#0c0c0c",
    noteBG = "#242024", -- note bg color
    qfBG = "#201010",
    qfFG = "#db4b4b",
    nvimtreeBG = "#333342",
    oilBG = "#1A1601",
    oilFG = "#BDB80B",
}

M.theme = {
    normal = {
        a = { fg = M.colors.orange1, bg = M.colors.normalBG },
        b = { fg = M.colors.orange1, bg = M.colors.normalBG },
        c = { fg = M.colors.orange1, bg = M.colors.normalBG },
        x = { fg = M.colors.orange1, bg = M.colors.normalBG },
        y = { fg = M.colors.orange1, bg = M.colors.normalBG },
        z = { fg = M.colors.orange1, bg = M.colors.normalBG },
    },
    inactive = {
        a = { fg = M.colors.black3, bg = M.colors.normalBG },
        b = { fg = M.colors.black3, bg = M.colors.normalBG },
        c = { fg = M.colors.black3, bg = M.colors.normalBG },
        x = { fg = M.colors.black3, bg = M.colors.normalBG },
        y = { fg = M.colors.black3, bg = M.colors.normalBG },
        z = { fg = M.colors.black3, bg = M.colors.normalBG },
    },
}

-- Helper functions for lualine components

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
    return "branch: " .. branch:gsub("%s+", "")
end

function M.this_is_fugitive() return "- Fugitive -" end

function M.harpoon_length()
    -- get the length of the harpoon list
    -- local items = require("harpoon"):list():length()
    local items = require("warp").count()
    if items == 0 then
        return ""
    else
        return "󰀱  " .. items
    end
end

function M.winfix_status()
    if vim.wo.winfixwidth and vim.wo.winfixheight then
        return "   " -- 🔒 고정 표시
    else
        return ""
    end
end

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
            color = { bg = color },
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
                color = { bg = M.colors.white1, fg = M.colors.termBG, gui = "bold,italic" },
                padding = { left = 1, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.termBG, fg = M.colors.white1, gui = "italic" },
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
                color = { bg = M.colors.qfFG, fg = M.colors.white1, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.qfFG, fg = M.colors.white1, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
        lualine_b = M.fill_color(M.colors.qfBG),
    },
}

M.my_nvimTree = {
    filetypes = { "NvimTree" },
    sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.nvimtreeBG, fg = M.colors.orange1, gui = "bold,italic" },
                padding = { left = 2 },
                separator = { right = "" },
            },
        },
        lualine_b = {
            {
                "",
                color = { bg = M.colors.nvimtreeBG, fg = M.colors.nvimtreeBG, gui = "bold,italic" },
            },
        },
        lualine_c = {
            {
                "",
                color = { bg = M.colors.nvimtreeBG, fg = M.colors.nvimtreeBG, gui = "bold,italic" },
            },
        },
        lualine_x = {
            {
                M.harpoon_length,
                color = { bg = M.colors.normalBG, fg = M.colors.warpBG, gui = "bold,italic" },
                padding = { right = 2 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.nvimtreeBG, fg = M.colors.orange1, gui = "bold,italic" },
                padding = { left = 2 },
                separator = { right = "" },
            },
        },
        lualine_x = {
            {
                M.harpoon_length,
                color = { bg = M.colors.nvimtreeBG, fg = M.colors.warpBG, gui = "bold,italic" },
                padding = { right = 2 },
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
                color = { bg = M.colors.orange1, fg = M.colors.black2, gui = "bold" },
                padding = { left = 1, right = 5 },
            },
        },
        -- lualine_z = { { M.this_is_fugitive, color = { bg = M.colors.orange, fg = M.colors.bblack } } },
    },
    inactive_sections = {
        lualine_a = {
            {
                M.get_git_branch,
                color = { bg = M.colors.orange1, fg = M.colors.black2, gui = "bold" },
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
                color = { bg = M.colors.oilFG, fg = M.colors.black2, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                "filetype",
                color = { bg = M.colors.oilFG, fg = M.colors.black2, gui = "bold,italic" },
                padding = { left = 3, right = 5 },
                -- separator = { right = " " },
            },
        },
        lualine_b = M.fill_color(M.colors.oilBG),
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
                color = { fg = M.colors.orange1, bg = M.colors.noteBG, gui = "italic" },
                padding = { left = 2, right = 0 },
            },
            {
                codecompanion_adapter_name,
                color = { fg = M.colors.orange2, bg = M.colors.noteBG, gui = "italic" },
                padding = { left = 1, right = 5 },
            },
            {
                require("AI.codecompanion.utils.lualine_component.active"),
                color = { fg = M.colors.orange1, bg = M.colors.noteBG },
            },
        },
    },
    inactive_sections = {
        lualine_a = {
            {
                codecompanion_current_model_name,
                color = { fg = M.colors.orange1, bg = M.colors.noteBG, gui = "italic" },
                padding = { left = 2, right = 0 },
            },
            {
                codecompanion_adapter_name,
                color = { fg = M.colors.orange2, bg = M.colors.noteBG, gui = "italic" },
                padding = { left = 1, right = 5 },
            },
            {
                require("AI.codecompanion.utils.lualine_component.inactive"),
                color = { fg = M.colors.orange1, bg = M.colors.noteBG },
            },
        },
    },
}
return M
