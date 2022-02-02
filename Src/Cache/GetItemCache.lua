local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomItemCacheModule
local itemCacheModule = BuffomatModule.DeclareModule("ItemCache") ---@type BomItemCacheModule

------@field cache table<number|string, GIICacheItem> Stores arg to results mapping for GetItemInfo
itemCacheModule.cache = {}

---@class GIICacheItem
---@field itemName string
---@field itemLink string Printable colored clickable item link
---@field itemRarity number 0=poor, 1=normal, 2=uncommon, 3=rare ... etc
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string One of "Armor", "Consumable", "Container", ... see Wiki "ItemType"
---@field itemSubType string Same as itemType
---@field itemStackCount number
---@field itemEquipLoc string "" or a constant INVTYPE_HEAD for example
---@field itemTexture string|number Texture or icon id
---@field itemSellPrice number Copper price for the item

---Calls GetItemInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return GIICacheItem|nil
function BOM.GetItemInfo(arg)
  if itemCacheModule.cache[arg] ~= nil then
    --print("Cached item response for ", arg)
    return itemCacheModule.cache[arg]
  end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType
  , itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(arg)
  if itemName == nil then
    return nil
  end

  local cache_item = {
    itemName = itemName,
    itemLink = itemLink,
    itemRarity = itemRarity,
    itemLevel = itemLevel,
    itemMinLevel = itemMinLevel,
    itemType = itemType,
    itemSubType = itemSubType,
    itemStackCount = itemStackCount,
    itemEquipLoc = itemEquipLoc,
    itemTexture = itemTexture,
    itemSellPrice = itemSellPrice
  }
  --print("Added to cache item info for ", arg)
  itemCacheModule.cache[arg] = cache_item
  return cache_item
end
