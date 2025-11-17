return {
    "nvim-lualine/lualine.nvim",
    -- enabled = false,
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local utils = require("utils")

        -- Import lualine components
        local lualine_components = require("UI.modules/lualine_components")
        local colors = lualine_components.colors
        local my_theme = lualine_components.theme

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = my_theme,
                -- component_separators = { left = '', right = '' },
                -- section_separators = { left = '', right = '' },
                -- component_separators = { left = ' 󰪍󰪍 ', right = '' },
                -- section_separators = { left = '', right = '' },󰪍󰪍
                component_separators = { left = "%#CustomSeparator#█", right = "" },
                section_separators = { left = "", right = " " },
                disabled_filetypes = {
                    statusline = {
                        "packer",
                        "alpha",
                        "vimwiki",
                        "aerial",
                        "noice",
                        "DiffviewFiles",
                        "DiffviewFileHistory",
                        -- "snacks_picker_input", -- 의미없네
                        -- "snacks_picker_list",  -- 의미없네
                        -- "snacks_picker_preview", -- 의미없네
                    },
                    -- winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = false,
                globalstatus = false,
                refresh = {
                    statusline = 50,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = {
                    {
                        "filename",
                        file_status = false,
                        newfile_status = false,
                        symbols = {
                            modified = "󰈸", -- Text to show when the file is modified.
                            readonly = "", -- Text to show when the file is non-modifiable or readonly.
                            unnamed = "New", -- Text to show for unnamed buffers.
                            newfile = "New", -- Text to show for newly created file before first write
                        },
                        color = function()
                            local bufnr = vim.fn.bufnr("%")
                            local warpItem = require("warp").get_item_by_buf(bufnr)
                            if warpItem then
                                return {
                                    fg = colors.white,
                                    bg = colors.warp,
                                    gui = "bold",
                                }
                            else
                                return {
                                    fg = colors.bg,
                                    gui = "bold",
                                }
                            end
                        end,
                        separator = { right = "" },
                        padding = { left = 1, right = 0 },
                    },
                    {
                        function()
                            if vim.bo.modified then
                                return "󰈸󰈸󰈸"
                            elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
                                return " "
                            else
                                return "  "
                            end
                        end,
                        padding = { left = 0, right = 1 },
                        color = function()
                            if vim.bo.modified then
                                local bufnr = vim.fn.bufnr("%")
                                local warpItem = require("warp").get_item_by_buf(bufnr)
                                if warpItem then return { bg = colors.warp, fg = colors.git_change } end
                                return { fg = colors.red2 }
                            elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
                                return { fg = colors.bg }
                            else
                                local bufnr = vim.fn.bufnr("%")
                                local warpItem = require("warp").get_item_by_buf(bufnr)
                                if warpItem then return { bg = colors.warp } end
                                return {}
                            end
                        end,
                    },
                },
                lualine_b = {
                    {
                        "diff",
                        diff_color = {
                            added = { fg = colors.git_add },
                            modified = { fg = colors.git_change },
                            removed = { fg = colors.git_delete },
                        },
                        symbols = {
                            added = utils.icons.git.Add,
                            modified = utils.icons.git.Change,
                            removed = utils.icons.git.Delete,
                        },
                    },
                    {
                        "diagnostics",
                        diagnostics_color = {
                            error = "DiagnosticError",
                            warn = "DiagnosticWarn",
                            info = "DiagnosticInfo",
                            hint = "DiagnosticHint",
                        },
                        symbols = {
                            error = utils.icons.diagnostics.Error .. " ",
                            warn = utils.icons.diagnostics.Warn .. " ",
                            hint = utils.icons.diagnostics.Hint .. " ",
                            info = utils.icons.diagnostics.Info .. " ",
                        },
                    },
                },
                lualine_c = {
                    {
                        lualine_components.register_recording,
                        padding = { left = 1, right = 1 },
                        color = {
                            bg = colors.real_blue,
                            fg = colors.search,
                        },
                    },
                },
                lualine_x = {
                    {
                        lualine_components.winfix_status,
                        padding = { left = 1, right = 1 },
                        color = {
                            -- bg = colors.bg,
                            fg = colors.black,
                        },
                    },
                    {
                        "lsp_status",
                        icon = "󰌚",
                        symbols = {
                            done = " ",
                            -- Delimiter inserted between LSP names:
                            separator = " & ",
                        },
                        -- List of LSP names to ignore (e.g., `null-ls`):
                        ignore_lsp = { "copilot" },
                        color = {
                            bg = colors.bg,
                            fg = colors.git_add,
                        },
                    },
                    {
                        lualine_components.search_counter,
                        padding = { left = 2, right = 1 },
                        color = {
                            bg = colors.search,
                        },
                    },
                },
                lualine_y = {
                    {
                        -- "harpoon2",
                        -- icon = "", -- 󰀱 󰃀 󰃃  󰆡  
                        -- indicators = { "", "", "", "", "", "" },
                        -- active_indicators = { "", "", "", "", "", "" },
                        -- color_active = { fg = colors.orange, bg = colors.bg, gui = "bold" },
                        -- _separator = "", --  󱋰 󰇜 󰇼 󱗘 󰑅 󱒖 󰩮 󰦟 󰓡    
                        -- no_harpoon = "Harpoon not loaded",
                        -- padding = { left = 1, right = 1 },
                    },
                },
                lualine_z = {
                    {
                        "selectioncount",
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.purple, fg = colors.black, gui = "bold" },
                    },
                    {
                        "location",
                        padding = { left = 1, right = 1 },
                        color = function()
                            local bufnr = vim.fn.bufnr("%")
                            local warpItem = require("warp").get_item_by_buf(bufnr)
                            if warpItem then return { bg = colors.warp, fg = colors.white } end
                        end,
                    },
                    {
                        "progress",
                        padding = { left = 0, right = 1 },

                        color = function()
                            local bufnr = vim.fn.bufnr("%")
                            local warpItem = require("warp").get_item_by_buf(bufnr)
                            if warpItem then return { bg = colors.warp, fg = colors.white } end
                        end,
                    },
                    {
                        function()
                            local bufnr = vim.fn.bufnr("%")
                            local warpItem = require("warp").get_item_by_buf(bufnr)
                            local count = require("warp").count()
                            if warpItem then return "󰀱 " .. warpItem.index .. "/" .. count end
                            return ""
                        end,
                        padding = { left = 1, right = 1 },
                        color = function()
                            local bufnr = vim.fn.bufnr("%")
                            local warpItem = require("warp").get_item_by_buf(bufnr)
                            if warpItem then return { bg = colors.warp, fg = colors.white, gui = "bold" } end
                        end,
                    },
                },
            },
            inactive_sections = {
                lualine_a = {
                    {
                        "filename",
                        file_status = false,
                        newfile_status = false,
                        symbols = {
                            modified = "󰈸", -- Text to show when the file is modified.
                            readonly = "", -- Text to show when the file is non-modifiable or readonly.
                            unnamed = "New", -- Text to show for unnamed buffers.
                            newfile = "New", -- Text to show for newly created file before first write
                        },
                        color = {
                            fg = colors.wwhite,
                            gui = "italic",
                        },
                        separator = { right = "" },
                    },
                    {
                        function()
                            if vim.bo.modified then
                                return "󰈸󰈸󰈸"
                            elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
                                return " "
                            else
                                return " "
                            end
                        end,
                        padding = { left = 0, right = 1 },
                        color = function()
                            if vim.bo.modified then
                                return { fg = colors.red2, bg = colors.bblack }
                            elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
                                return { fg = colors.wwhite, bg = colors.bblack }
                            else
                                return { bg = colors.bg }
                            end
                        end,
                    },
                },
                lualine_b = {
                    {
                        "diff",
                        diff_color = {
                            added = { fg = colors.git_add },
                            modified = { fg = colors.git_change },
                            removed = { fg = colors.git_delete },
                        },
                        symbols = {
                            added = utils.icons.git.Add,
                            modified = utils.icons.git.Change,
                            removed = utils.icons.git.Delete,
                        },
                    },
                    {
                        "diagnostics",
                        diagnostics_color = {
                            error = "DiagnosticError",
                            warn = "DiagnosticWarn",
                            info = "DiagnosticInfo",
                            hint = "DiagnosticHint",
                        },
                        symbols = {
                            error = utils.icons.diagnostics.Error .. " ",
                            warn = utils.icons.diagnostics.Warn .. " ",
                            hint = utils.icons.diagnostics.Hint .. " ",
                            info = utils.icons.diagnostics.Info .. " ",
                        },
                    },
                },
                lualine_y = {
                    {
                        lualine_components.winfix_status,
                        padding = { left = 1, right = 1 },
                        color = {
                            -- bg = colors.bg,
                            fg = colors.black,
                        },
                    },
                    {
                        lualine_components.search_counter,
                        padding = { left = 2, right = 1 },
                        color = {
                            bg = colors.search,
                        },
                    },
                },
                lualine_z = {
                    {
                        -- "harpoon2",
                        -- -- icon = '♥',
                        -- icon = "",
                        -- indicators = { "", "", "", "", "", "" },
                        -- active_indicators = { "", "", "", "", "", "" },
                        -- color_active = { fg = colors.orange, bg = colors.bg, gui = "bold" },
                        -- _separator = "", --  󱋰 󰇜 󰇼 󱗘 󰑅 󱒖 󰩮 󰦟 󰓡    
                        -- no_harpoon = "Harpoon not loaded",
                    },
                },
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {
                lualine_components.my_terminal,
                lualine_components.my_quickfix,
                lualine_components.my_nvimTree,
                lualine_components.my_fugitive,
                lualine_components.my_oil,
                lualine_components.my_copilot_chat,
                lualine_components.my_codecompanion,
            },
        })
    end,
}
