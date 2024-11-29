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
--     hs.alert.closeAll() hs.alert(counter)
--     directionkey.log.i(event:isEnabled())
-- end):start()

-- https://github.com/Hammerspoon/hammerspoon/issues/3512
function key_remapping()
    -- remap capslock to F13:
    status = os.execute("hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\": 0x700000039, \"HIDKeyboardModifierMappingDst\": 0x700000068}]}'") 
    if not status then
        hs.dialog.blockAlert("Key remapping failed", "Check with:\nhidutil property --get UserKeyMapping")
        return
    end
    hs.alert.show("Key remapping successful")
end
key_remapping()

directionkey._0 = hs.keycodes.map["0"]
directionkey._1 = hs.keycodes.map["1"]
directionkey._2 = hs.keycodes.map["2"]
directionkey._3 = hs.keycodes.map["3"]
directionkey._4 = hs.keycodes.map["4"]
directionkey._5 = hs.keycodes.map["5"]
directionkey._6 = hs.keycodes.map["6"]
directionkey._7 = hs.keycodes.map["7"]
directionkey._8 = hs.keycodes.map["8"]
directionkey._9 = hs.keycodes.map["9"]
directionkey.A = hs.keycodes.map["A"]
directionkey.B = hs.keycodes.map["B"]
directionkey.C = hs.keycodes.map["C"]
-- remapping capslock to F13
directionkey.capslock = hs.keycodes.map["F13"]
directionkey.H = hs.keycodes.map["H"]
directionkey.I = hs.keycodes.map["I"]
directionkey.J = hs.keycodes.map["J"]
directionkey.K = hs.keycodes.map["K"]
directionkey.L = hs.keycodes.map["L"]
directionkey.M = hs.keycodes.map["M"]
directionkey.N = hs.keycodes.map["N"]
directionkey.O = hs.keycodes.map["O"]
directionkey.P = hs.keycodes.map["P"]
directionkey.Q = hs.keycodes.map["Q"]
directionkey.R = hs.keycodes.map["R"]
directionkey.S = hs.keycodes.map["S"]
directionkey.E = hs.keycodes.map["E"]
directionkey.D = hs.keycodes.map["D"]
directionkey.F = hs.keycodes.map["F"]
directionkey.W = hs.keycodes.map["W"]
directionkey.Y = hs.keycodes.map["Y"]
directionkey.U = hs.keycodes.map["U"]
directionkey.I = hs.keycodes.map["I"]
directionkey.Z = hs.keycodes.map["Z"]
directionkey.X = hs.keycodes.map["X"]
directionkey.COMMA = hs.keycodes.map[","]
directionkey.DOT = hs.keycodes.map["."]
directionkey.LEFT_BRACKET = hs.keycodes.map["["]
directionkey.ALT = hs.keycodes.map["alt"]
directionkey.ENTER = hs.keycodes.map["return"]
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
    -- directionkey.log.i(currKey)
    if currKey == directionkey.capslock then
        directionkey.capState = false
        hs.alert.closeAll()
        -- hs.alert.show(capState,{atScreenEdge=2, textFont="Fira Code", textSize=20}, 'infi')
        return true
    end
end)
directionkey.eventKeyUp:start()


directionkey.eventKeyDownDefault = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    -- directionkey.log.i(e:getKeyCode())
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
directionkey.eventKeyDownDefault:start()

local function resetYabaiLeader()
  directionkey.log.i('leader reset')
  directionkey.yabaiResizeLeaderPressed = false
  directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed = false
  directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed = false
  directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed = false
  directionkey.yabaiWindowFocusOnLeaderPressed = false
end

resetYabaiLeader()

local function resetYabaiLock()
  directionkey.log.i('leader reset')
  directionkey.yabaiSpaceSwitchLock = false
end

resetYabaiLock()

directionkey.eventKeyDownYabai = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    -- directionkey.log.i(e:getKeyCode())
    local currKey = e:getKeyCode()
    if directionkey.capState == false then
        if directionkey.yabaiResizeLeaderPressed == true then
            -- directionkey.log.i('leader pressed resize window')
            if currKey == directionkey.ENTER then
                os.execute("/opt/homebrew/bin/yabai -m space --balance")
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey.H then
                os.execute("/opt/homebrew/bin/yabai -m window west --resize right:-50:0 2> /dev/null || /opt/homebrew/bin/yabai -m window --resize right:-50:0")
                return true
            end
            if currKey == directionkey.J then
                os.execute("/opt/homebrew/bin/yabai -m window north --resize bottom:0:50 2> /dev/null || /opt/homebrew/bin/yabai -m window --resize bottom:0:50")
                return true
            end
            if currKey == directionkey.K then
                os.execute("/opt/homebrew/bin/yabai -m window south --resize top:0:-50 2> /dev/null || /opt/homebrew/bin/yabai -m window --resize top:0:-50")
                return true
            end
            if currKey == directionkey.L then
                os.execute("/opt/homebrew/bin/yabai -m window east --resize left:50:0 2> /dev/null || /opt/homebrew/bin/yabai -m window --resize left:50:0")
                return true
            end
            resetYabaiLeader()
        end

        if directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed == true then
            -- directionkey.log.i('leader pressed move window in space')
            if currKey == directionkey.H then
                os.execute("/opt/homebrew/bin/yabai -m window --swap west")
                return true
            end
            if currKey == directionkey.J then
                os.execute("/opt/homebrew/bin/yabai -m window --swap south")
                return true
            end
            if currKey == directionkey.K then
                os.execute("/opt/homebrew/bin/yabai -m window --swap north")
                return true
            end
            if currKey == directionkey.L then
                os.execute("/opt/homebrew/bin/yabai -m window --swap east")
                return true
            end
            resetYabaiLeader()
        end

        if directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed == true then
            -- directionkey.log.i('leader pressed move window to display')
            if currKey == directionkey._1 then
                os.execute("/opt/homebrew/bin/yabai -m window --display 1")
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._2 then
                os.execute("/opt/homebrew/bin/yabai -m window --display 2")
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._3 then
                os.execute("/opt/homebrew/bin/yabai -m window --display 3")
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._4 then
                os.execute("/opt/homebrew/bin/yabai -m window --display 4")
                resetYabaiLeader()
                return true
            end
            resetYabaiLeader()
        end
        if directionkey.yabaiWindowFocusOnLeaderPressed == true then
            if currKey == directionkey.H then
                os.execute("/opt/homebrew/bin/yabai -m window --focus west")
                return true
            end
            if currKey == directionkey.J then
                os.execute("/opt/homebrew/bin/yabai -m window --focus south")
                return true
            end
            if currKey == directionkey.K then
                os.execute("/opt/homebrew/bin/yabai -m window --focus north")
                return true
            end
            if currKey == directionkey.L then
                os.execute("/opt/homebrew/bin/yabai -m window --focus east")
                return true
            end
            resetYabaiLeader()
        end
        if directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed == true then
            if currKey == directionkey.S or currKey == directionkey.N then
                os.execute("/opt/homebrew/bin/yabai -m window --space next")
                os.execute("/opt/homebrew/bin/yabai -m space --focus next")
                return true
            end
            if currKey == directionkey.A or currKey == directionkey.P then
                os.execute("/opt/homebrew/bin/yabai -m window --space prev")
                os.execute("/opt/homebrew/bin/yabai -m space --focus prev")
                return true
            end
            if currKey == directionkey.C then
                os.execute("/opt/homebrew/bin/yabai -m space --create")
                local rawInfo = hs.execute("/opt/homebrew/bin/yabai -m query --spaces --display")
                local info = hs.json.decode(rawInfo)
                local indexOfNewSpace = info[#(info)]['index']
                os.execute("/opt/homebrew/bin/yabai -m window --space ".. indexOfNewSpace)
                os.execute("/opt/homebrew/bin/yabai -m space --focus ".. indexOfNewSpace)
                return true
            end
            if currKey == directionkey._1 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 1")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 1")
                return true
            end
            if currKey == directionkey._2 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 2")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 2")
                return true
            end
            if currKey == directionkey._3 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 3")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 3")
                return true
            end
            if currKey == directionkey._4 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 4")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 4")
                return true
            end
            if currKey == directionkey._5 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 5")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 5")
                return true
            end
            if currKey == directionkey._6 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 6")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 6")
                return true
            end
            if currKey == directionkey._7 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 7")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 7")
                return true
            end
            if currKey == directionkey._8 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 8")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 8")
                return true
            end
            if currKey == directionkey._9 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 9")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 9")
            end
            if currKey == directionkey._0 then
                os.execute("/opt/homebrew/bin/yabai -m window --space 10")
                os.execute("/opt/homebrew/bin/yabai -m space --focus 10")
            end
          resetYabaiLeader()
        end
    end

    if directionkey.capState == true then
        if currKey == directionkey.W then
            directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed = true
            return true
        end
        if currKey == directionkey.D then
            directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed = true
        end
        if currKey == directionkey.F then
            directionkey.yabaiWindowFocusOnLeaderPressed = true
        end
        if currKey == directionkey.M then
            directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed = true
            return true
        end
        if currKey == directionkey.Z then
            directionkey.yabaiResizeLeaderPressed = true
            return true
        end
        if currKey == directionkey.X then
            os.execute("/opt/homebrew/bin/yabai -m window --toggle sticky")
            return true
        end
        if currKey == directionkey.Y then
            os.execute("/opt/homebrew/bin/yabai -m window --focus west")
            return true
        end
        if currKey == directionkey.U then
            os.execute("/opt/homebrew/bin/yabai -m window --focus south")
            return true
        end
        if currKey == directionkey.I then
            os.execute("/opt/homebrew/bin/yabai -m window --focus north")
            return true
        end
        if currKey == directionkey.O then
            os.execute("/opt/homebrew/bin/yabai -m window --focus east")
            return true
        end
        if currKey == directionkey.C then
            os.execute("/opt/homebrew/bin/yabai -m space --create")
            local rawInfo = hs.execute("/opt/homebrew/bin/yabai -m query --spaces --display")
            local info = hs.json.decode(rawInfo)
            os.execute("/opt/homebrew/bin/yabai -m space --focus "..info[#(info)]['index'])
            return true
        end
        if currKey == directionkey.Q then
            local rawInfo = hs.execute("/opt/homebrew/bin/yabai -m query --spaces --display")
            local spaces = hs.json.decode(rawInfo)
            if #(spaces) == 1 then
              return true
            end
            if spaces[1]['has-focus'] then
                os.execute("/opt/homebrew/bin/yabai -m space --focus "..spaces[2]['index'])
                os.execute("/opt/homebrew/bin/yabai -m space --destroy "..spaces[1]['index'])
                return true
            end

            local focused = -1
            for index, space in pairs(spaces) do
                if space['has-focus'] then
                  focused = index
                  break
                end
            end

            if focused ~= -1 then
                os.execute("/opt/homebrew/bin/yabai -m space --focus "..spaces[focused - 1]['index'])
                os.execute("/opt/homebrew/bin/yabai -m space --destroy "..spaces[focused]['index'])
              
            end
            return true
        end
        if currKey == directionkey.S or currKey == directionkey.N then
            
            -- local rawInfo = hs.execute("/opt/homebrew/bin/yabai -m query --spaces --display")
            -- local info = hs.json.decode(rawInfo)
            -- if info[#(info)]['has-focus'] == false then
            --     os.execute("/opt/homebrew/bin/yabai -m space --focus next")
            -- end
            
            if directionkey.yabaiSpaceSwitchLock == true then
              return true;
            end

            directionkey.yabaiSpaceSwitchLock = true
            os.execute("/opt/homebrew/bin/yabai -m space --focus next")
            directionkey.yabaiSpaceSwitchLock = false
            return true
        end
        if currKey == directionkey.A or currKey == directionkey.P then
            -- local rawInfo = hs.execute("/opt/homebrew/bin/yabai -m query --spaces --display")
            -- local info = hs.json.decode(rawInfo)

            -- if info[1]['has-focus'] == false then
            --     os.execute("/opt/homebrew/bin/yabai -m space --focus prev")
            -- end
            if directionkey.yabaiSpaceSwitchLock == true then
              return true;
            end

            directionkey.yabaiSpaceSwitchLock = true
            os.execute("/opt/homebrew/bin/yabai -m space --focus prev")
            directionkey.yabaiSpaceSwitchLock = false
            return true
        end
        if currKey == directionkey.LEFT_BRACKET then
            os.execute("/opt/homebrew/bin/yabai -m window --focus recent")
            return true
        end
        -- 聚焦屏幕
        if currKey == directionkey._1 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 1")
            return true
        end
        if currKey == directionkey._2 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 2")
            return true
        end
        if currKey == directionkey._3 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 3")
            return true
        end
        if currKey == directionkey._4 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 4")
            return true
        end
        if currKey == directionkey._5 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 5")
            return true
        end
        if currKey == directionkey._6 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 6")
            return true
        end
        if currKey == directionkey._7 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 7")
            return true
        end
        if currKey == directionkey._8 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 8")
            return true
        end
        if currKey == directionkey._9 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 9")
            return true
        end
        if currKey == directionkey._0 then
            os.execute("/opt/homebrew/bin/yabai -m space --focus 10")
            return true
        end
    end

end)
directionkey.eventKeyDownYabai:start()


return directionkey
