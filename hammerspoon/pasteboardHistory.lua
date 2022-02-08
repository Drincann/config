pastboard = {}
pastboard.history = {}

pastboard.minifyHistory = {}
pastboard.log = hs.logger.new("script", "debug")
pastboard.iscopy = false
pastboard.max = 10
pastboard.maxMinifyLength = 50
pastboard.watcher = hs.pasteboard.watcher.new(function(content)
    if content == nil then
        return
    end
    if pastboard.iscopy then
        pastboard.iscopy = false
        return
    end
    if #pastboard.history >= pastboard.max then
        table.remove(pastboard.history, pastboard.max)
        table.remove(pastboard.minifyHistory, pastboard.max)
    end
    table.insert(pastboard.history, 1, content)
    table.insert(pastboard.minifyHistory, 1, string.sub(content, 1, pastboard.maxMinifyLength))
    -- showStr = ""
    -- for i, v in ipairs(minifyHistory) do
    --     showStr = showStr .. i .. ". " .. v .. "\n"
    -- end
    -- hs.alert.closeAll()
    -- hs.alert.show(showStr, {
    --     atScreenEdge = 1,
    --     textFont = "Fira Code",
    --     textSize = 20,
    --     padding = 50
    -- })

end)
pastboard.ALT = hs.keycodes.map["alt"]
pastboard.V = hs.keycodes.map["V"]
pastboard.numkeys = {}
pastboard.numkeys[hs.keycodes.map["1"]] = 1
pastboard.numkeys[hs.keycodes.map["2"]] = 2
pastboard.numkeys[hs.keycodes.map["3"]] = 3
pastboard.numkeys[hs.keycodes.map["4"]] = 4
pastboard.numkeys[hs.keycodes.map["5"]] = 5
pastboard.numkeys[hs.keycodes.map["6"]] = 6
pastboard.numkeys[hs.keycodes.map["7"]] = 7
pastboard.numkeys[hs.keycodes.map["8"]] = 8
pastboard.numkeys[hs.keycodes.map["9"]] = 9
pastboard.numkeys[hs.keycodes.map["0"]] = 10
pastboard.historyViewIsOpen = false
pastboard.eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local currKey = e:getKeyCode()
    local flagTable = e:getFlags()
    local altState = flagTable['alt']
    -- pastboard.log.i(currKey)
    -- pastboard.log.i(altState)
    if altState and currKey == pastboard.V then
        if pastboard.historyViewIsOpen then
            return true
        end
        pastboard.historyViewIsOpen = true
        local showStr = ""
        for i, v in ipairs(pastboard.minifyHistory) do
            showStr = showStr .. i .. ". " .. v .. "\n"
        end
        hs.alert.show(showStr, {
            atScreenEdge = 1,
            textFont = "Fira Code",
            textSize = 20,
            padding = 50
        }, 'infinite')
        return true
    end
    if altState and pastboard.numkeys[currKey] then
        local index = pastboard.numkeys[currKey]
        if index <= #pastboard.history then
            pastboard.iscopy = true
            hs.pasteboard.setContents(pastboard.history[index])
            hs.alert.show('copy ' .. index .. ". " .. pastboard.minifyHistory[index], {
                atScreenEdge = 1,
                textFont = "Fira Code",
                textSize = 20,
                padding = 50
            })
            return true
        end
    end
end)
pastboard.eventKeyDown:start()

pastboard.eventUp = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local currKey = e:getKeyCode()
    local flagTable = e:getFlags()
    local altState = flagTable['alt']
    -- pastboard.log.i(currKey)
    -- pastboard.log.i(altState)
    if pastboard.historyViewIsOpen and (altState == nil or currKey == pastboard.V) then
        pastboard.historyViewIsOpen = false
        hs.alert.closeAll()
        return true
    end

end)
pastboard.eventUp:start()

return pastboard
