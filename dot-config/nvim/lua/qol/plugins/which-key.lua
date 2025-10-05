return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        win = {
            border = "none",
            height = { max = 25 },
            padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
        },
        icons = {
            separator = "", -- symbol used between a key and it's label
            group = "󰇘 ",
            mappings = false,
        },
        show_help = false, -- show a help message in the command line for using WhichKey
        show_keys = false, -- show the currently pressed key and its label as a message in the command line
        -- disable WhichKey for certain buf types and file types.
        disable = {
            ft = {},
            bt = {},
        },
        filter = function(mapping)
            -- 조건:
            -- 1. group 요소가 있는 경우
            -- 2. desc에 아이콘 ➜ 가 있는 경우
            return mapping.group or mapping.desc and mapping.desc:find("➜")
        end,

        ---@type (string|wk.Sorter)[]
        --- Mappings are sorted using configured sorters and natural sort of the keys
        --- Available sorters: ... help doc
        sort = { "manual", "alphanum" },

        ---@type number|fun(node: wk.Node):boolean?
        expand = function(node)
            local valid_descriptions = { "expand", "command" } -- 허용된 값 목록

            -- 특정 값이 `node.desc`에 포함되어 있는지 확인
            for _, desc in ipairs(valid_descriptions) do
                if node.group and node.desc == desc then return true end
            end

            return false
        end, -- expand groups when <= n mappings
        -- expand = function(node)
        --   return not node.desc -- expand all nodes without a description
        -- end,

        -- which-key triggers
        -- 'which-key triggers'를 찾아 prefix에 해당하는 것을 등록한다.
        triggers = {
            { "<leader>", mode = { "n", "v" } }, -- 코딩 외부 작업
            { "<Space>", mode = { "n", "v" } }, -- 코딩 내부 작업
            { ",", mode = { "n", "v" } }, -- 즉시 실행
        },

        plugins = {
            marks = false, -- shows a list of your marks on ' and `
            registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            -- the presets plugin, adds help for a bunch of default keybindings in Neovim
            -- No actual key bindings are created
            spelling = {
                enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                suggestions = 20, -- how many suggestions should be shown in the list?
            },
            presets = {
                operators = false, -- adds help for operators like d, y, ...
                motions = false, -- adds help for motions
                text_objects = false, -- help for text objects triggered after entering an operator
                windows = false, -- default bindings on <c-w>
                nav = false, -- misc bindings to work with windows
                z = false, -- bindings for folds, spelling and others prefixed with z
                g = false, -- bindings for prefixed with g
            },
        },
    },
}
