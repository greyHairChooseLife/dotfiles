local M = {}

local excluded_models = {
    ["GPT-5 mini (0x)"] = false,
    ["Claude Haiku 4.5 (0.33x)"] = false,
    ["Claude Sonnet 4.6 (1x)"] = false,
    ["Gemini 3.1 Pro (1x)"] = false,
    ["Claude Opus 4.6 (3x)"] = false,
    --------------------------------------
    ["Claude Opus 4.5 (3x)"] = true,
    ["Claude Opus 4.5 (3x)"] = true,
    ["Claude Sonnet 4 (1x)"] = true,
    ["Claude Sonnet 4.5 (1x)"] = true,
    ["GPT-4.1 (0x)"] = true,
    ["GPT-4o (0x)"] = true,
    ["GPT-5.1 (1x)"] = true,
    ["GPT-5.1-Codex (1x)"] = true,
    ["GPT-5.1-Codex-Max (1x)"] = true,
    ["GPT-5.1-Codex-Mini (0.33x)"] = true,
    ["GPT-5.2 (1x)"] = true,
    ["GPT-5.2-Codex (1x)"] = true,
    ["GPT-5.3-Codex (1x)"] = true,
    ["GPT-5.4 (1x)"] = true,
    ["Gemini 2.5 Pro (1x)"] = true,
    ["Gemini 3 Pro (Preview) (1x)"] = true,
    ["Grok Code Fast 1 (0.25x)"] = true,
    ["Raptor mini (Preview) (0x)"] = true,
}

function M.setup()
    local keymap_mod = require("codecompanion.interactions.chat.keymaps.change_adapter")
    local original_select_model = keymap_mod.select_model

    keymap_mod.select_model = function(chat)
        -- Temporarily wrap list_http_models and list_acp_models to filter results
        local original_http = keymap_mod.list_http_models
        local original_acp = keymap_mod.list_acp_models

        keymap_mod.list_http_models = function(adapter)
            local models = original_http(adapter)
            if not models then return models end
            local filtered = {}
            for _, model in ipairs(models) do
                local name = type(model) == "table" and (model.description or model.formatted_name or model.id or "") or tostring(model)
                if not excluded_models[name] then filtered[#filtered + 1] = model end
            end
            return filtered
        end

        keymap_mod.list_acp_models = function(acp_connection)
            local result = original_acp(acp_connection)
            if not result or not result.availableModels then return result end
            local filtered = {}
            for _, model in ipairs(result.availableModels) do
                local name = type(model) == "table" and (model.name or model.modelId or "") or tostring(model)
                if not excluded_models[name] then filtered[#filtered + 1] = model end
            end
            return vim.tbl_extend("force", result, { availableModels = filtered })
        end

        original_select_model(chat)

        -- Restore originals
        keymap_mod.list_http_models = original_http
        keymap_mod.list_acp_models = original_acp
    end
end

return M
