local M = {}

local state = ya.sync(function()
	local selected = {}
	for _, f in pairs(cx.active.selected) do
		selected[#selected + 1] = f.url
	end
	return cx.active.current.cwd, selected
end)

function M:entry()
	ya.emit("escape", { visual = true })

	local cwd, selected = state()
	if cwd.scheme.is_virtual then
		return ya.notify { title = "Fzf CWD", content = "Not supported under virtual filesystems", timeout = 5, level = "warn" }
	end

	local permit = ui.hide()
	local output, err = M.run_with(cwd, selected)

	permit:drop()
	if not output then
		return ya.notify { title = "Fzf CWD", content = tostring(err), timeout = 5, level = "error" }
	end

	local urls = M.split_urls(cwd, output)
	if #urls == 0 then
		return
	elseif #urls == 1 then
		local cha = #selected == 0 and fs.cha(urls[1])
		return ya.emit(cha and cha.is_dir and "cd" or "reveal", { urls[1], raw = true })
	end

	local files = {}
	for _, url in ipairs(urls) do
		files[#files + 1] = fs.file(url)
	end
	if #files > 0 then
		files.state = #selected > 0 and "off" or "on"
		ya.emit("toggle_all", files)
	end
end

---@param cwd Url
---@param selected Url[]
---@return string?, Error?
function M.run_with(cwd, selected)
	local hidden_state = "/tmp/fzf-yazi-hidden"
	local f = io.open(hidden_state, "w")
	if f then f:write("0"); f:close() end

	local child, err = Command("fzf")
		:arg("-m")
		:cwd(tostring(cwd))
		:env("FZF_DEFAULT_COMMAND", "fd . --max-depth=1 --strip-cwd-prefix --type f | sort")
		:env("FZF_DEFAULT_OPTS", os.getenv("FZF_DEFAULT_OPTS") or "")
		:arg("--header") :arg("<Alt+h>: toggle hidden")
		:arg("--bind")
		:arg('alt-h:transform:HIDDEN=$(cat ' .. hidden_state .. ' 2>/dev/null || echo 0); if [ "$HIDDEN" = 0 ]; then echo "reload(fd . --max-depth=1 --strip-cwd-prefix --hidden --no-ignore --type f | sort)+change-prompt(+hidden )+execute-silent(echo 1 > ' .. hidden_state .. ')"; else echo "reload(fd . --max-depth=1 --strip-cwd-prefix --type f | sort)+change-prompt()+execute-silent(echo 0 > ' .. hidden_state .. ')"; fi')
		:stdin(#selected > 0 and Command.PIPED or Command.INHERIT)
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		os.remove(hidden_state)
		return nil, Err("Failed to start `fzf`, error: %s", err)
	end

	for _, u in ipairs(selected) do
		child:write_all(string.format("%s\n", u))
	end
	if #selected > 0 then
		child:flush()
	end

	local output, err = child:wait_with_output()
	os.remove(hidden_state)
	if not output then
		return nil, Err("Cannot read `fzf` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`fzf` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

function M.split_urls(cwd, output)
	local t = {}
	for line in output:gmatch("[^\r\n]+") do
		local u = Url(line)
		t[#t + 1] = u.is_absolute and u or cwd:join(u)
	end
	return t
end

return M
