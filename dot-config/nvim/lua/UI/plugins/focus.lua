return {
    "cdmill/focus.nvim",
    cmd = "Focus",
    opts = {
        border = "none",
        zindex = 40, -- zindex of the focus window. Should be less than 50, which is the float default
        window = {
            backdrop = 0.9, -- shade the backdrop of the focus window. Set to 1 to keep the same as Normal
            -- height and width can be:
            -- * an asbolute number of cells when > 1
            -- * a percentage of the width / height of the editor when <= 1
            width = math.max(math.floor(0.5 * vim.o.columns), 200),
            height = 1, -- height of the focus window
            -- by default, no options are changed in for the focus window
            -- add any vim.wo options you want to apply
            options = {},
        },
        auto_zen = false, -- auto enable zen mode when entering focus mode
        -- by default, the options below are disabled for zen mode
        zen = {
            opts = {
                cmdheight = 0, -- disable cmdline
                cursorline = false, -- disable cursorline
                laststatus = 0, -- disable statusline
                number = false, -- disable number column
                relativenumber = false, -- disable relative numbers
                foldcolumn = "0", -- disable fold column
                signcolumn = "no", -- disable signcolumn
                statuscolumn = " ", -- disbale status column
            },
            diagnostics = false, -- disables diagnostics
        },
        plugins = {},
        on_open = function(_win) end,
        on_close = function()
            -- parent 윈도우의 winhighlight 복원
            local saved = vim.g._focus_saved_parent_whl
            local focus = require("focus.views.focus")
            local win = focus.parent
            if saved and win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_option_value("winhighlight", saved, { scope = "local", win = win })
            end
            vim.g._focus_saved_parent_whl = nil
        end,
    },
    config = function(_, opts)
        require("focus").setup(opts)

        -- fix_hl monkey-patch: parent 윈도우의 winhighlight 보존
        local focus_view = require("focus.views.focus")
        local orig_fix_hl = focus_view.fix_hl

        focus_view.fix_hl = function(win, backdrop)
            -- backdrop 윈도우 (bg_win)는 원래대로 처리
            if backdrop then
                orig_fix_hl(win, backdrop)
                return
            end

            -- focus 윈도우가 아닌 윈도우에는 winhighlight를 건드리지 않음
            if win ~= focus_view.win then return end

            -- focus 윈도우: parent의 winhighlight를 저장하고 focus 윈도우에 계승
            if not vim.g._focus_saved_parent_whl and focus_view.parent and vim.api.nvim_win_is_valid(focus_view.parent) then
                vim.g._focus_saved_parent_whl = vim.api.nvim_get_option_value("winhighlight", { scope = "local", win = focus_view.parent })
            end

            local parent_whl = vim.g._focus_saved_parent_whl or ""
            -- parent의 winhighlight를 focus 윈도우에 적용하되, NormalFloat도 매핑
            local hl = parent_whl
            if hl ~= "" then
                local normal_target = hl:match("Normal:([^,]+)")
                if normal_target then
                    hl = hl .. ",NormalFloat:" .. normal_target
                end
            else
                hl = "NormalFloat:Normal"
            end

            vim.api.nvim_set_option_value("winhighlight", hl, { scope = "local", win = win })
            vim.api.nvim_set_option_value("winblend", 0, { scope = "local", win = win })
        end
    end,
}
