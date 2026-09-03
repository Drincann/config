local canvas = require("hs.canvas")
local screen = require("hs.screen")
local spaces = require("hs.spaces")
local task = require("hs.task")
local timer = require("hs.timer")
local window = require("hs.window")
local windowFilter = require("hs.window.filter")

local focusBorder = {}

local YABAI_PATH = "/opt/homebrew/bin/yabai"
local BORDER_WIDTH = 6
local FOCUS_BORDER_COLOR = {
    red = 0xff / 0xff,
    green = 0xcc / 0xff,
    blue = 0x00 / 0xff,
    alpha = 1.0
}
local STACK_BORDER_COLOR = {
    red = 0xff / 0xff,
    green = 0x2d / 0xff,
    blue = 0x9b / 0xff,
    alpha = 1.0
}
local STACK_BADGE_HEIGHT = 36
local STACK_BADGE_PADDING = 11
local STACK_MARKER_DIAMETER = 14
local STACK_MARKER_GAP = 8
local STACK_ACTIVE_COLOR = {
    red = 0x30 / 0xff,
    green = 0xd1 / 0xff,
    blue = 0x58 / 0xff,
    alpha = 1.0
}
local STACK_INACTIVE_COLOR = {
    red = 0x8e / 0xff,
    green = 0x8e / 0xff,
    blue = 0x93 / 0xff,
    alpha = 0.9
}

local focusBorderCanvas = nil
local stackBadge = nil
local focusedWindow = nil
local focusedWindowFilter = nil
local refreshTimer = nil
local stackStatusTimer = nil
local screenWatcher = nil
local spaceWatcher = nil
local stackStatusTasks = {}
local stackStatusGeneration = 0
local visibleStackSize = 0

local function hideStackBadge()
    if stackBadge then
        stackBadge:hide()
    end
end

local function showNormalFocusState()
    if focusBorderCanvas and focusedWindow then
        focusBorderCanvas:frame(focusedWindow:frame())
        focusBorderCanvas[1].strokeColor = FOCUS_BORDER_COLOR
        focusBorderCanvas:show()
    end
    visibleStackSize = 0
    hideStackBadge()
end

local function stackBadgeWidth(stackSize)
    return STACK_BADGE_PADDING * 2
        + STACK_MARKER_DIAMETER * stackSize
        + STACK_MARKER_GAP * math.max(0, stackSize - 1)
end

local function moveStackBadge(targetWindow)
    if not stackBadge or not targetWindow or visibleStackSize == 0 then
        return
    end

    local frame = targetWindow:frame()
    local badgeWidth = stackBadgeWidth(visibleStackSize)
    stackBadge:frame({
        x = frame.x + frame.w - badgeWidth - 10,
        y = frame.y + frame.h - STACK_BADGE_HEIGHT - 10,
        w = badgeWidth,
        h = STACK_BADGE_HEIGHT
    })
end

local function stackBadgeElements(stackIndex, stackSize)
    local elements = {
        {
            type = "rectangle",
            action = "fill",
            fillColor = { red = 0.08, green = 0.09, blue = 0.14, alpha = 0.92 },
            roundedRectRadii = { xRadius = 9, yRadius = 9 },
            frame = { x = 0, y = 0, w = stackBadgeWidth(stackSize), h = STACK_BADGE_HEIGHT }
        }
    }

    local markerRadius = STACK_MARKER_DIAMETER / 2
    for index = 1, stackSize do
        local isActive = index == stackIndex
        table.insert(elements, {
            type = "circle",
            action = isActive and "strokeAndFill" or "stroke",
            center = {
                x = STACK_BADGE_PADDING + markerRadius
                    + (index - 1) * (STACK_MARKER_DIAMETER + STACK_MARKER_GAP),
                y = STACK_BADGE_HEIGHT / 2
            },
            radius = markerRadius,
            fillColor = STACK_ACTIVE_COLOR,
            strokeColor = isActive and STACK_ACTIVE_COLOR or STACK_INACTIVE_COLOR,
            strokeWidth = 2.5
        })
    end
    return elements
end

local function showStackState(targetWindow, stackIndex, stackSize)
    if not focusBorderCanvas or not stackBadge then
        return
    end

    focusBorderCanvas:frame(targetWindow:frame())
    focusBorderCanvas[1].strokeColor = STACK_BORDER_COLOR
    focusBorderCanvas:show()
    visibleStackSize = stackSize
    stackBadge
        :size({ w = stackBadgeWidth(stackSize), h = STACK_BADGE_HEIGHT })
        :replaceElements(stackBadgeElements(stackIndex, stackSize))
    moveStackBadge(targetWindow)
    stackBadge:show()
end

local function framesMatch(left, right)
    if not left or not right then
        return false
    end

    local tolerance = 1
    return math.abs(left.x - right.x) <= tolerance
        and math.abs(left.y - right.y) <= tolerance
        and math.abs(left.w - right.w) <= tolerance
        and math.abs(left.h - right.h) <= tolerance
end

local function queryFocusedWindowStack()
    if not focusedWindow then
        showNormalFocusState()
        return
    end

    stackStatusGeneration = stackStatusGeneration + 1
    local requestGeneration = stackStatusGeneration
    local focusedWindowId = focusedWindow:id()
    local queryTask
    queryTask = task.new(YABAI_PATH, function(exitCode, stdout)
        stackStatusTasks[queryTask] = nil
        if requestGeneration ~= stackStatusGeneration
            or not focusedWindow
            or focusedWindow:id() ~= focusedWindowId then
            return
        end

        if exitCode ~= 0 then
            showNormalFocusState()
            return
        end

        local decoded, windows = pcall(hs.json.decode, stdout)
        if not decoded or type(windows) ~= "table" then
            showNormalFocusState()
            return
        end

        local focusedWindowData = nil
        for _, windowData in ipairs(windows) do
            if windowData.id == focusedWindowId then
                focusedWindowData = windowData
                break
            end
        end

        local stackIndex = focusedWindowData and focusedWindowData["stack-index"] or 0
        if stackIndex == 0 then
            showNormalFocusState()
            return
        end

        local stackSize = 0
        for _, windowData in ipairs(windows) do
            if windowData.space == focusedWindowData.space
                and windowData["stack-index"] > 0
                and framesMatch(windowData.frame, focusedWindowData.frame) then
                stackSize = stackSize + 1
            end
        end
        showStackState(focusedWindow, stackIndex, stackSize)
    end, { "-m", "query", "--windows" })

    if queryTask then
        stackStatusTasks[queryTask] = true
        if not queryTask:start() then
            stackStatusTasks[queryTask] = nil
            showNormalFocusState()
        end
    else
        showNormalFocusState()
    end
end

local function scheduleStackStatusRefresh()
    if stackStatusTimer then
        stackStatusTimer:start()
    end
end

local function hideBorder()
    stackStatusGeneration = stackStatusGeneration + 1
    focusedWindow = nil
    if focusBorderCanvas then
        focusBorderCanvas:hide()
    end
    hideStackBadge()
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

    local focusChanged = not focusedWindow or focusedWindow:id() ~= targetWindow:id()
    focusedWindow = targetWindow
    if focusChanged then
        focusBorderCanvas:hide()
        hideStackBadge()
        queryFocusedWindowStack()
        return
    end
    focusBorderCanvas:frame(targetWindow:frame()):show()
    moveStackBadge(targetWindow)
    scheduleStackStatusRefresh()
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

function focusBorder.refresh()
    refreshBorder()
end

function focusBorder.start()
    focusBorder.stop()

    focusBorderCanvas = canvas.new({ x = -5, y = -5, w = 1, h = 1 })
        :level("overlay")
        :behavior({ "canJoinAllSpaces", "transient" })
        :clickActivating(false)
        :canvasMouseEvents(false, false, false, false)
        :appendElements({
            {
                type = "rectangle",
                action = "stroke",
                strokeColor = FOCUS_BORDER_COLOR,
                strokeWidth = BORDER_WIDTH,
                roundedRectRadii = { xRadius = 12, yRadius = 12 },
                padding = BORDER_WIDTH / 2,
                frame = { x = 0, y = 0, w = "100%", h = "100%" }
            }
        })

    stackBadge = canvas.new({ x = -5, y = -5, w = 1, h = STACK_BADGE_HEIGHT })
        :level("overlay")
        :behavior({ "canJoinAllSpaces", "transient" })
        :clickActivating(false)
        :canvasMouseEvents(false, false, false, false)

    refreshTimer = timer.delayed.new(0.05, refreshBorder)
    stackStatusTimer = timer.delayed.new(0.08, queryFocusedWindowStack)
    focusedWindowFilter = windowFilter.copy(windowFilter.default, "focus-border")
        :setOverrideFilter({ focused = true })
        :subscribe(focusedWindowEvents, true)
    screenWatcher = screen.watcher.new(scheduleRefresh):start()
    spaceWatcher = spaces.watcher.new(scheduleRefresh):start()
    refreshBorder()
end

function focusBorder.stop()
    stackStatusGeneration = stackStatusGeneration + 1
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
    if stackStatusTimer then
        stackStatusTimer:stop()
        stackStatusTimer = nil
    end
    if stackBadge then
        stackBadge:delete()
        stackBadge = nil
    end
    if focusBorderCanvas then
        focusBorderCanvas:delete()
        focusBorderCanvas = nil
    end
    stackStatusTasks = {}
    visibleStackSize = 0
    focusedWindow = nil
end

focusBorder.start()

return focusBorder
