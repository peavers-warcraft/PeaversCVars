local _, addon = ...

local Autocomplete = {}
addon.Autocomplete = Autocomplete

local Config = addon.Config
local CVarDatabase = addon.CVarDatabase

local dropdown = nil
local items = {}
local selectedIndex = 0
local currentResults = {}
local attachedEditBox = nil

-- ═══════════════════════════════════════════════════════════════
-- DROPDOWN ITEM CREATION
-- ═══════════════════════════════════════════════════════════════

local function CreateDropdownItem(parent, index)
    local cfg = Config.AUTOCOMPLETE
    local item = CreateFrame("Button", nil, parent, "BackdropTemplate")
    item:SetHeight(cfg.ITEM_HEIGHT)
    item:SetPoint("TOPLEFT", parent, "TOPLEFT", cfg.PADDING, -cfg.PADDING - ((index - 1) * cfg.ITEM_HEIGHT))
    item:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -cfg.PADDING, -cfg.PADDING - ((index - 1) * cfg.ITEM_HEIGHT))

    item:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    })
    item:SetBackdropColor(0, 0, 0, 0)

    -- Command name
    local commandText = item:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    commandText:SetPoint("TOPLEFT", 10, -6)
    commandText:SetJustifyH("LEFT")
    commandText:SetTextColor(Config.GetColor("TEXT_GOLD"))
    item.commandText = commandText

    -- Category badge
    local categoryBadge = item:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    categoryBadge:SetPoint("LEFT", commandText, "RIGHT", 8, 0)
    categoryBadge:SetTextColor(Config.GetColor("ACCENT"))
    item.categoryBadge = categoryBadge

    -- Description
    local descText = item:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    descText:SetPoint("TOPLEFT", 10, -22)
    descText:SetPoint("TOPRIGHT", -10, -22)
    descText:SetJustifyH("LEFT")
    descText:SetTextColor(Config.GetColor("TEXT_SECONDARY"))
    descText:SetMaxLines(1)
    item.descText = descText

    item:SetScript("OnEnter", function(self)
        if selectedIndex ~= self.index then
            selectedIndex = self.index
            Autocomplete.UpdateSelection()
        end
    end)

    item:SetScript("OnClick", function(self)
        Autocomplete.SelectCurrent()
    end)

    item.index = index
    return item
end

-- ═══════════════════════════════════════════════════════════════
-- DROPDOWN CREATION
-- ═══════════════════════════════════════════════════════════════

local function CreateDropdown()
    if dropdown then
        return dropdown
    end

    local cfg = Config.AUTOCOMPLETE

    dropdown = CreateFrame("Frame", "PeaversCVarsAutocomplete", UIParent, "BackdropTemplate")
    dropdown:SetWidth(cfg.DROPDOWN_WIDTH)
    dropdown:SetFrameStrata("TOOLTIP")
    dropdown:SetFrameLevel(200)

    dropdown:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    dropdown:SetBackdropColor(Config.GetColor("BG_PRIMARY"))
    dropdown:SetBackdropBorderColor(Config.GetColor("BORDER_ACCENT"))

    -- Header
    local header = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", cfg.PADDING + 4, -cfg.PADDING)
    header:SetText("SUGGESTIONS")
    header:SetTextColor(Config.GetColor("TEXT_MUTED"))
    dropdown.header = header

    for i = 1, cfg.MAX_RESULTS do
        items[i] = CreateDropdownItem(dropdown, i)
        -- Offset for header
        items[i]:ClearAllPoints()
        items[i]:SetPoint("TOPLEFT", dropdown, "TOPLEFT", cfg.PADDING, -(cfg.PADDING + 16 + ((i - 1) * cfg.ITEM_HEIGHT)))
        items[i]:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", -cfg.PADDING, -(cfg.PADDING + 16 + ((i - 1) * cfg.ITEM_HEIGHT)))
    end

    dropdown:Hide()
    return dropdown
end

-- ═══════════════════════════════════════════════════════════════
-- SELECTION MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

function Autocomplete.UpdateSelection()
    for i, item in ipairs(items) do
        if i == selectedIndex then
            item:SetBackdropColor(Config.GetColor("BG_SELECTED"))
            item.commandText:SetTextColor(Config.GetColor("TEXT_PRIMARY"))
        else
            item:SetBackdropColor(0, 0, 0, 0)
            item.commandText:SetTextColor(Config.GetColor("TEXT_GOLD"))
        end
    end
end

function Autocomplete.Show(editBox, results)
    if not dropdown then
        CreateDropdown()
    end

    local cfg = Config.AUTOCOMPLETE
    attachedEditBox = editBox
    currentResults = results
    selectedIndex = 0

    local numResults = math.min(#results, cfg.MAX_RESULTS)

    if numResults == 0 then
        dropdown:Hide()
        return
    end

    -- Position below the edit box
    dropdown:ClearAllPoints()
    dropdown:SetPoint("TOPLEFT", editBox:GetParent(), "BOTTOMLEFT", 0, -4)
    dropdown:SetHeight((numResults * cfg.ITEM_HEIGHT) + cfg.PADDING * 2 + 16) -- +16 for header

    -- Populate items
    for i = 1, cfg.MAX_RESULTS do
        local item = items[i]
        if i <= numResults then
            local cvar = results[i]
            item.commandText:SetText(cvar.command)
            item.categoryBadge:SetText(cvar.category or "")
            item.descText:SetText(cvar.description)
            item.cvarData = cvar
            item:Show()
        else
            item:Hide()
        end
    end

    Autocomplete.UpdateSelection()
    dropdown:Show()
end

function Autocomplete.Hide()
    if dropdown then
        dropdown:Hide()
    end
    selectedIndex = 0
    currentResults = {}
    attachedEditBox = nil
end

function Autocomplete.IsShown()
    return dropdown and dropdown:IsShown()
end

function Autocomplete.SelectCurrent()
    if selectedIndex > 0 and selectedIndex <= #currentResults then
        local cvar = currentResults[selectedIndex]
        if attachedEditBox and cvar then
            local currentValue = GetCVar(cvar.command)
            local value = currentValue or cvar.default or ""
            attachedEditBox:SetText(cvar.command .. " " .. value)
            attachedEditBox:SetCursorPosition(#attachedEditBox:GetText())
        end
    end
    Autocomplete.Hide()
end

function Autocomplete.MoveSelection(delta)
    if not Autocomplete.IsShown() then
        return false
    end

    local cfg = Config.AUTOCOMPLETE
    local numResults = math.min(#currentResults, cfg.MAX_RESULTS)
    if numResults == 0 then
        return false
    end

    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then
        selectedIndex = numResults
    elseif selectedIndex > numResults then
        selectedIndex = 1
    end

    Autocomplete.UpdateSelection()
    return true
end

function Autocomplete.HandleKeyDown(key)
    if not Autocomplete.IsShown() then
        return false
    end

    if key == "DOWN" then
        return Autocomplete.MoveSelection(1)
    elseif key == "UP" then
        return Autocomplete.MoveSelection(-1)
    elseif key == "TAB" then
        -- Tab selects current item (Enter is handled separately in OnEnterPressed)
        if selectedIndex > 0 then
            Autocomplete.SelectCurrent()
            return true
        elseif #currentResults > 0 then
            selectedIndex = 1
            Autocomplete.SelectCurrent()
            return true
        end
    elseif key == "ESCAPE" then
        Autocomplete.Hide()
        return true
    end

    return false
end

-- ═══════════════════════════════════════════════════════════════
-- TEXT CHANGE HANDLER
-- ═══════════════════════════════════════════════════════════════

function Autocomplete.OnTextChanged(editBox)
    local text = editBox:GetText()

    -- Only search if we have at least 2 characters
    if not text or #text < 2 then
        Autocomplete.Hide()
        return
    end

    -- Don't show autocomplete if there's already a space (value being entered)
    if text:find(" ") then
        Autocomplete.Hide()
        return
    end

    -- Search the database
    local results = CVarDatabase.Search(text)

    if #results > 0 then
        Autocomplete.Show(editBox, results)
    else
        Autocomplete.Hide()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ATTACH TO EDIT BOX
-- ═══════════════════════════════════════════════════════════════

function Autocomplete.AttachTo(editBox)
    if not editBox then return end

    local origOnTextChanged = editBox:GetScript("OnTextChanged")
    local origOnEnterPressed = editBox:GetScript("OnEnterPressed")

    editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            Autocomplete.OnTextChanged(self)
        end
        if origOnTextChanged then
            origOnTextChanged(self, userInput)
        end
    end)

    editBox:HookScript("OnKeyDown", function(self, key)
        Autocomplete.HandleKeyDown(key)
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        if Autocomplete.IsShown() and #currentResults > 0 then
            -- If nothing selected, select the first result
            if selectedIndex == 0 then
                selectedIndex = 1
            end
            Autocomplete.SelectCurrent()
        elseif origOnEnterPressed then
            origOnEnterPressed(self)
        end
    end)

    editBox:HookScript("OnEscapePressed", function(self)
        if Autocomplete.IsShown() then
            Autocomplete.Hide()
        end
    end)

    editBox:HookScript("OnEditFocusLost", function(self)
        C_Timer.After(0.1, function()
            Autocomplete.Hide()
        end)
    end)
end

return Autocomplete
