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

-- We create a global function so it can be called from your CapsLock (directionKey) script or a hotkey
function hints.toggle()
    -- If already active, we just want to cancel them. Unfortunately hs.hints doesn't expose a hide() function,
    -- but pressing Esc is the native way to cancel. We can simulate an Esc key press to cancel it.
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
    
    -- Show the hints!
    -- hs.hints natively blocks and waits. When it finishes or is canceled, we reset our state.
    -- Because windowHints is slightly asynchronous in its UI, we reset the state after a short delay
    -- or just rely on the toggle logic. A cleaner way:
    hs.hints.windowHints(windows, function()
        hintsActive = false
    end)
end

-- Fallback hotkey (Alt + Space) just in case you want to trigger it without CapsLock
hs.hotkey.bind({"alt"}, "space", function()
    hints.toggle()
end)

return hints
