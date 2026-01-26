local M = {}

--- Get list of tabs with their names
---@return table[] tabs List of {id, name} pairs
local function get_tab_list()
    local tabs = {}
    for i = 1, vim.fn.tabpagenr("$") do
        local name = vim.fn.gettabvar(i, "tabname")
        table.insert(tabs, { id = i, name = i .. ": " .. vim.fn.fnamemodify(name, ":t") })
    end
    return tabs
end

--- Shows a selection UI for tabs and executes a callback with the selected tab
---@param callback fun(tab_id: integer|nil) Function to call with the selected tab number (nil if cancelled)
M.selectTab = function(callback)
    vim.ui.select(get_tab_list(), {
        prompt = "Select tab:",
        format_item = function(item) return item.name end,
    }, function(choice) callback(choice and choice.id or nil) end)
end

---@class selectTabAndOpenOpts
---@field source_file_path? string file path to open. Or just current buffer
---@field quit_current_window? boolean|nil quit prev
---@field on_complete? function called after selection is handled
---@param opts selectTabAndOpenOpts?
M.selectTabAndOpen = function(opts)
    opts = opts or {}

    vim.ui.select(get_tab_list(), {
        prompt = "Select tab:",
        format_item = function(item) return item.name end,
    }, function(choice)
        if choice then
            local tab_id = choice.id
            local file_path = opts.source_file_path or vim.fn.expand("%:p")

            if tab_id then
                if opts.quit_current_window then vim.cmd("quit") end
                vim.cmd(tab_id .. "tabnext")
                local escaped_path = vim.fn.fnameescape(file_path)
                local ok, err = pcall(vim.cmd, "vsplit " .. escaped_path)
                if not ok then
                    vim.notify("Error opening file in selected tab: " .. err, vim.log.levels.ERROR)
                    pcall(vim.fn.delete, file_path)
                end
            end
        end
        if opts.on_complete then opts.on_complete() end
    end)
end

return M
