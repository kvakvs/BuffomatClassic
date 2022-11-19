--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@alias BomItemCacheKey number|string

---@shape BomItemCache
---@field [BomItemCacheKey] BomItemCacheElement
---@field Item2 table

---@shape BomItemCacheModule
---@field cache BomItemCache Stores arg to results mapping for GetItemInfo
local itemCacheModule = BomModuleManager.itemCacheModule ---@type BomItemCacheModule
itemCacheModule.cache = {}

local buffomatModule = BomModuleManager.buffomatModule

---@class BomItemCacheElement
---@field itemName string
---@field itemLink string Printable colored clickable item link
---@field itemRarity number 0=poor, 1=normal, 2=uncommon, 3=rare ... etc
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string One of "Armor", "Consumable", "Container", ... see Wiki "ItemType"
---@field itemSubType string Same as itemType
---@field itemStackCount number
---@field itemEquipLoc string "" or a constant INVTYPE_HEAD for example
---@field itemTexture string Texture or icon id
---@field itemSellPrice number Copper price for the item

---Calls GetItemInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return BomItemCacheElement|nil
function BOM.GetItemInfo(arg)
  if itemCacheModule.cache[arg] ~= nil then
    return itemCacheModule.cache[arg]
  end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType
  , itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(arg)
  if itemName == nil then
    return nil
  end

  local cacheItem = --[[---@type BomItemCacheElement]] {
    itemName       = itemName,
    itemLink       = itemLink,
    itemRarity     = itemRarity,
    itemLevel      = itemLevel,
    itemMinLevel   = itemMinLevel,
    itemType       = itemType,
    itemSubType    = itemSubType,
    itemStackCount = itemStackCount,
    itemEquipLoc   = itemEquipLoc,
    itemTexture    = itemTexture,
    itemSellPrice  = itemSellPrice,
  }

  --print("Added to cache item info for ", arg)
  itemCacheModule.cache[arg] = cacheItem
  return cacheItem
end

---@param arg BomItemCacheKey
function itemCacheModule:HasItemCached(arg)
  return self.cache[arg] ~= nil
end

---@param itemId number
---@param onLoaded function Called with loaded BomItemCacheElement
function itemCacheModule:LoadItem(itemId, onLoaded)
  if itemCacheModule.cache[itemId] ~= nil then
    onLoaded(itemCacheModule.cache[itemId])
    return
  end

  local itemMixin = Item:CreateFromItemID(itemId)

  local itemLoaded = function()
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType
    , itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemId)
    if itemName == nil then
      return
    end

    local cacheItem = --[[---@type BomItemCacheElement]] {
      itemName       = itemMixin:GetItemName(),
      itemLink       = itemMixin:GetItemLink(),
      itemRarity     = itemMixin:GetItemQuality(),
      itemLevel      = itemLevel,
      itemMinLevel   = itemMinLevel,
      itemType       = itemType,
      itemSubType    = itemSubType,
      itemStackCount = itemStackCount,
      itemEquipLoc   = itemEquipLoc,
      itemTexture    = itemMixin:GetItemIcon(),
      itemSellPrice  = itemSellPrice,
    }

    itemCacheModule.cache[itemId] = cacheItem
    buffomatModule:SetForceUpdate(string.format("item%d", itemId))

    if onLoaded ~= nil then
      onLoaded(cacheItem)
    end
  end

  if C_Item.DoesItemExistByID(itemId) then
    itemMixin:ContinueOnItemLoad(itemLoaded)
  end
end