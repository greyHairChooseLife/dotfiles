local closed_buffers_stack = {}
local MAX_HISTORY = 10

local function save_closed_buffer(event)
    local buf = event.buf
    local bufname = vim.api.nvim_buf_get_name(buf)
    local buftype = vim.bo[buf].buftype

    if bufname ~= "" and buftype == "" then
        if vim.fn.filereadable(bufname) == 1 then
            for i, path in ipairs(closed_buffers_stack) do
                if path == bufname then
                    table.remove(closed_buffers_stack, i)
                    break
                end
            end

            table.insert(closed_buffers_stack, 1, bufname)

            if #closed_buffers_stack > MAX_HISTORY then table.remove(closed_buffers_stack) end
        end
    end
end

local function restore_last_closed_buffer()
    if #closed_buffers_stack > 0 then
        local last_buffer = closed_buffers_stack[1]
        local status, error = pcall(function() vim.cmd("vnew " .. vim.fn.fnameescape(last_buffer)) end)

        if status then
            table.remove(closed_buffers_stack, 1)
            if #vim.api.nvim_list_wins() == 2 and type(_G.ReloadLayout) == "function" then _G.ReloadLayout() end
        else
            vim.notify("Failed to restore buffer: " .. error, vim.log.levels.ERROR)
        end
    else
        vim.notify("No buffer history to restore", vim.log.levels.INFO)
    end
end

local function show_closed_buffer_history()
    if #closed_buffers_stack == 0 then
        vim.notify("No buffer history saved", vim.log.levels.INFO)
        return
    end

    print("Recently closed buffers:")
    for i, path in ipairs(closed_buffers_stack) do
        local filename = vim.fn.fnamemodify(path, ":t")
        print(string.format("%d: %s", i, filename))
    end
end

local function restore_buffer_by_index(index)
    if not index or index < 1 or index > #closed_buffers_stack then
        vim.notify("Invalid buffer index", vim.log.levels.WARN)
        return
    end

    local buffer_to_restore = closed_buffers_stack[index]
    local status, error = pcall(function() vim.cmd("vnew " .. vim.fn.fnameescape(buffer_to_restore)) end)

    if status then
        table.remove(closed_buffers_stack, index)
        if #vim.api.nvim_list_wins() == 2 and type(_G.ReloadLayout) == "function" then _G.ReloadLayout() end
    else
        vim.notify("Failed to restore buffer: " .. error, vim.log.levels.ERROR)
    end
end

vim.api.nvim_create_autocmd("BufDelete", {
    callback = save_closed_buffer,
})

local wk_map = require("utils").wk_map
wk_map({
    ["<leader>b"] = {
        order = { "r", "h" },
        group = "  Buffer",
        ["r"] = { restore_last_closed_buffer, desc = "revive", mode = "n" },
        ["h"] = { show_closed_buffer_history, desc = "history", mode = "n" },
    },
})

vim.api.nvim_create_user_command("RestoreBuffer", function(opts)
    local index = tonumber(opts.args)
    restore_buffer_by_index(index)
end, { nargs = 1, desc = "Restore closed buffer by index" })
