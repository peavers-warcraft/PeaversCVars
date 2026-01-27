local addonName, addon = ...

local CVarManager = {}
addon.CVarManager = CVarManager

local PeaversCommons = _G.PeaversCommons

function CVarManager.ParseCommand(input)
    if not input or input == "" then
        return nil, nil, "Please enter a command"
    end

    input = strtrim(input)

    local command, value = input:match("^/console%s+([%w_]+)%s+(.+)$")

    if not command or not value then
        command, value = input:match("^([%w_]+)%s+(.+)$")
    end

    if not command or not value then
        return nil, nil, "Invalid format. Use: /console cvar value"
    end

    return command, strtrim(value), nil
end

function CVarManager.ApplyCVar(command, value)
    if not command or not value then
        return false, "Missing command or value"
    end

    local success, err = pcall(function()
        SetCVar(command, value)
    end)

    if success then
        return true, command .. " set to " .. value
    else
        return false, "Failed to apply " .. command .. ": " .. tostring(err)
    end
end

function CVarManager.ApplyAllLoginCVars()
    local Storage = addon.Storage
    local loginCVars = Storage.GetCVarsForLogin()

    if #loginCVars == 0 then
        return 0
    end

    local appliedCount = 0
    for _, cvar in ipairs(loginCVars) do
        local success = CVarManager.ApplyCVar(cvar.command, cvar.value)
        if success then
            appliedCount = appliedCount + 1
        end
    end

    return appliedCount
end

function CVarManager.GetDefaultValue(command)
    -- First try WoW's built-in default
    local wowDefault = GetCVarDefault(command)
    if wowDefault then
        return wowDefault
    end

    -- Fall back to our database
    local CVarDatabase = addon.CVarDatabase
    if CVarDatabase and CVarDatabase.GetInfo then
        local info = CVarDatabase.GetInfo(command)
        if info and info.default then
            return info.default
        end
    end

    return nil
end

function CVarManager.ResetToDefault(command)
    if not command then
        return false, "Missing command"
    end

    local defaultValue = CVarManager.GetDefaultValue(command)
    if not defaultValue then
        return false, "No default value found for " .. command
    end

    local success, err = pcall(function()
        SetCVar(command, defaultValue)
    end)

    if success then
        return true, command .. " reset to default (" .. defaultValue .. ")"
    else
        return false, "Failed to reset " .. command .. ": " .. tostring(err)
    end
end

return CVarManager
