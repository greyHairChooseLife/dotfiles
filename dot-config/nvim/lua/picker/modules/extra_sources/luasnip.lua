---@class snacks.Picker
---@field [string] unknown

return {
    supports_live = false,
    preview = "preview",

    layout = "dropdown",
    format = function(item, picker)
        local name = Snacks.picker.util.align(item.name, picker.align_1 + 5)
        return {
            { name, item.ft == "" and "Conceal" or "DiagnosticWarn" },
            { item.description },
        }
    end,
    finder = function(_, ctx)
        local snippets = {}
        -- Get all snippets (nil for all filetypes)
        for _, snip in ipairs(require("luasnip").get_snippets(nil)) do
            snip.ft = snip.filetype or "" -- Adjust based on Luasnip API
            table.insert(snippets, snip)
        end
        -- Optionally, prioritize current filetype
        local ft_snips = require("luasnip").get_snippets(vim.bo.ft) or {}
        for _, snip in ipairs(ft_snips) do
            snip.ft = vim.bo.ft
            table.insert(snippets, snip)
        end
        -- Remove duplicates if needed (e.g., by trigger)
        local seen = {}
        local unique_snips = {}
        for _, snip in ipairs(snippets) do
            if not seen[snip.trigger] then
                seen[snip.trigger] = true
                table.insert(unique_snips, snip)
            end
        end
        snippets = unique_snips

        local align_1 = 0
        for _, snip in pairs(snippets) do
            align_1 = math.max(align_1, #snip.name)
        end
        ctx.picker.align_1 = align_1
        local items = {}
        for _, snip in pairs(snippets) do
            local docstring = snip:get_docstring()
            if type(docstring) == "table" then docstring = table.concat(docstring) end
            local name = snip.name
            local description = table.concat(snip.description or {})
            description = name == description and "" or description
            table.insert(items, {
                text = name .. " " .. description, -- search string
                name = name,
                description = description,
                trigger = snip.trigger,
                ft = snip.ft,
                preview = {
                    ft = snip.ft,
                    text = docstring,
                },
            })
        end
        return items
    end,
    confirm = function(picker, item)
        picker:close()
        --
        local expand = {}
        require("luasnip").available(function(snippet)
            if snippet.trigger == item.trigger then table.insert(expand, snippet) end
            return snippet
        end)
        if #expand > 0 then
            vim.cmd(":startinsert!")
            vim.defer_fn(function() require("luasnip").snip_expand(expand[1]) end, 50)
        else
            Snacks.notify.warn("No snippet to expand")
        end
    end,
}
