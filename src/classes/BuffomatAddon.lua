---@type BuffomatAddon
local TOCNAME, BOM = ...

---@class BuffomatAddon
---@field ALL_PROFILES table<string> Lists all buffomat profile names (none, solo... etc)
---@field RESURRECT_CLASS table<string> Classes who can resurrect others
---@field MANA_CLASSES table<string> Classes with mana resource
---
---@field ArgentumDawn table Equipped AD trinket: Spell to and zone ids to check
---@field BuffExchangeId table<number, table<number>> Combines spell ids of spellrank flavours into main spell id
---@field BuffIgnoreAll table<number> Having this buff on target excludes the target (phaseshifted imp for example)
---@field CachedHasItems table Items in player's bag
---@field CancelBuffSource string Unit who casted the buff to be auto-canceled
---@field Carrot table Equipped Riding trinket: Spell to and zone ids to check
---@field CheckForError boolean Used by error suppression code
---@field CurrentProfile Profile
---@field DeclineHasResurrection boolean Set to true on combat start, stop, holding Alt, cleared on party update
---@field EnchantList table<number, table<number>> Spell ids  mapping to enchant ids
---@field EnchantToSpell table<number, number> Reverse-maps enchant ids back to spells
---@field ForceTracking number|nil Defines icon id for enforced tracking
---@field ForceUpdate boolean Requests immediate spells/buffs refresh
---@field IsMoving boolean Indicated that the player is moving (updated in event handlers)
---@field ItemList table<table<number>> Group different ranks of item together
---@field ItemListSpell table<number, number> Map itemid to spell?
---@field ItemListTarget table<number, string> Remember who casted item buff on you?
---@field PartyUpdateNeeded boolean Requests player party update
---@field PlayerCasting boolean Indicates that the player is currently casting (updated in event handlers)
---@field SpellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field SpellToSpell table<number, number> Maps spells ids to other spell ids
---@field TBC boolean Whether we are running TBC classic
---@field WipeCachedItems boolean Command to reset cached items
BOM.BuffomatAddon = {}
BOM.BuffomatAddon.__index = BOM.BuffomatAddon

local CLASS_TAG = "buffomat_addon"
