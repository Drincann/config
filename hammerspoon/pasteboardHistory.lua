_G.pastboard = {}
local pastboard = _G.pastboard
pastboard.history = {}
pastboard.max = 1000
pastboard.maxDisplayLength = 100
pastboard.searchMaxChars = 5000
pastboard.lastContent = hs.pasteboard.getContents()

local SCORE_MATCH = 16
local SCORE_GAP_START = -3
local SCORE_GAP_EXTENSION = -1
local BONUS_BOUNDARY = SCORE_MATCH / 2
local BONUS_NON_WORD = SCORE_MATCH / 2
local BONUS_CAMEL_123 = BONUS_BOUNDARY + SCORE_GAP_EXTENSION
local BONUS_CONSECUTIVE = -(SCORE_GAP_START + SCORE_GAP_EXTENSION)
local BONUS_FIRST_CHAR_MULTIPLIER = 2

local CHAR_WHITE = 1
local CHAR_NON_WORD = 2
local CHAR_DELIMITER = 3
local CHAR_LOWER = 4
local CHAR_UPPER = 5
local CHAR_NUMBER = 6

local function isAsciiUpper(c)
    return c >= 65 and c <= 90
end

local function isAsciiLower(c)
    return c >= 97 and c <= 122
end

local function isAsciiNumber(c)
    return c >= 48 and c <= 57
end

local function lowerCode(c)
    if isAsciiUpper(c) then
        return c + 32
    end
    return c
end

local function charClass(c)
    if c == 32 or c == 9 or c == 10 or c == 11 or c == 12 or c == 13 then
        return CHAR_WHITE
    end
    if c == 47 or c == 44 or c == 58 or c == 59 or c == 124 then
        return CHAR_DELIMITER
    end
    if isAsciiLower(c) then
        return CHAR_LOWER
    end
    if isAsciiUpper(c) then
        return CHAR_UPPER
    end
    if isAsciiNumber(c) then
        return CHAR_NUMBER
    end
    return CHAR_NON_WORD
end

local function bonusFor(prevClass, currentClass, patternIndex)
    local bonus = 0

    if prevClass == CHAR_WHITE then
        bonus = BONUS_BOUNDARY + 2
    elseif prevClass == CHAR_DELIMITER then
        bonus = BONUS_BOUNDARY + 1
    elseif prevClass == CHAR_NON_WORD then
        bonus = BONUS_NON_WORD
    elseif (prevClass == CHAR_LOWER and currentClass == CHAR_UPPER)
        or (prevClass ~= CHAR_NUMBER and currentClass == CHAR_NUMBER)
        or (prevClass == CHAR_NUMBER and currentClass ~= CHAR_NUMBER) then
        bonus = BONUS_CAMEL_123
    end

    if patternIndex == 1 then
        bonus = bonus * BONUS_FIRST_CHAR_MULTIPLIER
    end

    return bonus
end

local function toChars(str)
    local chars = {}
    local prevClass = CHAR_WHITE

    for byteIndex, code in utf8.codes(str) do
        local currentClass = charClass(code)
        table.insert(chars, {
            code = code,
            lower = lowerCode(code),
            byte = byteIndex,
            class = currentClass,
            prevClass = prevClass
        })
        prevClass = currentClass
    end

    return chars
end

local function toPatternChars(pattern)
    local chars = {}
    for _, code in utf8.codes(pattern) do
        table.insert(chars, lowerCode(code))
    end
    return chars
end

local function matchTerm(textChars, pattern)
    local patternChars = toPatternChars(pattern)
    local n = #textChars
    local m = #patternChars

    if m == 0 then
        return { score = 0, indices = {}, span = 0, startChar = 1, endChar = 1, textLen = n }
    end
    if n == 0 or m > n then
        return nil
    end

    local patternCursor = 1
    for _, ch in ipairs(textChars) do
        if ch.lower == patternChars[patternCursor] then
            patternCursor = patternCursor + 1
            if patternCursor > m then
                break
            end
        end
    end
    if patternCursor <= m then
        return nil
    end

    local prevScores = {}
    local backtrack = {}

    for i = 1, m do
        local currentScores = {}
        backtrack[i] = {}

        local bestGapScore = nil
        local bestGapIndex = nil

        for j = 1, n do
            if bestGapScore then
                bestGapScore = bestGapScore + SCORE_GAP_EXTENSION
            end

            if i > 1 and j >= 3 and prevScores[j - 2] then
                local newGapScore = prevScores[j - 2] + SCORE_GAP_START
                if not bestGapScore or newGapScore > bestGapScore then
                    bestGapScore = newGapScore
                    bestGapIndex = j - 2
                end
            end

            if textChars[j].lower == patternChars[i] then
                local bonus = bonusFor(textChars[j].prevClass, textChars[j].class, i)

                if i == 1 then
                    currentScores[j] = SCORE_MATCH + bonus
                    backtrack[i][j] = 0
                else
                    local bestPrevScore = nil
                    local bestPrevIndex = nil

                    if j > 1 and prevScores[j - 1] then
                        bestPrevScore = prevScores[j - 1] + BONUS_CONSECUTIVE
                        bestPrevIndex = j - 1
                    end

                    if bestGapScore and (not bestPrevScore or bestGapScore > bestPrevScore) then
                        bestPrevScore = bestGapScore
                        bestPrevIndex = bestGapIndex
                    end

                    if bestPrevScore then
                        currentScores[j] = bestPrevScore + SCORE_MATCH + bonus
                        backtrack[i][j] = bestPrevIndex
                    end
                end
            end
        end

        prevScores = currentScores
    end

    local bestScore = nil
    local bestEndIndex = nil
    for j, score in pairs(prevScores) do
        if not bestScore or score > bestScore or (score == bestScore and j < bestEndIndex) then
            bestScore = score
            bestEndIndex = j
        end
    end

    if not bestScore then
        return nil
    end

    local charIndices = {}
    local cursor = bestEndIndex
    for i = m, 1, -1 do
        charIndices[i] = cursor
        cursor = backtrack[i][cursor]
    end

    local byteIndices = {}
    for _, charIndex in ipairs(charIndices) do
        table.insert(byteIndices, textChars[charIndex].byte)
    end

    local startChar = charIndices[1]
    local endChar = charIndices[#charIndices]
    if endChar - startChar + 1 == m then
        bestScore = bestScore + (BONUS_CONSECUTIVE * m)
    end

    return {
        score = bestScore,
        indices = byteIndices,
        span = endChar - startChar + 1,
        startChar = startChar,
        endChar = endChar,
        textLen = n
    }
end

local function mergeIndices(target, source)
    for _, index in ipairs(source) do
        target[index] = true
    end
end

-- fzf-like fuzzy search: all whitespace-separated terms must match.
local function getFuzzyMatch(str, pattern, cachedTextChars)
    if pattern == "" then return { score = 0, indices = {}, span = 0, startChar = 1, textLen = 0 } end

    local terms = {}
    for term in pattern:gmatch("%S+") do
        table.insert(terms, term)
    end

    if #terms == 0 then
        return { score = 0, indices = {}, span = 0, startChar = 1, textLen = 0 }
    end

    local textChars = cachedTextChars or toChars(str)
    local score = 0
    local span = 0
    local startChar = nil
    local endChar = nil
    local uniqueIndices = {}

    for _, term in ipairs(terms) do
        local matchInfo = matchTerm(textChars, term)
        if not matchInfo then
            return nil
        end

        score = score + matchInfo.score
        span = span + matchInfo.span
        startChar = startChar and math.min(startChar, matchInfo.startChar) or matchInfo.startChar
        endChar = endChar and math.max(endChar, matchInfo.endChar) or matchInfo.endChar
        mergeIndices(uniqueIndices, matchInfo.indices)
    end

    local indices = {}
    for index in pairs(uniqueIndices) do
        table.insert(indices, index)
    end
    table.sort(indices)

    return {
        score = score,
        indices = indices,
        span = endChar - startChar + 1,
        startChar = startChar,
        termSpan = span,
        textLen = #textChars
    }
end

local function cleanClipboardText(str)
    return str:gsub("[\r\n]+", " "):gsub("^%s*", "")
end

local function truncateForSearch(str)
    local charCount = 0
    for byteIndex in utf8.codes(str) do
        charCount = charCount + 1
        if charCount > pastboard.searchMaxChars then
            return str:sub(1, byteIndex - 1)
        end
    end
    return str
end

local function getItemSearchData(item, text)
    local cleanStr = cleanClipboardText(text)
    local searchStr = truncateForSearch(cleanStr)

    if type(item) ~= "table" then
        return cleanStr, toChars(searchStr)
    end

    if item.searchSource ~= text or item.searchMaxChars ~= pastboard.searchMaxChars then
        item.searchSource = text
        item.searchMaxChars = pastboard.searchMaxChars
        item.searchCleanStr = cleanStr
        item.searchChars = toChars(searchStr)
    end

    return item.searchCleanStr, item.searchChars
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
        local cleanStr = cleanClipboardText(v)
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
        local cleanStr, searchChars = getItemSearchData(item, v)
        local matchInfo = getFuzzyMatch(cleanStr, query, searchChars)
        
        if matchInfo then
            local st = createStyledSnippet(cleanStr, matchInfo.indices)
            local timeStr = os.date("%m-%d %H:%M", t)

            table.insert(filtered, {
                text = st,
                subText = string.format("[%s]  Length: %d", timeStr, #v),
                fullText = v,
                score = matchInfo.score,
                span = matchInfo.span,
                startChar = matchInfo.startChar,
                textLen = matchInfo.textLen,
                originalIndex = i
            })
        end
    end
    
    -- Sort by score descending, then by original index ascending (recency)
    table.sort(filtered, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.span ~= b.span then
            return a.span < b.span
        end
        if a.startChar ~= b.startChar then
            return a.startChar < b.startChar
        end
        if a.textLen ~= b.textLen then
            return a.textLen < b.textLen
        end
        return a.originalIndex < b.originalIndex
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
