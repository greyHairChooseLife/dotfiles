-- MEMO:: Language Server의 본명과 Mason에서 인식하는 이름이 서로 다르다.
-- 이 맵핑 관계를 확인할 수 있는 커맨드는 아래와 같다.
--
--                                               *mason-lspconfig.get_mappings()*
-- get_mappings()
--     Returns:
--         - server name mappings between nvim-lspconfig and Mason.
--         - filetype mappings for supported servers

--     Returns: ~
--         {
--             lspconfig_to_package: table<string, string>,
--             package_to_lspconfig: table<string, string>,
--             filetypes: table<string, string[]>
--         }

--     Note: ~
--         This function only returns nvim-lspconfig servers that are recognized
--         by Mason.

--     Example:
--
--     ## From Lua code
--     local mappings = require('mason-lspconfig').get_mappings()
--     print(vim.inspect(mappings))

--     ## From Neovim command line
--     :lua local mappings = require('mason-lspconfig').get_mappings(); print(vim.inspect(mappings))

return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"html",
				"superhtml",
				"biome",
				"ts_ls",
				"pylsp",
				"ruff",
				"basedpyright",
				"taplo",
				"yamlls",
				"dockerls", -- "dockerfile-language-server",
				"docker_compose_language_service", -- "docker-compose-language-service",
			},
			---@type boolean | string[] | { exclude: string[] }
			automatic_enable = false,
		})
	end,
}
