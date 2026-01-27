# PeaversCVars

A World of Warcraft addon that lets you save, manage, and automatically apply console variables (CVars) across sessions.

**Website:** [peavers.io](https://peavers.io) | **Addon Backup:** [vault.peavers.io](https://vault.peavers.io) | **Issues:** [GitHub](https://github.com/peavers-warcraft/PeaversCVars/issues)

## Features

- Save console variables with a clean, modern interface
- Dynamic discovery of all available CVars using the WoW API
- Autocomplete suggestions with curated descriptions for 400+ common CVars
- Apply CVars automatically on login per-character
- Search CVars by name or description
- Per-character storage for different setups

## Installation

1. Download from [CurseForge](https://www.curseforge.com/wow/addons/peaverscvars)
2. Ensure PeaversCommons is also installed
3. Enable the addon on the character selection screen

## Usage

The addon provides a searchable interface for managing CVars that persist across game sessions.

1. Open the CVar manager with `/pcv`
2. Start typing a console command to see suggestions
3. Select a CVar from autocomplete or enter manually
4. Click "Add" to save the CVar
5. Enable "Apply on Login" to auto-apply when you log in

### Slash Commands

- `/pcv` - Open the CVar manager
- `/peaverscvars` - Open the CVar manager

## Configuration

Access the CVar manager through `/pcv`:

- **Console Command Input**: Enter CVars manually or use autocomplete
- **Apply on Login**: Toggle automatic application per CVar
- **Apply Now**: Instantly apply a saved CVar
- **Remove**: Delete a saved CVar

## Dependencies

- PeaversCommons (required)
