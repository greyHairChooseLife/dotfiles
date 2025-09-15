local wk_map = require("utils").wk_map

local dap = require("dap")
local dapui = require("dapui")

wk_map({
  ["<Space>d"] = {
    group = "Debug",
    order = { "b", "B", "c", "l", "h", "H", "i", "O", "Q", "t", "v" },
    ["b"] = {
      function() dap.toggle_breakpoint() end,
      desc = "Toggle breakpoint",
      mode = "n",
    },
    ["B"] = {
      function() dap.clear_breakpoints() end,
      desc = "clear Breakpoint",
      mode = "n",
    },
    ["c"] = {
      function() dap.continue() end,
      desc = "Continue/Start",
      mode = "n",
    },
    ["l"] = {
      function() dap.step_over() end,
      desc = "Step over",
      mode = "n",
    },
    ["h"] = {
      function() dap.step_back() end,
      desc = "Step back",
      mode = "n",
    },
    ["H"] = {
      function() dap.reverse_continue() end,
      desc = "Reverse continue",
      mode = "n",
    },
    ["i"] = {
      function() dap.step_into() end,
      desc = "Step into",
      mode = "n",
    },
    ["O"] = {
      function() dap.step_out() end,
      desc = "Step out",
      mode = "n",
    },
    ["j"] = {
      function() dap.run_to_cursor() end,
      desc = "Jump to Cursor",
      mode = "n",
    },
    ["f"] = {
      function() dap.focus_frame() end,
      desc = "Focus Frame",
      mode = "n",
    },
    ["Q"] = {
      function() require("dap").terminate() end,
      desc = "Terminate debugging",
      mode = "n",
    },
    ["t"] = {
      function()
        dapui.toggle()
        vim.bo.readonly = false
      end,
      desc = "Toggle DAP UI",
      mode = "n",
    },
    ["v"] = {
      function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes, { border = "rounded" })
      end,
      desc = "local variable",
      mode = "n",
    },
  },
})

-- vim.keymap.set('n', '<Space>dl', dap.run_last)
vim.keymap.set('n', '<C-p>', dap.up)
vim.keymap.set('n', '<C-n>', dap.down)
vim.keymap.set('n', '<Space>dV', '<cmd>DapVirtualTextToggle<cr>')

vim.keymap.set('n', ',b', function()
  if vim.bo.readonly then
    vim.bo.readonly = false
    vim.notify("Read-only OFF")
  else
    vim.bo.readonly = true
    vim.notify("Read-only ON")
  end
end, { desc = "Toggle read-only for current buffer" })
