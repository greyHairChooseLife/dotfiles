-- Day / night switch for the whole UI.
--
-- `<Space>ut` toggles between the dark and the light palette (UI/palette.lua).
-- The choice is stored in `stdpath("state")/ui-background` and restored on
-- start, so a manual switch survives a restart.
--
-- Order matters: 'background' alone does not reload the colorscheme, and
-- TokyoNight picks its `light_style` (day) from 'background' on load. So set
-- the option, reload the colorscheme, then let the ColorScheme autocmd push
-- the palette into the custom highlights and lualine.
local M = {}

local state_file = vim.fn.stdpath("state") .. "/ui-background"

local function read_state()
    local file = io.open(state_file, "r")
    if not file then return nil end
    local background = file:read("*l")
    file:close()
    if background == "dark" or background == "light" then return background end
end

local function write_state(background)
    local file = io.open(state_file, "w")
    if not file then return end
    file:write(background, "\n")
    file:close()
end

--- lualine_components resolves its colors and its per-filetype extension
--- tables when the module is loaded. Drop both modules so requiring them again
--- rebuilds everything against the current palette.
local function refresh_lualine()
    package.loaded["UI.modules.lualine_components"] = nil
    package.loaded["UI.plugins.lualine"] = nil

    local ok, spec = pcall(require, "UI.plugins.lualine")
    if not ok or type(spec) ~= "table" or type(spec.config) ~= "function" then
        vim.notify("[UI.theme] lualine spec not available", vim.log.levels.WARN)
        return
    end

    local applied, err = pcall(spec.config)
    if not applied then vim.notify("[UI.theme] lualine refresh failed: " .. tostring(err), vim.log.levels.WARN) end
end

--- Re-apply every palette driven highlight for the current 'background'.
function M.apply()
    require("UI.highlights").apply()
    refresh_lualine()
end

---@param background "dark"|"light"
function M.set(background)
    if background ~= "dark" and background ~= "light" then
        vim.notify("[UI.theme] unknown background: " .. tostring(background), vim.log.levels.ERROR)
        return
    end

    write_state(background)
    vim.o.background = background
    vim.cmd.colorscheme("tokyonight") -- -> ColorScheme -> M.apply()
end

function M.toggle() M.set(vim.o.background == "light" and "dark" or "light") end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UITheme", { clear = true }),
    callback = function()
        -- only our own colorscheme shares the palette; leave others untouched
        if (vim.g.colors_name or ""):match("^tokyonight") then M.apply() end
    end,
})

local saved = read_state()
if saved and saved ~= vim.o.background then
    M.set(saved) -- reloads the colorscheme and applies the palette
else
    require("UI.highlights").apply()
end

return M
