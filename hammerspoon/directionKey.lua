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
directionkey.H = hs.keycodes.map["H"]
directionkey.K = hs.keycodes.map["K"]
directionkey.L = hs.keycodes.map["L"]
directionkey.I = hs.keycodes.map["I"]
directionkey.E = hs.keycodes.map["E"]
directionkey.R = hs.keycodes.map["R"]
directionkey.D = hs.keycodes.map["D"]
directionkey.F = hs.keycodes.map["F"]
directionkey.ALT = hs.keycodes.map["alt"]
directionkey.CMD = hs.keycodes.map["cmd"]
directionkey.SHIFT = hs.keycodes.map["shift"]
directionkey.ESC = hs.keycodes.map["escape"]
directionkey.shiftState = false;
directionkey.capState = false;
directionkey.log = hs.logger.new("script", "debug")

directionkey.eventMouseDownAndFlagChange = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown,hs.eventtap.event.types.flagsChanged}, function(e)
    -- log.i(e:getProperty(hs.eventtap.evento.oroperties['mouseEventButtonNumber']))
    -- directionkey.log.i(e:getKeyCode())
    local currKey = e:getKeyCode()
    if currKey == directionkey.SHIFT then
        directionkey.shiftState = not directionkey.shiftState 
        return false
    end 
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == directionkey.capslock then
        directionkey.capState = true
        hs.alert.closeAll()
        -- 不消失
        hs.alert.show('dir mod', {
            atScreenEdge = 2,
            textFont = "Fira Code",
            textSize = 20
        }, 'infinite')
        -- directionkey.log.i("capslock toggle")
        return true
    end
end)
directionkey.eventMouseDownAndFlagChange:start()

directionkey.eventMouseUp = hs.eventtap.new({hs.eventtap.event.types.otherMouseUp}, function(e)
    -- directionkey.log.i(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == directionkey.capslock then
        directionkey.capState = false
        hs.alert.closeAll()
        -- hs.alert.show(capState,{atScreenEdge=2, textFont="Fira Code", textSize=20}, 'infi')
        return true
    end
end)
directionkey.eventMouseUp:start()



directionkey.eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    directionkey.log.i(e:getKeyCode())
    local currKey = e:getKeyCode()

    if directionkey.shiftState then
        -- directionkey.log.i("otherkey down")
        if currKey == directionkey.ESC then
            sendKey("shift" , 50) -- 波浪
            return true
        end
    end
    if directionkey.capState then

        -- directionkey.log.i("otherkey down")
        if currKey == directionkey.ESC then
            sendKey(nil, "`")
            return true
        end
        if currKey == directionkey.H then
            sendKey(nil, "left")
            return true
        end
        if currKey == directionkey.J then
            sendKey(nil, "down")
            return true
        end
        if currKey == directionkey.L then
            sendKey(nil, "right")
            return true
        end
        if currKey == directionkey.K then
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
