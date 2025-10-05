-- BUG:: WORK IN PROGRESS
local M = {}

-- Cache for file contents and outlines
local file_cache = {}

-- Async file read (using plenary if available, otherwise sync fallback)
---@param path string The file path
---@return string|nil content
function M.read_file(path)
    -- Try to use plenary's async if available
    local has_plenary, async = pcall(require, "plenary.async")

    if has_plenary then
        local err, fd = async.uv.fs_open(path, "r", 438)
        if err or not fd then return nil end

        local stat_err, stat = async.uv.fs_fstat(fd)
        if stat_err or not stat then
            async.uv.fs_close(fd)
            return nil
        end

        local read_err, data = async.uv.fs_read(fd, stat.size, 0)
        async.uv.fs_close(fd)
        return read_err and nil or data
    else
        -- Fallback to sync read
        local file = io.open(path, "r")
        if not file then return nil end

        local content = file:read("*all")
        file:close()
        return content
    end
end

-- Get file modification time
---@param path string
---@return number|nil mtime
function M.file_mtime(path)
    local has_plenary, async = pcall(require, "plenary.async")

    if has_plenary then
        local err, stat = async.uv.fs_stat(path)
        return err and nil or stat.mtime.sec
    else
        error("This function requires the plenary.nvim plugin. Please install it to use this feature.")
    end
end

-- Get filetype from path
---@param path string
function M.get_filetype(path)
    -- First try using Neovim's built-in filetype detection if available
    if vim.fn.has("nvim-0.7") == 1 then
        local ok, ft = pcall(function() return vim.filetype.match({ filename = path }) end)
        if ok and ft then return ft end
    end

    -- Fallback to extension-based detection
    local ext = path:match("%.([^%.]+)$")
    if not ext then return nil end

    -- Basic filetype mapping
    local ft_map = {
        lua = "lua",
        js = "javascript",
        ts = "typescript",
        jsx = "javascriptreact",
        tsx = "typescriptreact",
        py = "python",
        rs = "rust",
        go = "go",
        rb = "ruby",
        md = "markdown",
        json = "json",
        html = "html",
        css = "css",
        c = "c",
        cpp = "cpp",
        h = "c",
        hpp = "cpp",
        vim = "vim",
        -- Add more mappings as needed
    }

    return ft_map[ext:lower()]
end

-- Get or process a file
---@param path string
---@return table|nil file_data
local function get_file(path)
    local ft = M.get_filetype(path)
    if not ft then
        -- Try to get filetype from vim if path is a buffer
        local bufnr = vim.fn.bufnr(path)
        if bufnr ~= -1 then ft = vim.bo[bufnr].filetype end

        -- If still no filetype, use plain text
        ft = ft or "text"
    end

    local modified = M.file_mtime(path)
    if not modified then return nil end

    local cached = file_cache[path]
    if cached and cached.modified >= modified then return cached.data end

    local content = M.read_file(path)
    if not content then return nil end

    local file_data = {
        content = content,
        filename = vim.fn.fnamemodify(path, ":t"),
        filepath = path,
        filetype = ft,
    }

    file_cache[path] = {
        data = file_data,
        modified = modified,
    }

    return file_data
end

-- Read multiple files and return their contents
-- Read multiple files and return their contents
---@param paths table<string> Array of file paths
---@return table context Collection of file data
---@usage
--- ```lua
--- local reader = require('AI.get_context')
--- local paths = {'/home/user/project/main.lua', '/home/user/project/config.json'}
--- local context = reader.read_files(paths)
---
--- -- The context variable would contain something like this:
--- -- {
--- --   {
--- --     content = "local function setup()\n  print('Hello world!')\nend\n\nreturn { setup = setup }",
--- --     filename = "main.lua",
--- --     filepath = "/home/user/project/main.lua",
--- --     filetype = "lua"
--- --   },
--- --   {
--- --     content = "{\n  \"name\": \"my-project\",\n  \"version\": \"1.0.0\",\n  \"dependencies\": {\n    \"some-lib\": \"^2.0.1\"\n  }\n}",
--- --     filename = "config.json",
--- --     filepath = "/home/user/project/config.json",
--- --     filetype = "json"
--- --   }
--- -- }
--- ```
function M.read_files(paths)
    local context = {}

    -- vim.notify(vim.inspect(paths))

    for _, path in ipairs(paths) do
        local file_data = get_file(path)
        if file_data then table.insert(context, file_data) end
    end

    return context
end

function M.get_changed_files(from_ref, to_ref, include_deleted)
    from_ref = from_ref or "HEAD^"
    to_ref = to_ref or "HEAD"
    include_deleted = include_deleted or false

    local has_plenary, Job = pcall(require, "plenary.job")
    local files = {}

    if has_plenary then
        -- Use plenary.job for async-safe git operations
        local output = Job:new({
            command = "git",
            args = { "diff", "--name-only", from_ref .. ".." .. to_ref },
            cwd = vim.fn.getcwd(),
        }):sync()

        for _, file in ipairs(output or {}) do
            if file and #file > 0 then
                local absolute_path = vim.fn.fnamemodify(file, ":p")
                if vim.fn.filereadable(absolute_path) == 1 then
                    table.insert(files, absolute_path)
                elseif include_deleted and file ~= "" then
                    table.insert(files, { path = absolute_path, deleted = true })
                end
            end
        end
    else
        -- Fallback to system when not in async context
        local output = vim.fn.system({
            "git",
            "diff",
            "--name-only",
            from_ref .. ".." .. to_ref,
        })

        if type(output) == "string" then
            for file in output:gmatch("[^\r\n]+") do
                if file and #file > 0 then
                    local absolute_path = vim.fn.fnamemodify(file, ":p")
                    if vim.fn.filereadable(absolute_path) == 1 then
                        table.insert(files, absolute_path)
                    elseif include_deleted then
                        table.insert(files, { path = absolute_path, deleted = true })
                    end
                end
            end
        end
    end

    return files
end
