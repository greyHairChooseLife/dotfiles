---@module "AI.get_context"
---@description Utility functions for gathering context from files and git

local M = {}
local uv = vim.uv

-- Cache for file contents
local file_cache = {}

---Read file content synchronously using vim.uv
---@param path string The file path
---@return string|nil content
function M.read_file(path)
    local fd = uv.fs_open(path, "r", 438)
    if not fd then return nil end

    local stat = uv.fs_fstat(fd)
    if not stat then
        uv.fs_close(fd)
        return nil
    end

    local data = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)
    return data
end

---Get file modification time
---@param path string
---@return number|nil mtime
function M.file_mtime(path)
    local stat = uv.fs_stat(path)
    return stat and stat.mtime.sec or nil
end

---Get filetype from path using Neovim's built-in detection
---@param path string
---@return string|nil
function M.get_filetype(path)
    local ok, ft = pcall(vim.filetype.match, { filename = path })
    return ok and ft or nil
end

---Get or process a file with caching
---@param path string
---@return table|nil file_data {content, filename, filepath, filetype}
local function get_file(path)
    local ft = M.get_filetype(path) or "text"

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

---Read multiple files and return their contents
---@param paths string[] Array of file paths
---@return table[] context Array of {content, filename, filepath, filetype}
function M.read_files(paths)
    local context = {}
    for _, path in ipairs(paths) do
        local file_data = get_file(path)
        if file_data then table.insert(context, file_data) end
    end
    return context
end

---Clear the file cache
function M.clear_cache()
    file_cache = {}
end

---Get changed files between two git refs
---@param from_ref? string Default: "HEAD^"
---@param to_ref? string Default: "HEAD"
---@param include_deleted? boolean Default: false
---@return table files List of file paths (or {path, deleted=true} for deleted files)
function M.get_changed_files(from_ref, to_ref, include_deleted)
    from_ref = from_ref or "HEAD^"
    to_ref = to_ref or "HEAD"
    include_deleted = include_deleted or false

    local result = vim.system({
        "git", "diff", "--name-only", from_ref .. ".." .. to_ref,
    }, { cwd = vim.fn.getcwd() }):wait()

    local files = {}
    if result.code ~= 0 or not result.stdout then return files end

    for file in result.stdout:gmatch("[^\r\n]+") do
        if file and #file > 0 then
            local absolute_path = vim.fn.fnamemodify(file, ":p")
            if vim.fn.filereadable(absolute_path) == 1 then
                table.insert(files, absolute_path)
            elseif include_deleted then
                table.insert(files, { path = absolute_path, deleted = true })
            end
        end
    end

    return files
end

return M
