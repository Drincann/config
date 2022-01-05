local function sendKey(mod, key)
    hs.eventtap.event.newKeyEvent(mod, key, true):post()
    hs.eventtap.event.newKeyEvent(mod, key, false):post()
end

-- hs.timer.doAfter(30, function() hs.reload() end)
-- local log = hs.logger.new("script", "debug")

-- local counter = 0
-- local event = nil
-- event = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function()
--     counter = counter + 1
--     hs.alert.closeAll()
--     hs.alert(counter)
--     log.i(event:isEnabled())
-- end):start()

capslock = 31
J = hs.keycodes.map["J"]
K = hs.keycodes.map["K"]
L = hs.keycodes.map["L"]
I = hs.keycodes.map["I"]
E = hs.keycodes.map["E"]
R = hs.keycodes.map["R"]
D = hs.keycodes.map["D"]
F = hs.keycodes.map["F"]
ALT = hs.keycodes.map["alt"]
CMD = hs.keycodes.map["cmd"]
capState = false;
log = hs.logger.new("script", "debug")
hs.alert.defaultStyle["atScreenEdge"] = 1
eventDown = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown},
                            function(e)
    log.i(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) ==
        capslock then
        capState = true
        hs.alert.closeAll()
        -- 不消失
        hs.alert.show('dir mod',{atScreenEdge=2, textFont="Fira Code", textSize=20}, 10000)
        log.i("capslock toggle")
        return true
    end
end)
eventDown:start()

eventUp = hs.eventtap.new({hs.eventtap.event.types.otherMouseUp}, function(e)
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) ==
        capslock then
        capState = false
        hs.alert.closeAll()
        -- hs.alert.show(capState,{atScreenEdge=2, textFont="Fira Code", textSize=20}, 'infi')
        return true
    end

end)
eventUp:start()

eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    log.i(e:getKeyCode())

    if capState then
        local currKey = e:getKeyCode()

        log.i("otherkey down")
        if currKey == J then
            sendKey(nil, "left")
            return true
        end
        if currKey == K then
            sendKey(nil, "down")
            return true
        end
        if currKey == L then
            sendKey(nil, "right")
            return true
        end
        if currKey == I then
            sendKey(nil, "up")
            return true
        end
        if currKey == E then
            sendKey({"cmd"}, "left")
            return true
        end
        if currKey == R then
            sendKey({"cmd"}, "right")
            return true
        end
        if currKey == D then
            sendKey({"alt"}, "left")
            return true
        end
        if currKey == F then
            sendKey({"alt"}, "right")
            return true
        end
    end
end)
eventKeyDown:start()
