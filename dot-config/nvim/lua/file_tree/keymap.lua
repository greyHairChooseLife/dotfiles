local wk_map = require("utils").wk_map

-- MEMO:: Directory
wk_map({
    ["<Space>f"] = {
        group = "FileTree  - NvimTree",
        order = { "f", "t" },
        ["f"] = { "<cmd>NvimTreeFocus<CR>", desc = "focus", mode = "n" },
        ["t"] = { ToggleTree, desc = "toggle ", mode = "n" },
    },
})

-- MEMO: warp.nvim
wk_map({
    ["<Space>h"] = {
        group = "Harpoon",
        order = { "h", "a", "A", "d", "c", "1", "2", "3", "4", "5" },
        ["h"] = {
            function() require("warp").show_list() end,
            desc = "open",
            mode = "n",
        },
        ["a"] = {
            function()
                require("warp").add()
                vim.notify("Harpoon Added", 2, { render = "minimal" })
            end,
            desc = "add",
            mode = "n",
        },
        ["A"] = {
            function()
                require("warp").add_all_onscreen()
                vim.notify("Harpoon All Added", 2, { render = "minimal" })
            end,
            desc = "add all",
            mode = "n",
        },
        ["d"] = {
            function()
                require("warp").del()
                vim.notify("harpoon Deleted", 3, { render = "minimal" })
            end,
            desc = "delete",
            mode = "n",
        },
        ["c"] = {
            function()
                require("warp").clear_current_list() -- clear_all_list
                vim.notify("harpoon Cleared", 3, { render = "minimal" })
            end,
            desc = "clear",
            mode = "n",
        },
        ["1"] = {
            function()
                local count = require("warp").count()
                if count < 1 then
                    vim.notify("No such Idx harpoon", 3, { render = "minimal" })
                    return
                end
                require("warp").goto_index(1)
                vim.notify("harpoon One", 2, { render = "minimal" })
            end,
            desc = "Entry 1",
            mode = "n",
        },
        ["2"] = {
            function()
                local count = require("warp").count()
                if count < 2 then
                    vim.notify("No such Idx harpoon", 3, { render = "minimal" })
                    return
                end
                require("warp").goto_index(2)
                vim.notify("harpoon Two", 2, { render = "minimal" })
            end,
            desc = "Entry 2",
            mode = "n",
        },
        ["3"] = {
            function()
                local count = require("warp").count()
                if count < 3 then
                    vim.notify("No such Idx harpoon", 3, { render = "minimal" })
                    return
                end
                require("warp").goto_index(3)
                vim.notify("harpoon Three", 2, { render = "minimal" })
            end,
            desc = "Entry 3",
            mode = "n",
        },
        ["4"] = {
            function()
                local count = require("warp").count()
                if count < 4 then
                    vim.notify("No such Idx harpoon", 3, { render = "minimal" })
                    return
                end
                require("warp").goto_index(4)
                vim.notify("harpoon Four", 2, { render = "minimal" })
            end,
            desc = "Entry 4",
            mode = "n",
        },
        ["5"] = {
            function()
                local count = require("warp").count()
                if count < 4 then
                    vim.notify("No such Idx harpoon", 3, { render = "minimal" })
                    return
                end
                require("warp").goto_index(5)
                vim.notify("harpoon Five", 2, { render = "minimal" })
            end,
            desc = "Entry 5",
            mode = "n",
        },
    },
})

local map = vim.keymap.set
local opt = { noremap = true, silent = true }

---@alias Warp.Config.MoveDirection
---| '"prev"'
---| '"next"'
---| '"first"'
---| '"last"'

-- map("n", "kK", function()
--     require("warp").goto_index("first")
--     print("harpoon First")
-- end, opt)
--
-- map("n", "kk", function()
--     local bufnr = vim.fn.bufnr("%")
--     local curr = require("warp").get_item_by_buf(bufnr)
--     vim.notify("harpoon: " .. curr.index, 3, { render = "wrapped-compact", minimum_width = 5, max_width = 5 })
--
--     require("warp").goto_index("prev")
--     print("harpoon Prev")
-- end, opt)
--
-- map("n", "jj", function()
--     require("warp").goto_index("next")
--     print("harpoon Next")
-- end, opt)
--
-- map("n", "jJ", function()
--     require("warp").goto_index("last")
--     print("harpoon Last")
-- end, opt)

-- map("n", "j1", function() require("warp").goto_index(1) end, opt)
-- map("n", "j2", function() require("warp").goto_index(2) end, opt)
-- map("n", "j3", function() require("warp").goto_index(3) end, opt)
-- map("n", "j4", function() require("warp").goto_index(4) end, opt)
-- map("n", "j5", function() require("warp").goto_index(5) end, opt)

-- map("n", "jj", function() require("warp").move_to("next") end, opt)
-- map("n", "jJ", function() require("warp").move_to("last") end, opt)
