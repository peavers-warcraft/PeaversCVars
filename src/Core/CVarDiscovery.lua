local _, addon = ...

local CVarDiscovery = {}
addon.CVarDiscovery = CVarDiscovery

local CVarDatabase = addon.CVarDatabase

-- State
local isInitialized = false
local mergedDatabase = {}
local mergedLookup = {}

-- ═══════════════════════════════════════════════════════════════
-- CATEGORY MAPPING
-- ═══════════════════════════════════════════════════════════════

-- Map Enum.ConsoleCategory to human-readable category strings
local categoryMap = {
    [Enum.ConsoleCategory.Debug] = "Advanced",
    [Enum.ConsoleCategory.Graphics] = "Graphics",
    [Enum.ConsoleCategory.Console] = "Advanced",
    [Enum.ConsoleCategory.Combat] = "Combat",
    [Enum.ConsoleCategory.Game] = "UI",
    [Enum.ConsoleCategory.Default] = "Miscellaneous",
    [Enum.ConsoleCategory.Net] = "Network",
    [Enum.ConsoleCategory.Sound] = "Sound",
    [Enum.ConsoleCategory.Gm] = "Advanced",
}

local function MapConsoleCategory(enumCategory)
    if not enumCategory then
        return "Miscellaneous"
    end
    return categoryMap[enumCategory] or "Miscellaneous"
end

-- ═══════════════════════════════════════════════════════════════
-- VALUE TYPE INFERENCE
-- ═══════════════════════════════════════════════════════════════

local function InferValueType(defaultValue)
    if not defaultValue then
        return "string"
    end

    -- Check for boolean-like values
    if defaultValue == "0" or defaultValue == "1" then
        return "boolean"
    end

    -- Check if it's a number
    if tonumber(defaultValue) then
        return "number"
    end

    return "string"
end

-- ═══════════════════════════════════════════════════════════════
-- DISCOVERY
-- ═══════════════════════════════════════════════════════════════

local function DiscoverAll()
    local discovered = {}

    -- C_Console.GetAllCommands() returns all console commands
    local allCommands = C_Console.GetAllCommands()
    if not allCommands then
        return discovered
    end

    for _, cmd in ipairs(allCommands) do
        -- Filter to CVars only (not slash commands or other types)
        if cmd.commandType == Enum.ConsoleCommandType.Cvar then
            -- Get additional info from C_CVar
            local cvarInfo = C_CVar.GetCVarInfo(cmd.command)
            local defaultValue = cvarInfo and cvarInfo.defaultValue or nil

            discovered[cmd.command] = {
                command = cmd.command,
                help = cmd.help or "",
                category = MapConsoleCategory(cmd.category),
                defaultValue = defaultValue,
                source = "discovered",
            }
        end
    end

    return discovered
end

-- ═══════════════════════════════════════════════════════════════
-- MERGE LOGIC
-- ═══════════════════════════════════════════════════════════════

local function BuildMergedDatabase()
    local curated = CVarDatabase.GetAll()
    local discovered = DiscoverAll()

    -- Build lookup from curated data
    local curatedLookup = {}
    for _, cvar in ipairs(curated) do
        curatedLookup[cvar.command] = cvar
    end

    mergedDatabase = {}
    mergedLookup = {}

    -- First, add all discovered CVars (they form the complete set)
    for command, discData in pairs(discovered) do
        local curData = curatedLookup[command]

        local entry
        if curData then
            -- Merge: curated data takes priority
            entry = {
                command = command,
                description = curData.description or discData.help or "No description available",
                category = curData.category or discData.category,
                valueType = curData.valueType or InferValueType(discData.defaultValue),
                default = discData.defaultValue or curData.default,
                source = "merged",
            }
        else
            -- Discovered only
            entry = {
                command = command,
                description = discData.help ~= "" and discData.help or "No description available",
                category = discData.category,
                valueType = InferValueType(discData.defaultValue),
                default = discData.defaultValue,
                source = "discovered",
            }
        end

        table.insert(mergedDatabase, entry)
        mergedLookup[command] = entry
    end

    -- Add any curated CVars that weren't discovered (shouldn't happen, but safety)
    for _, cvar in ipairs(curated) do
        if not mergedLookup[cvar.command] then
            local entry = {
                command = cvar.command,
                description = cvar.description,
                category = cvar.category,
                valueType = cvar.valueType,
                default = cvar.default,
                source = "curated",
            }
            table.insert(mergedDatabase, entry)
            mergedLookup[cvar.command] = entry
        end
    end

    -- Sort alphabetically by command name
    table.sort(mergedDatabase, function(a, b)
        return a.command < b.command
    end)

    return #mergedDatabase
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

function CVarDiscovery.Initialize()
    if isInitialized then
        return
    end

    local count = BuildMergedDatabase()
    isInitialized = true

    -- Log discovery results
    local curatedCount = CVarDatabase.GetCount()
    local discoveredCount = 0
    local mergedCount = 0
    for _, entry in ipairs(mergedDatabase) do
        if entry.source == "discovered" then
            discoveredCount = discoveredCount + 1
        elseif entry.source == "merged" then
            mergedCount = mergedCount + 1
        end
    end

    local PeaversCommons = _G.PeaversCommons
    if PeaversCommons and PeaversCommons.Debug then
        PeaversCommons.Debug:LogInfo("CVarDiscovery",
            string.format("Initialized: %d total CVars (%d curated, %d discovered-only, %d merged)",
                count, curatedCount, discoveredCount, mergedCount))
    end
end

function CVarDiscovery.IsInitialized()
    return isInitialized
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API (mirrors CVarDatabase)
-- ═══════════════════════════════════════════════════════════════

function CVarDiscovery.GetAll()
    if not isInitialized then
        return CVarDatabase.GetAll()
    end
    return mergedDatabase
end

function CVarDiscovery.Search(query)
    if not isInitialized then
        return CVarDatabase.Search(query)
    end

    if not query or query == "" then
        return mergedDatabase
    end

    local results = {}
    local queryLower = strlower(query)

    -- Prioritize command name matches over description matches
    local commandMatches = {}
    local descriptionMatches = {}

    for _, cvar in ipairs(mergedDatabase) do
        local commandLower = strlower(cvar.command)
        local descLower = strlower(cvar.description)

        if commandLower:find(queryLower, 1, true) then
            table.insert(commandMatches, cvar)
        elseif descLower:find(queryLower, 1, true) then
            table.insert(descriptionMatches, cvar)
        end
    end

    -- Command matches first, then description matches
    for _, cvar in ipairs(commandMatches) do
        table.insert(results, cvar)
    end
    for _, cvar in ipairs(descriptionMatches) do
        table.insert(results, cvar)
    end

    return results
end

function CVarDiscovery.GetByCategory(category)
    if not isInitialized then
        return CVarDatabase.GetByCategory(category)
    end

    local results = {}
    for _, cvar in ipairs(mergedDatabase) do
        if cvar.category == category then
            table.insert(results, cvar)
        end
    end
    return results
end

function CVarDiscovery.GetCategories()
    if not isInitialized then
        return CVarDatabase.GetCategories()
    end

    local categories = {}
    local seen = {}
    for _, cvar in ipairs(mergedDatabase) do
        if not seen[cvar.category] then
            seen[cvar.category] = true
            table.insert(categories, cvar.category)
        end
    end
    table.sort(categories)
    return categories
end

function CVarDiscovery.GetInfo(command)
    if not isInitialized then
        return CVarDatabase.GetInfo(command)
    end
    return mergedLookup[command]
end

function CVarDiscovery.GetCount()
    if not isInitialized then
        return CVarDatabase.GetCount()
    end
    return #mergedDatabase
end

-- Get default value with authoritative source (API first, then curated)
function CVarDiscovery.GetDefaultValue(command)
    if not isInitialized then
        return nil
    end

    local entry = mergedLookup[command]
    if entry and entry.default then
        return entry.default
    end

    return nil
end

return CVarDiscovery
