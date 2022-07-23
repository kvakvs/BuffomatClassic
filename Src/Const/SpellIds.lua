--- Spell IDS given reasonable names
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomSpellIdsModule
local spellIdsModule = BuffomatModule.New("SpellIds") ---@type BomSpellIdsModule

BOM.SpellId = {}

-- Spell ids in this list hide food buffs from the task list
-- BOM.SpellId.Food = {33264}

BOM.SpellId.Mage = {}
BOM.SpellId.Mage.ConjureManaSapphire = 42985
BOM.SpellId.Mage.ConjureManaEmerald = 27101
BOM.SpellId.Mage.ConjureManaRuby = 10054
BOM.SpellId.Mage.ConjureManaCitrine = 10053
BOM.SpellId.Mage.ConjureManaJade = 3552
BOM.SpellId.Mage.ConjureManaAgate = 759

BOM.SpellId.Warlock = {}
BOM.SpellId.Warlock.DemonicSacrifice = 18788

BOM.SpellId.Priest = {}
BOM.SpellId.Priest.SpiritTap = 15271

BOM.SpellId.Druid = {}
BOM.SpellId.Druid.TrackHumanoids = 5225

BOM.SpellId.Paladin = {}
BOM.SpellId.Paladin.CrusaderAura = 32223

BOM.SpellId.FindHerbs = 2383
BOM.SpellId.FindMinerals = 2580
