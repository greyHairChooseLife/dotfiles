local map = vim.keymap.set

-- Define disallowed filetypes and buftypes (customize as needed)
local disallowed_filetypes = { "help", "qf", "markdown", "vimwiki", "oil", "fugitive", "gitcommit", "git", "terraform", "json", "yaml", "yml", "toml" }
local disallowed_buftypes = { "nofile", "terminal" }

local function is_disabled()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    return vim.tbl_contains(disallowed_filetypes, ft) or vim.tbl_contains(disallowed_buftypes, bt)
end

-- Table of mappings: { key = { original, remapped_function } }
local mappings = {
    j = { "j", function() return vim.v.count == 0 and "`" or "j" end },
    k = {
        "k",
        function() return vim.v.count == 0 and "<Plug>(leap)" or "k" end,
    },
}

-- Set the mappings
for key, config in pairs(mappings) do
    local original, remap_func = unpack(config)
    map({ "n", "v" }, key, function()
        if is_disabled() then return original end
        return remap_func()
    end, { expr = true })
end

map({ "n", "v" }, "h", function() return vim.v.count == 0 and "," or "h" end, { expr = true })
map({ "n", "v" }, "l", function() return vim.v.count == 0 and ";" or "l" end, { expr = true })
