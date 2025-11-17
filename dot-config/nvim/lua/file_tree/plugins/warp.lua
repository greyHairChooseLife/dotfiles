-- https://github.com/y3owk1n/warp.nvim
return {
    "y3owk1n/warp.nvim",
    version = "*", -- remove this if you want to use the `main` branch
    event = "VeryLazy",
    cmd = {
        "WarpAddFile",
        "WarpAddOnScreenFiles",
        "WarpDelFile",
        "WarpMoveTo",
        "WarpShowList",
        "WarpClearCurrentList",
        "WarpClearAllList",
        "WarpGoToIndex",
    },
    opts = {

        keymaps = {
            quit = { "gq", "<Esc>" }, -- quit the warp selection window
            select = { "<CR>" }, -- select the file in the warp selection window
            delete = { "dd" }, -- delete the file in the warp selection window
            move_up = { "<C-k>" }, -- move an item up in the warp selection window
            move_down = { "<C-j>" }, -- move an item down in the warp selection window
            split_horizontal = { "<C-s>" }, -- horizontal split
            split_vertical = { "<C-v>" }, -- vertical split
            show_help = { "g?" }, -- show the help menu
        },
        -- [window] window configurations
        window = {
            -- [window.list] window configurations for the list window
            -- can be a table of `win_config` or a function that takes a list of lines and returns a `win_config`
            list = {
                border = "rounded",
                title = "",
                title_pos = "right",
                col = 999,
                row = 1,
            },
            -- [window.help] window configurations for the help window
            -- can be a table of `win_config` or a function that takes a list of lines and returns a `win_config`
            help = {},
        },
        hl_groups = {
            --- list window hl
            list_normal = { link = "WarpNormal" },
            list_border = { link = "WarpFloatBorder" },
            list_title = { link = "FloatTitle" },
            list_footer = { link = "FloatFooter" },
            list_cursor_line = { link = "CursorLine" },
            list_item_active = { link = "WarpAdded" },
            list_item_error = { link = "Error" },
            --- help window hl
            help_normal = { link = "Normal" },
            help_border = { link = "FloatBorder" },
            help_title = { link = "FloatTitle" },
            help_footer = { link = "FloatFooter" },
            help_cursor_line = { link = "CursorLine" },
        },
    },
}
