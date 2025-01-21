local utils = require("utils")

function TelescopeSearchVisual()
	local text = utils.get_visual_text()
	require("telescope.builtin").live_grep({ default_text = text })
end
