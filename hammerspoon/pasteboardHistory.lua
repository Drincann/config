_G.pastboard = {}
local pastboard = _G.pastboard
pastboard.history = {}
pastboard.max = 1000
pastboard.maxDisplayLength = 100
pastboard.lastContent = hs.pasteboard.getContents()

-- Fuzzy search with scoring and match indices extraction (UTF-8 safe via byte indices)
local function getFuzzyMatch(str, pattern)
    if pattern == "" then return { score = 0, indices = {} } end
    
    local lowerStr = str:lower()
    local lowerPat = pattern:lower()
    
    local patChars = {}
    for _, c in utf8.codes(lowerPat) do
        table.insert(patChars, c)
    end
    
    if #patChars == 0 then return { score = 0, indices = {} } end
    
    local patIdx = 1
    local score = 0
    local consecutiveCount = 0
    local lastMatchCharIdx = 0
    local charIdx = 1
    local byteIndices = {}
    local prevChar = nil
    
    for b, c in utf8.codes(lowerStr) do
        if c == patChars[patIdx] then
            table.insert(byteIndices, b) -- Save the BYTE index of the match
            score = score + 10
            
            if lastMatchCharIdx == charIdx - 1 then
                consecutiveCount = consecutiveCount + 1
                score = score + (consecutiveCount * 5)
            else
                consecutiveCount = 0
            end
            
            if charIdx == 1 then score = score + 15 end
            
            if prevChar and (prevChar == 32 or prevChar == 9 or prevChar == 10) then
                score = score + 10
            end
            
            lastMatchCharIdx = charIdx
            patIdx = patIdx + 1
            if patIdx > #patChars then break end
        end
        prevChar = c
        charIdx = charIdx + 1
    end
    
    if patIdx > #patChars then
        return { score = score - #lowerStr, indices = byteIndices }
    else
        return nil
    end
end

-- Helper to create styled text snippet using accurate byte bounds
local function createStyledSnippet(cleanStr, matchByteIndices)
    local firstMatchByte = matchByteIndices and matchByteIndices[1] or 1
    
    local charCount = 0
    local firstMatchCharIdx = 1
    local byteToChar = {}
    local charToByte = {}
    
    for b, c in utf8.codes(cleanStr) do
        charCount = charCount + 1
        byteToChar[b] = charCount
        charToByte[charCount] = b
        if b == firstMatchByte then
            firstMatchCharIdx = charCount
        end
    end
    
    local maxLenChars = 150
    local startShowChar = 1
    local endShowChar = math.min(charCount, maxLenChars)
    
    if firstMatchCharIdx > maxLenChars / 2 then
        startShowChar = math.max(1, firstMatchCharIdx - 40)
        endShowChar = math.min(charCount, startShowChar + maxLenChars - 1)
    end
    
    local startShowByte = charToByte[startShowChar] or 1
    local nextCharByte = charToByte[endShowChar + 1]
    local endShowByte = nextCharByte and (nextCharByte - 1) or #cleanStr
    
    local snippet = cleanStr:sub(startShowByte, endShowByte)
    local prefix = startShowChar > 1 and "..." or ""
    local suffix = endShowChar < charCount and "..." or ""
    
    local displayText = prefix .. snippet .. suffix
    
    -- Base style is required to avoid transparency issues in some themes
    local st = hs.styledtext.new(displayText, { color = { white = 0.9 } })
    
    local prefixByteLen = #prefix
    
    if matchByteIndices then
        for _, b in ipairs(matchByteIndices) do
            if b >= startShowByte and b <= endShowByte then
                local charIdx = byteToChar[b]
                local nextB = charToByte[charIdx + 1] or (#cleanStr + 1)
                local charByteLen = nextB - b
                
                local adjustedStartByte = b - startShowByte + 1 + prefixByteLen
                local adjustedEndByte = adjustedStartByte + charByteLen - 1
                
                st = st:setStyle({
                    backgroundColor = {hex="#FFFF00", alpha=0.4},
                    color = {hex="#FF0000"}
                }, adjustedStartByte, adjustedEndByte)
            end
        end
    end
    
    return st
end

-- Function to prepare choices for hs.chooser
local function getChoices()
    local choices = {}
    for i, item in ipairs(pastboard.history) do
        local v = type(item) == "table" and item.text or item
        local t = type(item) == "table" and item.time or os.time()
        
        -- We must clean the string BEFORE rendering
        local cleanStr = v:gsub("[\r\n]+", " "):gsub("^%s*", "")
        local st = createStyledSnippet(cleanStr, nil)
        local timeStr = os.date("%m-%d %H:%M", t)
        
        table.insert(choices, {
            text = st,
            subText = string.format("[%s]  Length: %d", timeStr, #v),
            fullText = v
        })
    end
    return choices
end

-- Initialize hs.chooser
pastboard.chooser = hs.chooser.new(function(choice)
    if choice then
        pastboard.lastContent = choice.fullText -- Update lastContent to avoid re-adding
        hs.pasteboard.setContents(choice.fullText)
        hs.alert.show("Copied", 0.5)
    end
end)

-- Configure chooser UI
pastboard.chooser:placeholderText("Search clipboard history...")
 -- Default search behavior for better responsiveness if queryChangedCallback is not used, but we are using it

-- Enable fuzzy search by overriding the query change callback
pastboard.chooser:queryChangedCallback(function(query)
    if query == "" then
        pastboard.chooser:choices(getChoices())
        return
    end

    local filtered = {}
    for i, item in ipairs(pastboard.history) do
        local v = type(item) == "table" and item.text or item
        local t = type(item) == "table" and item.time or os.time()
        
        -- MUST clean the string BEFORE matching so indices align perfectly with snippet
        local cleanStr = v:gsub("[\r\n]+", " "):gsub("^%s*", "")
        local matchInfo = getFuzzyMatch(cleanStr, query)
        
        if matchInfo then
            local st = createStyledSnippet(cleanStr, matchInfo.indices)
            local timeStr = os.date("%m-%d %H:%M", t)

            table.insert(filtered, {
                text = st,
                subText = string.format("[%s]  Length: %d", timeStr, #v),
                fullText = v,
                score = matchInfo.score,
                originalIndex = i
            })
        end
    end
    
    -- Sort by score descending, then by original index ascending (recency)
    table.sort(filtered, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        else
            return a.originalIndex < b.originalIndex
        end
    end)
    
    pastboard.chooser:choices(filtered)
end)

-- Watcher to capture clipboard changes
pastboard.watcher = hs.pasteboard.watcher.new(function(content)
    if content == nil or content == "" or content == pastboard.lastContent then
        return
    end
    
    -- Check if it already exists and remove it (to move to top)
    for i, item in ipairs(pastboard.history) do
        local v = type(item) == "table" and item.text or item
        if v == content then
            table.remove(pastboard.history, i)
            break
        end
    end
    
    table.insert(pastboard.history, 1, {text = content, time = os.time()})
    pastboard.lastContent = content
    
    -- Trim history
    if #pastboard.history > pastboard.max then
        table.remove(pastboard.history, pastboard.max + 1)
    end
end)
pastboard.watcher:start()

-- Hotkey to trigger the clipboard history chooser (Alt + V)
hs.hotkey.bind({"alt"}, "V", function()
    if pastboard.chooser:isVisible() then
        pastboard.chooser:hide()
    else
        pastboard.chooser:choices(getChoices())
        pastboard.chooser:show()
    end
end)

-- Intercept Alt + Number to select items
pastboard.numTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    if not pastboard.chooser:isVisible() then return false end
    
    local flags = e:getFlags()
    local keyCode = e:getKeyCode()
    
    -- Check if only 'alt' is pressed
    if flags.alt and not flags.cmd and not flags.shift and not flags.ctrl then
        local num = nil
        if keyCode == hs.keycodes.map["1"] then num = 1
        elseif keyCode == hs.keycodes.map["2"] then num = 2
        elseif keyCode == hs.keycodes.map["3"] then num = 3
        elseif keyCode == hs.keycodes.map["4"] then num = 4
        elseif keyCode == hs.keycodes.map["5"] then num = 5
        elseif keyCode == hs.keycodes.map["6"] then num = 6
        elseif keyCode == hs.keycodes.map["7"] then num = 7
        elseif keyCode == hs.keycodes.map["8"] then num = 8
        elseif keyCode == hs.keycodes.map["9"] then num = 9
        elseif keyCode == hs.keycodes.map["0"] then num = 10
        end
        
        if num then
            pastboard.chooser:select(num)
            return true -- Block the event
        end
    end
    
    return false
end)
pastboard.numTap:start()

return pastboard
