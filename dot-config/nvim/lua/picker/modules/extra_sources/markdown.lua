-- filepath: /home/sy/dotfiles/dot-config/nvim/lua/picker/modules/extra_sources/markdown.lua
local M = {}

-- 로컬 함수들 (외부 노출 불필요)
local get_headings = function(bufnr)
    local ts = vim.treesitter

    local lang = ts.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then return {} end

    local parser = assert(ts.get_parser(bufnr, lang, { error = false }))

    local header_query = [[
    (setext_heading
      heading_content: (_) @h1
      (setext_h1_underline))
    (setext_heading
      heading_content: (_) @h2
      (setext_h2_underline))
    (atx_heading
      (atx_h1_marker)
      heading_content: (_) @h1)
    (atx_heading
      (atx_h2_marker)
      heading_content: (_) @h2)
    (atx_heading
      (atx_h3_marker)
      heading_content: (_) @h3)
    (atx_heading
      (atx_h4_marker)
      heading_content: (_) @h4)
    (atx_heading
      (atx_h5_marker)
      heading_content: (_) @h5)
    (atx_heading
      (atx_h6_marker)
      heading_content: (_) @h6)
  ]]

    local query = ts.query.parse(lang, header_query)
    local root = parser:parse()[1]:root()

    local headings = {}
    for id, node, _, _ in query:iter_captures(root, bufnr) do
        local text = ts.get_node_text(node, bufnr)
        local row, col = node:start()
        table.insert(headings, {
            file = vim.api.nvim_buf_get_name(bufnr),
            pos = { row + 1, col },
            text = text,
            name = text,
            depth = id,
        })
    end

    -- 각 헤더에 end_row 추가 (다음 헤더 시작 행 - 1, 마지막은 파일 끝)
    for i, heading in ipairs(headings) do
        local next_heading = headings[i + 1]
        heading.end_row = next_heading and (next_heading.pos[1] - 1) or vim.api.nvim_buf_line_count(bufnr)
    end

    -- Mark parents and last sibling for snacks tree formatting.
    local parents = {}
    for _, heading in ipairs(headings) do
        local depth = heading.depth
        parents[depth] = heading

        for i = depth - 1, 1, -1 do
            if parents[i] then
                heading.parent = parents[i]
                break
            end
        end

        for i = depth + 1, 6 do
            if parents[i] then
                parents[i].last = true
                parents[i] = nil
            end
        end
    end

    for i = 1, 6 do
        if parents[i] then parents[i].last = true end
    end

    return headings
end

local function format_headings(item, picker)
    local result = {}
    vim.list_extend(result, Snacks.picker.format.tree(item, picker))
    Snacks.picker.highlight.format(item, item.text, result)
    return result
end

---@param opts? snacks.picker.Config
function M.markdown_headings(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local headings = get_headings(bufnr)
    if #headings == 0 then
        Snacks.notify.info("No headings found in current buffer")
        return
    end

    return Snacks.picker.pick(vim.tbl_deep_extend("keep", opts or {}, {
        title = "Markdown Headings",
        items = headings,
        format = format_headings,
        confirm = function(picker, item)
            picker:close()
            item.pos[1] = item.pos[1] + 1
            vim.api.nvim_win_set_cursor(0, item.pos)

            require("utils").feed_keys_with_delay({ "zo", "zo", "zo", "zo", "zo", "zz" }, 10)
        end,
        preview = function(ctx)
            local lines = vim.api.nvim_buf_get_lines(
                ctx.item.file == vim.api.nvim_buf_get_name(0) and 0 or vim.fn.bufnr(ctx.item.file),
                ctx.item.pos[1] - 1,
                ctx.item.end_row,
                false
            )
            ctx.preview:highlight({ ft = "markdown" })
            ctx.preview:set_lines(lines)
        end,
    } --[[@as snacks.picker.Config]]))
end

return M.markdown_headings
