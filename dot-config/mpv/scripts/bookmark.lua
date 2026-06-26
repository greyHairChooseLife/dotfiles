---@class Mpv
---@field add_key_binding fun(key: string, name: string, fn: fun())
---@field get_property_number fun(name: string): number?
---@field set_property fun(name: string, value: any)
---@field osd_message fun(msg: string, duration?: number)

---@type Mpv
---@diagnostic disable-next-line: lowercase-global
mp = mp

-- Multi-bookmark: b to add, B to remove nearest, n/p to navigate by index
local bookmarks = {}
local current = nil -- nil means no index yet

mp.add_key_binding("b", "bookmark-set", function()
	local pos = mp.get_property_number("time-pos")
	table.insert(bookmarks, pos)
	table.sort(bookmarks)
	mp.osd_message(string.format("Bookmark added: %.1fs (%d total)", pos, #bookmarks))
end)

mp.add_key_binding("B", "bookmark-remove", function()
	if #bookmarks == 0 then
		mp.osd_message("No bookmarks")
		return
	end
	local pos = mp.get_property_number("time-pos")
	local nearest_idx = 1
	local nearest_dist = math.abs(bookmarks[1] - pos)
	for i = 2, #bookmarks do
		local dist = math.abs(bookmarks[i] - pos)
		if dist < nearest_dist then
			nearest_dist = dist
			nearest_idx = i
		end
	end
	local removed = table.remove(bookmarks, nearest_idx)
	-- adjust current index
	if current ~= nil then
		if #bookmarks == 0 then
			current = nil
		elseif nearest_idx <= current then
			current = math.max(1, current - 1)
		end
	end
	mp.osd_message(string.format("Bookmark removed: %.1fs (%d remaining)", removed, #bookmarks))
end)

mp.add_key_binding("n", "bookmark-next", function()
	if #bookmarks == 0 then
		mp.osd_message("No bookmarks")
		return
	end
	if current == nil then
		current = 1
	else
		current = (current % #bookmarks) + 1
	end
	mp.set_property("time-pos", bookmarks[current])
	mp.osd_message(string.format("Bookmark %d/%d: %.1fs", current, #bookmarks, bookmarks[current]))
end)

mp.add_key_binding("p", "bookmark-prev", function()
	if #bookmarks == 0 then
		mp.osd_message("No bookmarks")
		return
	end
	if current == nil then
		current = #bookmarks
	else
		current = ((current - 2) % #bookmarks) + 1
	end
	mp.set_property("time-pos", bookmarks[current])
	mp.osd_message(string.format("Bookmark %d/%d: %.1fs", current, #bookmarks, bookmarks[current]))
end)
