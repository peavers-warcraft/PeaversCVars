local _, addon = ...

local Storage = {}
addon.Storage = Storage

local PeaversCommons = _G.PeaversCommons
local Debug = PeaversCommons and PeaversCommons.Debug
local SOURCE = "CVars:Storage"

local cachedCharacterKey = nil

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

local function GetTableKeys(t)
    local keys = {}
    if t then
        for k in pairs(t) do
            table.insert(keys, tostring(k))
        end
    end
    if #keys == 0 then
        return "(none)"
    end
    return table.concat(keys, ", ")
end

local function GetCharacterKey()
    if cachedCharacterKey then
        Log("DEBUG", "GetCharacterKey: returning cached key:", cachedCharacterKey)
        return cachedCharacterKey
    end

    local name = UnitName("player")
    local realm = GetRealmName()

    Log("DEBUG", "GetCharacterKey: UnitName='" .. tostring(name) .. "', GetRealmName='" .. tostring(realm) .. "'")

    if name and realm and name ~= "" and realm ~= "" then
        cachedCharacterKey = name .. "-" .. realm
        Log("INFO", "GetCharacterKey: cached new key:", cachedCharacterKey)
        return cachedCharacterKey
    end

    Log("WARN", "GetCharacterKey: returning nil (player info not available)")
    return nil
end

local function GetCharacterDB()
    Log("DEBUG", "GetCharacterDB: PeaversCVarsDB exists:", tostring(PeaversCVarsDB ~= nil))

    if not PeaversCVarsDB then
        Log("INFO", "GetCharacterDB: creating new PeaversCVarsDB")
        PeaversCVarsDB = {
            characters = {},
            version = "1.0.0"
        }
    end

    if not PeaversCVarsDB.characters then
        Log("WARN", "GetCharacterDB: characters table was missing, creating")
        PeaversCVarsDB.characters = {}
    end

    local characterKey = GetCharacterKey()
    if not characterKey then
        Log("ERROR", "GetCharacterDB: no character key! Returning empty cvars")
        return { cvars = {} }
    end

    Log("DEBUG", "GetCharacterDB: looking for key:", characterKey)
    Log("DEBUG", "GetCharacterDB: available keys:", GetTableKeys(PeaversCVarsDB.characters))

    if not PeaversCVarsDB.characters[characterKey] then
        Log("INFO", "GetCharacterDB: creating new entry for", characterKey)
        PeaversCVarsDB.characters[characterKey] = {
            cvars = {}
        }
    end

    if not PeaversCVarsDB.characters[characterKey].cvars then
        Log("WARN", "GetCharacterDB: cvars table was missing for", characterKey)
        PeaversCVarsDB.characters[characterKey].cvars = {}
    end

    local cvarCount = #PeaversCVarsDB.characters[characterKey].cvars
    Log("DEBUG", "GetCharacterDB: returning entry with", cvarCount, "cvars")

    return PeaversCVarsDB.characters[characterKey]
end

function Storage.Initialize()
    Log("INFO", "=== Storage.Initialize called ===")
    local key = GetCharacterKey()
    local cvars = Storage.GetAllCVars()
    Log("INFO", "Initialized with", #cvars, "CVar(s) for", key or "unknown")
    print("|cff3abdf7PeaversCVars:|r Loaded " .. #cvars .. " saved CVar(s) for " .. (key or "unknown"))
end

function Storage.GetAllCVars()
    Log("DEBUG", "=== GetAllCVars called ===")
    local characterDB = GetCharacterDB()
    local count = characterDB.cvars and #characterDB.cvars or 0
    Log("DEBUG", "GetAllCVars: returning", count, "cvars")
    return characterDB.cvars or {}
end

function Storage.SaveCVar(command, value, fullCommand, applyOnLogin)
    Log("INFO", "SaveCVar:", command, "=", value, "(applyOnLogin:", tostring(applyOnLogin), ")")
    local characterDB = GetCharacterDB()

    if not characterDB.cvars then
        characterDB.cvars = {}
    end

    for i, cvar in ipairs(characterDB.cvars) do
        if cvar.command == command then
            Log("DEBUG", "SaveCVar: updating existing entry at index", i)
            characterDB.cvars[i] = {
                command = command,
                value = value,
                fullCommand = fullCommand,
                applyOnLogin = applyOnLogin or false,
                timestamp = time()
            }
            return i
        end
    end

    Log("DEBUG", "SaveCVar: inserting new entry")
    table.insert(characterDB.cvars, {
        command = command,
        value = value,
        fullCommand = fullCommand,
        applyOnLogin = applyOnLogin or false,
        timestamp = time()
    })

    return #characterDB.cvars
end

function Storage.RemoveCVar(index)
    local characterDB = GetCharacterDB()

    if characterDB.cvars and characterDB.cvars[index] then
        Log("INFO", "RemoveCVar: removing index", index)
        table.remove(characterDB.cvars, index)
        return true
    end

    Log("WARN", "RemoveCVar: index", index, "not found")
    return false
end

function Storage.UpdateApplyOnLogin(index, enabled)
    local characterDB = GetCharacterDB()

    if characterDB.cvars and characterDB.cvars[index] then
        characterDB.cvars[index].applyOnLogin = enabled
        return true
    end

    return false
end

function Storage.UpdateApplyOnLoginByCommand(command, enabled)
    local characterDB = GetCharacterDB()

    if not characterDB.cvars then
        return false
    end

    for _, cvar in ipairs(characterDB.cvars) do
        if cvar.command == command then
            cvar.applyOnLogin = enabled
            Log("DEBUG", "UpdateApplyOnLoginByCommand:", command, "set to", tostring(enabled))
            return true
        end
    end

    return false
end

function Storage.RemoveCVarByCommand(command)
    local characterDB = GetCharacterDB()

    if not characterDB.cvars then
        return false
    end

    for i, cvar in ipairs(characterDB.cvars) do
        if cvar.command == command then
            Log("INFO", "RemoveCVarByCommand: removing", command, "at index", i)
            table.remove(characterDB.cvars, i)
            return true
        end
    end

    Log("WARN", "RemoveCVarByCommand:", command, "not found")
    return false
end

function Storage.GetCVarsForLogin()
    Log("DEBUG", "GetCVarsForLogin called")
    local cvars = Storage.GetAllCVars()
    local loginCVars = {}

    for _, cvar in ipairs(cvars) do
        if cvar.applyOnLogin then
            table.insert(loginCVars, cvar)
        end
    end

    Log("DEBUG", "GetCVarsForLogin: found", #loginCVars, "cvars with applyOnLogin=true")
    return loginCVars
end

return Storage
