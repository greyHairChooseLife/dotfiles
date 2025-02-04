return {
	{
    "greyhairchooselife/timerly.nvim",
	    dependencies = { "nvzone/volt" },
      cmd = "TTimerlyToggle",
	},

	{
    "ggandor/leap.nvim",
	  lazy = false,
	  dependencies = {
	    -- TODO: dot(.) repeat을 위한 의존성인데, 이거 어떻게 활용하나?
	    -- https://www.lazyvim.org/extras/editor/leap#vim-repeat
		 "tpope/vim-repeat"
	  },
	  opts = {}
	},

	{
		"rmagatti/auto-session",
		cmd= {"SessionSearch", "SessionSave"},
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/test", "~/Downloads", "/*" },
				session_lens = {
					buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
					load_on_setup = true,
					theme_conf = {
						border = true,
						layout_config = {
							width = 1.8, -- Can set width and height as percent of window
							height = 0.5,
						},
					},
					previewer = false,
				},
				auto_save_enabled = false,
			})
		end,
	},

	{
		"sindrets/winshift.nvim",
		cmd = "WinShift",
		config = {
      highlight_moving_win = true, -- Highlight the window being moved
      focused_hl_group = "Visual", -- The highlight group used for the moving window
      moving_win_options = {
        -- These are local options applied to the moving window while it's
        -- being moved. They are unset when you leave Win-Move mode.
        wrap = false,
        cursorline = false,
        cursorcolumn = false,
        colorcolumn = "",
      },
      keymaps = {
        disable_defaults = true, -- Disable the default keymaps
        win_move_mode = {
          ["h"] = "left",
          ["j"] = "down",
          ["k"] = "up",
          ["l"] = "right",
          ["H"] = "far_left",
          ["J"] = "far_down",
          ["K"] = "far_up",
          ["L"] = "far_right",
          ["<left>"] = "left",
          ["<down>"] = "down",
          ["<up>"] = "up",
          ["<right>"] = "right",
          ["<S-left>"] = "far_left",
          ["<S-down>"] = "far_down",
          ["<S-up>"] = "far_up",
          ["<S-right>"] = "far_right",
        },
      },
      ---A function that should prompt the user to select a window.
      ---
      ---The window picker is used to select a window while swapping windows with
      ---`:WinShift swap`.
      ---@return integer? winid # Either the selected window ID, or `nil` to
      ---   indicate that the user cancelled / gave an invalid selection.
      window_picker = function()
        return require("winshift.lib").pick_window({
          -- A string of chars used as identifiers by the window picker.
          picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          filter_rules = {
            -- This table allows you to indicate to the window picker that a window
            -- should be ignored if its buffer matches any of the following criteria.
            cur_win = true, -- Filter out the current window
            floats = true, -- Filter out floating windows
            filetype = {}, -- List of ignored file types
            buftype = {}, -- List of ignored buftypes
            bufname = {}, -- List of vim regex patterns matching ignored buffer names
          },
          ---A function used to filter the list of selectable windows.
          ---@return integer[] filtered # The filtered list of window IDs.
          filter_func = nil,
        })
      end,
		}
	},
  {
    "folke/ts-comments.nvim",
    enabled=  false, -- 일단은 Comment.nvim으로 해결
    opts = {},
    event = "VeryLazy",
    -- enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      local prehook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = "^$",
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        extra = {
          above = "gcO",
          below = "gco",
          eol = "gcA",
        },
        mappings = {
          basic = true,
          extra = true,
          extended = false,
        },
        pre_hook = prehook,
        post_hook = nil,
      })
    end,
    event = "BufReadPre",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    opts = {
      signs = true, -- show icons in the signs column
      sign_priority = 8, -- sign priority
      -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "test" },
        START_debug = { icon = " ", color = "error" },
        END___debug = { icon = " ", color = "error" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        MEMO = { icon = "󱩼 ", color = "hint", alt = { "INFO" } },
        PSEUDO_CODE = { icon = " ", color = "pseudo", alt = { "PSEUDO_CODE" } },
        DEPRECATED = { icon = "", color = "depreacted", alt = { "DEPRECATED" } },
      },
      gui_style = {
        fg = "NONE", -- The gui style to use for the fg highlight group.
        bg = "BOLD", -- The gui style to use for the bg highlight group.
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
          multiline = true, -- enable multine todo comments
          multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
          multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
          before = "fg", -- "fg" or "bg" or empty
          keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
          after = "fg", -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" },
          pseudo = { "#37D060" },
          depreacted = { "#9F9F9F" },
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          -- regex that will be used to match keywords.
          -- don't replace the (KEYWORDS) placeholder
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex
          -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        },



    }
  },

  {
    'stevearc/quicker.nvim',
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      -- Local options to set for quickfix
      opts = {
        buflisted = false,
        number = false,
        relativenumber = false,
        signcolumn = "auto",
        winfixheight = true,
        wrap = false,
      },
      -- Set to false to disable the default options in `opts`
      use_default_opts = true,
      -- Keymaps to set for the quickfix buffer
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 5, after = 5, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").expand({ before = -5, after = -5, add_to_existing = true })
          end,
          desc = "Collapse quickfix context",
        },
      },
      -- Callback function to run any custom logic or keymaps for the quickfix buffer
      on_qf = function(bufnr) end,
      edit = {
        -- Enable editing the quickfix like a normal buffer
        enabled = true,
        -- Set to true to write buffers after applying edits.
        -- Set to "unmodified" to only write unmodified buffers.
        autosave = "unmodified",
      },
      -- Keep the cursor to the right of the filename and lnum columns
      constrain_cursor = true,
      highlight = {
        -- Use treesitter highlighting
        treesitter = true,
        -- Use LSP semantic token highlighting
        lsp = true,
        -- Load the referenced buffers to apply more accurate highlights (may be slow)
        load_buffers = true,
      },
      -- Map of quickfix item type to icon
      type_icons = {
        E = "󰅚 ",
        W = "󰀪 ",
        I = " ",
        N = " ",
        H = " ",
      },
      -- Border characters
      borders = {
        vert = "┃",
        -- Strong headers separate results from different files
        strong_header = "━",
        strong_cross = "╋",
        strong_end = "┫",
        -- Soft headers separate results within the same file
        soft_header = "╌",
        soft_cross = "╂",
        soft_end = "┨",
      },
      -- Trim the leading whitespace from results
      trim_leading_whitespace = true,
      -- Maximum width of the filename column
      max_filename_width = function()
        return math.floor(math.min(95, vim.o.columns / 2))
      end,
      -- How far the header should extend to the right
      header_length = function(type, start_col)
        return vim.o.columns - start_col
      end,
    },
  },

  {
    'pteroctopus/faster.nvim',
    -- TODO: beter option?
    lazy = false,
  },

  {
    "tpope/vim-surround",
    event = "BufReadPost"
  },

  {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
  },
}
