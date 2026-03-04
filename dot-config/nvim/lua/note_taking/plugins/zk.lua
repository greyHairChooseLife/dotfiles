return {
    "zk-org/zk-nvim",
    ft = { "markdown" },
    config = function()
        -- metadata.json 업데이트: 노트 저장 시 tags/types/areas 스캔
        local notebook = vim.env.ZK_NOTEBOOK_DIR or (vim.env.HOME .. "/Documents/zk")
        local meta_path = notebook .. "/.zk/metadata.json"

        -- frontmatter에서 특정 필드 값 추출
        local function parse_frontmatter_field(path, field)
            local f = io.open(path, "r")
            if not f then return nil end
            local in_fm = false
            local value = nil
            for line in f:lines() do
                if line == "---" then
                    if not in_fm then
                        in_fm = true
                    else
                        break
                    end
                elseif in_fm then
                    local v = line:match("^" .. field .. ":%s*(.+)$")
                    if v then
                        value = v:match("^%s*(.-)%s*$")
                        break
                    end
                end
            end
            f:close()
            return value
        end

        -- frontmatter에서 tags 배열 파싱 (예: `tags: [foo, bar, baz]`)
        local function parse_tags(path)
            local f = io.open(path, "r")
            if not f then return {} end
            local result = {}
            local in_fm = false
            for line in f:lines() do
                if line == "---" then
                    if not in_fm then
                        in_fm = true
                    else
                        break
                    end
                elseif in_fm then
                    local raw = line:match("^tags:%s*%[(.-)%]")
                    if raw then
                        for tag in raw:gmatch("[^,]+") do
                            local t = tag:match("^%s*(.-)%s*$")
                            if t ~= "" then result[#result + 1] = t end
                        end
                        break
                    end
                end
            end
            f:close()
            return result
        end

        local function update_metadata()
            vim.system({ "zk", "list", "--quiet", "--format", "{{abs-path}}" }, {
                cwd = notebook,
            }, function(result)
                if result.code ~= 0 then return end
                local tags, types, areas = {}, {}, {}
                local seen_tags, seen_types, seen_areas = {}, {}, {}
                for path in result.stdout:gmatch("[^\n]+") do
                    for _, t in ipairs(parse_tags(path)) do
                        if not seen_tags[t] then
                            seen_tags[t] = true
                            tags[#tags + 1] = t
                        end
                    end
                    local typ = parse_frontmatter_field(path, "type")
                    if typ and not seen_types[typ] then
                        seen_types[typ] = true
                        types[#types + 1] = typ
                    end
                    local area = parse_frontmatter_field(path, "area")
                    if area and not seen_areas[area] then
                        seen_areas[area] = true
                        areas[#areas + 1] = area
                    end
                end
                table.sort(tags)
                table.sort(types)
                table.sort(areas)
                local json = vim.json.encode({ tags = tags, types = types, areas = areas })
                local f = io.open(meta_path, "w")
                if f then
                    f:write(json)
                    f:close()
                end
            end)
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = "*.md",
            callback = function(ev)
                local path = ev.file
                if path:sub(1, #notebook) == notebook then update_metadata() end
            end,
        })

        -- updated: frontmatter 자동 갱신
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.md",
            callback = function(ev)
                local path = ev.file
                if path:sub(1, #notebook) ~= notebook then return end
                local rel = path:sub(#notebook + 2)
                if rel:match("^docs/") then return end
                local today = os.date("%Y-%m-%d")
                local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
                local in_fm = false
                for i, line in ipairs(lines) do
                    if line == "---" then
                        if not in_fm then
                            in_fm = true
                        else
                            break
                        end
                    elseif in_fm then
                        if line:match("^updated:%s*") then
                            local new_line = "updated: " .. today
                            if new_line ~= line then vim.api.nvim_buf_set_lines(ev.buf, i - 1, i, false, { new_line }) end
                            break
                        end
                    end
                end
            end,
        })

        require("zk").setup({
            -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
            -- or select" (`vim.ui.select`).
            picker = "snacks_picker",

            lsp = {
                -- `config` is passed to `vim.lsp.start(config)`
                config = {
                    name = "zk",
                    cmd = { "zk", "lsp" },
                    filetypes = { "markdown" },
                    -- on_attach = ...
                    -- etc, see `:h vim.lsp.start()`
                },

                -- automatically attach buffers in a zk notebook that match the given filetypes
                auto_attach = {
                    enabled = true,
                },
            },
            picker_options = {
                snacks_picker = { layout = "full" },
            },
        })
    end,
}
