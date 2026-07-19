local _, addon = ...

local ConfigUI = {}
addon.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then return end

local W = PeaversCommons.Widgets
local C = W.Colors

function ConfigUI:BuildGeneralPage(parentFrame)
    local y = -10
    local indent = 25

    local _, newY = W:CreateSectionHeader(parentFrame, "CVar Manager", indent, y)
    y = newY - 8

    local desc = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    desc:SetPoint("TOPLEFT", indent, y)
    desc:SetPoint("TOPRIGHT", -indent, y)
    desc:SetJustifyH("LEFT")
    desc:SetTextColor(C.textSec[1], C.textSec[2], C.textSec[3])
    desc:SetText("PeaversCVars manages console variables through its own dedicated interface. Changes are persisted across login sessions.")
    y = y - 40

    local hint = W:CreateLabel(parentFrame, "Use |cff" .. string.format("%02x%02x%02x",
        C.accent[1] * 255, C.accent[2] * 255, C.accent[3] * 255) .. "/pcv|r to open the CVar manager window.", { color = C.textMuted })
    hint:SetPoint("TOPLEFT", indent, y)
    y = y - 30

    local openBtn = W:CreateButton(parentFrame, "Open CVar Manager", {
        style = "primary",
        width = 160,
        onClick = function()
            addon.ToggleDialog()
        end,
    })
    openBtn:SetPoint("TOPLEFT", indent, y)
    y = y - 40

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildInfoPage(parentFrame)
    PeaversCommons.ConfigUIUtils.BuildInfoPage(parentFrame, "CVars", {
        "Saves console variables (CVars) and reapplies them automatically when " ..
            "you log in, so tweaks survive patches, reloads, and setting resets.",
        { command = "/pcv", desc = "open the CVar manager" },

        { header = "What CVars are" },
        "CVars are the game's internal settings - hundreds of options that " ..
            "never appear in the graphics or interface menus, from camera " ..
            "distance to nameplate behavior. Normally they are set with " ..
            "/console and silently lost when the game resets them.",

        { header = "Finding the right one" },
        "Start typing in the manager and it suggests matching CVars from the " ..
            "game's own list, with curated descriptions for over 400 common " ..
            "ones. You can search by name or by what the setting does.",

        { header = "Per-character storage" },
        "Saved CVars are stored per character, so an alt can keep a different " ..
            "setup - useful for different camera or nameplate preferences " ..
            "between a tank and a healer.",
    })
end

function ConfigUI:GetPages()
    return {
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
        { key = "general", label = "General", builder = function(f) ConfigUI:BuildGeneralPage(f) end },
    }
end

function ConfigUI:BuildIntoFrame(parentFrame)
    self:BuildGeneralPage(parentFrame)
    return parentFrame
end

function ConfigUI:Initialize()
end

return ConfigUI
