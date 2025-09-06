return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  -- event = { "InsertEnter", "VeryLazy" },
  opts = {
    panel = {
      enabled = false,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom", -- | top | left | right | horizontal | vertical
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = false,
      hide_during_completion = true,
      debounce = 75,
      keymap = {
        accept = "<A-k>",
        dismiss = "<A-h>",
        accept_word = false, -- 이어지는 suggestion을 위해 별도 설정
        accept_line = "<A-j>",
        prev = "<A-p>",
        next = "<A-n>",
      },
    },
    filetypes = {
      ["."] = false,
    },
    copilot_node_command = "node", -- Node.js version must be > 18.x
    server_opts_overrides = {},
  },
}
