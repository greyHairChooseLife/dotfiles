local wk_map = require("utils").wk_map

-- MEMO:: Directory
wk_map({
  ["<Space>f"] = {
    group = "FileTree  - NvimTree",
    order = { "f", "t" },
    ["f"] = { "<cmd>NvimTreeFocus<CR>", desc = "focus", mode = "n" },
    ["t"] = { ToggleTree, desc = "toggle ", mode = "n" },
  },
})
