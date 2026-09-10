local map = vim.keymap.set

-- Define disallowed filetypes and buftypes (customize as needed)
local disallowed_filetypes =
    { "", "help", "qf", "markdown", "vimwiki", "oil", "fugitive", "gitcommit", "git", "terraform", "json", "yaml", "yml", "toml", "taskedit" }
local disallowed_buftypes = { "nofile", "terminal" }

local function is_disabled()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    return vim.tbl_contains(disallowed_filetypes, ft) or vim.tbl_contains(disallowed_buftypes, bt)
end

-- `j` (no count) jumps to a mark; while waiting for the mark char, a chip
-- shows in the statusline (see lualine_components.jump_pending).
-- The mark char is read here with getcharstr instead of leaving it to builtin
-- `` ` ``: scheduled callbacks/redraws do not run while the builtin pending
-- state blocks, so the chip could never be shown or cleared on time.
local function refresh_statusline()
    -- lualine renders 'statusline' into a plain string on its own timer/events;
    -- flipping vim.g.jump_pending does not repaint anything by itself. Ask it to
    -- rebuild now, before we block on input and its timer can no longer run.
    local ok, lualine = pcall(require, "lualine")
    if ok then pcall(lualine.refresh, { place = { "statusline" }, force = true }) end
    pcall(vim.cmd, "redraw")
end

local function jump_to_mark()
    vim.g.jump_pending = true
    refresh_statusline()
    local ok, char = pcall(vim.fn.getcharstr)
    vim.g.jump_pending = false
    refresh_statusline()
    if not ok or char == "\27" then return "" end -- Esc or C-c cancels
    return "`" .. char
end

-- Table of mappings: { key = { original, remapped_function } }
local mappings = {
    j = { "j", function() return vim.v.count == 0 and jump_to_mark() or "j" end },
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
