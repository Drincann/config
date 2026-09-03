local drawing = require("hs.drawing")
local screen = require("hs.screen")
local spaces = require("hs.spaces")
local timer = require("hs.timer")
local window = require("hs.window")
local windowFilter = require("hs.window.filter")

local focusBorder = {}

local BORDER_WIDTH = 4
local BORDER_COLOR = {
    red = 0x7a / 0xff,
    green = 0xa2 / 0xff,
    blue = 0xf7 / 0xff,
    alpha = 1.0
}

local borderDrawing = nil
local focusedWindow = nil
local focusedWindowFilter = nil
local refreshTimer = nil
local screenWatcher = nil
local spaceWatcher = nil

local function hideBorder()
    focusedWindow = nil
    if borderDrawing then
        borderDrawing:hide()
    end
end

local function canDrawBorder(targetWindow)
    return targetWindow
        and targetWindow:isStandard()
        and not targetWindow:isFullScreen()
end

local function drawBorder(targetWindow)
    if not canDrawBorder(targetWindow) then
        hideBorder()
        return
    end

    focusedWindow = targetWindow
    borderDrawing:setFrame(targetWindow:frame()):show()
end

local function refreshBorder()
    drawBorder(window.focusedWindow())
end

local function scheduleRefresh()
    if refreshTimer then
        refreshTimer:start()
    end
end

local focusedWindowEvents = {
    [windowFilter.windowFocused] = function(targetWindow)
        drawBorder(targetWindow)
    end,
    [windowFilter.windowMoved] = function(targetWindow)
        if focusedWindow and targetWindow:id() == focusedWindow:id() then
            drawBorder(targetWindow)
        end
    end,
    [windowFilter.windowUnfocused] = scheduleRefresh,
    [windowFilter.windowNotVisible] = scheduleRefresh,
    [windowFilter.windowDestroyed] = scheduleRefresh
}

function focusBorder.start()
    focusBorder.stop()

    borderDrawing = drawing.rectangle({ x = -5, y = -5, w = 1, h = 1 })
        :setFill(false)
        :setStroke(true)
        :setStrokeWidth(BORDER_WIDTH)
        :setStrokeColor(BORDER_COLOR)
        :setLevel("overlay")
        :setBehaviorByLabels({ "canJoinAllSpaces", "transient" })

    refreshTimer = timer.delayed.new(0.05, refreshBorder)
    focusedWindowFilter = windowFilter.copy(windowFilter.default, "focus-border")
        :setOverrideFilter({ focused = true })
        :subscribe(focusedWindowEvents, true)
    screenWatcher = screen.watcher.new(scheduleRefresh):start()
    spaceWatcher = spaces.watcher.new(scheduleRefresh):start()
    refreshBorder()
end

function focusBorder.stop()
    if focusedWindowFilter then
        focusedWindowFilter:unsubscribe(focusedWindowEvents)
        focusedWindowFilter:delete()
        focusedWindowFilter = nil
    end
    if screenWatcher then
        screenWatcher:stop()
        screenWatcher = nil
    end
    if spaceWatcher then
        spaceWatcher:stop()
        spaceWatcher = nil
    end
    if refreshTimer then
        refreshTimer:stop()
        refreshTimer = nil
    end
    if borderDrawing then
        borderDrawing:delete()
        borderDrawing = nil
    end
    focusedWindow = nil
end

focusBorder.start()

return focusBorder
