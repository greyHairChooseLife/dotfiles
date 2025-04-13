local font = "D2 Coding" -- defaults to guifont
local foreground_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).fg)
local background_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).bg)
local outline_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "NoteBackground" }).bg)

local bodyStyle = "body { margin: 0; color: " .. foreground_color .. "; }"
local containerStyle = ".container { background-color: " .. outline_color .. "; padding: 2%; }"
local preStyle = "pre { background-color: " .. background_color .. "; }"

local convert = function(range, opts)
	opts = opts or {}
	local save_to_file = opts.save_to_file or false
	local format = opts.format or "png" -- png or pdf
	local save_path = opts.save_path or vim.fn.getcwd() -- Default to current working directory

	local html = require("tohtml").tohtml(0, { range = range, font = font })

	for i, line in pairs(html) do
		if line:match("^%s*body") then
			-- html[i] = bodyStyle .. preStyle
			html[i] = bodyStyle .. containerStyle .. preStyle
		end

		if line:match("^%s*<pre>") then
			html[i] = "<div class='container'><pre>"
		end

		if line:match("^%s*</pre>") then
			html[i] = "</pre></div>"
		end
	end

	local wk_args = { "wkhtmltoimage", "-" }
	if format == "pdf" then
		wk_args = { "wkhtmltopdf", "-" }
	end

	if save_to_file then
		local timestamp = os.date("%Y%m%d_%H%M%S")
		local filename = "code_snippet_" .. timestamp .. "." .. format
		local full_path = save_path .. "/" .. filename

		-- Make sure the directory exists
		vim.fn.mkdir(save_path, "p")

		table.insert(wk_args, full_path)

		local out = vim.system(wk_args, { stdin = html }):wait()
		-- Check if the conversion was successful
		if out.code == 0 then
			return full_path
		else
			vim.notify("Failed to save image: " .. (out.stderr or "Unknown error"), vim.log.levels.ERROR)
			return nil
		end
	else
		table.insert(wk_args, "-")
		local out = vim.system(wk_args, { stdin = html }):wait()
		vim.system({ "xclip", "-selection", "clipboard", "-t", "image/png" }, { stdin = out.stdout })

		return nil
	end
end

local visual_convert = function(opts)
	opts = opts or {}
	local save_to_file = opts.save_to_file or false
	local format = opts.format or "png" -- png or pdf
	local save_path = opts.save_path or vim.fn.expand("~/Documents/html_to_img")

	local range = { vim.fn.getpos("v")[2], vim.fn.getpos(".")[2] }
	-- sort the range
	local line1 = math.min(range[1], range[2])
	local line2 = math.max(range[1], range[2])

	convert({ line1, line2 }, { save_to_file = save_to_file, format = format, save_path = save_path })
end

vim.keymap.set("v", "<leader>dc", function()
	visual_convert()
	vim.notify("copied!")
end)

vim.keymap.set("v", "<leader>dsi", function()
	local filename = visual_convert({ save_to_file = true, format = "png" })
	if filename then
		vim.notify("Saved as " .. filename)
	end
end)

vim.keymap.set("v", "<leader>dsp", function()
	local filename = visual_convert({ save_to_file = true, format = "pdf" })
	if filename then
		vim.notify("Saved as " .. filename)
	end
end)
