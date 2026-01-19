return {
    "goolord/alpha-nvim",
    lazy = false,
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local picker = require("picker.modules.picker_sources")

        -- MEMO:: header
        local function header()
            local cwd = vim.fn.getcwd()
            -- Git 디렉토리인지 확인
            local git_dir_check = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
            if git_dir_check:match("true") == nil then
                return {
                    "                                                                              " .. cwd,
                    "Not git dir                                                                                                               ",
                }
            end

            local fetch_output = vim.fn.system("git log --oneline HEAD..FETCH_HEAD")
            local fetch_lines = {}
            for line in fetch_output:gmatch("([^\n]*)\n?") do
                table.insert(fetch_lines, line)
            end

            local result = {
                "                                                                                   " .. cwd,
                " HEAD..FETCH_HEAD                                                                                                                                 ",
                " ",
            }

            for _, line in ipairs(fetch_lines) do
                table.insert(result, "  " .. line)
            end

            table.insert(result, " origin/main..HEAD")
            table.insert(result, "")

            local workload_output = vim.fn.system("git log --oneline origin/main..HEAD")
            local workload_lines = {}
            for line in workload_output:gmatch("([^\n]*)\n?") do
                table.insert(workload_lines, line)
            end

            for _, line in ipairs(workload_lines) do
                table.insert(result, "  " .. line)
            end

            return result
        end
        dashboard.section.header.val = header()

        -- MEMO:: footer
        -- local function footer()
        -- 	return {
        -- 		"1. 미루지 않기",
        -- 		"2. 어려운 쪽을 선택하기",
        -- 	}
        -- end
        -- dashboard.section.footer.val = footer()

        -- Set menu
        dashboard.section.buttons.val = {
            dashboard.button(".", "                             ________   dir ____", function()
                vim.cmd("NvimTreeOpen")
                vim.cmd("only")
            end),
            -- dashboard.button("n", "New", ":ene <BAR> startinsert <CR>"),
            dashboard.button("n", "New", ":ene<CR>"),
            dashboard.button("f", "File", function() picker.files() end),
            dashboard.button("w", "Word grep", function() picker.grep() end),
            dashboard.button("o", "old", function() picker.recent() end),
            dashboard.button("O", "Old (global)", function() picker.recent_global() end),
            dashboard.button("_", "                             ________   AI _____", ""),
            dashboard.button("cc", "Copilot", function()
                local cdc_func = require("AI.codecompanion.utils.general")
                cdc_func.create_new()
                vim.cmd("only")
            end),
            dashboard.button("cp", "c.c: Prompts", ":cd ~/.claude | e CLAUDE.md<CR>"),
            dashboard.button("ce", "c.c: Commands", ":cd ~/.claude | e commands<CR>"),

            dashboard.button("_", "                              _______   doc _____", ""),
            dashboard.button("1", "dev", ":cd ~/Documents/dev-wiki | :VimwikiIndex<CR>"),
            dashboard.button("2", "job", ":cd ~/Documents/job-wiki | :2VimwikiIndex<CR>"),
            dashboard.button("d", "all", ":cd ~/Documents | vi .<CR>"),

            dashboard.button("_", "                              ______  configs ___", ""),
            dashboard.button("lz", "lazy plugins", ":Lazy<CR>"),
            dashboard.button("i3", "i3", ":cd ~/.config/i3 | e config<CR>"),
            dashboard.button("te", "term", ":cd ~/.config/alacritty | e alacritty.toml<CR>"),
            dashboard.button("tm", "tmux", ":cd ~/.config/tmux | e tmux.conf<CR>"),
            dashboard.button("vi", "vi", ":cd ~/.config | e nvim<CR>"),
            dashboard.button("ba", "bash", ":cd ~/.config | e bash.sub/<CR>"),
            dashboard.button("sc", "Snippet C", ":e ~/dotfiles/dot-config/nvim/lua/completion/modules/snippets.lua<CR>"),
            dashboard.button("_", "                              ______  sessions __", ""),
            dashboard.button("sv", "Session View", function()
                vim.cmd("AutoSession search")
                vim.fn.feedkeys("!json ", "m") -- json 파일에 탭 이름 정보 저장해둠
            end),
        }

        dashboard.section.header.opts.hl = "AlphaHeaderLabel"
        dashboard.section.buttons.opts.hl = "GitSignsChange"
        dashboard.section.footer.opts.hl = "ErrorMsg"

        -- Send config to alpha
        alpha.setup(dashboard.opts)
    end,
}
