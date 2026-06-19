directionkey = {}
local function sendKey(mod, key)
    if _G.windowSearcher and _G.windowSearcher.chooser and _G.windowSearcher.chooser:isVisible() then
        local chooser = _G.windowSearcher.chooser
        if key == "down" then
            local row = chooser:selectedRow() or 0
            chooser:selectedRow(row + 1)
            return
        elseif key == "up" then
            local row = chooser:selectedRow() or 2
            if row > 1 then
                chooser:selectedRow(row - 1)
            end
            return
        elseif key == "return" then
            chooser:select()
            return
        elseif key == "escape" then
            chooser:hide()
            return
        end
    end

    if _G.pastboard and _G.pastboard.chooser and _G.pastboard.chooser:isVisible() then
        local chooser = _G.pastboard.chooser
        if key == "down" then
            local row = chooser:selectedRow() or 0
            chooser:selectedRow(row + 1)
            return
        elseif key == "up" then
            local row = chooser:selectedRow() or 2
            if row > 1 then
                chooser:selectedRow(row - 1)
            end
            return
        elseif key == "return" then
            chooser:select()
            return
        elseif key == "escape" then
            chooser:hide()
            return
        end
    end

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
directionkey.SPACE = hs.keycodes.map["space"]
directionkey.CMD = hs.keycodes.map["cmd"]
directionkey.SHIFT = hs.keycodes.map["shift"]
directionkey.ESC = hs.keycodes.map["escape"]
directionkey.showTerminal = hs.keycodes.map["t"]
directionkey.shiftState = false;
directionkey.capState = false;
directionkey.log = hs.logger.new("script", "debug")

local YABAI_PATH = "/opt/homebrew/bin/yabai"
local YABAI_SPACE_SWITCH_COOLDOWN_SECONDS = 0.08
local yabaiRunningTasks = {}

local yabaiClient = {}

local function rememberYabaiTask(task)
    if task then
        yabaiRunningTasks[task] = true
    end
end

local function forgetYabaiTask(task)
    if task then
        yabaiRunningTasks[task] = nil
    end
end

function yabaiClient.run(args, onExit)
    local task
    task = hs.task.new(YABAI_PATH, function(exitCode, stdout, stderr)
        forgetYabaiTask(task)
        if exitCode ~= 0 and stderr and stderr ~= "" then
            directionkey.log.w("yabai failed: " .. stderr)
        end
        if onExit then
            onExit(exitCode, stdout, stderr)
        end
    end, args)

    if not task then
        directionkey.log.e("failed to create yabai task")
        return
    end

    rememberYabaiTask(task)
    if not task:start() then
        forgetYabaiTask(task)
        directionkey.log.e("failed to start yabai task")
    end
end

function yabaiClient.runShell(command, onExit)
    local task
    task = hs.task.new("/bin/zsh", function(exitCode, stdout, stderr)
        forgetYabaiTask(task)
        if exitCode ~= 0 and stderr and stderr ~= "" then
            directionkey.log.w("yabai shell command failed: " .. stderr)
        end
        if onExit then
            onExit(exitCode, stdout, stderr)
        end
    end, {"-lc", command})

    if not task then
        directionkey.log.e("failed to create shell task")
        return
    end

    rememberYabaiTask(task)
    if not task:start() then
        forgetYabaiTask(task)
        directionkey.log.e("failed to start shell task")
    end
end

function yabaiClient.focusSpace(space, onExit)
    yabaiClient.run({"-m", "space", "--focus", tostring(space)}, onExit)
end

function yabaiClient.focusNextSpace(onExit)
    yabaiClient.focusSpace("next", onExit)
end

function yabaiClient.focusPreviousSpace(onExit)
    yabaiClient.focusSpace("prev", onExit)
end

function yabaiClient.moveWindowToSpace(space, onExit)
    yabaiClient.run({"-m", "window", "--space", tostring(space)}, onExit)
end

function yabaiClient.moveWindowToNextSpace()
    yabaiClient.moveWindowToSpace("next")
end

function yabaiClient.moveWindowToPreviousSpace()
    yabaiClient.moveWindowToSpace("prev")
end

function yabaiClient.moveWindowToDisplay(display)
    yabaiClient.run({"-m", "window", "--display", tostring(display)})
end

function yabaiClient.focusWindow(direction)
    yabaiClient.run({"-m", "window", "--focus", direction})
end

function yabaiClient.focusRecentWindow()
    yabaiClient.focusWindow("recent")
end

function yabaiClient.swapWindow(direction)
    yabaiClient.run({"-m", "window", "--swap", direction})
end

function yabaiClient.balanceSpace()
    yabaiClient.run({"-m", "space", "--balance"})
end

function yabaiClient.toggleSticky()
    yabaiClient.run({"-m", "window", "--toggle", "sticky"})
end

function yabaiClient.resizeWindowFromWest()
    yabaiClient.runShell(YABAI_PATH .. " -m window west --resize right:-50:0 2> /dev/null || " .. YABAI_PATH .. " -m window --resize right:-50:0")
end

function yabaiClient.resizeWindowFromNorth()
    yabaiClient.runShell(YABAI_PATH .. " -m window north --resize bottom:0:50 2> /dev/null || " .. YABAI_PATH .. " -m window --resize bottom:0:50")
end

function yabaiClient.resizeWindowFromSouth()
    yabaiClient.runShell(YABAI_PATH .. " -m window south --resize top:0:-50 2> /dev/null || " .. YABAI_PATH .. " -m window --resize top:0:-50")
end

function yabaiClient.resizeWindowFromEast()
    yabaiClient.runShell(YABAI_PATH .. " -m window east --resize left:50:0 2> /dev/null || " .. YABAI_PATH .. " -m window --resize left:50:0")
end

function yabaiClient.queryDisplaySpaces(callback)
    yabaiClient.run({"-m", "query", "--spaces", "--display"}, function(exitCode, stdout, stderr)
        if exitCode ~= 0 then
            return
        end

        local ok, spaces = pcall(hs.json.decode, stdout)
        if not ok or type(spaces) ~= "table" then
            directionkey.log.w("failed to decode yabai spaces")
            return
        end

        callback(spaces)
    end)
end

function yabaiClient.createSpaceAndFocus()
    yabaiClient.run({"-m", "space", "--create"}, function(exitCode)
        if exitCode ~= 0 then
            return
        end

        yabaiClient.queryDisplaySpaces(function(spaces)
            local newestSpace = spaces[#spaces]
            if newestSpace and newestSpace["index"] then
                yabaiClient.focusSpace(newestSpace["index"])
            end
        end)
    end)
end

function yabaiClient.createSpaceAndMoveFocusedWindow()
    yabaiClient.run({"-m", "space", "--create"}, function(exitCode)
        if exitCode ~= 0 then
            return
        end

        yabaiClient.queryDisplaySpaces(function(spaces)
            local newestSpace = spaces[#spaces]
            if newestSpace and newestSpace["index"] then
                yabaiClient.moveWindowToSpace(newestSpace["index"])
            end
        end)
    end)
end

function yabaiClient.destroyFocusedSpace()
    yabaiClient.queryDisplaySpaces(function(spaces)
        if #spaces <= 1 then
            return
        end

        if spaces[1]["has-focus"] then
            yabaiClient.focusSpace(spaces[2]["index"], function()
                yabaiClient.run({"-m", "space", "--destroy", tostring(spaces[1]["index"])})
            end)
            return
        end

        local focused = nil
        for index, space in ipairs(spaces) do
            if space["has-focus"] then
                focused = index
                break
            end
        end

        if focused and focused > 1 then
            yabaiClient.focusSpace(spaces[focused - 1]["index"], function()
                yabaiClient.run({"-m", "space", "--destroy", tostring(spaces[focused]["index"])})
            end)
        end
    end)
end

local function finishYabaiSpaceSwitch()
    directionkey.yabaiSpaceSwitchLock = false
    if directionkey.yabaiSpaceSwitchUnlockTimer then
        directionkey.yabaiSpaceSwitchUnlockTimer:stop()
        directionkey.yabaiSpaceSwitchUnlockTimer = nil
    end
end

local function switchYabaiSpace(direction)
    if directionkey.yabaiSpaceSwitchLock == true then
        return
    end

    directionkey.yabaiSpaceSwitchLock = true
    directionkey.yabaiSpaceSwitchUnlockTimer = hs.timer.doAfter(YABAI_SPACE_SWITCH_COOLDOWN_SECONDS, finishYabaiSpaceSwitch)

    if direction == "next" then
        yabaiClient.focusNextSpace(finishYabaiSpaceSwitch)
    else
        yabaiClient.focusPreviousSpace(finishYabaiSpaceSwitch)
    end
end

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
                hs.alert.show("⚖️ Balancing Space")
                yabaiClient.balanceSpace()
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey.H then
                yabaiClient.resizeWindowFromWest()
                return true
            end
            if currKey == directionkey.J then
                yabaiClient.resizeWindowFromNorth()
                return true
            end
            if currKey == directionkey.K then
                yabaiClient.resizeWindowFromSouth()
                return true
            end
            if currKey == directionkey.L then
                yabaiClient.resizeWindowFromEast()
                return true
            end
            resetYabaiLeader()
        end

        if directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed == true then
            -- directionkey.log.i('leader pressed move window in space')
            if currKey == directionkey.H then
                yabaiClient.swapWindow("west")
                return true
            end
            if currKey == directionkey.J then
                yabaiClient.swapWindow("south")
                return true
            end
            if currKey == directionkey.K then
                yabaiClient.swapWindow("north")
                return true
            end
            if currKey == directionkey.L then
                yabaiClient.swapWindow("east")
                return true
            end
            resetYabaiLeader()
        end

        if directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed == true then
            -- directionkey.log.i('leader pressed move window to display')
            if currKey == directionkey._1 then
                yabaiClient.moveWindowToDisplay(1)
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._2 then
                yabaiClient.moveWindowToDisplay(2)
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._3 then
                yabaiClient.moveWindowToDisplay(3)
                resetYabaiLeader()
                return true
            end
            if currKey == directionkey._4 then
                yabaiClient.moveWindowToDisplay(4)
                resetYabaiLeader()
                return true
            end
            resetYabaiLeader()
        end
        if directionkey.yabaiWindowFocusOnLeaderPressed == true then
            if currKey == directionkey.H then
                yabaiClient.focusWindow("west")
                return true
            end
            if currKey == directionkey.J then
                yabaiClient.focusWindow("south")
                return true
            end
            if currKey == directionkey.K then
                yabaiClient.focusWindow("north")
                return true
            end
            if currKey == directionkey.L then
                yabaiClient.focusWindow("east")
                return true
            end
            resetYabaiLeader()
        end
        if directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed == true then
            if currKey == directionkey.S or currKey == directionkey.N then
                yabaiClient.moveWindowToNextSpace()
                return true
            end
            if currKey == directionkey.A or currKey == directionkey.P then
                yabaiClient.moveWindowToPreviousSpace()
                return true
            end
            if currKey == directionkey.C then
                yabaiClient.createSpaceAndMoveFocusedWindow()
                return true
            end
            if currKey == directionkey._1 then
                yabaiClient.moveWindowToSpace(1)
                yabaiClient.focusSpace(1)
                return true
            end
            if currKey == directionkey._2 then
                yabaiClient.moveWindowToSpace(2)
                yabaiClient.focusSpace(2)
                return true
            end
            if currKey == directionkey._3 then
                yabaiClient.moveWindowToSpace(3)
                yabaiClient.focusSpace(3)
                return true
            end
            if currKey == directionkey._4 then
                yabaiClient.moveWindowToSpace(4)
                yabaiClient.focusSpace(4)
                return true
            end
            if currKey == directionkey._5 then
                yabaiClient.moveWindowToSpace(5)
                yabaiClient.focusSpace(5)
                return true
            end
            if currKey == directionkey._6 then
                yabaiClient.moveWindowToSpace(6)
                yabaiClient.focusSpace(6)
                return true
            end
            if currKey == directionkey._7 then
                yabaiClient.moveWindowToSpace(7)
                yabaiClient.focusSpace(7)
                return true
            end
            if currKey == directionkey._8 then
                yabaiClient.moveWindowToSpace(8)
                yabaiClient.focusSpace(8)
                return true
            end
            if currKey == directionkey._9 then
                yabaiClient.moveWindowToSpace(9)
                yabaiClient.focusSpace(9)
                return true
            end
            if currKey == directionkey._0 then
                yabaiClient.moveWindowToSpace(10)
                yabaiClient.focusSpace(10)
                return true
            end
          resetYabaiLeader()
        end
    end

    if directionkey.capState == true then
        if currKey == directionkey.SPACE then
            if _G.windowHintsPlugin then
                _G.windowHintsPlugin.toggle()
            end
            return true
        end
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
            hs.alert.show("📌 Toggle Sticky")
            yabaiClient.toggleSticky()
            return true
        end
        if currKey == directionkey.Y then
            yabaiClient.focusWindow("west")
            return true
        end
        if currKey == directionkey.U then
            yabaiClient.focusWindow("south")
            return true
        end
        if currKey == directionkey.I then
            yabaiClient.focusWindow("north")
            return true
        end
        if currKey == directionkey.O then
            yabaiClient.focusWindow("east")
            return true
        end
        if currKey == directionkey.C then
            hs.alert.show("🚀 Creating new Space...")
            yabaiClient.createSpaceAndFocus()
            return true
        end
        if currKey == directionkey.Q then
            hs.alert.show("🗑 Destroying current Space...")
            yabaiClient.destroyFocusedSpace()
            return true
        end
        if currKey == directionkey.S or currKey == directionkey.N then
            switchYabaiSpace("next")
            return true
        end
        if currKey == directionkey.A or currKey == directionkey.P then
            switchYabaiSpace("prev")
            return true
        end
        if currKey == directionkey.LEFT_BRACKET then
            yabaiClient.focusRecentWindow()
            return true
        end
        -- 聚焦屏幕
        if currKey == directionkey._1 then
            yabaiClient.focusSpace(1)
            return true
        end
        if currKey == directionkey._2 then
            yabaiClient.focusSpace(2)
            return true
        end
        if currKey == directionkey._3 then
            yabaiClient.focusSpace(3)
            return true
        end
        if currKey == directionkey._4 then
            yabaiClient.focusSpace(4)
            return true
        end
        if currKey == directionkey._5 then
            yabaiClient.focusSpace(5)
            return true
        end
        if currKey == directionkey._6 then
            yabaiClient.focusSpace(6)
            return true
        end
        if currKey == directionkey._7 then
            yabaiClient.focusSpace(7)
            return true
        end
        if currKey == directionkey._8 then
            yabaiClient.focusSpace(8)
            return true
        end
        if currKey == directionkey._9 then
            yabaiClient.focusSpace(9)
            return true
        end
        if currKey == directionkey._0 then
            yabaiClient.focusSpace(10)
            return true
        end
    end

end)
directionkey.eventKeyDownYabai:start()


return directionkey
