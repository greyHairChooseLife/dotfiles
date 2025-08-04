local session_file_dir = vim.fn.stdpath("data") .. "/sessions/"
local was_codecompanion_visible = false

local function save_tab_names()
	local tab_names = {}
	for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local name = vim.t[tabpage].tabname or "no name"
		tab_names[i] = name
	end
	return tab_names
end

local function restore_tab_names(tab_names)
	if not tab_names then
		return
	end
	for i, name in pairs(tab_names) do
		if vim.fn.tabpagenr("$") >= i then
			-- 문자열이 아니면 변환
			if type(name) ~= "string" then
				name = tostring(name)
			end
			vim.api.nvim_tabpage_set_var(i, "tabname", name)
		end
	end
end

return {
	"rmagatti/auto-session",
	cmd = { "SessionSearch", "SessionSave" },
	opts = {
		log_level = "error",
		bypass_save_filetypes = { "alpha", "codecompanion" }, -- not working
		auto_session_suppress_dirs = { "~/", "~/test", "~/Downloads", "/*" },
		session_lens = {
			-- buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
			-- load_on_setup = true,
			-- theme = "ivy", -- default is dropdown
			theme_conf = {
				border = true,
			},
			-- previewer = true,
			path_dispaly = { "tail" },
		},
		auto_save_enabled = false,
		-- ignore_filetypes_on_save = { "checkhealth", "codecompanion" }, -- codecompanion은 내 방식이 더 낫다, 지금은
		pre_save_cmds = {
			function()
				local cdc = require("codecompanion")
				if cdc.last_chat() and cdc.last_chat().ui:is_visible() then
					cdc.toggle()
					was_codecompanion_visible = true
				end
			end,
		},
		post_save_cmds = {
			function()
				local session_name = vim.fn.fnamemodify(vim.v.this_session or vim.fn.getcwd(), ":t")
				local tab_names = save_tab_names()
				if next(tab_names) ~= nil then
					local tab_names_file = session_file_dir .. session_name .. "_tabnames.json"
					local file = io.open(tab_names_file, "w")
					if file then
						file:write(vim.fn.json_encode(tab_names))
						file:close()
					end
				end
			end,
			function()
				local cdc = require("codecompanion")
				if was_codecompanion_visible then
					cdc.toggle()
				end
			end,
		},
		post_restore_cmds = {
			function()
				local session_name = vim.fn.fnamemodify(vim.v.this_session or vim.fn.getcwd(), ":t")
				local tab_names_file = session_file_dir .. session_name .. "_tabnames.json"
				local file = io.open(tab_names_file, "r")
				if file then
					local content = file:read("*all")
					file:close()
					local tab_names = vim.fn.json_decode(content)
					restore_tab_names(tab_names)
				end
			end,
		},
		pre_delete_cmds = {
			function()
				local session_name = vim.fn.fnamemodify(vim.v.this_session or vim.fn.getcwd(), ":t")
				local tab_names_file = session_file_dir .. session_name .. "_tabnames.json"
				vim.notify(tab_names_file)
				os.remove(tab_names_file)
			end,
		},
		-- Save quickfix list and open it when restoring the session
		save_extra_cmds = {
			function()
				local qflist = vim.fn.getqflist()
				-- return nil to clear any old qflist
				if #qflist == 0 then
					return nil
				end
				local qfinfo = vim.fn.getqflist({ title = 1 })

				for _, entry in ipairs(qflist) do
					-- use filename instead of bufnr so it can be reloaded
					entry.filename = vim.api.nvim_buf_get_name(entry.bufnr)
					entry.bufnr = nil
				end

				local setqflist = "call setqflist(" .. vim.fn.string(qflist) .. ")"
				local setqfinfo = 'call setqflist([], "a", ' .. vim.fn.string(qfinfo) .. ")"
				return { setqflist, setqfinfo, "copen" }
			end,
		},
	},
}
