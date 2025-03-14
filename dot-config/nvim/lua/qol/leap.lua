-- LEAP

local map = vim.keymap.set
local TIME = 80
local g_pressed = false
local timer = nil

-- Function to execute leap-forward
local function execute_leap_forward()
	local leap_forward = vim.api.nvim_replace_termcodes("<Plug>(leap-forward)", true, false, true)
	vim.api.nvim_feedkeys(leap_forward, "n", false)
end

-- Function to execute leap-backward
local function execute_leap_backward()
	local leap_backward = vim.api.nvim_replace_termcodes("<Plug>(leap-backward)", true, false, true)
	vim.api.nvim_feedkeys(leap_backward, "n", false)
end

map({ "n", "v" }, "g", function()
	-- set g_pressed flag and start timer
	g_pressed = true
	if timer then
		timer:stop()
	end
	timer = vim.defer_fn(function()
		if g_pressed then
			-- If no 'j' or 'k' follows, do the normal 'g' command
			vim.api.nvim_feedkeys("g", "n", true)
			g_pressed = false
		end
	end, TIME)
end, {})

map({ "n", "v" }, "j", function()
	if g_pressed then
		-- g was pressed before j, trigger leap-forward
		g_pressed = false
		if timer then
			timer:stop()
			timer = nil
		end
		execute_leap_forward()
	else
		-- do the normal 'j' movement
		vim.api.nvim_feedkeys("j", "n", true)
	end
end, {})

map({ "n", "v" }, "k", function()
	if g_pressed then
		-- g was pressed before k, trigger leap-backward
		g_pressed = false
		if timer then
			timer:stop()
			timer = nil
		end
		execute_leap_backward()
	else
		-- do the normal 'k' movement
		vim.api.nvim_feedkeys("k", "n", true)
	end
end, {})

map({ "n" }, ",l", "<Plug>(leap-from-window)")
