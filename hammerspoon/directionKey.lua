local directionkey = {}
_G.directionkey = directionkey
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
local function key_remapping()
    -- remap capslock to F13:
    local status = os.execute("hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\": 0x700000039, \"HIDKeyboardModifierMappingDst\": 0x700000068}]}'")
    if not status then
        hs.dialog.blockAlert("Key remapping failed", "Check with:\nhidutil property --get UserKeyMapping")
        return
    end
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
    directionkey.shiftState = e:getFlags().shift == true
    return false
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

local function resetYabaiLeader()
  directionkey.yabaiResizeLeaderPressed = false
  directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed = false
  directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed = false
  directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed = false
  directionkey.yabaiWindowFocusOnLeaderPressed = false
end

resetYabaiLeader()

local function resetYabaiLock()
  directionkey.yabaiSpaceSwitchLock = false
end

resetYabaiLock()

local function isYabaiLeaderActive()
    return directionkey.yabaiResizeLeaderPressed
        or directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed
        or directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed
        or directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed
        or directionkey.yabaiWindowFocusOnLeaderPressed
end

local function focusedAppName()
    local win = hs.window.focusedWindow()
    if not win then
        return nil
    end

    local app = win:application()
    return app and app:name() or nil
end

local function isFocusedApp(appName)
    return focusedAppName() == appName
end

local function focusAlacrittyOnCurrentSpace(attempt)
    attempt = attempt or 1

    local app = hs.application.find("Alacritty")
    if isFocusedApp("Alacritty") then
        if app then
            app:hide()
        end
        return
    end

    if not app then
        hs.application.launchOrFocus("Alacritty")
        if attempt < 10 then
            hs.timer.doAfter(0.15, function() focusAlacrittyOnCurrentSpace(attempt + 1) end)
        end
        return
    end

    local win = app:mainWindow()
    if not win then
        hs.application.launchOrFocus("Alacritty")
        if attempt < 10 then
            hs.timer.doAfter(0.15, function() focusAlacrittyOnCurrentSpace(attempt + 1) end)
        else
            hs.alert.show("Alacritty window not ready")
        end
        return
    end

    local currentSpace = hs.spaces.activeSpaceOnScreen()
    if currentSpace then
        pcall(hs.spaces.moveWindowToSpace, win, currentSpace)
    end
    win:focus()
end

local function moveWindowToSpaceAndFocus(space)
    yabaiClient.moveWindowToSpace(space)
    yabaiClient.focusSpace(space)
end

local function handleYabaiLeaderKey(currKey)
    if directionkey.yabaiResizeLeaderPressed then
        if currKey == directionkey.ENTER then
            hs.alert.show("⚖️ Balancing Space")
            yabaiClient.balanceSpace()
            resetYabaiLeader()
            return true
        elseif currKey == directionkey.H then
            yabaiClient.resizeWindowFromWest()
            return true
        elseif currKey == directionkey.J then
            yabaiClient.resizeWindowFromNorth()
            return true
        elseif currKey == directionkey.K then
            yabaiClient.resizeWindowFromSouth()
            return true
        elseif currKey == directionkey.L then
            yabaiClient.resizeWindowFromEast()
            return true
        end
        resetYabaiLeader()
        return false
    end

    if directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed then
        if currKey == directionkey.H then
            yabaiClient.swapWindow("west")
            return true
        elseif currKey == directionkey.J then
            yabaiClient.swapWindow("south")
            return true
        elseif currKey == directionkey.K then
            yabaiClient.swapWindow("north")
            return true
        elseif currKey == directionkey.L then
            yabaiClient.swapWindow("east")
            return true
        end
        resetYabaiLeader()
        return false
    end

    if directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed then
        if currKey == directionkey._1 then
            yabaiClient.moveWindowToDisplay(1)
            resetYabaiLeader()
            return true
        elseif currKey == directionkey._2 then
            yabaiClient.moveWindowToDisplay(2)
            resetYabaiLeader()
            return true
        elseif currKey == directionkey._3 then
            yabaiClient.moveWindowToDisplay(3)
            resetYabaiLeader()
            return true
        elseif currKey == directionkey._4 then
            yabaiClient.moveWindowToDisplay(4)
            resetYabaiLeader()
            return true
        end
        resetYabaiLeader()
        return false
    end

    if directionkey.yabaiWindowFocusOnLeaderPressed then
        if currKey == directionkey.H then
            yabaiClient.focusWindow("west")
            return true
        elseif currKey == directionkey.J then
            yabaiClient.focusWindow("south")
            return true
        elseif currKey == directionkey.K then
            yabaiClient.focusWindow("north")
            return true
        elseif currKey == directionkey.L then
            yabaiClient.focusWindow("east")
            return true
        end
        resetYabaiLeader()
        return false
    end

    if directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed then
        if currKey == directionkey.S or currKey == directionkey.N then
            yabaiClient.moveWindowToNextSpace()
            return true
        elseif currKey == directionkey.A or currKey == directionkey.P then
            yabaiClient.moveWindowToPreviousSpace()
            return true
        elseif currKey == directionkey.C then
            yabaiClient.createSpaceAndMoveFocusedWindow()
            return true
        elseif currKey == directionkey._1 then
            moveWindowToSpaceAndFocus(1)
            return true
        elseif currKey == directionkey._2 then
            moveWindowToSpaceAndFocus(2)
            return true
        elseif currKey == directionkey._3 then
            moveWindowToSpaceAndFocus(3)
            return true
        elseif currKey == directionkey._4 then
            moveWindowToSpaceAndFocus(4)
            return true
        elseif currKey == directionkey._5 then
            moveWindowToSpaceAndFocus(5)
            return true
        elseif currKey == directionkey._6 then
            moveWindowToSpaceAndFocus(6)
            return true
        elseif currKey == directionkey._7 then
            moveWindowToSpaceAndFocus(7)
            return true
        elseif currKey == directionkey._8 then
            moveWindowToSpaceAndFocus(8)
            return true
        elseif currKey == directionkey._9 then
            moveWindowToSpaceAndFocus(9)
            return true
        elseif currKey == directionkey._0 then
            moveWindowToSpaceAndFocus(10)
            return true
        end
        resetYabaiLeader()
        return false
    end

    return false
end

local function handleCapsModeKey(currKey, flags)
    if flags.shift and currKey == directionkey.ESC then
        sendKey("shift", 50)
        return true
    end

    if currKey == directionkey.ESC then
        sendKey(nil, "`")
        return true
    elseif currKey == directionkey.H then
        sendKey(nil, "left")
        return true
    elseif currKey == directionkey.J then
        sendKey(nil, "down")
        return true
    elseif currKey == directionkey.L then
        sendKey(nil, "right")
        return true
    elseif currKey == directionkey.K then
        sendKey(nil, "up")
        return true
    elseif currKey == directionkey.E then
        if isFocusedApp("Alacritty") then
            sendKey(nil, "home")
        else
            sendKey({"cmd"}, "left")
        end
        return true
    elseif currKey == directionkey.R then
        if isFocusedApp("Alacritty") then
            sendKey(nil, "end")
        else
            sendKey({"cmd"}, "right")
        end
        return true
    elseif currKey == directionkey.D then
        directionkey.yabaiWindowMoveWindowToDisplayLeaderPressed = true
        sendKey({"alt"}, "left")
        return true
    elseif currKey == directionkey.F then
        directionkey.yabaiWindowFocusOnLeaderPressed = true
        sendKey({"alt"}, "right")
        return true
    elseif currKey == directionkey.showTerminal then
        focusAlacrittyOnCurrentSpace()
        return true
    elseif currKey == directionkey.SPACE then
        if _G.windowHintsPlugin then
            _G.windowHintsPlugin.toggle()
        end
        return true
    elseif currKey == directionkey.W then
        directionkey.yabaiWindowMoveWindowInSpaceLeaderPressed = true
        return true
    elseif currKey == directionkey.M then
        directionkey.yabaiWindowMoveWindowToSpaceOrDisplayLeaderPressed = true
        return true
    elseif currKey == directionkey.Z then
        directionkey.yabaiResizeLeaderPressed = true
        return true
    elseif currKey == directionkey.X then
        hs.alert.show("📌 Toggle Sticky")
        yabaiClient.toggleSticky()
        return true
    elseif currKey == directionkey.Y then
        yabaiClient.focusWindow("west")
        return true
    elseif currKey == directionkey.U then
        yabaiClient.focusWindow("south")
        return true
    elseif currKey == directionkey.I then
        yabaiClient.focusWindow("north")
        return true
    elseif currKey == directionkey.O then
        yabaiClient.focusWindow("east")
        return true
    elseif currKey == directionkey.C then
        hs.alert.show("🚀 Creating new Space...")
        yabaiClient.createSpaceAndFocus()
        return true
    elseif currKey == directionkey.Q then
        hs.alert.show("🗑 Destroying current Space...")
        yabaiClient.destroyFocusedSpace()
        return true
    elseif currKey == directionkey.S or currKey == directionkey.N then
        switchYabaiSpace("next")
        return true
    elseif currKey == directionkey.A or currKey == directionkey.P then
        switchYabaiSpace("prev")
        return true
    elseif currKey == directionkey.LEFT_BRACKET then
        yabaiClient.focusRecentWindow()
        return true
    elseif currKey == directionkey._1 then
        yabaiClient.focusSpace(1)
        return true
    elseif currKey == directionkey._2 then
        yabaiClient.focusSpace(2)
        return true
    elseif currKey == directionkey._3 then
        yabaiClient.focusSpace(3)
        return true
    elseif currKey == directionkey._4 then
        yabaiClient.focusSpace(4)
        return true
    elseif currKey == directionkey._5 then
        yabaiClient.focusSpace(5)
        return true
    elseif currKey == directionkey._6 then
        yabaiClient.focusSpace(6)
        return true
    elseif currKey == directionkey._7 then
        yabaiClient.focusSpace(7)
        return true
    elseif currKey == directionkey._8 then
        yabaiClient.focusSpace(8)
        return true
    elseif currKey == directionkey._9 then
        yabaiClient.focusSpace(9)
        return true
    elseif currKey == directionkey._0 then
        yabaiClient.focusSpace(10)
        return true
    end

    return false
end

directionkey.eventKeyDown = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local currKey = e:getKeyCode()
    local flags = e:getFlags()
    directionkey.shiftState = flags.shift == true

    if not directionkey.capState and isYabaiLeaderActive() then
        if handleYabaiLeaderKey(currKey) then
            return true
        end
    end

    if currKey == directionkey.capslock then
        if not directionkey.capState then
            directionkey.capState = true
            hs.alert.closeAll()
            hs.alert.show("dir mod", {
                atScreenEdge = 2,
                textFont = "Fira Code",
                textSize = 20
            }, "infinite")
        end
        return true
    end

    if directionkey.capState then
        return handleCapsModeKey(currKey, flags)
    end

    return false
end)
directionkey.eventKeyDown:start()


return directionkey
