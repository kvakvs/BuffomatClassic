---@type BuffomatAddon
local TOCNAME, BOM = ...

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

---@type table<number|string, GIICacheItem> Stores arg to results mapping for GetItemInfo
local bom_gii_cache = {}

---Calls GetItemInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return GIICacheItem|nil
function BOM.GetItemInfo(arg)
  if bom_gii_cache[arg] ~= nil then
    --print("Cached item response for ", arg)
    return bom_gii_cache[arg]
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
  bom_gii_cache[arg] = cache_item
  return cache_item
end

---@class GSICacheItem
---@field name string
---@field rank string
---@field icon string
---@field castTime number
---@field minRange number
---@field maxRange number
---@field spellId number

---@type table<number|string, GSICacheItem> Stores arg to results mapping for GetItemInfo
local bom_gsi_cache = {}

---Calls GetSpellInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return GSICacheItem|nil
function BOM.GetSpellInfo(arg)
  if bom_gsi_cache[arg] ~= nil then
    return bom_gsi_cache[arg]
  end

  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(arg)
  if name == nil then
    return nil
  end

  name = name or "MISSING NAME"
  icon = icon or "MISSING ICON"

  local cache_item = {
    name = name,
    rank = rank,
    icon = icon,
    castTime = castTime,
    minRange = minRange,
    maxRange = maxRange,
    spellId = spellId,
  }

  bom_gsi_cache[arg] = cache_item
  return cache_item
end