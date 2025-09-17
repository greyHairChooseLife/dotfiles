return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<Space>db", function() require("dapui").toggle_breakpoint() end },
      { "<Space>dc", function() require("dapui").continue() end },
      { "<Space>dt", function() require("dapui").toggle() end },
    },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      {
        'theHamsta/nvim-dap-virtual-text',
        enabled = true,
        config = function()
          local status, nvimdapvirtualtext = pcall(require, 'nvim-dap-virtual-text')
          if not status then
            return
          end
          nvimdapvirtualtext.setup({
            enabled = false,
            enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true,               -- show stop reason when stopped for exceptions
            commented = true,                      -- prefix virtual text with comment string
            only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
            all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
            filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
            -- experimental features:
            virt_text_pos = 'eol',                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
            all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
            virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
            virt_text_win_col = nil,               -- position the virtual text at a fixed window column (starting from the first text column) ,
            -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dapui").setup({
        expand_lines = false,
        controls = { enabled = false },
        floating = {
          border = "none",
          mappings = {
            close = { "gq", "q", "<Esc>" }
          }
        },
        layouts = { {
          elements = {
            -- {
            --   id = "scopes",
            --   size = 0.6
            -- },
            --   {
            --   id = "breakpoints",
            --   size = 0.25
            -- },
            {
              id = "watches",
              -- size = 0.25
              size = 1
            },
          },
          position = "left",
          size = 80
        }, {
          elements = {
            {
              id = "console",
              -- size = 0.5
              size = 0.5
            },
            {
              id = "stacks",
              size = 0.5
              -- size = 0.25
            },
            -- {
            --   id = "repl",
            --   size = 0.5
            -- },
          },
          position = "right",
          size = 35
        } },

        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "<CR>"
        },
      })


      local dapuiwidgets, status
      status, dapuiwidgets = pcall(require, 'dapui.widgets')
      if status then
        vim.keymap.set("n", "<Space>dp", dapuiwidgets.hover)
      end


      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DebugBreakPointText",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DebugBreakPointRejectedText",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = " ", -- or "→"
        texthl = "DebugStoppedText",
        linehl = "DebugStoppedLine",
        numhl = "",
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        vim.bo.readonly = true
        vim.bo.modifiable = false
        dapui.open()
        vim.defer_fn(function()
          require('utils').switch_to_normal_mode()
        end, 100)
      end

      -- MEMO:: bash
      dap.adapters.bashdb = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
        name = 'bashdb',
      }
      dap.configurations.sh = {
        {
          type = 'bashdb',
          request = 'launch',
          name = 'Launch file',
          showDebugOutput = false,
          pathBashdb = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
          pathBashdbLib = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
          trace = false,
          file = '${file}',
          program = '${file}',
          cwd = '${workspaceFolder}',
          pathCat = 'cat',
          pathBash = '/opt/homebrew/bin/bash',
          pathMkfifo = 'mkfifo',
          pathPkill = 'pkill',
          args = {},
          env = {},
          terminalKind = 'integrated',
        },
        {
          type = 'bashdb',
          request = 'launch',
          name = 'Launch file with arguments',
          showDebugOutput = false,
          pathBashdb = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
          pathBashdbLib = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
          trace = false,
          file = '${file}',
          program = '${file}',
          cwd = '${workspaceFolder}',
          pathCat = 'cat',
          pathBash = '/opt/homebrew/bin/bash',
          pathMkfifo = 'mkfifo',
          pathPkill = 'pkill',
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' +')
          end,
          env = {},
          terminalKind = 'integrated',
        },
      }


      -- MEMO:: c
      -- dap.adapters.codelldb = {
      --   type = "server",
      --   port = "${port}",
      --   executable = {
      --     command = "codelldb",
      --     args = { "--port", "${port}" },
      --   },
      -- }

      -- see https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)
      dap.adapters.codelldb = {
        type = 'executable',
        command = 'codelldb',
      }

      dap.configurations.c = {
        {
          name = 'codelldb launch',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ' .. vim.fn.getcwd() .. '/')
          end,
          cwd = '${workspaceFolder}',
          terminal = 'integrated',
          stopOnEntry = false,
        },
        {
          name = 'codelldb attach',
          type = 'codelldb',
          request = 'attach',
          pid = function()
            return vim.fn.input('pid: ')
          end,
          cwd = '${workspaceFolder}',
          terminal = 'integrated',
          stopOnEntry = false,
          waitFor = true,
        },
      }
    end,
  },
}
