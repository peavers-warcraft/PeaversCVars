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

return CVarManager
