_G.windowSearcher = {}
local windowSearcher = _G.windowSearcher
local YABAI_PATH = "/opt/homebrew/bin/yabai"
local yabaiTasks = {}

local function runYabai(args)
    local task
    task = hs.task.new(YABAI_PATH, function(exitCode, stdout, stderr)
        yabaiTasks[task] = nil
        if exitCode ~= 0 and stderr and stderr ~= "" then
            hs.printf("windowSearcher yabai failed: %s", stderr)
        end
    end, args)

    if task then
        yabaiTasks[task] = true
        if not task:start() then
            yabaiTasks[task] = nil
        end
    end
end

-- The chooser object
windowSearcher.chooser = hs.chooser.new(function(choice)
    if not choice then
        return
    end

    -- User selected a window
    local win = hs.window.get(choice.windowID)
    if win then
        -- We try Hammerspoon's native focus first
        win:focus()
        
        -- Yabai fallback is extremely powerful for cross-space jumping, but we need the native window ID.
        -- Hammerspoon's win:id() perfectly matches Yabai's window ID!
        runYabai({"-m", "window", "--focus", tostring(choice.windowID)})
    else
        hs.alert.show("Window no longer exists")
    end
end)

windowSearcher.chooser:placeholderText("Search for an open window...")
-- Hammerspoon's default chooser behavior handles typing out of the box

-- Function to get all windows
local function getWindowChoices()
    local choices = {}
    -- getWindows() returns all windows across ALL spaces
    local windows = hs.window.filter.default:getWindows()
    
    for _, win in ipairs(windows) do
        local app = win:application()
        if app then
            local appName = app:name() or "Unknown App"
            local winTitle = win:title()
            
            -- Fallback if title is empty
            if winTitle == "" then winTitle = "Untitled" end
            
            -- Try to load the application icon
            local appIcon = nil
            local bundleID = app:bundleID()
            if bundleID then
                appIcon = hs.image.imageFromAppBundle(bundleID)
            end
            
            table.insert(choices, {
                text = appName .. " - " .. winTitle,
                subText = "Window ID: " .. win:id(),
                windowID = win:id(),
                image = appIcon -- Beautiful UI addition!
            })
        end
    end
    
    return choices
end

function windowSearcher.toggle()
    if windowSearcher.chooser:isVisible() then
        windowSearcher.chooser:hide()
    else
        windowSearcher.chooser:choices(getWindowChoices())
        windowSearcher.chooser:show()
    end
end

-- Fallback hotkey: Cmd + Ctrl + F (or adjust based on what your super key maps to system-wide)
hs.hotkey.bind({"cmd", "shift", "alt"}, "f", function()
    windowSearcher.toggle()
end)

return windowSearcher
