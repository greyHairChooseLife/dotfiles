-- Custom foldtext with treesitter syntax highlighting
-- Returns virtual text chunks: { {text, hl_group}, ... }

local SEPARATOR = "󰇘"
local INFO_HL = "FoldText"

--- Get treesitter highlight groups for a line
--- Returns array of {text, hl_group} chunks
local function get_ts_highlights(bufnr, lnum)
    local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
    if not line or line == "" then return { { line or "", "" } } end

    local has_parser = pcall(vim.treesitter.get_parser, bufnr)
    if not has_parser then return { { line, "" } } end

    -- get_captures_at_pos resolves priority correctly (narrower range wins)
    local char_hl = {}
    for col = 0, #line - 1 do
        local captures = vim.treesitter.get_captures_at_pos(bufnr, lnum, col)
        if #captures > 0 then char_hl[col] = "@" .. captures[#captures].capture end
    end

    -- Merge consecutive characters with same highlight into chunks
    local chunks = {}
    local i = 0
    while i < #line do
        local hl = char_hl[i] or ""
        local j = i + 1
        while j < #line and (char_hl[j] or "") == hl do
            j = j + 1
        end
        chunks[#chunks + 1] = { line:sub(i + 1, j), hl }
        i = j
    end

    return chunks
end

local function foldtext()
    local bufnr = vim.api.nvim_get_current_buf()
    local foldstart = vim.v.foldstart
    local foldend = vim.v.foldend
    local fold_size = foldend - foldstart

    -- Get treesitter-highlighted first line
    local chunks = get_ts_highlights(bufnr, foldstart - 1) -- 0-indexed

    -- Separator: length scales with fold size
    local sep_len = math.min(math.max(fold_size, 2), 20)
    local separator = "  " .. string.rep(SEPARATOR, sep_len) .. "  "
    local info = fold_size .. (fold_size == 1 and " line" or " lines")

    chunks[#chunks + 1] = { separator, INFO_HL }
    chunks[#chunks + 1] = { info, INFO_HL }

    return chunks
end

vim.opt.foldtext = ""
_G.CustomFoldText = foldtext
vim.opt.foldtext = "v:lua.CustomFoldText()"

return true
