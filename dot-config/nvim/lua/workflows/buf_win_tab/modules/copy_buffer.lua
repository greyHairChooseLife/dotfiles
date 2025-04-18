local M = {}

--- Opens the duplicated content in a new window/tab.
--- Calls M.duplicateAndSaveTempFile internally.
---@param opts duplicateAndSaveTempFileOpts Options including source_file_path, range (optional), and direction.
---@return string? path Path to the temporary file if successful, or nil on error.
M.duplicateAndOpenTempFile = function(opts)
	-- First, create the temporary file
	local temp_file_path = M.duplicateAndSaveTempFile(opts)

	if not temp_file_path then
		-- Error already notified by duplicateAndSaveTempFile
		return nil
	end

	-- Determine the command to open the new window/tab
	local direction = opts.direction or "right" -- Default to vertical split

	if direction == "select_tab" then
		require("workflows.buf_win_tab.modules.select_tab").selectTab(function(tab_id)
			if tab_id then
				-- Switch to selected tab
				vim.cmd(tab_id .. "tabnext")
				-- Open the file
				local escaped_path = vim.fn.fnameescape(temp_file_path)
				local ok, err = pcall(vim.cmd, "vsplit " .. escaped_path)
				if not ok then
					vim.notify("Error opening temporary file in selected tab: " .. err, vim.log.levels.ERROR)
					pcall(vim.fn.delete, temp_file_path)
				end
			end
		end)
		return temp_file_path
	end

	local cmd_prefix
	if direction == "tab" then
		cmd_prefix = "tabnew"
	elseif direction == "right" then
		cmd_prefix = "vsplit"
	elseif direction == "down" then
		cmd_prefix = "split"
	else
		-- Fallback if direction is invalid, notify and use default
		vim.notify("Invalid direction: " .. tostring(direction) .. ". Using 'right'.", vim.log.levels.WARN)
		cmd_prefix = "vsplit"
	end

	-- Escape the file path for use in a command
	local escaped_path = vim.fn.fnameescape(temp_file_path)

	-- Construct and execute the command
	local full_cmd = cmd_prefix .. " " .. escaped_path
	local ok, err = pcall(vim.cmd, full_cmd)

	if not ok then
		vim.notify("Error opening temporary file in new window: " .. err, vim.log.levels.ERROR)
		-- Attempt to clean up the temporary file if opening failed
		pcall(vim.fn.delete, temp_file_path)
		return nil
	end

	-- Optional: Set buffer options for the temporary file, e.g., nofile, nomodified
	-- vim.bo.buftype = 'nofile'
	-- vim.bo.bufhidden = 'hide'
	-- vim.bo.swapfile = false
	-- vim.bo.modified = false

	return temp_file_path
end

---@class duplicateAndSaveTempFileOpts
---@field source_file_path? string file path to duplicate
---@field range { startLine: integer, endLine: integer }? selected range (1-based inclusive)
---@field direction "select_tab" | "tab" | "right" | "down" where to place window
---@param opts duplicateAndSaveTempFileOpts Options for duplicating content
---@return string? path Path to the temporary file, or nil on error
M.duplicateAndSaveTempFile = function(opts)
	opts = opts or {}
	opts.source_file_path = opts.source_file_path or vim.fn.expand("%:p")

	local lines
	if vim.fn.filereadable(opts.source_file_path) == 0 then
		-- If file isn't readable, try to get current buffer content instead
		local bufnr = vim.api.nvim_get_current_buf()
		if bufnr == 0 or vim.api.nvim_buf_line_count(bufnr) == 0 then
			vim.notify("Source file path is not readable and current buffer is empty", vim.log.levels.ERROR)
			return nil
		end
		lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	else
		-- Read from file as before
		lines = vim.fn.readfile(opts.source_file_path)
		if vim.v.shell_error ~= 0 then
			vim.notify("Error reading file: " .. opts.source_file_path, vim.log.levels.ERROR)
			return nil
		end
	end

	local lines_to_write
	if opts.range and opts.range.startLine and opts.range.endLine and opts.range.startLine <= opts.range.endLine then
		local start_line = math.max(1, opts.range.startLine)
		local end_line = math.min(#lines, opts.range.endLine)
		if start_line > end_line then
			lines_to_write = {}
		else
			lines_to_write = {}
			for i = start_line, end_line do
				table.insert(lines_to_write, lines[i])
			end
		end
	else
		lines_to_write = lines
	end

	local temp_file_path = vim.fn.tempname()
	if not temp_file_path or temp_file_path == "" then
		vim.notify("Could not generate temporary file name", vim.log.levels.ERROR)
		return nil
	end

	local ok = pcall(vim.fn.writefile, lines_to_write, temp_file_path)
	if not ok or vim.v.shell_error ~= 0 then
		vim.notify("Error writing to temporary file: " .. temp_file_path, vim.log.levels.ERROR)
		pcall(vim.fn.delete, temp_file_path)
		return nil
	end

	return temp_file_path
end

return M
