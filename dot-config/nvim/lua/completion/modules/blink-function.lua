local M = {
	-- MEMO::
	-- {
	--   accept = <function 1>,
	--   accept_and_enter = <function 2>,
	--   add_filetype_source = <function 3>,
	--   add_provider = <function 4>,
	--   add_source_provider = <function 5>,
	--   cancel = <function 6>,
	--   get_items = <function 7>,
	--   get_lsp_capabilities = <function 8>,
	--   get_selected_item = <function 9>,
	--   get_selected_item_idx = <function 10>,
	--   hide = <function 11>,
	--   hide_documentation = <function 12>,
	--   hide_signature = <function 13>,
	--   insert_next = <function 14>,
	--   insert_prev = <function 15>,
	--   is_active = <function 16>,
	--   is_documentation_visible = <function 17>,
	--   is_ghost_text_visible = <function 18>,
	--   is_menu_visible = <function 19>,
	--   is_signature_visible = <function 20>,
	--   is_visible = <function 21>,
	--   reload = <function 22>,
	--   resubscribe = <function 23>,
	--   scroll_documentation_down = <function 24>,
	--   scroll_documentation_up = <function 25>,
	--   select_accept_and_enter = <function 26>,
	--   select_and_accept = <function 27>,
	--   select_next = <function 28>,
	--   select_prev = <function 29>,
	--   setup = <function 30>,
	--   show = <function 31>,
	--   show_and_insert = <function 32>,
	--   show_documentation = <function 33>,
	--   show_signature = <function 34>,
	--   snippet_active = <function 35>,
	--   snippet_backward = <function 36>,
	--   snippet_forward = <function 37>
	-- }
}

local cmp_state = {
	is_init = false,
	sort = "lsp", -- 'buffer', 'lsp' or 'snippets', 어떤 completion이 로드되었는지 상태를 저장
}

---Shows completion items from specified provider
---@param cmp table The completion engine instance
---@param sort string The provider to sort by ("lsp", "buffer", etc.)
---@param initial_select boolean|nil Whether to select the first item automatically (defaults to false)
---@return boolean Always returns true to prevent executing the next command in keymap chain
local function show_provider(cmp, sort, initial_select)
	initial_select = initial_select or false
	if sort == "lsp" then
		cmp.show({
			-- DEPRECATED:: 2025-05-21 codecompanion works out of box
			-- providers = { sort, "path", "codecompanion" },
			providers = { sort, "path" },
			initial_selected_item_idx = initial_select == true and 1 or nil,
		})
	else
		cmp.show({
			providers = { sort },
			initial_selected_item_idx = initial_select == true and 1 or nil,
		})
	end
	cmp_state.sort = sort
	print(sort)
	return true -- doesn't runs the next command in keymap setting
end

M.cancel = function(cmp)
	if cmp.is_menu_visible() then
		cmp_state.is_init = false -- 초기화
		return cmp.cancel()
	end
end

M.hide = function(cmp)
	if cmp.is_menu_visible() then
		cmp_state.is_init = false -- 초기화
		cmp.hide()
	end
end

--- Shows the completion menu for a specific provider
--- @param cmp table The completion engine instance
--- @param provider string The name of the completion provider to use
--- @param initial_select boolean Whether to select the first item automatically (defaults to false)
--- @return any Result from show_provider if menu isn't already visible
M.show = function(cmp, provider, initial_select)
	initial_select = initial_select or false
	if not cmp.is_menu_visible() then
		cmp_state.is_init = true
		return show_provider(cmp, provider, initial_select)
	end
end

M.next_provider = function(cmp)
	if not cmp_state.is_init then
		cmp_state.is_init = true
		return show_provider(cmp, "lsp")
	elseif cmp_state.sort == "lsp" then
		return show_provider(cmp, "buffer")
	elseif cmp_state.sort == "buffer" then
		return show_provider(cmp, "lsp")
	end
end

M.prev_provider = function(cmp)
	if not cmp_state.is_init then
		cmp_state.is_init = true
		return show_provider(cmp, "buffer")
	elseif cmp_state.sort == "buffer" then
		return show_provider(cmp, "lsp")
	elseif cmp_state.sort == "lsp" then
		return show_provider(cmp, "buffer")
	end
end

M.super_tab = function(cmp)
	if cmp.snippet_active() then
		cmp_state.is_init = false -- 초기화
		return cmp.accept()
	elseif cmp.is_menu_visible() then
		cmp_state.is_init = false -- 초기화
		return cmp.select_and_accept()
	end
end

M.accept_and_enter = function(cmp)
	if cmp.snippet_active() then
		cmp_state.is_init = false -- 초기화
		return cmp.accept()
	elseif cmp.is_menu_visible() then
		cmp_state.is_init = false -- 초기화
		cmp.select_and_accept()
		vim.schedule(function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "t", false)
		end)
		return true
	end
end

M.toggle_documentation = function(cmp)
	if not cmp.is_menu_visible() then
		return false
	end

	if cmp.is_documentation_visible() then
		return cmp.hide_documentation()
	else
		return cmp.show_documentation()
	end
end

M.toggle_signature = function(cmp)
	if cmp.is_signature_visible() then
		return cmp.hide_signature()
	else
		return cmp.show_signature()
	end
end

return M
