directionkey = {}
local function sendKey(mod, key)
    hs.eventtap.event.newKeyEvent(mod, key, true):post()
    hs.eventtap.event.newKeyEvent(mod, key, false):post()
end

-- hs.timer.doAfter(30, function() hs.reload() end)
-- local directionkey.log = hs.directionkey.logger.new("script", "debug")

-- local counter = 0
-- local event = nil
-- event = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function()
--     counter = counter + 1
--     hs.alert.closeAll()
--     hs.alert(counter)
--     directionkey.log.i(event:isEnabled())
-- end):start()

directionkey.capslock = 31
directionkey.J = hs.keycodes.map["J"]
directionkey.K = hs.keycodes.map["K"]
directionkey.L = hs.keycodes.map["L"]
directionkey.I = hs.keycodes.map["I"]
directionkey.E = hs.keycodes.map["E"]
directionkey.R = hs.keycodes.map["R"]
directionkey.D = hs.keycodes.map["D"]
directionkey.F = hs.keycodes.map["F"]
directionkey.ALT = hs.keycodes.map["alt"]
directionkey.CMD = hs.keycodes.map["cmd"]
directionkey.capState = false;
directionkey.log = hs.logger.new("script", "debug")
directionkey.eventDown = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(e)
    -- log.i(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == directionkey.capslock then
        directionkey.capState = true
        hs.alert.closeAll()
        -- 不消失
        hs.alert.show('dir mod', {
            atScreenEdge = 2,
            textFont = "Fira Code",
            textSize = 20
        }, 10000)
        -- log.i("capslock toggle")
        return true
    end
end)
directionkey.eventDown:start()

directionkey.eventUp = hs.eventtap.new({hs.eventtap.event.types.otherMouseUp}, function(e)
    -- directionkey.log.i(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == directionkey.capslock then
        directionkey.capState = false
        hs.alert.closeAll()
        -- hs.alert.show(capState,{atScreenEdge=2, textFont="Fira Code", textSize=20}, 'infi')
        return true
    end

end)
directionkey.eventUp:start()

directionkey.eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    -- directionkey.log.i(e:getKeyCode())

    if directionkey.capState then
        local currKey = e:getKeyCode()

        -- directionkey.log.i("otherkey down")
        if currKey == directionkey.J then
            sendKey(nil, "left")
            return true
        end
        if currKey == directionkey.K then
            sendKey(nil, "down")
            return true
        end
        if currKey == directionkey.L then
            sendKey(nil, "right")
            return true
        end
        if currKey == directionkey.I then
            sendKey(nil, "up")
            return true
        end
        if currKey == directionkey.E then
            sendKey({"cmd"}, "left")
            return true
        end
        if currKey == directionkey.R then
            sendKey({"cmd"}, "right")
            return true
        end
        if currKey == directionkey.D then
            sendKey({"alt"}, "left")
            return true
        end
        if currKey == directionkey.F then
            sendKey({"alt"}, "right")
            return true
        end
    end
end)
directionkey.eventKeyDown:start()

return directionkey
