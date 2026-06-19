local hintsModule = require("hs.hints")
local timer = require("hs.timer")
local windowFilter = require("hs.window.filter")

local hints = {}
local hintsActive = false
local cachedWindows = {}
local lastRefreshAt = 0

-- Customize the appearance of hints to match your Vim/geek aesthetic
hintsModule.style = "default" -- 'vimperator' forces app-name prefix (2 letters), 'default' uses single letters
hintsModule.showTitleThresh = 4 -- Show window titles if there are more than 4 windows
hintsModule.titleMaxSize = 40 -- Max length of window title
hintsModule.fontSize = 25 -- Make the letters easy to read

-- You can customize the characters used for the hints. 
-- The default is A-Z. Let's stick to the left hand home row first for maximum speed.
hintsModule.hintChars = {"A", "S", "D", "F", "J", "K", "L", "Q", "W", "E", "R", "U", "I", "O", "P"}

local function refreshWindows()
    cachedWindows = windowFilter.defaultCurrentSpace:getWindows()
    lastRefreshAt = timer.secondsSinceEpoch()
    return cachedWindows
end

local function currentWindows()
    if #cachedWindows == 0 then
        return refreshWindows()
    end
    return cachedWindows
end

function hints.toggle()
    if hintsActive then
        hs.eventtap.keyStroke({}, "escape")
        hintsActive = false
        return
    end

    -- Get all standard visible windows on the current space
    local windows = currentWindows()
    
    if #windows == 0 then
        return
    end
    
    hintsActive = true
    
    hintsModule.windowHints(windows, function()
        hintsActive = false
        timer.doAfter(0.1, refreshWindows)
    end)
end

timer.doAfter(1.5, refreshWindows)

-- Fallback hotkey (Alt + Space) removed to use Superkey (CapsLock) in directionKey.lua

_G.windowHintsPlugin = hints
return hints
