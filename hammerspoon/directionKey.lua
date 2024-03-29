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

-- https://github.com/Hammerspoon/hammerspoon/issues/3512
function key_remapping()
    -- remap capslock to F13:
    status = os.execute("hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\": 0x700000039, \"HIDKeyboardModifierMappingDst\": 0x700000068}]}'") 
    if not status then
        hs.dialog.blockAlert("Key remapping failed", "Check with:\nhidutil property --get UserKeyMapping")
    end
end
key_remapping()

-- remapping capslock to F13
directionkey.capslock = hs.keycodes.map["F13"]
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
directionkey.showTerminal = hs.keycodes.map["t"]
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
end)
directionkey.eventMouseDownAndFlagChange:start()

directionkey.eventKeyUp = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local currKey = e:getKeyCode()
    if currKey == directionkey.capslock then
        directionkey.capState = false
        hs.alert.closeAll()
        -- hs.alert.show(capState,{atScreenEdge=2, textFont="Fira Code", textSize=20}, 'infi')
        return true
    end
end)
directionkey.eventKeyUp:start()


directionkey.eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    directionkey.log.i(e:getKeyCode())
    local currKey = e:getKeyCode()

    if currKey == directionkey.capslock then
        if not directionkey.capState then
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
        else
            return true
        end
    end
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
            if string.find('alacritty', string.lower(hs.window.focusedWindow():application():name())) then
                sendKey(nil, "home")
            else
                sendKey({"cmd"}, 'left')
            end
            return true
        end
        if currKey == directionkey.R then
            if string.find('alacritty', string.lower(hs.window.focusedWindow():application():name())) then
                sendKey(nil, "end")
            else
                sendKey({"cmd"}, 'right')
            end
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
        if currKey == directionkey.showTerminal then
            local alacritty = hs.application.find('Alacritty')
            -- if alacritty is already focused, hide it
            if hs.window.focusedWindow():application():name() == 'Alacritty' then
                hs.application.find('Alacritty'):hide()
                return true
            end

            -- if is not exist, launch it
            if alacritty == nil then
                hs.application.launchOrFocus('Alacritty')
                alacritty = hs.application.find('Alacritty')
            end

            local currentSpace = hs.spaces.activeSpaceOnScreen()
            hs.spaces.moveWindowToSpace(alacritty:mainWindow(), currentSpace)

            -- focus it
            alacritty:mainWindow():focus()
            return true
        end
    end
end)
directionkey.eventKeyDown:start()

return directionkey
