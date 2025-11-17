-- https://github.com/chentoast/marks.nvim
return {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {},
    configs = function()
        require("marks").setup({
            -- whether to map keybinds or not. default true
            default_mappings = false,
            -- which builtin marks to show. default {}
            builtin_marks = {}, -- { ".", "<", ">", "^" },
            -- whether movements cycle back to the beginning/end of buffer. default true
            cyclic = true,
            -- whether the shada file is updated after modifying uppercase marks. default false
            force_write_shada = false,
            -- how often (in ms) to redraw signs/recompute mark positions.
            -- higher values will have better performance but may cause visual lag,
            -- while lower values may cause performance penalties. default 150.
            refresh_interval = 150,
            -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
            -- marks, and bookmarks.
            -- can be either a table with all/none of the keys, or a single number, in which case
            -- the priority applies to all marks.
            -- default 10.
            sign_priority = { lower = 10, upper = 15, builtin = 0, bookmark = 20 },
            -- disables mark tracking for specific filetypes. default {}
            excluded_filetypes = {},
            -- disables mark tracking for specific buftypes. default {}
            excluded_buftypes = {},
            -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
            -- sign/virttext. Bookmarks can be used to group together positions and quickly move
            -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
            -- default virt_text is "".
            bookmark_0 = {
                sign = "⚑",
                virt_text = "hello world",
                -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
                -- defaults to false.
                annotate = false,
            },
            mappings = {
                -- set_next = "mj", -- Set next available lowercase mark at cursor.
                -- toggle = "mk", -- Toggle next available mark at cursor.
                -- delete_line = "dmm", -- Deletes all marks on current line.
                -- -- delete_buf             -- Deletes all marks in current buffer.
                -- next = "mJ", -- Goes to next mark in buffer.
                -- prev = "mK", -- Goes to previous mark in buffer.
                -- -- preview                -- Previews mark (will wait for user input). press <cr> to just preview the next mark.
                -- set = "m", -- Sets a letter mark (will wait for input).
                -- delete = "mk", -- Delete a letter mark (will wait for input).
                -- --
                -- set_bookmark0 = "m0",
                -- set_bookmark1 = "m1",
                -- -- set_bookmark[0-9]      -- Sets a bookmark from group[0-9].
                -- -- delete_bookmark[0-9]   -- Deletes all bookmarks from group[0-9].
                -- -- delete_bookmark        -- Deletes the bookmark under the cursor.
                -- -- next_bookmark          -- Moves to the next bookmark having the same type as the
                -- --                        -- bookmark under the cursor.
                -- -- prev_bookmark          -- Moves to the previous bookmark having the same type as the
                -- --                        -- bookmark under the cursor.
                -- -- next_bookmark[0-9]     -- Moves to the next bookmark of the same group type. Works by
                -- --                        -- first going according to line number, and then according to buffer
                -- --                        -- number.
                -- -- prev_bookmark[0-9]     -- Moves to the previous bookmark of the same group type. Works by
                -- --                        -- first going according to line number, and then according to buffer
                -- --                        -- number.
                -- -- annotate               -- Prompts the user for a virtual line annotation that is then placed
                -- --                        -- above the bookmark. Requires neovim 0.6+ and is not mapped by default.
            },
        })
    end,
}

-- return {
--     "2kabhishek/markit.nvim",
--     dependencies = { "2kabhishek/pickme.nvim", "nvim-lua/plenary.nvim" },
--     opts = {}, -- Add your configuration here, required if you are not calling markit.setup manually elsewhere
--     event = { "BufReadPre", "BufNewFile" },
--     configs = function()
--         require("markit").setup({
--             -- whether to add comprehensive default keybindings. default true
--             add_default_keybindings = false,
--             -- which builtin marks to show. default {}
--             builtin_marks = {}, -- { ".", "<", ">", "^" },
--             -- whether movements cycle back to the beginning/end of buffer. default true
--             cyclic = true,
--             -- whether the shada file is updated after modifying uppercase marks. default false
--             force_write_shada = false,
--             -- how often (in ms) to redraw signs/recompute mark positions.
--             -- higher value means better performance but may cause visual lag,
--             -- while lower value may cause performance penalties. default 150.
--             refresh_interval = 10,
--             -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
--             -- marks, and bookmarks.
--             -- can be either a table with all/none of the keys, or a single number, in which case
--             -- the priority applies to all marks.
--             -- default 10.
--             sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
--             -- disables mark tracking for specific filetypes. default {}
--             excluded_filetypes = {},
--             -- disables mark tracking for specific buftypes. default {}
--             excluded_buftypes = {},
--             -- whether to enable the bookmark system. when disabled, improves startup performance, default true
--             enable_bookmarks = true,
--             -- bookmark groups configuration (only used when enable_bookmarks = true)
--             bookmarks = {
--                 {
--                     sign = "⚑", -- string: sign character to display (empty string to disable)
--                     virt_text = "hello", -- string: virtual text to show at end of line
--                     annotate = false, -- boolean: whether to prompt for annotation when setting bookmark
--                 },
--                 { sign = "!", virt_text = "", annotate = false },
--                 { sign = "@", virt_text = "", annotate = true },
--             },
--         })
--     end,
-- }
