-- reference
-- https://github.com/yetone/avante.nvim/wiki/Recipe-and-Tricks
local M = {}
local AS = require("avante.api").ask
local AE = require("avante.api").edit
local prefill = {}

prefill.code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
  Answer in Korean.
]]
prefill.optimize_code = "Optimize the following code"
prefill.explain_diagnostics = "Explain and solve the following diagnostics in Korean \n"
prefill.explain_code = "Explain the following code in Korean"
prefill.add_docstring = "Add docstring to the following codes in Korean"
prefill.fix_bugs = "Fix the bugs inside the following codes if any"
prefill.add_tests = "Implement tests for the following code"

M.prefill_1 = function()
	AS({ question = prefill.code_readability_analysis })
end
M.prefill_2 = function()
	AS({ question = prefill.optimize_code })
end
M.prefill_3 = function()
	local diagnostics = CopyDiagnosticsAtLine()

	local new_prefill = prefill.explain_diagnostics .. diagnostics

	AS({ question = new_prefill })
end
M.prefill_4 = function()
	AS({ question = prefill.explain_code })
end
M.prefill_5 = function()
	AS({ question = prefill.add_docstring })
end
M.prefill_6 = function()
	AS({ question = prefill.fix_bugs })
end
M.prefill_7 = function()
	AS({ question = prefill.add_tests })
end

return M
