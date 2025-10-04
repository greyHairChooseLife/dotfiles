local g_utils = require("utils")
local SN = require("snacks")
local snp = require("snacks").picker

local M = {}

-- MEMO: CUSTOM PICKER EXAMPLE
local function pick_cmd_result(picker_opts)
  local git_root = SN.git.get_root()
  local finder = function(opts, ctx)
    return require("snacks.picker.source.proc").proc({
      opts,
      {
        cmd = picker_opts.cmd,
        args = picker_opts.args,
        transform = function(item)
          item.cwd = picker_opts.cwd or git_root
          item.file = item.text
        end,
      },
    }, ctx)
  end

  snp.pick({
    source = picker_opts.name,
    finder = finder,
    preview = picker_opts.preview,
    title = picker_opts.title,
  })
end

M.example = function()
  pick_cmd_result({
    cmd = "git",
    args = { "diff-tree", "--no-commit-id", "--name-only", "--diff-filter=d", "HEAD", "-r" },
    name = "git_show",
    title = "Git Last Commit",
    preview = "git_show",
  })
end
-- MEMO: GIT
local log_actions = {
  open_picker_files_from_last_commit = function(picker)
    local select = picker:current().commit
    M.files_from_last_commit(select)
  end,
  view_in_diffview = function(picker)
    local select = picker:current().commit
    local args = select .. "^!"
    vim.cmd("DiffviewOpen " .. args)
  end,
  rebase_interactively = function(picker)
    local select = picker:current().commit
    local args = select .. "^"
    vim.cmd("GV")
    vim.defer_fn(function()
      vim.cmd("Git rebase -i " .. args)
    end, 1)
  end,
}
M.git_log = function()
  local config = {
    actions = log_actions,
    win = {
      input = {
        keys = {
          ["<Space>"] = { "open_picker_files_from_last_commit", mode = { "n" } },
          ["<c-t>"] = { "view_in_diffview", mode = { "n", "i" } },
          ["<c-r>i"] = { "rebase_interactively", mode = { "n", "i" } },
          ["<c-r><c-i>"] = { "rebase_interactively", mode = { "n", "i" } },
        },
      },
    },
  }
  snp.git_log(config)
end
M.git_log_line = function()
  -- vim.cmd("normal! <Esc>")
  local config = {
    actions = log_actions,
    win = {
      input = {
        keys = {
          ["<Space>"] = { "open_picker_files_from_last_commit", mode = { "n" } },
          ["<c-t>"] = { "view_in_diffview", mode = { "n", "i" } },
          ["<c-r>i"] = { "rebase_interactively", mode = { "n", "i" } },
          ["<c-r><c-i>"] = { "rebase_interactively", mode = { "n", "i" } },
        },
      },
    },
  }
  snp.git_log_line(config)
end
M.git_log_file = function()
  local config = {
    actions = log_actions,
    win = {
      input = {
        keys = {
          ["<Space>"] = { "open_picker_files_from_last_commit", mode = { "n" } },
          ["<c-t>"] = { "view_in_diffview", mode = { "n", "i" } },
          ["<c-r>i"] = { "rebase_interactively", mode = { "n", "i" } },
          ["<c-r><c-i>"] = { "rebase_interactively", mode = { "n", "i" } },
        },
      },
    },
  }
  snp.git_log_file(config)
end
M.git_diff = function()
  local config = {
    -- preview = "diff",
  }
  snp.git_diff(config)
  -- builtin.git_status({
  -- 	previewer = diff_delta,
  -- 	layout_config = wide_layout_config,
  -- })
end
local stash_actions = {
  stash_pop = function(picker)
    local select = picker:current().stash
    vim.cmd("Git stash pop " .. select)
    picker:close()
  end,
  stash_drop = function(picker)
    local select = picker:current().stash
    vim.cmd("Git stash drop " .. select)
    picker:close()
    M.git_stash()
  end,
}
M.git_stash = function()
  local config = {
    actions = stash_actions,
    win = {
      input = {
        keys = {
          ["<c-p>"] = { "stash_pop", mode = { "n", "i" } },
          ["<c-d>"] = { "stash_drop", mode = { "n", "i" } },
        },
      },
    },
  }
  snp.git_stash(config)
  -- builtin.git_stash({
  -- 	previewer = stash_delta,
  -- 	layout_config = wide_layout_config,
  -- })
end
M.git_status = function()
  local config = {}
  snp.git_status(config)
end
M.git_branches = function()
  local config = {
    layout = { fullscreen = true },
  }
  snp.git_branches(config)
end

-- MEMO: FIND
M.files = function()
  local config = {}
  snp.files(config)
end
M.files_visual = function()
  local search_text = g_utils.get_visual_text()
  local config = {
    on_show = function()
      vim.api.nvim_put({ search_text .. " " }, "c", true, true)
    end,
  }
  snp.files(config)
end
M.buffers = function()
  g_utils.close_empty_unnamed_buffers()
  g_utils.save_cursor_position()
  local config = {
    layout = {
      preset = "default",
      layout = {
        preset = "default",
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
          width = 0.8,
          wo = {
            winhighlight = {
              NormalFloat = "Normal",
              FloatBorder = "SnacksPickerPreviewBorder",
              CursorLine = "SnacksPickerCursorLine",
            },
          },
        },
      },
    },
    current = true,
    sort_lastused = false,
    filter = {
      filter = function(item)
        if item.file then
          local filename = item.file:match("([^/]+)$")
          if filename and filename:match("^Term:") then
            return false -- Filter out this item
          end
        end
        return true -- Keep this item
      end,
    },
    actions = {
      close_and_stay = function(picker)
        picker:close()
        g_utils.restore_cursor_position()
      end,
      my_bufdelete = function(picker)
        picker.preview:reset()
        local non_buf_delete_requested = false
        local to_be_closed_win = {}
        for _, item in ipairs(picker:selected({ fallback = true })) do
          if item.buf then
            table.insert(to_be_closed_win, item.info.windows[1])
            Snacks.bufdelete.delete(item.buf)
          else
            non_buf_delete_requested = true
          end
        end
        if non_buf_delete_requested then
          Snacks.notify.warn("Only open buffers can be deleted", { title = "Snacks Picker" })
        end
        picker.list:set_selected()
        picker.list:set_target()
        picker:find()

        picker:close()
        for _, win_id in ipairs(to_be_closed_win) do
          vim.api.nvim_win_close(win_id, false)
        end
        picker:resume()
      end,
    },
    win = {
      input = {
        keys = {
          ["gq"] = { "close_and_stay", mode = { "n", "i" } },
          ["<c-d>"] = { "my_bufdelete", mode = { "n", "i" } },
        },
      },
    },
  }

  snp.buffers(config)
end
M.buffers_term_only = function()
  local config = {
    layout = {
      preset = "bottom",
      -- fullscreen = true,
    },
    title = "TERMINAL",
    current = true,
    filter = {
      filter = function(item)
        if item.file then
          local filename = item.file:match("([^/]+)$")
          if filename and filename:match("^Term:") then
            return true -- Filter out this item
          end
        end
      end,
    },
  }
  snp.buffers(config)
end
M.recent = function()
  local config = {
    filter = { cwd = true },
  }
  snp.recent(config)
end
M.recent_global = function()
  local config = {
    filter = { cwd = false },
  }
  snp.recent(config)
end

-- MEMO: ETC
M.command_history = function()
  local config = {}
  snp.command_history(config)
end
M.files_from_last_commit = function(commit_hash)
  commit_hash = commit_hash or "HEAD" -- 기본값은 HEAD로 설정

  pick_cmd_result({
    cmd = "git",
    args = { "diff-tree", "--no-commit-id", "--name-only", "--diff-filter=d", commit_hash, "-r" },
    name = "git_show",
    title = "Git Commit Files: " .. commit_hash,
    preview = "git_diff",
  })
end
M.qflist = function()
  local config = {
    actions = {
      remove_select = function(picker)
        local buf_id = picker:current()
        QF_RemoveItem(buf_id.idx, true)
        vim.schedule(M.qflist)
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-d>"] = { "remove_select", mode = { "n", "i" } },
        },
      },
    },
  }
  snp.qflist(config)
end

-- MEMO: GREP
M.grep = function()
  local config = {}
  snp.grep(config)
end
M.grep_current_buffer = function()
  local config = {}
  snp.lines(config)
end
M.grep_current_buffers = function()
  local config = { need_search = true }
  snp.grep_buffers(config)
end
M.grep_visual = function()
  local search_text = g_utils.get_visual_text()
  local config = {
    on_show = function()
      vim.api.nvim_put({ search_text .. " " }, "c", true, true)
    end,
  }
  snp.grep(config)
end
M.grep_visual_current_buffers = function()
  local search_text = g_utils.get_visual_text()
  local config = {
    on_show = function()
      vim.api.nvim_put({ search_text .. " " }, "c", true, true)
    end,
  }
  snp.grep_buffers(config)
end
M.grep_word = function()
  local config = {}
  snp.grep_word(config)
end

return M
