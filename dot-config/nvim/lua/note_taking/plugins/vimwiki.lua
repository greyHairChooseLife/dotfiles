return {
	-- The plugin location on GitHub
	"vimwiki/vimwiki",
	-- The event that triggers the plugin
	-- lazy = false,
	event = "BufEnter *.md",
	cmd = "VimwikiIndex",
	-- The configuration for the plugin
	init = function()
		vim.g.vimwiki_global_ext = 0 -- 문제 해결: vimwiki 설정이 markdown 설정을 침투하지 않게 하기

		vim.g.vimwiki_list = {
			{
				path = "~/Documents/dev-wiki/notes/",
				-- path_html = "~/Documents/vimwiki/",
				syntax = "markdown",
				ext = ".md",
				links_space_char = "_", -- link에 띄어쓰기를 알아서 '_'로 바꿔줌
			},
			{
				path = "~/Documents/job-wiki/notes/",
				syntax = "markdown",
				ext = ".md",
				links_space_char = "_",
			},
		}

		vim.g.vimwiki_key_mappings = {
			global = 0,
			lists = 0,
			links = 0,
			table_format = 0,
		}

		vim.g.vimwiki_create_link = 0

		vim.g.vimwiki_folding = "custom"

		vim.api.nvim_create_autocmd("BufWinEnter", {
			pattern = "*",
			callback = function()
				if vim.tbl_contains({ "markdown", "md", "vimwiki" }, vim.bo.filetype) then
					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldenable = true
					vim.opt_local.foldtext = "v:lua.markdown_fold_text(v:foldstart, v:foldend, v:foldlevel)"
					vim.opt_local.foldexpr = "v:lua.markdown_fold_expr(v:lnum)"
				end
			end,
		})

		-- TODO: 편의기능 개선
		-- 또한, 이외에도 static file의 주소를 가져온 뒤 손쉽게 하이퍼링크를 만들어주는 것도 해주자. 그림파일인지는 확장자를 통해 판단하면 되니 모든 종류의 스태틱 파일에 동일한 커맨드를 사용가능할듯.
	end,
}
