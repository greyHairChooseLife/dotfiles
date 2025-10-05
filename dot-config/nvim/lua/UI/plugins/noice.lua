return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        {
            "rcarriga/nvim-notify",
            config = function()
                require("notify").setup({
                    -- 필수 필드 추가
                    merge_duplicates = true, -- 또는 false
                    -- 여기에 nvim-notify 설정 추가
                    -- background_colour = "#fff332",
                    timeout = 200,
                    -- max_width = 80,
                    -- 더 많은 설정 옵션은 공식 문서 참조
                })
            end,
        },
    },
    opts = {
        lsp = {
            progress = {
                enabled = false,
            },
            signature = { auto_open = false },
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            },
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        routes = {
            {
                filter = { event = "msg_show", kind = "search_count" },
                opts = { skip = true },
            },
        },
        cmdline = {
            enabled = true, -- enables the Noice cmdline UI
            view = "cmdline", -- view for rendering the cmdline. Set `cmdline` to get a classic cmdline at the bottom or try 'cmdline_popup'
            opts = {}, -- global options for the cmdline. See section on views
            ---@type table<string, CmdlineFormat>
            format = {
                -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                -- view: (default is cmdline view)
                -- opts: any options passed to the view
                -- icon_hl_group: optional hl_group for the icon
                -- title: set to anything or empty string to hide
                -- ex)
                -- cmdline = { pattern = "^:", icon = "", lang = "vim" },
                -- search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                -- search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                cmdline = { lang = "vim", icon = "", conceal = false },
                search_down = { kind = "search", icon = "", lang = "regex", conceal = false },
                search_up = { kind = "search", icon = "", lang = "regex", conceal = false },
            },
        },
        messages = {
            view = "mini",
        },
        views = {
            cmdline_popup = {
                position = {
                    row = "50%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
                border = {
                    -- style = require("utils").borders.full,
                    style = "rounded",
                    padding = { 0, 0 },
                },
                filter_options = {},
                win_options = {
                    -- winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                },
            },
        },
    },
}
