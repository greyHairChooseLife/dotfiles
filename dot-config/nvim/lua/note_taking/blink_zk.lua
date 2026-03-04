-- blink.cmp custom source: zk frontmatter 자동완성
-- tags:, area:, type: 줄에서만 트리거 → .zk/metadata.json 기반 완성 제공

local source = {}

local notebook = vim.env.ZK_NOTEBOOK_DIR or (vim.env.HOME .. "/Documents/zk")
local meta_path = notebook .. "/.zk/metadata.json"

local function read_metadata()
    local f = io.open(meta_path, "r")
    if not f then return {} end
    local raw = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, raw)
    return ok and data or {}
end

-- 커서 줄이 frontmatter 내의 특정 필드인지 확인
-- 반환: "tags" | "area" | "type" | nil
local function get_frontmatter_field(bufnr)
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, cursor_line + 1, false)

    -- frontmatter 범위 확인
    local in_fm = false
    local fm_end = false
    for i, line in ipairs(lines) do
        if line == "---" then
            if not in_fm then
                in_fm = true
            else
                if i - 1 < cursor_line then
                    fm_end = true
                end
                break
            end
        end
    end
    if not in_fm or fm_end then return nil end

    local current = lines[cursor_line + 1] or ""
    if current:match("^area:%s*") then return "area" end
    if current:match("^type:%s*") then return "type" end
    return nil
end

function source.new()
    return setmetatable({}, { __index = source })
end

function source:enabled()
    -- notebook 하위 .md 파일에서만 활성화
    local path = vim.api.nvim_buf_get_name(0)
    return vim.bo.filetype == "markdown" and path:sub(1, #notebook) == notebook
end

function source:get_completions(ctx, callback)
    local field = get_frontmatter_field(ctx.bufnr)
    if not field then
        callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
        return
    end

    local meta = read_metadata()
    local values = meta[field == "tags" and "tags" or field == "area" and "areas" or "types"] or {}

    local kind = require("blink.cmp.types").CompletionItemKind.Value
    local items = {}
    for _, v in ipairs(values) do
        items[#items + 1] = {
            label = v,
            insertText = v,
            kind = kind,
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        }
    end

    callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
end

return source
