local g_util = require("utils")

local layout = {
  backdrop = true,
  --- Use the default layout or vertical if the window is too narrow
  preset = function()
    return vim.o.columns >= 120 and "default" or "vertical"
  end,
}
local layouts = {
  -- Override 'default' layout
  default = {
    layout = {
      box = "horizontal",
      width = 0.8,
      min_width = 120,
      height = 0.8,
      {
        box = "vertical",
        border = "rounded",
        title = "{title} {live} {flags}",
        { win = "input", height = 1,     border = "bottom" },
        { win = "list",  border = "none" },
      },
      {
        win = "preview",
        title = "{preview}",
        border = "single",
        width = 0.75,
        wo = {
          winhighlight = {
            NormalFloat = "Normal",
            FloatBorder = "SnacksPickerPreviewBorder",
          },
        },
      },
    },
  },
  my_telescope_top = {
    layout = {
      box = "horizontal",
      backdrop = true,
      width = 0.8,
      height = 0.9,
      border = "none",
      {
        box = "vertical",
        {
          win = "input",
          height = 1,
          border = "none",
          title = "{title} {live} {flags}",
          title_pos = "center",
        },
        { win = "list", title = " Results ", title_pos = "center", border = "none" },
      },
      {
        win = "preview",
        title = "{preview:Preview}",
        width = 0.45,
        border = "none",
        title_pos = "center",
      },
    },
  },
}

---@class snacks.picker.matcher.Config
local matcher = {
  fuzzy = true,          -- use fuzzy matching
  smartcase = true,      -- use smartcase
  ignorecase = true,     -- use ignorecase
  sort_empty = false,    -- sort results when the search string is empty
  filename_bonus = true, -- give bonus for matching file names (last part of the path)
  file_pos = true,       -- support patterns like `file:line:col` and `file:line`
  -- the bonusses below, possibly require string concatenation and path normalization,
  -- so this can have a performance impact for large lists and increase memory usage
  cwd_bonus = true,      -- give bonus for matching files in the cwd
  frecency = true,       -- frecency bonus
  history_bonus = false, -- give more weight to chronological order
}

---@class snacks.picker.formatters.Config
local formatters = {
  text = {
    ft = nil, ---@type string? filetype for highlighting
  },
  file = {
    filename_first = true, -- display filename before the file path
    truncate = 40,         -- truncate the file path to (roughly) this length
    filename_only = false, -- only show the filename
    icon_width = 2,        -- width of the icon (in characters)
    git_status_hl = true,  -- use the git status highlight group for the filename
  },
  selected = {
    show_always = false, -- only show the selected column when there are multiple selections
    unselected = true,   -- use the unselected icon for unselected items
  },
  severity = {
    icons = true,  -- show severity icons
    level = false, -- show severity level
    ---@type "left"|"right"
    pos = "left",  -- position of the diagnostics
  },
}

---@class snacks.picker.previewers.Config
local previewers = {
  diff = {
    builtin = true,    -- use Neovim for previewing diffs (true) or use an external tool (false)
    cmd = { "delta" }, -- example to show a diff with delta
  },
  git = {
    builtin = true, -- use Neovim for previewing git output (true) or use git (false)
    -- native = true, uncomment this to use delta as I use it native diff tool for git
    args = {},      -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
  },
  file = {
    max_size = 1024 * 1024, -- 1MB
    max_line_length = 500,  -- max line length
    ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
  },
  man_pager = nil, ---@type string? MANPAGER env to use for `man` preview
}

---@class snacks.picker.keymaps
local keymaps = {
  input = {
    -- to close the picker on ESC instead of going to normal mode,
    -- add the following keymap to your config
    -- ["<Esc>"] = { "close", mode = { "n", "i" } },
    ["/"] = "toggle_focus",
    ["<C-n>"] = { "history_forward", mode = { "i", "n" } },
    ["<C-p>"] = { "history_back", mode = { "i", "n" } },
    ["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
    ["<CR>"] = { "confirm", mode = { "n", "i" } },
    -- ["<Down>"] = { "list_down", mode = { "i", "n" } },
    -- ["<Esc>"] = "cancel",
    ["<S-CR>"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
    ["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
    ["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
    ["<Up>"] = { "list_up", mode = { "i", "n" } },
    -- ["<a-d>"] = { "inspect", mode = { "n", "i" } },
    ["<a-f>"] = { "toggle_follow", mode = { "i", "n" } },
    ["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
    ["<a-s-i>"] = { "toggle_ignored", mode = { "i", "n" } },
    ["<a-m>"] = { "toggle_maximize", mode = { "i", "n" } },
    ["<a-p>"] = { "toggle_preview", mode = { "i", "n" } },
    ["<a-Space>"] = { "focus_preview", mode = { "i", "n" } },
    ["<c-a>"] = { "select_all", mode = { "n", "i" } },
    ["<a-k>"] = { "preview_scroll_up", mode = { "i", "n" } },
    ["<a-j>"] = { "preview_scroll_down", mode = { "i", "n" } },
    ["<c-g>"] = { "toggle_live", mode = { "i", "n" } },
    ["<c-j>"] = { "list_down", mode = { "i", "n" } },
    ["<c-k>"] = { "list_up", mode = { "i", "n" } },
    ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
    ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
    ["<c-u>"] = "",
    ["<c-d>"] = "",
    ["<c-n>"] = "",
    ["<c-p>"] = "",
    ["<c-q>"] = { "qflist_all", mode = { "i", "n" } },
    ["<a-q>"] = { "qflist", mode = { "i", "n" } },
    ["<c-s>"] = { "split_multi", mode = { "i", "n" } },
    ["<c-t>"] = { "tab_split_multi", mode = { "n", "i" } },
    ["<c-a-t>"] = { "select_to_tab_multi", mode = { "n", "i" } },
    ["<c-v>"] = { "vsplit_multi", mode = { "i", "n" } },
    ["<c-r>#"] = { "insert_alt", mode = "i" },
    ["<c-r>%"] = { "insert_filename", mode = "i" },
    ["<c-r><c-a>"] = { "insert_cWORD", mode = "i" },
    ["<c-r><c-f>"] = { "insert_file", mode = "i" },
    ["<c-r><c-l>"] = { "insert_line", mode = "i" },
    ["<c-r><c-p>"] = { "insert_file_full", mode = "i" },
    ["<c-r><c-w>"] = { "insert_cword", mode = "i" },
    ["<c-r><c-r>"] = {
      function()
        vim.cmd("norm! cc")
      end,
      mode = "i",
    },
    ["<c-Left>"] = { { "layout_left", "focus_input" }, mode = { "i", "n" } },
    -- ["<c-Down>"] = { { "layout_bottom", "focus_input" }, mode = { "i", "n" } }, -- this keymap is taken by tmux
    -- ["<c-Up>"] = { { "layout_top", "focus_input" }, mode = { "i", "n" } }, -- this keymap is taken by tmux
    ["<c-Right>"] = { { "resume_picker_ui", "focus_input" }, mode = { "i", "n" } },
    ["<c-w>H"] = "",
    ["<c-w>J"] = "",
    ["<c-w>K"] = "",
    ["<c-w>L"] = "",
    ["?"] = "toggle_help_input",
    ["G"] = "list_bottom",
    ["gg"] = "list_top",
    ["j"] = "list_down",
    ["k"] = "list_up",
    -- ["gq"] = "close",
    ["gq"] = { "cancel", mode = { "i", "n" } },
    ["gQ"] = { "cancel", mode = { "i", "n" } },
    ["zb"] = "list_scroll_bottom",
    ["zt"] = "list_scroll_top",
    ["zz"] = "list_scroll_center",
  },
  list = {
    ["/"] = "toggle_focus",
    ["<2-LeftMouse>"] = "confirm",
    ["<CR>"] = "confirm",
    ["<Down>"] = "list_down",
    ["<Esc>"] = "cancel",
    ["<S-CR>"] = { { "pick_win", "jump" } },
    ["<S-Tab>"] = { "select_and_prev", mode = { "n", "x" } },
    ["<Tab>"] = { "select_and_next", mode = { "n", "x" } },
    ["<Up>"] = "list_up",
    ["<a-d>"] = "inspect",
    ["<a-f>"] = "toggle_follow",
    ["<a-h>"] = "toggle_hidden",
    ["<a-s-i>"] = "toggle_ignored",
    ["<a-m>"] = "toggle_maximize",
    ["<a-p>"] = "toggle_preview",
    ["<a-Space>"] = { "focus_preview" },
    ["<c-a>"] = "select_all",
    ["<c-u>"] = "",
    ["<c-d>"] = "",
    ["<c-f>"] = "list_scroll_down",
    ["<c-b>"] = "list_scroll_up",
    ["<c-n>"] = "",
    ["<c-p>"] = "",
    ["<a-k>"] = "preview_scroll_up",
    ["<a-j>"] = "preview_scroll_down",
    ["<c-j>"] = "list_down",
    ["<c-k>"] = "list_up",
    ["<c-q>"] = "qflist",
    ["<c-s>"] = "split_multi", -- MEMO: 이거 tmux랑 겹치네..
    ["<c-v>"] = "vsplit_multi",
    ["<c-t>"] = "tab_split_multi",
    ["<c-a-t>"] = "select_to_tab_multi",
    ["<c-w>H"] = "layout_left",
    ["<c-w>J"] = "layout_bottom",
    ["<c-w>K"] = "layout_top",
    ["<c-w>L"] = "layout_right",
    ["?"] = "toggle_help_list",
    ["G"] = "list_bottom",
    ["gg"] = "list_top",
    ["i"] = "focus_input",
    ["j"] = "list_down",
    ["k"] = "list_up",
    ["gq"] = "close",
    ["zb"] = "list_scroll_bottom",
    ["zt"] = "list_scroll_top",
    ["zz"] = "list_scroll_center",
  },
  preview = {
    ["gq"] = "focus_input",
    ["gQ"] = "focus_input",
    ["<Esc>"] = "focus_input",
    ["i"] = "focus_input",
    ["<a-h>"] = "focus_input",
    ["<a-Space>"] = "cycle_win",
  },
}

local setPostIfPossible = function(item)
  vim.cmd("normal! zz")
  if item.pos then
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(win, item.pos)
    vim.cmd("normal! zz")
    BlinkCursorLine()
  end
end

local actions = {
  flash = function(picker)
    require("flash").jump({
      pattern = "^",
      labels = "asdfghjklqwertyuiopzxcvbnm1234",
      label = {
        after = { 0, 0 },
        rainbow = {
          enabled = true,
          -- number between 1 and 9
          shade = 5,
        },
      },
      search = {
        mode = "search",
        exclude = {
          function(win)
            return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
          end,
        },
      },
      action = function(match)
        local idx = picker.list:row2idx(match.pos[1])
        picker.list:_move(idx, true, true)
      end,
    })
  end,
  split_multi = function(picker)
    local items = picker:selected({ fallback = true })
    picker:close()
    if #items == 0 then
      return
    elseif #items >= 1 then
      for item_idx, item in ipairs(items) do
        local path = item._path
        vim.cmd("split " .. path)
        setPostIfPossible(item)

        if item_idx == 1 then
          g_util.save_cursor_position()
        end
      end
      g_util.restore_cursor_position()
    end
  end,
  vsplit_multi = function(picker)
    local items = picker:selected({ fallback = true })
    picker:close()
    if #items == 0 then
      return
    elseif #items >= 1 then
      for item_idx, item in ipairs(items) do
        local path = item._path
        vim.cmd("vsplit " .. path)
        setPostIfPossible(item)

        if item_idx == 1 then
          g_util.save_cursor_position()
        end
      end
      g_util.restore_cursor_position()
    end
  end,
  tab_split_multi = function(picker)
    local items = picker:selected({ fallback = true })
    picker:close()
    if #items == 0 then
      return
    elseif #items >= 1 then
      for item_idx, item in ipairs(items) do
        local path = item._path
        if item_idx == 1 then
          vim.cmd("tabnew " .. path)
          setPostIfPossible(item)
          g_util.save_cursor_position()
        else
          vim.cmd("vsplit " .. path)
          setPostIfPossible(item)
        end
      end
      g_util.restore_cursor_position()
    end
  end,
  select_to_tab_multi = function(picker)
    local items = picker:selected({ fallback = true })
    if #items == 0 then
      return
    end

    local function process_item(idx)
      local item = items[idx]
      if not item then
        g_util.restore_cursor_position()
        vim.cmd.stopinsert()
        return
      end
      local path = item._path
      if idx == 1 then
        require("buf_win_tab.modules.select_tab").selectTabAndOpen({
          source_file_path = path,
          on_complete = function()
            picker:close()
            setPostIfPossible(item)
            g_util.save_cursor_position()
            process_item(idx + 1)
          end,
        })
      else
        vim.cmd("vsplit " .. path)
        setPostIfPossible(item)
        process_item(idx + 1)
      end
    end

    process_item(1)
  end,
  resume_picker_ui = function(picker)
    picker:close()
    picker.resume()
  end,
}

local M = {}
M.is_grep = nil

local function switch_grep_files(picker, _)
  -- switch b/w grep and files picker
  local snacks = require("snacks")
  local cwd = picker.input.filter.cwd
  picker:close()
  if M.is_grep then
    -- if we are inside grep picker then switch to files picker and set M.is_grep = false
    local pattern = picker.input.filter.search or picker.input.filter.pattern
    snacks.picker.files({ cwd = cwd, pattern = pattern })
    M.is_grep = false
    return
  else
    -- if we are inside files picker then switch to grep picker and set M.is_grep = true
    local pattern = picker.input.filter.pattern or picker.input.filter.search
    snacks.picker.grep({ cwd = cwd, search = pattern })
    M.is_grep = true
  end
end

local sources = {
  files = {
    actions = {
      switch_grep_files = function(picker, _)
        M.is_grep = false
        switch_grep_files(picker, _)
      end,
    },
    win = {
      input = {
        keys = {
          ["<a-r>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
        },
      },
    },
  },
  grep = {
    actions = {
      switch_grep_files = function(picker, _)
        M.is_grep = true
        switch_grep_files(picker, _)
      end,
    },
    win = {
      input = {
        keys = {
          ["<a-r>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
        },
      },
    },
  },
}

local config = {
  enabled = true,
  prompt = "󰭎  ",
  sources = sources,
  focus = "input",
  layout = layout,
  layouts = layouts,
  matcher = matcher,
  sort = { fields = { "score:desc", "#text", "idx" } },
  ui_select = true, -- replace `vim.ui.select` with the snacks picker
  formatters = formatters,
  previewers = previewers,
  ---@class snacks.picker.jump.Config
  jump = {
    jumplist = true,  -- save the current position in the jumplist
    tagstack = false, -- save the current position in the tagstack
    reuse_win = true, -- reuse an existing window if the buffer is already open
    close = true,     -- close the picker when jumping/editing to a location (defaults to true)
    match = false,    -- jump to the first match position. (useful for `lines`)
  },
  toggles = {
    follow = "f",
    hidden = "h",
    ignored = "i",
    modified = "m",
    regex = { icon = "R", value = false },
  },
  win = {
    input = {
      keys = keymaps.input,
      b = {
        minipairs_disable = true,
      },
    },
    list = {
      keys = keymaps.list,
      wo = {
        conceallevel = 2,
        concealcursor = "nvc",
      },
    },
    -- preview window
    preview = {
      keys = keymaps.preview,
      wo = {
        number = false,
        relativenumber = false,
      },
    },
  },
  actions = actions,
  ---@class snacks.picker.icons
  icons = {
    files = {
      enabled = true, -- show file icons
      dir = "󰉋 ",
      dir_open = "󰝰 ",
      file = "󰈔 ",
    },
    keymaps = {
      nowait = "󰓅 ",
    },
    tree = {
      vertical = "│ ",
      middle = "├╴",
      last = "└╴",
    },
    undo = {
      saved = " ",
    },
    ui = {
      live = "󰐰 ",
      hidden = "h",
      ignored = "i",
      follow = "f",
      selected = "󰸞 ",
      unselected = "○ ",
    },
    git = {
      enabled = true, -- show git icons
      commit = "󰜘 ", -- used by git log
      staged = g_util.icons.nvimtree_git.staged, -- staged changes. always overrides the type icons
      added = g_util.icons.git.Add,
      deleted = g_util.icons.git.Delete,
      ignored = g_util.icons.nvimtree_git.ignored,
      modified = g_util.icons.etc.modified,
      renamed = g_util.icons.nvimtree_git.renamed,
      unmerged = g_util.icons.nvimtree_git.unmerged,
      untracked = g_util.icons.nvimtree_git.untracked,
    },
    diagnostics = g_util.icons.diagnostics,
    lsp = {
      unavailable = "",
      enabled = " ",
      disabled = " ",
      attached = "󰖩 ",
    },
    kinds = {
      Array = " ",
      Boolean = "󰨙 ",
      Class = " ",
      Color = " ",
      Control = " ",
      Collapsed = " ",
      Constant = "󰏿 ",
      Constructor = " ",
      Copilot = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = "󰊕 ",
      Interface = " ",
      Key = " ",
      Keyword = " ",
      Method = "󰊕 ",
      Module = " ",
      Namespace = "󰦮 ",
      Null = " ",
      Number = "󰎠 ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = "󱄽 ",
      String = " ",
      Struct = "󰆼 ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Unknown = " ",
      Value = " ",
      Variable = "󰀫 ",
    },
  },
  ---@class snacks.picker.db.Config
  db = {
    -- path to the sqlite3 library
    -- If not set, it will try to load the library by name.
    -- On Windows it will download the library from the internet.
    sqlite3_path = nil, ---@type string?
  },
  ---@class snacks.picker.debug
  debug = {
    scores = false,   -- show scores in the list
    leaks = false,    -- show when pickers don't get garbage collected
    explorer = false, -- show explorer debug info
    files = false,    -- show file debug info
    grep = false,     -- show file debug info
    proc = false,     -- show proc debug info
    extmarks = false, -- show extmarks errors
  },
}

return config
