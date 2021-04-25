---@type BuffomatAddon
local TOCNAME, BOM = ...

---@class State Snapshot of current options state as selected by the player
---@field ArgentumDawn boolean Warn if AD trinket is equipped while in an instance (set by string name)
---@field AutoDismount boolean Dismount if necessary for buff cast (set by string name)
---@field AutoDisTravel boolean Remove travel form if necessary for buff cast (set by string name)
---@field AutoOpen boolean Open buffomat if required (set by string name)
---@field AutoStand boolean Stand up if required for a cast (set by string name)
---@field BuffTarget boolean (set by string name)
---@field Carrot boolean Whether to track carrot equipped in dungeons (set by string name)
---@field DeathBlock boolean
---@field DontUseConsumables boolean Prevent use of consumables (set by string name)
---@field InInstance boolean Buff while in an instance (set by string name)
---@field InPVP boolean Buff while in PvP instance (set by string name)
---@field InWorld boolean Buff in the open world (set by string name)
---@field MainHand boolean Warn about mainhand missing temporary enchant (set by string name)
---@field NoGroupBuff boolean Avoid casting group buffs (set by string name)
---@field OpenLootable boolean List lootable items for opening in the task list (set by string name)
---@field ReplaceSingle boolean Replace single buffs with group (set by string name)
---@field ResGhost boolean Attempt resurrecting ghosts (set by string name)
---@field SameZone boolean Check only in the same zone (set by string name)
---@field SecondaryHand boolean Warn about offhand temporary enchant missing (set by string name)
---@field SelfFirst boolean Buff self first (set by string name)
---@field UseRank boolean Use ranked spells (set by string name)
---
---@field Spell table<number, SpellDef>
BOM.State = {}
BOM.State.__index = BOM.State

local CLASS_TAG = "buffomat_state"
