--[[
*Change Adapter Tool*
This tool is used to change adapter for better performance.
--]]

local change_adapter = require("AI.codecompanion.utils.deprecated.change_adapter")
local codecompanion = require("codecompanion")
local config = require("codecompanion.config")

---@class CodeCompanion.Agent.Tool
return {
	name = "change_adapter",
	adapters = {},
	cmds = {
		---@param action table The action object
		---@return { status: string, msg: string }
		function(_, action, _)
			local current_chat = codecompanion.last_chat()
			local ok, result = pcall(change_adapter, current_chat, action.adapter, action.model)
			if not ok then
				return { status = "error", msg = result, data = result }
			end

			return { status = "success", msg = result, data = result }
		end,
	},
	schema = {
		{
			tool = {
				_attr = { name = "change_adapter" },
				action = {
					adapter = "value",
					model = "value",
				},
			},
		},
	},
	system_prompt = function(_)
		local current_chat = codecompanion.last_chat()
		return string.format(
			[[# Change Adapter Tool (`change_adapter`)
This tool is used for selecting a best model for improving overall quality of LLMs.

NOTE: You should always consider that if there's another better model which fits current tasks.
IMPORTANT: When you planing, use reasoning models; when you executing, use non-reasoning models.

Current adapter is %s, model is %s.

## Description
- tool name: `change_adapter`
- action type: none
  - element `adapter`: name of the adapter to switch to
  - element `model`: name of the model to use
- sequential execution: no
- provided adapters and models:
  - copilot
    - claude-3.5-sonnet: good at writing code and commands execution, fast, but not good at reasoning. Recommended in most common daily coding and most commands executing.
    - claude-3.7-sonnet-thought: excellent at writing code and commands execution, also good at reasoning. But slow. Only recommended in very complex coding.
    - claude-3.7-sonnet: good at writing code and commands execution, fast, but not good at reasoning, also with some limitations. Only recommended in more complex coding tasks.
    - o3-mini: excellent at reasoning, scheduling, and STEM: Science, Technology, Engineering, and Mathematics. But with limitations. Highly recommended in scheduling and conclusion tasks. Do not writing codes or executing commands with this model.
    - gpt-4o: good at overall tasks and don't have limitations, but not good at writing code and commands execution.
    - o1: excellent at reasoning and conclusion. But not good at STEM and writing code and commands execution. Also have limitations, and slow. Only recommended in deep conclusion. Do not writing codes or executing commands with this model.
  - deepseek
    - deepseek-reasoner: good at reasoning. Very cheap. Recommended in scheduling, but do not writing codes or executing commands with this model.

## Key Considerations
- Both adapter and model must be provided
- The adapter must be one of the configured adapters
- The model must be supported by the selected adapter
- Choose the best model for the current task

HINT: For example, if you're going to do a complex task, you can first use `o3-mini` to schedule, and then change to claude models for executing, and at last switch to o1 for summary.
]],
			current_chat and current_chat.adapter.name or "unknown",
			current_chat and current_chat.adapter.schema.model.default or "unknown"
		)
	end,
	output = {
		---@param self CodeCompanion.Agent.Tool
		prompt = function(_, self)
			local action = self.request.action
			return string.format("Change adapter to %s/%s?", action.adapter, action.model)
		end,

		---@param agent CodeCompanion.Agent
		rejected = function(agent)
			if not vim.g.codecompanion_auto_tool_mode then
				agent.status = "rejected"
			end
			agent.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = "I chose not to change the adapter.",
			})
		end,

		---@param agent CodeCompanion.Agent
		error = function(agent, _, err)
			agent.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("Failed to change adapter.:\n<error>\n%s\n</error>", vim.inspect(err)),
			})
		end,

		---@param agent CodeCompanion.Agent
		success = function(agent, action)
			agent.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("Successfully changed model to: %s/%s", action.adapter, action.model),
			})
		end,
	},
}
