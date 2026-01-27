local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons to work properly.")
    return
end

local requiredModules = {"Events", "FrameUtils", "Utils"}
for _, module in ipairs(requiredModules) do
    if not PeaversCommons[module] then
        print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons." .. module .. " which is missing.")
        return
    end
end

addon.name = addonName
addon.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

local Config = addon.Config
local Storage = addon.Storage
local CVarManager = addon.CVarManager
local CVarDiscovery = addon.CVarDiscovery
local DialogUI = addon.DialogUI
local Debug = PeaversCommons.Debug
local SOURCE = "CVars:Main"

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

function addon.ShowDialog()
    DialogUI.ShowDialog()
end

function addon.ToggleDialog()
    Log("DEBUG", "addon.ToggleDialog called, DialogUI exists:", tostring(DialogUI ~= nil))
    if DialogUI and DialogUI.ToggleDialog then
        DialogUI.ToggleDialog()
    else
        Log("ERROR", "DialogUI not available!")
    end
end

local loginCVarsApplied = false

PeaversCommons.Events:Init(addonName, function()
    SLASH_PEAVERSCVARS1 = "/peaverscvars"
    SLASH_PEAVERSCVARS2 = "/pcv"
    SlashCmdList["PEAVERSCVARS"] = function()
        addon.ToggleDialog()
    end

    -- Initialize CVar discovery early (before UI might need it)
    PeaversCommons.Events:RegisterEvent("VARIABLES_LOADED", function()
        if CVarDiscovery then
            CVarDiscovery.Initialize()
        end
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if not loginCVarsApplied then
            loginCVarsApplied = true
            C_Timer.After(1, function()
                Storage.Initialize()
                CVarManager.ApplyAllLoginCVars()
            end)
        end
    end)

    C_Timer.After(0.5, function()
        if PeaversCommons.SettingsUI then
            PeaversCommons.SettingsUI:CreateSettingsPages(
                addon,
                "PeaversCVars",
                "Peavers CVars",
                "Manage console variables with login persistence.",
                {
                    "/pcv - Open CVar manager",
                    "/peaverscvars - Open CVar manager"
                }
            )
        end
    end)
end, {
    suppressAnnouncement = true
})

_G.PeaversCVars = addon
