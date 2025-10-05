return {
    "ThePrimeagen/harpoon",
    lazy = false,
    -- event = "VeryLazy",
    enabled = false,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- REQUIRED
        harpoon:setup({
            settings = {
                save_on_toggle = false,
                sync_on_ui_close = true,
                key = function() return vim.loop.cwd() end,
            },
        })
        -- REQUIRED

        vim.keymap.set("n", "<leader><space>a", function()
            harpoon:list():add()
            vim.notify("Added to Harpoon", "info", { title = "Harpoon" })
        end)
        vim.keymap.set("n", "<leader><space>b", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<leader><space>1", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<leader><space>2", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<leader><space>3", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<leader><space>4", function() harpoon:list():select(4) end)
        vim.keymap.set("n", "<leader><space>5", function() harpoon:list():select(4) end)

        -- DEPRECATED:: 2025-05-21
        -- this keymap work for treewalker
        -- vim.keymap.set("n", "<C-h>", function()
        -- 	if vim.bo.filetype == "NvimTree" then
        -- 		harpoon.ui:toggle_quick_menu(harpoon:list())
        -- 		return
        -- 	end

        -- 	if vim.bo.filetype == "harpoon" then
        -- 		if vim.fn.line(".") == 1 then
        -- 			vim.cmd("normal j")
        -- 			return
        -- 		end

        -- 		vim.cmd("normal k")
        -- 		return
        -- 	end

        -- 	local success, _ = pcall(function()
        -- 		harpoon:list():prev({ ui_nav_wrap = true })
        -- 	end)
        -- 	if not success then
        -- 		harpoon:list():prev({ ui_nav_wrap = true })
        -- 	end
        -- end) -- ui_nav_wrap will cycle the list

        -- DEPRECATED:: 2025-05-21
        -- this keymap work for treewalker
        -- vim.keymap.set("n", "<C-l>", function()
        -- 	if vim.bo.filetype == "NvimTree" then
        -- 		harpoon.ui:toggle_quick_menu(harpoon:list())
        -- 		return
        -- 	end

        -- 	if vim.bo.filetype == "harpoon" then
        -- 		-- 현재 커서가 마지막 라인이라면
        -- 		if vim.fn.line(".") == vim.fn.line("$") then
        -- 			-- 커서를 마지막 라인으로 이동
        -- 			vim.cmd("normal k")
        -- 			return
        -- 		end
        -- 		vim.cmd("normal j")
        -- 		return
        -- 	end

        -- 	harpoon:list():next({ ui_nav_wrap = true })
        -- end)

        harpoon:extend({
            UI_CREATE = function(cx)
                vim.keymap.set("n", "<C-v>", function() harpoon.ui:select_menu_item({ vsplit = true }) end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-s>", function()
                    harpoon.ui:select_menu_item({ split = true })
                    vim.cmd("WinShift down")
                    vim.cmd("WinShift down")
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-t>", function() harpoon.ui:select_menu_item({ tabedit = true }) end, { buffer = cx.bufnr })
            end,
        })

        -- basic telescope configuration
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers")
                .new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                })
                :find()
        end
        vim.keymap.set("n", "<leader><space>B", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })
    end,
}
