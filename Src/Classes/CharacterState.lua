local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomCharacterStateModule
local characterStateModule = BuffomatModule.DeclareModule("CharacterState") ---@type BomCharacterStateModule

BOM.Class = BOM.Class or {}

---@class BomCharacterState Current character state snapshots per profile
---@field Spell table<number, BomSpellDef>
---@field Duration table<string, number> Remaining aura duration on SELF, keyed with buff names
---@field LastTracking number Icon id for the last active tracking (not relevant in TBC?)
---@field solo BomProfile
---@field group BomProfile
---@field raid BomProfile
---@field battleground BomProfile
---@field BuffCategoriesHidden table<string, boolean> True if category is hidden (control in options)

---@type BomCharacterState
BOM.Class.CharacterState = {}
BOM.Class.CharacterState.__index = BOM.Class.CharacterState

local CLASS_TAG = "buffomat_character_state"
