-- Multi-bookmark: b to add, p/n to navigate by index
local bookmarks = {}
local current = nil  -- nil means no index yet

mp.add_key_binding("b", "bookmark-set", function()
    local pos = mp.get_property_number("time-pos")
    table.insert(bookmarks, pos)
    table.sort(bookmarks)
    mp.osd_message(string.format("Bookmark added: %.1fs (%d total)", pos, #bookmarks))
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
