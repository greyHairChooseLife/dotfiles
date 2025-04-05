local function generate_review_message()
	local handle_diff = io.popen("git --no-pager log -p HEAD^..HEAD")
	local handle_git_files =
		io.popen("git diff --name-only HEAD^..HEAD | xargs -I {} sh -c 'echo ===== {}; git show HEAD^:{}'")

	if handle_diff == nil then
		return nil
	end

	local diff = ""
	local git_files = ""
	if handle_diff ~= nil then
		diff = handle_diff:read("*a")
		handle_diff:close()
	end
	if handle_git_files ~= nil then
		git_files = handle_git_files:read("*a")
		handle_git_files:close()
	end

	local content = [[
Please read the provided Git diff and write a concise technical report in Korean, following the structure below. Respond only in Korean.

Structure:
- Title: One-line summary
- Summary of Changes
- Description of Functional or Behavioral Impact
- Examples in a format of 'as-is, to-be'",


### Git-diff

]]
	if #diff > 0 then
		content = content
			.. "== Diff Start(`git --no-pager log -p HEAD^..HEAD`) ==\n```diff\n"
			.. diff
			.. "\n```\n== Diff End(`git --no-pager log -p HEAD^..HEAD`) ==\n\n"
	end
	if #git_files > 0 then
		content = content
			.. "== Related git_files Start(`git diff --name-only HEAD^..HEAD | xargs -I {} sh -c 'echo ===== {}; git show HEAD^:{}'`) ==\n```bash\n"
			.. git_files
			.. "\n```\n== Related git_files End(`git diff --name-only HEAD^..HEAD | xargs -I {} sh -c 'echo ===== {}; git show HEAD^:{}'`) ==\n\n"
	end

	return content
end

---@param chat CodeCompanion.Chat
local function callback(chat)
	local content = generate_review_message()
	if content == nil then
		vim.notify("No git diff available", vim.log.levels.INFO, { title = "CodeCompanion" })
		return
	end
	chat:add_buf_message({
		role = "user",
		content = content,
	})
end

return {
	description = "ReviewCommit-Deep",
	callback = callback,
	opts = {
		contains_code = true,
	},
}
