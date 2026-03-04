return {
    "goolord/alpha-nvim",
    lazy = false,
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local picker = require("picker.modules.picker_sources")

        -- MEMO:: header
        local function header()
            local home = vim.fn.expand("$HOME")
            local function to_home(path) return path:gsub("^" .. home, "~") end

            local cwd = to_home(vim.fn.getcwd())
            local is_git = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")

            local col = "  %-22s  %s"
            local lines = {
                "",
                col:format("󰙊 CWD", " " .. cwd),
            }

            if is_git then
                local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
                local git_root = to_home(vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", ""))
                local last_mod = vim.fn.system("git log -1 --format='%cr,  \"%s\"' 2>/dev/null"):gsub("\n", "")
                local cloned_at = vim.fn.system("date -d @$(stat -c '%Y' $(git rev-parse --git-dir)) '+%Y-%m-%d ' 2>/dev/null"):gsub("%s*$", "")

                local fetch_head = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "") .. "/FETCH_HEAD"
                local fetch_info = "(never fetched)"
                local f = io.open(fetch_head, "r")
                if f then
                    local first_line = f:read("*l")
                    f:close()
                    if first_line then
                        local sha, ref = first_line:match("^(%x+)%s+%S+%s+'(.-)'")
                        local fetch_time = vim.fn.system("date -d @$(stat -c '%Y' " .. fetch_head .. ") '+%Y-%m-%d %H:%M' 2>/dev/null"):gsub("%s*$", "")
                        fetch_info = fetch_time .. "  " .. (ref or "") .. (sha and ("  " .. sha:sub(1, 7)) or "")
                    end
                end

                table.insert(lines, col:format(" Git Root", git_root))
                table.insert(lines, col:format("  │", ""))
                table.insert(lines, col:format("  ├ Modified", last_mod .. ",  @[" .. branch .. "]"))
                table.insert(lines, col:format("  ├ Fetched", fetch_info))
                table.insert(lines, col:format("  └ Cloned", cloned_at))
            else
                table.insert(lines, col:format(" Git Root", "(not a git repo)"))
            end

            table.insert(lines, "")
            return lines
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
            dashboard.button("ba", "bash", ":cd ~/.config | e zsh.sub/<CR>"),
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
