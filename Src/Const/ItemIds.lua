--- Item IDS given reasonable names
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomItemIdsModule
local itemIdsModule = BuffomatModule.DeclareModule("ItemIds") ---@type BomItemIdsModule

BOM.ItemId = {}

BOM.ItemId.Mage = {}

BOM.ItemId.Mage.ManaEmerald = 22044
BOM.ItemId.Mage.ManaRuby = 8008
BOM.ItemId.Mage.ManaCitrine = 8007
BOM.ItemId.Mage.ManaJade = 5513
BOM.ItemId.Mage.ManaAgate = 5514

BOM.ItemId.Warlock = {}
BOM.ItemId.Warlock.SoulShard = 6265

BOM.ItemId.Paladin = {}
BOM.ItemId.Paladin.SymbolOfKings = 21177
