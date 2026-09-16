-- Fold helpers shared by picker / zk_search.
-- Opening a buffer in a new window resets foldmethod, so fold state is lost.
-- Borrowed from snacks.picker's built-in jump action (snacks/picker/actions.lua).
local M = {}

--- Reapply foldmethod="expr" to the current window, deferred.
--- Uses vim.wo so the global default is not overwritten.
function M.fix()
    if vim.wo.foldmethod == "expr" then
        vim.schedule(function() vim.wo.foldmethod = "expr" end)
    end
end

return M
