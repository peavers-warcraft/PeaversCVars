local _, addon = ...

local CVarDatabase = {}
addon.CVarDatabase = CVarDatabase

-- Curated list of commonly used CVars with descriptions
-- Format: { command = "cvarName", description = "What it does", category = "Category", valueType = "type", default = "defaultValue" }

local database = {
    -- ═══════════════════════════════════════════════════════════════
    -- GRAPHICS & PERFORMANCE
    -- ═══════════════════════════════════════════════════════════════
    { command = "graphicsQuality", description = "Overall graphics quality preset (1-10)", category = "Graphics", valueType = "number", default = "5" },
    { command = "MSAAQuality", description = "Anti-aliasing quality (0-4)", category = "Graphics", valueType = "number", default = "0" },
    { command = "shadowQuality", description = "Shadow quality (0-5)", category = "Graphics", valueType = "number", default = "3" },
    { command = "liquidDetail", description = "Water detail level (0-3)", category = "Graphics", valueType = "number", default = "2" },
    { command = "sunShafts", description = "Sun shaft/god ray quality (0-2)", category = "Graphics", valueType = "number", default = "2" },
    { command = "particleDensity", description = "Particle effect density (0-5)", category = "Graphics", valueType = "number", default = "3" },
    { command = "ssao", description = "Ambient occlusion quality (0-4)", category = "Graphics", valueType = "number", default = "2" },
    { command = "depthEffects", description = "Depth of field effects (0-4)", category = "Graphics", valueType = "number", default = "2" },
    { command = "reflectionMode", description = "Reflection quality (0-3)", category = "Graphics", valueType = "number", default = "1" },
    { command = "textureFilteringMode", description = "Texture filtering (0-5)", category = "Graphics", valueType = "number", default = "3" },
    { command = "groundEffectDensity", description = "Ground clutter density (0-256)", category = "Graphics", valueType = "number", default = "64" },
    { command = "groundEffectDist", description = "Ground clutter view distance (0-500)", category = "Graphics", valueType = "number", default = "140" },
    { command = "environmentDetail", description = "Environment detail level (0-3)", category = "Graphics", valueType = "number", default = "2" },
    { command = "farclip", description = "View distance (100-2500)", category = "Graphics", valueType = "number", default = "1000" },
    { command = "spellDensity", description = "Spell effect density (0-100)", category = "Graphics", valueType = "number", default = "100" },
    { command = "projectedTextures", description = "Show projected textures like spell circles (0-1)", category = "Graphics", valueType = "boolean", default = "1" },
    { command = "weatherDensity", description = "Weather effect density (0-3)", category = "Graphics", valueType = "number", default = "2" },

    -- ═══════════════════════════════════════════════════════════════
    -- FRAMERATE & VSYNC
    -- ═══════════════════════════════════════════════════════════════
    { command = "maxFPS", description = "Maximum foreground framerate (8-1000)", category = "Performance", valueType = "number", default = "300" },
    { command = "maxFPSBk", description = "Maximum background framerate (8-1000)", category = "Performance", valueType = "number", default = "60" },
    { command = "vsync", description = "Vertical sync (0-1)", category = "Performance", valueType = "boolean", default = "0" },
    { command = "tripleBuffer", description = "Triple buffering for vsync (0-1)", category = "Performance", valueType = "boolean", default = "0" },
    { command = "frameRateOnLoad", description = "FPS during loading screens (0-1)", category = "Performance", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- CAMERA
    -- ═══════════════════════════════════════════════════════════════
    { command = "cameraDistanceMaxZoomFactor", description = "Max camera zoom distance multiplier (1-2.6)", category = "Camera", valueType = "number", default = "1.9" },
    { command = "cameraSmoothStyle", description = "Camera smoothing style (0-4)", category = "Camera", valueType = "number", default = "0" },
    { command = "cameraYawMoveSpeed", description = "Camera horizontal rotation speed (0-360)", category = "Camera", valueType = "number", default = "180" },
    { command = "cameraPitchMoveSpeed", description = "Camera vertical rotation speed (0-360)", category = "Camera", valueType = "number", default = "90" },
    { command = "cameraBobbing", description = "Camera bob while moving (0-1)", category = "Camera", valueType = "boolean", default = "0" },
    { command = "cameraWaterCollision", description = "Camera collision with water (0-1)", category = "Camera", valueType = "boolean", default = "1" },
    { command = "cameraTerrainTilt", description = "Camera tilts with terrain (0-1)", category = "Camera", valueType = "boolean", default = "0" },
    { command = "cameraViewBlendStyle", description = "Camera transition style (0-2)", category = "Camera", valueType = "number", default = "1" },
    { command = "test_cameraHeadMovementStrength", description = "Head movement strength (0-2)", category = "Camera", valueType = "number", default = "0" },
    { command = "test_cameraDynamicPitch", description = "Dynamic camera pitch (0-1)", category = "Camera", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- SOUND
    -- ═══════════════════════════════════════════════════════════════
    { command = "Sound_EnableAllSound", description = "Master sound toggle (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableMusic", description = "Enable music (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableSFX", description = "Enable sound effects (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableAmbience", description = "Enable ambient sounds (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableDialog", description = "Enable NPC dialog (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_MasterVolume", description = "Master volume (0-1)", category = "Sound", valueType = "number", default = "1" },
    { command = "Sound_MusicVolume", description = "Music volume (0-1)", category = "Sound", valueType = "number", default = "0.4" },
    { command = "Sound_SFXVolume", description = "Sound effects volume (0-1)", category = "Sound", valueType = "number", default = "1" },
    { command = "Sound_AmbienceVolume", description = "Ambience volume (0-1)", category = "Sound", valueType = "number", default = "0.6" },
    { command = "Sound_DialogVolume", description = "Dialog volume (0-1)", category = "Sound", valueType = "number", default = "1" },
    { command = "Sound_EnableErrorSpeech", description = "Enable error speech (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnablePetSounds", description = "Enable pet sounds (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableEmoteSounds", description = "Enable emote sounds (0-1)", category = "Sound", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- NAMEPLATES
    -- ═══════════════════════════════════════════════════════════════
    { command = "nameplateShowAll", description = "Show all nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "1" },
    { command = "nameplateShowEnemies", description = "Show enemy nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "1" },
    { command = "nameplateShowFriends", description = "Show friendly nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowFriendlyNPCs", description = "Show friendly NPC nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowFriendlyPets", description = "Show friendly pet nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateMotion", description = "Nameplate stacking motion (0-1)", category = "Nameplates", valueType = "number", default = "0" },
    { command = "nameplateMaxDistance", description = "Max nameplate distance (10-60)", category = "Nameplates", valueType = "number", default = "60" },
    { command = "nameplateMinAlpha", description = "Minimum nameplate alpha (0-1)", category = "Nameplates", valueType = "number", default = "0.6" },
    { command = "nameplateMaxAlpha", description = "Maximum nameplate alpha (0-1)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateMinScale", description = "Minimum nameplate scale (0.5-1)", category = "Nameplates", valueType = "number", default = "0.8" },
    { command = "nameplateMaxScale", description = "Maximum nameplate scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateGlobalScale", description = "Global nameplate scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateSelectedScale", description = "Selected target nameplate scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1.2" },
    { command = "nameplateLargerScale", description = "Boss/important nameplate scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1.2" },
    { command = "nameplateOtherTopInset", description = "Top inset for stacking (-0.5 to 0.5)", category = "Nameplates", valueType = "number", default = "0.08" },
    { command = "nameplateOtherBottomInset", description = "Bottom inset for stacking (-0.5 to 0.5)", category = "Nameplates", valueType = "number", default = "0.1" },
    { command = "nameplateOverlapH", description = "Horizontal overlap (0-3)", category = "Nameplates", valueType = "number", default = "0.8" },
    { command = "nameplateOverlapV", description = "Vertical overlap (0-3)", category = "Nameplates", valueType = "number", default = "1.1" },
    { command = "NamePlateHorizontalScale", description = "Nameplate width scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "NamePlateVerticalScale", description = "Nameplate height scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateResourceOnTarget", description = "Show resources on target nameplate (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowDebuffsOnFriendly", description = "Show debuffs on friendly nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateSelfAlpha", description = "Personal nameplate alpha (0-1)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateSelfScale", description = "Personal nameplate scale (0.5-2)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateSelfTopInset", description = "Personal nameplate top inset (0-0.5)", category = "Nameplates", valueType = "number", default = "0.5" },
    { command = "nameplateSelfBottomInset", description = "Personal nameplate bottom inset (0-0.5)", category = "Nameplates", valueType = "number", default = "0.2" },

    -- ═══════════════════════════════════════════════════════════════
    -- COMBAT & UI
    -- ═══════════════════════════════════════════════════════════════
    { command = "floatingCombatTextCombatDamage", description = "Show damage numbers (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextCombatHealing", description = "Show healing numbers (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextCombatDamageDirectionalScale", description = "Directional damage text scale (0-2)", category = "Combat", valueType = "number", default = "1" },
    { command = "WorldTextScale", description = "World text scale (0.5-2)", category = "Combat", valueType = "number", default = "1" },
    { command = "SpellQueueWindow", description = "Spell queue window in milliseconds (0-400)", category = "Combat", valueType = "number", default = "400" },
    { command = "AutoInteract", description = "Auto-interact with NPCs/objects (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "autoDismountFlying", description = "Auto dismount when casting in air (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "autoDismount", description = "Auto dismount when casting (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "autoUnshift", description = "Auto cancel shapeshift for spells (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "autoLootDefault", description = "Auto loot by default (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "lootUnderMouse", description = "Loot window appears under mouse (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "interactOnLeftClick", description = "Interact with target on left click (0-1)", category = "Combat", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- TARGET & FOCUS
    -- ═══════════════════════════════════════════════════════════════
    { command = "deselectOnClick", description = "Deselect target when clicking terrain (0-1)", category = "Target", valueType = "boolean", default = "1" },
    { command = "targetOfTargetMode", description = "Target of target display mode (0-5)", category = "Target", valueType = "number", default = "5" },
    { command = "doNotFlashLowHealthWarning", description = "Disable low health screen flash (0-1)", category = "Target", valueType = "boolean", default = "0" },
    { command = "showTargetCastbar", description = "Show target castbar (0-1)", category = "Target", valueType = "boolean", default = "1" },
    { command = "showTargetOfTarget", description = "Show target of target (0-1)", category = "Target", valueType = "boolean", default = "1" },
    { command = "showVKeyCastbar", description = "Show focus castbar with V key (0-1)", category = "Target", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- CHAT
    -- ═══════════════════════════════════════════════════════════════
    { command = "chatBubbles", description = "Show NPC chat bubbles (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "chatBubblesParty", description = "Show party chat bubbles (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "chatStyle", description = "Chat input style - im/classic (string)", category = "Chat", valueType = "string", default = "im" },
    { command = "whisperMode", description = "Whisper mode - inline/popout (string)", category = "Chat", valueType = "string", default = "inline" },
    { command = "chatMouseScroll", description = "Mouse scroll changes chat tabs (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "removeChatDelay", description = "Remove chat message delay (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "profanityFilter", description = "Enable profanity filter (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "showTimestamps", description = "Show chat timestamps (format string)", category = "Chat", valueType = "string", default = "none" },

    -- ═══════════════════════════════════════════════════════════════
    -- RAID & DUNGEON
    -- ═══════════════════════════════════════════════════════════════
    { command = "raidFramesDisplayAggroHighlight", description = "Highlight aggro on raid frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "raidFramesDisplayClassColor", description = "Use class colors in raid frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "raidFramesDisplayOnlyDispellableDebuffs", description = "Only show dispellable debuffs (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "raidFramesDisplayPowerBars", description = "Show power bars in raid frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "raidOptionDisplayMainTankAndAssist", description = "Show main tank/assist (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "raidOptionDisplayPets", description = "Show pets in raid frames (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "raidOptionKeepGroupsTogether", description = "Keep groups together in raid frames (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "raidOptionShowBorders", description = "Show borders on raid frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "raidOptionSortMode", description = "Raid frame sort mode (string)", category = "Raid", valueType = "string", default = "role" },

    -- ═══════════════════════════════════════════════════════════════
    -- ACCESSIBILITY & MISC
    -- ═══════════════════════════════════════════════════════════════
    { command = "colorblindMode", description = "Colorblind mode (0-1)", category = "Accessibility", valueType = "boolean", default = "0" },
    { command = "colorblindSimulator", description = "Colorblind simulation type (0-4)", category = "Accessibility", valueType = "number", default = "0" },
    { command = "overrideScreenFlash", description = "Reduce screen flash effects (0-1)", category = "Accessibility", valueType = "boolean", default = "0" },
    { command = "movieSubtitle", description = "Show movie subtitles (0-1)", category = "Accessibility", valueType = "boolean", default = "0" },
    { command = "enableWoWMouse", description = "Enable mouse accessibility features (0-1)", category = "Accessibility", valueType = "boolean", default = "0" },
    { command = "cursorSizePreferred", description = "Cursor size (0-2)", category = "Accessibility", valueType = "number", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- ACTION BARS
    -- ═══════════════════════════════════════════════════════════════
    { command = "countdownForCooldowns", description = "Show cooldown countdown text (0-1)", category = "ActionBars", valueType = "boolean", default = "1" },
    { command = "lockActionBars", description = "Lock action bars (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "alwaysShowActionBars", description = "Always show action bars (0-1)", category = "ActionBars", valueType = "boolean", default = "1" },
    { command = "showMultiBarBottomLeft", description = "Show bottom left action bar (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "showMultiBarBottomRight", description = "Show bottom right action bar (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "showMultiBarLeft", description = "Show left action bar (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "showMultiBarRight", description = "Show right action bar (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- MOUSE & CONTROLS
    -- ═══════════════════════════════════════════════════════════════
    { command = "rawMouseEnable", description = "Enable raw mouse input (0-1)", category = "Controls", valueType = "boolean", default = "1" },
    { command = "rawMouseAccelerationEnable", description = "Enable mouse acceleration (0-1)", category = "Controls", valueType = "boolean", default = "0" },
    { command = "mouseSpeed", description = "Mouse sensitivity (0.1-2.75)", category = "Controls", valueType = "number", default = "1" },
    { command = "mouseInvertPitch", description = "Invert mouse Y-axis (0-1)", category = "Controls", valueType = "boolean", default = "0" },
    { command = "mouseInvertYaw", description = "Invert mouse X-axis (0-1)", category = "Controls", valueType = "boolean", default = "0" },
    { command = "enableMovePad", description = "Enable click-to-move pad (0-1)", category = "Controls", valueType = "boolean", default = "0" },
    { command = "interactKeyWarningTutorial", description = "Show interact key tutorial (0-1)", category = "Controls", valueType = "boolean", default = "1" },
    { command = "SoftTargetInteract", description = "Soft targeting interact range (0-3)", category = "Controls", valueType = "number", default = "1" },
    { command = "SoftTargetEnemy", description = "Soft targeting enemy mode (0-3)", category = "Controls", valueType = "number", default = "1" },
    { command = "SoftTargetFriend", description = "Soft targeting friendly mode (0-3)", category = "Controls", valueType = "number", default = "1" },
    { command = "turnSpeed", description = "Keyboard turning speed (0-500)", category = "Controls", valueType = "number", default = "180" },

    -- ═══════════════════════════════════════════════════════════════
    -- NETWORK & ADVANCED
    -- ═══════════════════════════════════════════════════════════════
    { command = "scriptErrors", description = "Show Lua error messages (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "taintLog", description = "Enable taint logging (0-2)", category = "Advanced", valueType = "number", default = "0" },
    { command = "useIPv6", description = "Enable IPv6 connections (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "disableServerNagle", description = "Disable Nagle algorithm (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "synchronizeSettings", description = "Sync settings across characters (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "synchronizeConfig", description = "Sync config across characters (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "synchronizeBindings", description = "Sync keybindings across characters (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "synchronizeMacros", description = "Sync macros across characters (0-1)", category = "Advanced", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- UNIT NAMES (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "UnitNameOwn", description = "Show your own name above your character (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameNPC", description = "Show NPC names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameHostleNPC", description = "Show hostile NPC names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameInteractiveNPC", description = "Show interactive NPC names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameFriendlyPlayerName", description = "Show friendly player names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameFriendlyPetName", description = "Show friendly pet names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameFriendlyGuardianName", description = "Show friendly guardian names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameFriendlyTotemName", description = "Show friendly totem names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameEnemyPlayerName", description = "Show enemy player names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameEnemyPetName", description = "Show enemy pet names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameEnemyGuardianName", description = "Show enemy guardian names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameEnemyTotemName", description = "Show enemy totem names (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNamePlayerGuild", description = "Show player guild names (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameGuildTitle", description = "Show guild titles (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNamePlayerPVPTitle", description = "Show PVP titles (0-1)", category = "Names", valueType = "boolean", default = "1" },
    { command = "UnitNameNonCombatCreatureName", description = "Show non-combat creature names like critters (0-1)", category = "Names", valueType = "boolean", default = "0" },
    { command = "UnitNameForceHideMinus", description = "Hide minor unit names (0-1)", category = "Names", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- ADDITIONAL NAMEPLATES (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "nameplateShowSelf", description = "Show personal resource bar (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowEnemyPets", description = "Show enemy pet nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowEnemyGuardians", description = "Show enemy guardian nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowEnemyTotems", description = "Show enemy totem nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowEnemyMinus", description = "Show minor enemy nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "1" },
    { command = "nameplateShowFriendlyGuardians", description = "Show friendly guardian nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateShowFriendlyTotems", description = "Show friendly totem nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplateOtherAtBase", description = "Position nameplates at unit base (0=over, 2=under)", category = "Nameplates", valueType = "number", default = "0" },
    { command = "nameplateMotionSpeed", description = "Nameplate animation speed (0-1)", category = "Nameplates", valueType = "number", default = "0.025" },
    { command = "nameplateMinScaleDistance", description = "Distance where nameplates reach minimum scale (0-40)", category = "Nameplates", valueType = "number", default = "10" },
    { command = "nameplateMaxScaleDistance", description = "Distance where nameplates reach maximum scale (0-40)", category = "Nameplates", valueType = "number", default = "10" },
    { command = "nameplateMinAlphaDistance", description = "Distance where nameplates reach minimum alpha (0-40)", category = "Nameplates", valueType = "number", default = "10" },
    { command = "nameplateMaxAlphaDistance", description = "Distance where nameplates reach maximum alpha (0-40)", category = "Nameplates", valueType = "number", default = "10" },
    { command = "nameplateSelectedAlpha", description = "Selected target nameplate alpha (0-1)", category = "Nameplates", valueType = "number", default = "1" },
    { command = "nameplateTargetBehindMaxDistance", description = "Max distance to show target nameplate when behind camera (0-60)", category = "Nameplates", valueType = "number", default = "15" },
    { command = "nameplateOccludedAlphaMult", description = "Alpha multiplier for occluded nameplates (0-1)", category = "Nameplates", valueType = "number", default = "0.4" },
    { command = "nameplatePersonalShowAlways", description = "Always show personal nameplate (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "nameplatePersonalShowInCombat", description = "Show personal nameplate in combat (0-1)", category = "Nameplates", valueType = "boolean", default = "1" },
    { command = "nameplatePersonalShowWithTarget", description = "Show personal nameplate when targeting enemy (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "ShowClassColorInNameplate", description = "Show class colors on nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "ShowClassColorInFriendlyNameplate", description = "Show class colors on friendly nameplates (0-1)", category = "Nameplates", valueType = "boolean", default = "0" },
    { command = "ShowNamePlateLoseAggroFlash", description = "Flash nameplate when losing aggro as tank (0-1)", category = "Nameplates", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- FLOATING COMBAT TEXT (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "enableFloatingCombatText", description = "Enable floating combat text (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextAuras", description = "Show aura gains/losses (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextComboPoints", description = "Show combo point gains (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextDodgeParryMiss", description = "Show dodge/parry/miss (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextDamageReduction", description = "Show damage resistances (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextEnergyGains", description = "Show energy/rage/focus gains (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextFriendlyHealers", description = "Show healer names on incoming heals (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextHonorGains", description = "Show honor gains (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextLowManaHealth", description = "Show low health/mana warnings (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextRepChanges", description = "Show reputation changes (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextReactives", description = "Show reactive ability procs (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "floatingCombatTextCombatState", description = "Show entering/leaving combat (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextFloatMode", description = "Combat text float direction (1=up, 2=down, 3=arc)", category = "Combat", valueType = "number", default = "1" },
    { command = "floatingCombatTextPetMeleeDamage", description = "Show pet melee damage (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextPetSpellDamage", description = "Show pet spell damage (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextSpellMechanics", description = "Show crowd control effects on target (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "floatingCombatTextSpellMechanicsOther", description = "Show crowd control effects on others (0-1)", category = "Combat", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- LOSS OF CONTROL (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "lossOfControl", description = "Enable loss of control alerts (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "lossOfControlFull", description = "Loss of control: full CC alert mode (0=off, 1=alert, 2=duration)", category = "Combat", valueType = "number", default = "2" },
    { command = "lossOfControlSilence", description = "Loss of control: silence alert mode (0=off, 1=alert, 2=duration)", category = "Combat", valueType = "number", default = "2" },
    { command = "lossOfControlInterrupt", description = "Loss of control: interrupt alert mode (0=off, 1=alert, 2=duration)", category = "Combat", valueType = "number", default = "1" },
    { command = "lossOfControlDisarm", description = "Loss of control: disarm alert mode (0=off, 1=alert, 2=duration)", category = "Combat", valueType = "number", default = "1" },
    { command = "lossOfControlRoot", description = "Loss of control: root alert mode (0=off, 1=alert, 2=duration)", category = "Combat", valueType = "number", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- ADDITIONAL SOUND (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "Sound_EnableReverb", description = "Enable sound reverb effects (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableDSPEffects", description = "Enable DSP sound effects (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "Sound_EnableSoundWhenGameIsInBG", description = "Play sound when game is in background (0-1)", category = "Sound", valueType = "boolean", default = "0" },
    { command = "Sound_ListenerAtCharacter", description = "Sound originates from character not camera (0-1)", category = "Sound", valueType = "boolean", default = "0" },
    { command = "Sound_EnablePetBattleMusic", description = "Play music during pet battles (0-1)", category = "Sound", valueType = "boolean", default = "0" },
    { command = "Sound_ZoneMusicNoDelay", description = "Loop zone music without delay (0-1)", category = "Sound", valueType = "boolean", default = "0" },
    { command = "Sound_EnablePositionalLowPassFilter", description = "Enable positional audio low-pass filter (0-1)", category = "Sound", valueType = "boolean", default = "1" },
    { command = "FootstepSounds", description = "Play footstep sounds (0-1)", category = "Sound", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- ADDITIONAL CAMERA (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "cameraPivot", description = "Smart camera pivot when turning (0-1)", category = "Camera", valueType = "boolean", default = "1" },
    { command = "cameraYawSmoothSpeed", description = "Camera auto-follow rotation speed (0-360)", category = "Camera", valueType = "number", default = "180" },
    { command = "cameraOverShoulder", description = "Camera over-shoulder offset (-1 to 1)", category = "Camera", valueType = "number", default = "0" },
    { command = "cameraHeadMovementStrength", description = "ActionCam head movement intensity (0-2)", category = "Camera", valueType = "number", default = "0" },
    { command = "cameraDynamicPitch", description = "ActionCam dynamic pitch enabled (0-1)", category = "Camera", valueType = "boolean", default = "0" },
    { command = "cameraLockedTargetFocusing", description = "ActionCam locked target focus (0-1)", category = "Camera", valueType = "boolean", default = "0" },
    { command = "cameraDistanceMoveSpeed", description = "Camera zoom speed (0-50)", category = "Camera", valueType = "number", default = "8.33" },

    -- ═══════════════════════════════════════════════════════════════
    -- TARGETING (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "TargetNearestUseNew", description = "Use modern nearest-target functionality (0-1)", category = "Target", valueType = "boolean", default = "1" },
    { command = "TargetPriorityCombatLock", description = "Lock to combat targets (0=off, 1=in-combat, 2=player-combat)", category = "Target", valueType = "number", default = "0" },
    { command = "TargetPriorityPvp", description = "PVP target priority (0=off, 2=all pvp, 3=players only)", category = "Target", valueType = "number", default = "0" },
    { command = "stopAutoAttackOnTargetChange", description = "Stop auto-attack when changing targets (0-1)", category = "Target", valueType = "boolean", default = "0" },
    { command = "assistAttack", description = "Auto-attack when assisting (0-1)", category = "Target", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- HIGHLIGHTING & VISIBILITY (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "findYourselfAnywhere", description = "Always highlight your character (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "findYourselfAnywhereOnlyInCombat", description = "Highlight your character only in combat (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "findYourselfInBG", description = "Highlight your character in battlegrounds (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "findYourselfInRaid", description = "Highlight your character in raids (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "findYourselfMode", description = "Highlight mode (0=circle, 1=circle+outline)", category = "UI", valueType = "number", default = "0" },
    { command = "emphasizeMySpellEffects", description = "Emphasize your own spell effects (0-1)", category = "Graphics", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- ADDITIONAL UI (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "autoSelfCast", description = "Auto self-cast when no target (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "ActionButtonUseKeyDown", description = "Cast spells on key down not key up (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "secureAbilityToggle", description = "Prevent toggling off abilities (0-1)", category = "ActionBars", valueType = "boolean", default = "0" },
    { command = "displaySpellActivationOverlays", description = "Show spell activation overlays (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "spellActivationOverlayOpacity", description = "Spell activation overlay opacity (0-1)", category = "Combat", valueType = "number", default = "1" },
    { command = "showSpenderFeedback", description = "Show resource spending animation (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "showBuilderFeedback", description = "Show resource building animation (0-1)", category = "Combat", valueType = "boolean", default = "1" },
    { command = "predictedHealth", description = "Show predicted health changes (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "comboPointLocation", description = "Combo point display location (1=target, 2=self)", category = "Combat", valueType = "number", default = "1" },
    { command = "displayFreeBagSlots", description = "Show free bag slots count (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "reverseCleanupBags", description = "Reverse direction when cleaning bags (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "lootLeftmostBag", description = "Loot to leftmost bag first (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "alwaysCompareItems", description = "Always show item comparison tooltips (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "UberTooltips", description = "Show enhanced tooltips with extra info (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "showQuestTrackingTooltips", description = "Show quest info in tooltips (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "noBuffDebuffFilterOnTarget", description = "Show all buffs/debuffs on target (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "buffDurations", description = "Show buff duration timers (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "showDispelDebuffs", description = "Show dispellable debuffs (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "showCastableBuffs", description = "Show castable buffs (0-1)", category = "UI", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- FRAMES & PARTY (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "useCompactPartyFrames", description = "Use raid-style party frames (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "showPartyBackground", description = "Show party frame background (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "showPartyPets", description = "Show party pet frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "fullSizeFocusFrame", description = "Use full-size focus frame (0-1)", category = "Target", valueType = "boolean", default = "0" },
    { command = "showArenaEnemyFrames", description = "Show arena enemy frames (0-1)", category = "Raid", valueType = "boolean", default = "1" },
    { command = "showArenaEnemyPets", description = "Show arena enemy pet frames (0-1)", category = "Raid", valueType = "boolean", default = "0" },
    { command = "showArenaEnemyCastbar", description = "Show arena enemy castbars (0-1)", category = "Raid", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- STATUS TEXT (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "statusText", description = "Show numeric values on health/mana bars (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "statusTextDisplay", description = "Status text display mode (string)", category = "UI", valueType = "string", default = "NONE" },
    { command = "xpBarText", description = "Show XP bar text (0-1)", category = "UI", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- SOCIAL & CHAT (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "spamFilter", description = "Enable chat spam filter (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "blockTrades", description = "Block trade requests (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "blockChannelInvites", description = "Block chat channel invites (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "guildMemberNotify", description = "Notify when guild members come online (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "wholeChatWindowClickable", description = "Make entire chat window clickable (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "colorChatNamesByClass", description = "Color chat names by class (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "showToastOnline", description = "Show toast when friends come online (0-1)", category = "Chat", valueType = "boolean", default = "1" },
    { command = "showToastOffline", description = "Show toast when friends go offline (0-1)", category = "Chat", valueType = "boolean", default = "0" },
    { command = "showToastBroadcast", description = "Show toast for friend broadcasts (0-1)", category = "Chat", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- MAP & MINIMAP (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "mapFade", description = "Fade map when moving (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "rotateMinimap", description = "Rotate minimap with player (0-1)", category = "UI", valueType = "boolean", default = "0" },
    { command = "screenEdgeFlash", description = "Flash screen edge for notifications (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "autoQuestWatch", description = "Auto-track accepted quests (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "autoQuestProgress", description = "Auto-track quest progress (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "showTamers", description = "Show pet tamers on world map (0-1)", category = "UI", valueType = "boolean", default = "1" },
    { command = "ShowQuestUnitCircles", description = "Show quest objective ground circles (0-1)", category = "UI", valueType = "boolean", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- THREAT & WARNINGS (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "threatShowNumeric", description = "Show numeric threat values (0-1)", category = "Combat", valueType = "boolean", default = "0" },
    { command = "threatWarning", description = "Threat warning mode (0=off, 1=dungeon, 2=party, 3=always)", category = "Combat", valueType = "number", default = "1" },
    { command = "threatPlaySounds", description = "Play sounds for aggro warnings (0-1)", category = "Combat", valueType = "boolean", default = "0" },

    -- ═══════════════════════════════════════════════════════════════
    -- GRAPHICS ADVANCED (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "ffxGlow", description = "Enable full-screen glow effect (0-1)", category = "Graphics", valueType = "boolean", default = "1" },
    { command = "ffxDeath", description = "Enable full-screen death effect (0-1)", category = "Graphics", valueType = "boolean", default = "1" },
    { command = "violenceLevel", description = "Violence level (0-5)", category = "Graphics", valueType = "number", default = "5" },
    { command = "RenderScale", description = "Render resolution scale (0.5-2)", category = "Graphics", valueType = "number", default = "1" },

    -- ═══════════════════════════════════════════════════════════════
    -- ADVANCED & DEBUG (from AdvancedInterfaceOptions)
    -- ═══════════════════════════════════════════════════════════════
    { command = "advancedCombatLogging", description = "Enable advanced combat logging (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "scriptWarnings", description = "Show Lua script warnings (0-1)", category = "Advanced", valueType = "boolean", default = "0" },
    { command = "showTutorials", description = "Show in-game tutorials (0-1)", category = "Accessibility", valueType = "boolean", default = "1" },
    { command = "autoStand", description = "Auto-stand when needed (0-1)", category = "Combat", valueType = "boolean", default = "1" },
}

-- Get all CVars
function CVarDatabase.GetAll()
    return database
end

-- Search CVars by query (matches command name or description)
function CVarDatabase.Search(query)
    if not query or query == "" then
        return database
    end

    local results = {}
    local queryLower = strlower(query)

    for _, cvar in ipairs(database) do
        local commandLower = strlower(cvar.command)
        local descLower = strlower(cvar.description)

        -- Prioritize command name matches
        if commandLower:find(queryLower, 1, true) then
            table.insert(results, cvar)
        elseif descLower:find(queryLower, 1, true) then
            table.insert(results, cvar)
        end
    end

    return results
end

-- Get CVars by category
function CVarDatabase.GetByCategory(category)
    local results = {}
    for _, cvar in ipairs(database) do
        if cvar.category == category then
            table.insert(results, cvar)
        end
    end
    return results
end

-- Get all categories
function CVarDatabase.GetCategories()
    local categories = {}
    local seen = {}
    for _, cvar in ipairs(database) do
        if not seen[cvar.category] then
            seen[cvar.category] = true
            table.insert(categories, cvar.category)
        end
    end
    return categories
end

-- Get a specific CVar's info
function CVarDatabase.GetInfo(command)
    for _, cvar in ipairs(database) do
        if cvar.command == command then
            return cvar
        end
    end
    return nil
end

-- Get count
function CVarDatabase.GetCount()
    return #database
end

return CVarDatabase
