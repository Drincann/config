local hints = {}

-- Customize the appearance of hints to match your Vim/geek aesthetic
hs.hints.style = "default" -- 'vimperator' forces app-name prefix (2 letters), 'default' uses single letters
hs.hints.showTitleThresh = 4 -- Show window titles if there are more than 4 windows
hs.hints.titleMaxSize = 40 -- Max length of window title
hs.hints.fontSize = 25 -- Make the letters easy to read

-- You can customize the characters used for the hints. 
-- The default is A-Z. Let's stick to the left hand home row first for maximum speed.
hs.hints.hintChars = {"A", "S", "D", "F", "J", "K", "L", "Q", "W", "E", "R", "U", "I", "O", "P"}

local hintsActive = false

function hints.toggle()
    if hintsActive then
        hs.eventtap.keyStroke({}, "escape")
        hintsActive = false
        return
    end

    -- Get all standard visible windows on the current space
    local windows = hs.window.filter.defaultCurrentSpace:getWindows()
    
    if #windows == 0 then
        return
    end
    
    hintsActive = true
    
    hs.hints.windowHints(windows, function()
        hintsActive = false
    end)
end

-- Fallback hotkey (Alt + Space) removed to use Superkey (CapsLock) in directionKey.lua

_G.windowHintsPlugin = hints
return hints
