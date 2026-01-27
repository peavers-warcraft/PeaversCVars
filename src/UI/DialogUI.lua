local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons or not PeaversCommons.FrameUtils then
    return
end

local DialogUI = {}
addon.DialogUI = DialogUI

local Config = addon.Config
local Storage = addon.Storage
local CVarManager = addon.CVarManager
local Autocomplete = addon.Autocomplete
local FrameUtils = PeaversCommons.FrameUtils
local Debug = PeaversCommons.Debug
local SOURCE = "CVars:DialogUI"

local function Log(level, ...)
    if Debug then
        if level == "ERROR" then
            Debug:LogError(SOURCE, ...)
        elseif level == "WARN" then
            Debug:LogWarn(SOURCE, ...)
        elseif level == "INFO" then
            Debug:LogInfo(SOURCE, ...)
        else
            Debug:LogDebug(SOURCE, ...)
        end
    end
end

local dialog = nil
local scrollContent = nil
local feedbackLabel = nil
local listItems = {}

-- ═══════════════════════════════════════════════════════════════
-- UI HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function CreateStyledButton(parent, width, height, text, isPrimary)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)

    local bgColor = isPrimary and Config.COLORS.ACCENT or Config.COLORS.BG_TERTIARY
    local bgHover = isPrimary and Config.COLORS.ACCENT_DARK or Config.COLORS.BG_HOVER

    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    btn:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    btn:SetBackdropBorderColor(Config.GetColor("BORDER_LIGHT"))

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text)
    if isPrimary then
        label:SetTextColor(0, 0, 0, 1)
    else
        label:SetTextColor(Config.GetColor("TEXT_PRIMARY"))
    end
    btn.label = label

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(bgHover[1], bgHover[2], bgHover[3], bgHover[4])
    end)

    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    end)

    return btn
end

local function ShowFeedback(message, isError)
    if feedbackLabel then
        feedbackLabel:SetText(message)
        if isError then
            feedbackLabel:SetTextColor(Config.GetColor("TEXT_ERROR"))
        else
            feedbackLabel:SetTextColor(Config.GetColor("TEXT_SUCCESS"))
        end
        feedbackLabel:Show()

        C_Timer.After(3, function()
            if feedbackLabel then
                feedbackLabel:SetText("")
            end
        end)
    end
end

local function ClearListItems()
    for _, item in ipairs(listItems) do
        if item.emptyLabel then
            item.emptyLabel:Hide()
        end
        item:Hide()
        item:SetParent(nil)
    end
    listItems = {}
end

-- ═══════════════════════════════════════════════════════════════
-- LIST ITEM CREATION
-- ═══════════════════════════════════════════════════════════════

local function CreateListItem(parent, cvarData, yOffset)
    local cfg = Config.DIALOG
    local itemHeight = cfg.LIST_ITEM_HEIGHT
    local itemWidth = cfg.WIDTH - 56  -- Account for padding and scrollbar
    local cvarCommand = cvarData.command

    Log("DEBUG", "CreateListItem:", cvarCommand, "yOffset:", yOffset)

    local item = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    item:SetSize(itemWidth, itemHeight)
    item:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, yOffset)

    item:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    item:SetBackdropColor(Config.GetColor("BG_SECONDARY"))
    item:SetBackdropBorderColor(Config.GetColor("BORDER_PRIMARY"))

    -- Command name
    local commandLabel = item:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    commandLabel:SetPoint("TOPLEFT", cfg.INNER_PADDING, -8)
    commandLabel:SetText(cvarData.command)
    commandLabel:SetTextColor(Config.GetColor("TEXT_GOLD"))

    -- Value display
    local valueLabel = item:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valueLabel:SetPoint("LEFT", commandLabel, "RIGHT", 8, 0)
    valueLabel:SetText("= " .. cvarData.value)
    valueLabel:SetTextColor(Config.GetColor("TEXT_SECONDARY"))

    -- Apply on Login checkbox
    local checkbox = CreateFrame("CheckButton", nil, item, "UICheckButtonTemplate")
    checkbox:SetPoint("BOTTOMLEFT", cfg.INNER_PADDING - 4, 4)
    checkbox:SetSize(22, 22)
    checkbox:SetChecked(cvarData.applyOnLogin)

    local checkboxLabel = item:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    checkboxLabel:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    checkboxLabel:SetText("Apply on Login")
    checkboxLabel:SetTextColor(Config.GetColor("TEXT_SECONDARY"))

    checkbox:SetScript("OnClick", function(self)
        Storage.UpdateApplyOnLoginByCommand(cvarCommand, self:GetChecked())
        if self:GetChecked() then
            ShowFeedback(cvarCommand .. " will apply on login", false)
        else
            ShowFeedback(cvarCommand .. " will not apply on login", false)
        end
    end)

    -- Buttons container (right side)
    local removeBtn = CreateStyledButton(item, cfg.BUTTON_WIDTH_SMALL, cfg.BUTTON_HEIGHT, "Remove", false)
    removeBtn:SetPoint("BOTTOMRIGHT", -cfg.INNER_PADDING, 8)
    removeBtn:SetScript("OnClick", function()
        Storage.RemoveCVarByCommand(cvarCommand)
        ShowFeedback(cvarCommand .. " removed", false)
        DialogUI.RefreshCVarList()
    end)

    local applyBtn = CreateStyledButton(item, cfg.BUTTON_WIDTH_MEDIUM, cfg.BUTTON_HEIGHT, "Apply Now", true)
    applyBtn:SetPoint("RIGHT", removeBtn, "LEFT", -6, 0)
    applyBtn:SetScript("OnClick", function()
        local success, message = CVarManager.ApplyCVar(cvarData.command, cvarData.value)
        ShowFeedback(message, not success)
    end)

    item:Show()
    table.insert(listItems, item)
    return item
end

-- ═══════════════════════════════════════════════════════════════
-- REFRESH LIST
-- ═══════════════════════════════════════════════════════════════

function DialogUI.RefreshCVarList()
    Log("DEBUG", "=== RefreshCVarList called ===")
    if not scrollContent then
        Log("ERROR", "scrollContent is nil!")
        return
    end

    ClearListItems()

    local cvars = Storage.GetAllCVars()
    local cfg = Config.DIALOG
    Log("INFO", "RefreshCVarList found", #cvars, "CVar(s)")

    local yOffset = -8
    local itemHeight = cfg.LIST_ITEM_HEIGHT

    for _, cvarData in ipairs(cvars) do
        CreateListItem(scrollContent, cvarData, yOffset)
        yOffset = yOffset - itemHeight - 6
    end

    local totalHeight = math.max(1, (#cvars * (itemHeight + 6)) + 16)
    scrollContent:SetHeight(totalHeight)

    -- Update scrollbar
    if dialog and dialog.scrollFrame and dialog.scrollFrame.UpdateScrollThumb then
        C_Timer.After(0, dialog.scrollFrame.UpdateScrollThumb)
    end

    if #cvars == 0 then
        local emptyItem = CreateFrame("Frame", nil, scrollContent)
        emptyItem:SetSize(cfg.WIDTH - 60, 80)
        emptyItem:SetPoint("TOP", 0, -40)

        local emptyIcon = emptyItem:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
        emptyIcon:SetPoint("TOP", 0, 0)
        emptyIcon:SetText("No CVars Saved")
        emptyIcon:SetTextColor(Config.GetColor("TEXT_MUTED"))

        local emptyLabel = emptyItem:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        emptyLabel:SetPoint("TOP", emptyIcon, "BOTTOM", 0, -8)
        emptyLabel:SetText("Type a console command above to get started.\nStart typing to see suggestions.")
        emptyLabel:SetTextColor(Config.GetColor("TEXT_MUTED"))
        emptyLabel:SetJustifyH("CENTER")

        emptyItem.emptyLabel = emptyLabel
        table.insert(listItems, emptyItem)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ADD CVAR HANDLER
-- ═══════════════════════════════════════════════════════════════

local function OnAddCVar(inputBox)
    local text = inputBox:GetText()

    local command, value, err = CVarManager.ParseCommand(text)
    if err then
        ShowFeedback(err, true)
        return
    end

    Storage.SaveCVar(command, value, text, false)
    ShowFeedback(command .. " saved", false)

    inputBox:SetText("")
    DialogUI.RefreshCVarList()
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE DIALOG
-- ═══════════════════════════════════════════════════════════════

function DialogUI.CreateDialog()
    Log("DEBUG", "CreateDialog called, dialog exists:", tostring(dialog ~= nil))
    if dialog then
        Log("DEBUG", "Returning existing dialog")
        return dialog
    end
    Log("INFO", "Creating new dialog...")

    local cfg = Config.DIALOG

    -- Main frame
    dialog = CreateFrame("Frame", "PeaversCVarsDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(cfg.WIDTH, cfg.HEIGHT)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel(100)

    dialog:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    dialog:SetBackdropColor(Config.GetColor("BG_PRIMARY"))
    dialog:SetBackdropBorderColor(Config.GetColor("BORDER_PRIMARY"))

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    titleBar:SetHeight(cfg.TITLE_HEIGHT)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    })
    titleBar:SetBackdropColor(0.05, 0.05, 0.07, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", 12, 0)
    titleText:SetText("|cff3abdf7Peavers|r CVars")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(cfg.TITLE_HEIGHT - 8, cfg.TITLE_HEIGHT - 8)
    closeBtn:SetPoint("RIGHT", -6, 0)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeBtnText:SetPoint("CENTER", 0, 0)
    closeBtnText:SetText("x")
    closeBtnText:SetTextColor(Config.GetColor("TEXT_SECONDARY"))

    closeBtn:SetScript("OnEnter", function()
        closeBtnText:SetTextColor(Config.GetColor("TEXT_ERROR"))
    end)
    closeBtn:SetScript("OnLeave", function()
        closeBtnText:SetTextColor(Config.GetColor("TEXT_SECONDARY"))
    end)
    closeBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)

    -- Make draggable
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() dialog:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() dialog:StopMovingOrSizing() end)
    tinsert(UISpecialFrames, dialog:GetName())

    local yPos = -(cfg.TITLE_HEIGHT + cfg.PADDING)

    -- Section: Input
    local inputSection = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    inputSection:SetPoint("TOPLEFT", cfg.PADDING, yPos)
    inputSection:SetPoint("TOPRIGHT", -cfg.PADDING, yPos)
    inputSection:SetHeight(70)
    inputSection:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    inputSection:SetBackdropColor(Config.GetColor("BG_SECONDARY"))
    inputSection:SetBackdropBorderColor(Config.GetColor("BORDER_PRIMARY"))

    local inputLabel = inputSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    inputLabel:SetPoint("TOPLEFT", cfg.INNER_PADDING, -cfg.INNER_PADDING)
    inputLabel:SetText("CONSOLE COMMAND")
    inputLabel:SetTextColor(Config.GetColor("TEXT_MUTED"))

    -- Input box container
    local inputContainer = CreateFrame("Frame", nil, inputSection, "BackdropTemplate")
    inputContainer:SetPoint("TOPLEFT", cfg.INNER_PADDING, -28)
    inputContainer:SetPoint("RIGHT", -90, 0)
    inputContainer:SetHeight(cfg.INPUT_HEIGHT)
    inputContainer:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    inputContainer:SetBackdropColor(Config.GetColor("BG_TERTIARY"))
    inputContainer:SetBackdropBorderColor(Config.GetColor("BORDER_PRIMARY"))

    local inputBox = CreateFrame("EditBox", "PeaversCVarsInput", inputContainer)
    inputBox:SetPoint("TOPLEFT", 8, 0)
    inputBox:SetPoint("BOTTOMRIGHT", -8, 0)
    inputBox:SetFontObject("GameFontHighlightSmall")
    inputBox:SetAutoFocus(false)
    inputBox:SetMaxLetters(255)
    inputBox:SetTextColor(Config.GetColor("TEXT_PRIMARY"))

    inputBox:SetScript("OnEnterPressed", function(self)
        if not (Autocomplete and Autocomplete.IsShown and Autocomplete.IsShown()) then
            OnAddCVar(self)
        end
    end)

    inputBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- Attach autocomplete
    if Autocomplete and Autocomplete.AttachTo then
        Autocomplete.AttachTo(inputBox)
    end

    -- Add button
    local addButton = CreateStyledButton(inputSection, 70, cfg.INPUT_HEIGHT, "Add", true)
    addButton:SetPoint("RIGHT", -cfg.INNER_PADDING, -8)
    addButton:SetScript("OnClick", function()
        OnAddCVar(inputBox)
    end)

    yPos = yPos - 70 - cfg.PADDING

    -- Section: Saved CVars header
    local listHeader = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    listHeader:SetPoint("TOPLEFT", cfg.PADDING, yPos)
    listHeader:SetText("SAVED CVARS")
    listHeader:SetTextColor(Config.GetColor("TEXT_MUTED"))

    yPos = yPos - 20

    -- Scroll area container
    local scrollContainer = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    scrollContainer:SetPoint("TOPLEFT", cfg.PADDING, yPos)
    scrollContainer:SetPoint("BOTTOMRIGHT", -cfg.PADDING, 45)
    scrollContainer:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    scrollContainer:SetBackdropColor(Config.GetColor("BG_SECONDARY"))
    scrollContainer:SetBackdropBorderColor(Config.GetColor("BORDER_PRIMARY"))

    -- Scroll frame (no template)
    local scrollFrame = CreateFrame("ScrollFrame", "PeaversCVarsScrollFrame", scrollContainer)
    scrollFrame:SetPoint("TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -14, 4)

    scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollContent)
    scrollContent:SetWidth(scrollFrame:GetWidth() or (cfg.WIDTH - cfg.PADDING * 2 - 18))
    scrollContent:SetHeight(1)

    -- Custom scrollbar track
    local scrollTrack = CreateFrame("Frame", nil, scrollContainer, "BackdropTemplate")
    scrollTrack:SetWidth(6)
    scrollTrack:SetPoint("TOPRIGHT", -4, -4)
    scrollTrack:SetPoint("BOTTOMRIGHT", -4, 4)
    scrollTrack:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    })
    scrollTrack:SetBackdropColor(0.1, 0.1, 0.12, 1)

    -- Custom scrollbar thumb
    local scrollThumb = CreateFrame("Button", nil, scrollTrack, "BackdropTemplate")
    scrollThumb:SetWidth(6)
    scrollThumb:SetHeight(40)
    scrollThumb:SetPoint("TOP", 0, 0)
    scrollThumb:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    })
    scrollThumb:SetBackdropColor(Config.GetColor("ACCENT"))
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)

    scrollThumb:SetScript("OnEnter", function(self)
        self:SetBackdropColor(Config.GetColor("ACCENT_DARK"))
    end)
    scrollThumb:SetScript("OnLeave", function(self)
        self:SetBackdropColor(Config.GetColor("ACCENT"))
    end)

    -- Scrollbar state
    local isDragging = false
    local dragStartY = 0
    local dragStartScroll = 0

    local function UpdateScrollThumb()
        local contentHeight = scrollContent:GetHeight() or 1
        local frameHeight = scrollFrame:GetHeight() or 1
        local trackHeight = scrollTrack:GetHeight() or 1

        if contentHeight <= frameHeight then
            scrollThumb:Hide()
            return
        end

        scrollThumb:Show()

        -- Calculate thumb size (proportional to visible area)
        local thumbHeight = math.max(20, (frameHeight / contentHeight) * trackHeight)
        scrollThumb:SetHeight(thumbHeight)

        -- Calculate thumb position
        local maxScroll = contentHeight - frameHeight
        local currentScroll = scrollFrame:GetVerticalScroll()
        local scrollPercent = currentScroll / maxScroll
        local maxThumbOffset = trackHeight - thumbHeight
        local thumbOffset = scrollPercent * maxThumbOffset

        scrollThumb:ClearAllPoints()
        scrollThumb:SetPoint("TOP", scrollTrack, "TOP", 0, -thumbOffset)
    end

    -- Mouse wheel scrolling
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local contentHeight = scrollContent:GetHeight() or 1
        local frameHeight = self:GetHeight() or 1
        local maxScroll = math.max(0, contentHeight - frameHeight)
        local currentScroll = self:GetVerticalScroll()
        local scrollStep = 30

        local newScroll = currentScroll - (delta * scrollStep)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        self:SetVerticalScroll(newScroll)
        UpdateScrollThumb()
    end)

    -- Thumb dragging
    scrollThumb:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDragging = true
            dragStartY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            dragStartScroll = scrollFrame:GetVerticalScroll()
            self:SetScript("OnUpdate", function()
                if isDragging then
                    local currentY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                    local deltaY = dragStartY - currentY

                    local contentHeight = scrollContent:GetHeight() or 1
                    local frameHeight = scrollFrame:GetHeight() or 1
                    local trackHeight = scrollTrack:GetHeight() or 1
                    local maxScroll = math.max(0, contentHeight - frameHeight)

                    local scrollRatio = maxScroll / (trackHeight - scrollThumb:GetHeight())
                    local newScroll = dragStartScroll + (deltaY * scrollRatio)
                    newScroll = math.max(0, math.min(newScroll, maxScroll))

                    scrollFrame:SetVerticalScroll(newScroll)
                    UpdateScrollThumb()
                end
            end)
        end
    end)

    scrollThumb:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            isDragging = false
            self:SetScript("OnUpdate", nil)
        end
    end)

    -- Track click to jump
    scrollTrack:EnableMouse(true)
    scrollTrack:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local _, cursorY = GetCursorPosition()
            cursorY = cursorY / UIParent:GetEffectiveScale()
            local trackTop = self:GetTop()
            local clickOffset = trackTop - cursorY

            local contentHeight = scrollContent:GetHeight() or 1
            local frameHeight = scrollFrame:GetHeight() or 1
            local trackHeight = self:GetHeight() or 1
            local maxScroll = math.max(0, contentHeight - frameHeight)

            local scrollPercent = clickOffset / trackHeight
            local newScroll = scrollPercent * maxScroll
            newScroll = math.max(0, math.min(newScroll, maxScroll))

            scrollFrame:SetVerticalScroll(newScroll)
            UpdateScrollThumb()
        end
    end)

    -- Store update function for external use
    scrollFrame.UpdateScrollThumb = UpdateScrollThumb
    dialog.scrollFrame = scrollFrame

    -- Update thumb when content changes
    scrollContent:SetScript("OnSizeChanged", function()
        C_Timer.After(0, UpdateScrollThumb)
    end)

    -- Feedback label
    feedbackLabel = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    feedbackLabel:SetPoint("BOTTOMLEFT", cfg.PADDING, 15)
    feedbackLabel:SetPoint("BOTTOMRIGHT", -cfg.PADDING, 15)
    feedbackLabel:SetJustifyH("LEFT")
    feedbackLabel:SetText("")

    -- Events
    dialog:SetScript("OnShow", function()
        Log("DEBUG", "OnShow fired, calling RefreshCVarList")
        DialogUI.RefreshCVarList()
    end)

    dialog:SetScript("OnHide", function()
        dialog:ClearAllPoints()
        dialog:SetPoint("CENTER")
    end)

    -- Initial refresh
    C_Timer.After(0, function()
        if dialog:IsShown() then
            Log("DEBUG", "Initial refresh on dialog creation")
            DialogUI.RefreshCVarList()
        end
    end)

    return dialog
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════

function DialogUI.ShowDialog()
    Log("DEBUG", "ShowDialog called")
    local dlg = DialogUI.CreateDialog()
    dlg:Show()
end

function DialogUI.HideDialog()
    if dialog then
        dialog:Hide()
    end
end

function DialogUI.ToggleDialog()
    Log("DEBUG", "ToggleDialog called, dialog exists:", tostring(dialog ~= nil))
    if dialog and dialog:IsShown() then
        DialogUI.HideDialog()
    else
        DialogUI.ShowDialog()
    end
end

return DialogUI
