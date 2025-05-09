--- Module for handling mini.diff highlight synchronization
local M = {}

--- Set up function to sync mini.diff highlights with current colorscheme
local function sync_diff_highlights()
	-- Link the MiniDiff's custom highlights to the default diff highlights
	-- Set highlight color for added lines to match the default DiffAdd highlight
	vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { link = "DiffAdd" })
	-- Set highlight color for deleted lines to match the default DiffDelete highlight
	vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { link = "DiffDelete" })
	-- Set highlight color for changed lines to match the default DiffChange highlight
	vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffChange" })
	-- Set highlight color for context lines to match the default DiffText highlight
	vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "DiffText" })
end

--- Initialize mini.diff highlight synchronization
--- Sets up initial highlights and creates an autocmd to update on colorscheme changes
function M.setup()
	-- Initial highlight setup
	sync_diff_highlights()

	-- Update highlights when colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = sync_diff_highlights,
		group = vim.api.nvim_create_augroup("CodeCompanionDiffHighlights", {}),
	})
end

return M

