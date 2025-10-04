return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-hop.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  config = function()
    local actions = require("telescope.actions")
    local action_layout = require("telescope.actions.layout")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")
    local previewers = require("telescope.previewers")

    local function switch_to_normal_mode()
      local escape_key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.api.nvim_feedkeys(escape_key, "n", true)
    end

    local focus_preview = function(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prompt_win = picker.prompt_win
      local previewer = picker.previewer
      local winid = previewer.state.winid
      local bufnr = previewer.state.bufnr
      vim.keymap.set({ "n", "v" }, "gq", function()
        actions.close(prompt_bufnr)
      end, { buffer = bufnr })
      vim.keymap.set("n", "i", function()
        vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
      end, { buffer = bufnr })
      vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
      -- api.nvim_set_current_win(winid)
    end

    -- 프롬프트 내용 초기화
    local function clear_prompt()
      local picker = action_state.get_current_picker(vim.api.nvim_get_current_buf())
      picker:reset_prompt() -- 프롬프트 초기화
    end

    local function focus_or_open(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      local filepath = entry.path or entry.filename
      local bufnr = entry.bufnr -- buffers picker의 경우에는 bufnr 필드를 참조합니다.
      local lnum = entry.lnum or 1
      local lcol = entry.col or 1

      -- 버퍼 리스트에서 filepath에 해당하는것 있는지 확인
      local function is_file_in_buffer_list(filepath)
        local buffers = vim.api.nvim_list_bufs()
        for _, buf in ipairs(buffers) do
          if
              vim.api.nvim_buf_is_loaded(buf)
              and (vim.api.nvim_buf_get_name(buf) == filepath or buf == bufnr)
          then
            return true, buf
          end
        end
        return false
      end

      local is_loaded, buf = is_file_in_buffer_list(filepath)

      if is_loaded then
        actions.close(prompt_bufnr)

        local wins = vim.api.nvim_list_wins()
        local found_win = false
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            found_win = true
          end
        end

        if not found_win and buf ~= nil then
          vim.api.nvim_set_current_buf(buf)
        end
        -- For already loaded buffers, don't change cursor position
      else
        actions.file_edit(prompt_bufnr)

        -- Only set cursor position for newly opened files
        vim.defer_fn(function()
          vim.api.nvim_win_set_cursor(0, { lnum, lcol - 1 })
        end, 20)
      end

      vim.defer_fn(function()
        vim.api.nvim_win_set_cursor(0, { lnum, lcol - 1 })
      end, 20)
    end

    local select_one_or_multi = function(prompt_bufnr, variant)
      -- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-1991532321
      -- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-2177826003
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi = picker:get_multi_selection()
      if not vim.tbl_isempty(multi) then
        actions.close(prompt_bufnr)
        if variant == "T" then
          vim.cmd("tabnew")
        end
        for _, j in pairs(multi) do
          local filename = j.path or j.filename or j.value
          local lnum = j.lnum or 1
          local lcol = j.col or 1
          if filename ~= nil then
            if variant == "Enter" then
              vim.cmd(string.format("%s %s", "edit", filename))
            elseif variant == "X" then
              vim.cmd(string.format("%s %s", "below split", filename))
            elseif variant == "V" or variant == "T" then
              vim.cmd(string.format("%s %s", "vsplit", filename))
            end
            -- vim.cmd(string.format("normal! %dG%d|zz", lnum, lcol))
            vim.api.nvim_win_set_cursor(0, { lnum, lcol })
          end
        end
        if variant == "T" then
          vim.cmd("wincmd w | q | wincmd p")
        end
      else
        if variant == "Enter" then
          focus_or_open(prompt_bufnr)
        elseif variant == "X" then
          actions.select_horizontal(prompt_bufnr)
          vim.cmd("WinShift down")
          -- builtin.resume() -- picker를 재실행, 연속적으로 선택할 수 있도록
        elseif variant == "V" then
          actions.select_vertical(prompt_bufnr)
        elseif variant == "T" then
          actions.select_tab(prompt_bufnr)
        end
      end
      if variant ~= "T" and require("utils").tree:is_visible() then
        NvimTreeResetUI()
      end
    end

    local stash_delta = previewers.new_termopen_previewer({
      get_command = function(entry)
        -- 스태시 항목을 선택했을 때 diff 보여주기
        return { "git", "stash", "show", "-p", entry.value }
      end,
    })

    local wide_layout_config = { preview_width = 0.8, width = 0.9, height = 0.9 }

    local h_pct = 1.00
    local w_pct = 1.00
    local fullscreen_setup = {
      -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      preview = { hide_on_startup = true },
      layout_strategy = "flex",
      layout_config = {
        flex = { flip_columns = 100 },
        horizontal = {
          mirror = false,
          prompt_position = "bottom",
          width = function(_, cols, _)
            return math.floor(cols * w_pct)
          end,
          height = function(_, _, rows)
            return math.floor(rows * h_pct)
          end,
          preview_cutoff = 10,
          preview_width = 0.5,
        },
        vertical = {
          mirror = true,
          prompt_position = "top",
          width = function(_, cols, _)
            return math.floor(cols * w_pct)
          end,
          height = function(_, _, rows)
            return math.floor(rows * h_pct)
          end,
          preview_cutoff = 10,
          preview_height = 0.5,
        },
      },
    }

    require("telescope").setup({
      defaults = {
        mappings = {
          n = {
            ["gq"] = "close",
            ["<C-g>"] = require("telescope").extensions.hop.hop,
            ["<A-Space>"] = focus_preview,
            ["<A-p>"] = action_layout.toggle_preview,
            ["<A-k>"] = actions.preview_scrolling_up,
            ["<A-j>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.results_scrolling_up,
            ["<C-d>"] = actions.results_scrolling_down,
          },
          i = {
            ["<C-r>"] = clear_prompt,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["gq"] = "close",
            ["<C-g>"] = require("telescope").extensions.hop.hop,
            ["<A-Space>"] = focus_preview,
            ["<A-p>"] = action_layout.toggle_preview,
            ["<A-k>"] = actions.preview_scrolling_up,
            ["<A-j>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.results_scrolling_up,
            ["<C-d>"] = actions.results_scrolling_down,
            ["<C-a>"] = actions.add_to_qflist,
            ["<A-a>"] = actions.add_selected_to_qflist,
            ["<C-Enter>"] = function(prompt_bufnr)
              select_one_or_multi(prompt_bufnr, "Enter")
            end,
            ["<C-x>"] = function(prompt_bufnr)
              select_one_or_multi(prompt_bufnr, "X")
            end,
            ["<C-v>"] = function(prompt_bufnr)
              select_one_or_multi(prompt_bufnr, "V")
            end,
            ["<C-t>"] = function(prompt_bufnr)
              select_one_or_multi(prompt_bufnr, "T")
            end,
          },
        },
        layout_config = {
          horizontal = {
            preview_width = 0.7,
          },
          -- preview_width = 0.7
          prompt_position = "bottom",
        },
        sorting_strategy = "descending",
        prompt_prefix = "  󰭎  ",
        selection_caret = " 󰜴 ",
        entry_prefix = "   ",
        multi_icon = "󰸞 ",
        -- border = false,
        -- borderchars = { "▄", "█", "█", "█", "▄", "▄", "█", "█" },
        borderchars = { "█", "█", "█", "█", "█", "█", "█", "█" },
        set_env = {
          LESS = "",
          DELTA_PAGER = "less",
        },
      },
      pickers = {
        buffers = {
          -- theme = "ivy",
          mappings = {
            n = {
              ["dd"] = "delete_buffer",
              ["<CR>"] = focus_or_open,
            },
            i = {
              ["<C-d>"] = "delete_buffer",
              ["<CR>"] = focus_or_open,
            },
          },
          ignore_current_buffer = false, -- quickfix에 전체 리스트 넣을 때 불편할 수 있겠다.
          preview = {
            hide_on_startup = true,
          },
          -- file_ignore_patterns = { '^Term:' }, -- buftype으로 체크가 된다!  ignore buffer
        },
        current_buffer_fuzzy_find = vim.tbl_extend("error", fullscreen_setup, {
          prompt_title = "Current Buffer",
          sorting_strategy = "ascending",
        }),
        -- find_files = vim.tbl_extend("error", fullscreen_setup, {
        --     -- for full screen
        -- }),
        find_files = {
          mappings = {
            n = {
              ["<CR>"] = focus_or_open,
            },
            i = {
              ["<CR>"] = focus_or_open,
            },
          },
          preview = {
            hide_on_startup = true,
          },
        },
        grep_string = {
          mappings = {
            n = {
              ["<CR>"] = focus_or_open,
            },
            i = {
              ["<CR>"] = focus_or_open,
            },
          },
          disable_coordinates = true, -- diable lnum, col
        },
        live_grep = {
          mappings = {
            n = {
              ["<CR>"] = focus_or_open,
            },
            i = {
              ["<CR>"] = focus_or_open,
            },
          },
          disable_coordinates = true, -- diable lnum, col
        },
        git_stash = {
          mappings = {
            n = {
              ["dd"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash drop " .. selection.value)
                actions.close(prompt_bufnr)
                builtin.git_stash({
                  previewer = stash_delta,
                  layout_config = wide_layout_config,
                })
                switch_to_normal_mode()
              end,
              ["ap"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash apply " .. selection.value)
                actions.close(prompt_bufnr)
              end,
              ["pp"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash pop " .. selection.value)
                actions.close(prompt_bufnr)
              end,
            },
            i = {
              ["<C-d>"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash drop " .. selection.value)
                actions.close(prompt_bufnr)
                builtin.git_stash({
                  previewer = stash_delta,
                  layout_config = wide_layout_config,
                })
                switch_to_normal_mode()
              end,
              ["<C-a>"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash apply " .. selection.value)
                actions.close(prompt_bufnr)
              end,
              ["<C-p>"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("Git stash pop " .. selection.value)
                actions.close(prompt_bufnr)
              end,
            },
          },
        },
        help_tags = {
          mappings = {
            n = {
              ["<CR>"] = focus_or_open,
            },
            i = {
              ["<CR>"] = focus_or_open,
            },
          },
        },
      },
      extensions = {
        -- ["ui-select"] = {
        -- 	require("telescope.themes").get_cursor({
        -- 		-- even more opts
        -- 	}),
        -- },
        -- ["ui-select"] = vim.tbl_extend("error", fullscreen_setup, {
        -- 	preview_title = "Sangyeon",
        -- }),
        hop = {
          -- the shown `keys` are the defaults, no need to set `keys` if defaults work for you ;)
          keys = {
            "a",
            "s",
            "d",
            "f",
            "g",
            "h",
            "j",
            "k",
            "l",
            ";",
            "q",
            "w",
            "e",
            "r",
            "t",
            "y",
            "u",
            "i",
            "o",
            "p",
            "A",
            "S",
            "D",
            "F",
            "G",
            "H",
            "J",
            "K",
            "L",
            ":",
            "Q",
            "W",
            "E",
            "R",
            "T",
            "Y",
            "U",
            "I",
            "O",
            "P",
            "z",
            "x",
            "c",
            "v",
            "b",
            "n",
            "m",
            ",",
            ".",
            "/",
            "Z",
            "X",
            "C",
            "V",
            "B",
            "N",
            "M",
            "<",
            ">",
            "?",
          },
          -- Highlight groups to link to signs and lines; the below configuration refers to demo
          -- sign_hl typically only defines foreground to possibly be combined with line_hl
          sign_hl = { "WarningMsg", "Title" },
          -- optional, typically a table of two highlight groups that are alternated between
          line_hl = { "CursorLine", "Normal" },
          -- options specific to `hop_loop`
          -- true temporarily disables Telescope selection highlighting
          clear_selection_hl = false,
          -- highlight hopped to entry with telescope selection highlight
          -- note: mutually exclusive with `clear_selection_hl`
          trace_entry = true,
          -- jump to entry where hoop loop was started from
          reset_selection = true,
        },
        fzf = {
          fuzzy = true,                   -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true,    -- override the file sorter
          case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
      },
    })

    require("telescope").load_extension("hop")
    require("telescope").load_extension("fzf")
  end,
}
