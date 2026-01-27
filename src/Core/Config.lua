local addonName, addon = ...

local Config = {}
addon.Config = Config

-- ═══════════════════════════════════════════════════════════════
-- COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════
Config.COLORS = {
    -- Brand colors
    ACCENT = { 0.23, 0.74, 0.97, 1 },           -- #3ABDF7 - Peavers blue
    ACCENT_DARK = { 0.18, 0.59, 0.78, 1 },      -- Darker accent for hover

    -- Text colors
    TEXT_PRIMARY = { 1, 1, 1, 1 },               -- White
    TEXT_SECONDARY = { 0.7, 0.7, 0.7, 1 },       -- Light gray
    TEXT_MUTED = { 0.5, 0.5, 0.5, 1 },           -- Muted gray
    TEXT_GOLD = { 1, 0.82, 0, 1 },               -- Gold for commands
    TEXT_SUCCESS = { 0.3, 0.9, 0.3, 1 },         -- Green
    TEXT_ERROR = { 1, 0.4, 0.4, 1 },             -- Red

    -- Background colors
    BG_PRIMARY = { 0.08, 0.08, 0.10, 0.97 },     -- Main background
    BG_SECONDARY = { 0.12, 0.12, 0.14, 0.95 },   -- Card background
    BG_TERTIARY = { 0.15, 0.15, 0.18, 0.9 },     -- Input/hover background
    BG_HOVER = { 0.2, 0.4, 0.55, 0.6 },          -- Hover highlight
    BG_SELECTED = { 0.23, 0.74, 0.97, 0.25 },    -- Selected highlight

    -- Border colors
    BORDER_PRIMARY = { 0.3, 0.3, 0.35, 1 },      -- Main border
    BORDER_LIGHT = { 0.4, 0.4, 0.45, 1 },        -- Light border
    BORDER_ACCENT = { 0.23, 0.74, 0.97, 0.6 },   -- Accent border
}

-- ═══════════════════════════════════════════════════════════════
-- DIALOG DIMENSIONS
-- ═══════════════════════════════════════════════════════════════
Config.DIALOG = {
    WIDTH = 480,
    HEIGHT = 500,
    TITLE_HEIGHT = 32,
    INPUT_HEIGHT = 28,
    LIST_ITEM_HEIGHT = 56,
    PADDING = 16,
    INNER_PADDING = 12,
    BUTTON_HEIGHT = 24,
    BUTTON_WIDTH_SMALL = 70,
    BUTTON_WIDTH_MEDIUM = 80,
    CORNER_RADIUS = 3,
}

-- ═══════════════════════════════════════════════════════════════
-- AUTOCOMPLETE DIMENSIONS
-- ═══════════════════════════════════════════════════════════════
Config.AUTOCOMPLETE = {
    MAX_RESULTS = 6,
    ITEM_HEIGHT = 40,
    DROPDOWN_WIDTH = 440,
    PADDING = 6,
}

Config.DEBUG_ENABLED = false

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Unpack color table for SetTextColor, SetBackdropColor, etc.
function Config.GetColor(colorName)
    local color = Config.COLORS[colorName]
    if color then
        return color[1], color[2], color[3], color[4]
    end
    return 1, 1, 1, 1
end

-- Get color as table (for backdrop)
function Config.GetColorTable(colorName)
    return Config.COLORS[colorName] or { 1, 1, 1, 1 }
end

return Config
