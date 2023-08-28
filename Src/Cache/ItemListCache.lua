local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@deprecated Not connected properly to any imports
---@shape BomItemListCacheModule
local itemListCacheModule = BomModuleManager.itemListCacheModule ---@type BomItemListCacheModule

local buffomatModule = BomModuleManager.buffomatModule
local toolboxModule = BomModuleManager.toolboxModule
local envModule = KvModuleManager.envModule

BOM.wipeCachedItems = true

---@class GetContainerItemInfoResult
---@field Index number
---@field ID number
---@field CD table
---@field Link string
---@field Bag number
---@field Slot number
---@field Lootable boolean
---@field Texture WowIconId

---@alias BomInventory GetContainerItemInfoResult[]
-- alternative type? {[number]: GetContainerItemInfoResult}

-- Stores copies of GetContainerItemInfo parse results
local itemListCache = --[[---@type BomInventory]] {}

---@return BomInventory
function itemListCacheModule:GetItemList()
  if BOM.wipeCachedItems then
    wipe(itemListCache)
    BOM.wipeCachedItems = false

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, envModule.GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)
        local itemInfo = envModule.GetContainerItemInfo(bag, slot)

        if itemInfo then
          for iList, list in ipairs(BOM.itemList) do
            if tContains(list, itemInfo.itemID) then
              table.insert(itemListCache, --[[---@type GetContainerItemInfoResult]] {
                Index = iList,
                ID = itemInfo.itemID,
                CD = { },
                Link = itemInfo.hyperlink,
                Bag = bag,
                Slot = slot,
                Texture = itemInfo.iconFileID
              })
            end
          end -- for itemList

          if itemInfo.hasLoot and buffomatModule.shared.OpenLootable then
            local locked = false

            for i, text in ipairs(toolboxModule:ScanToolTip("SetBagItem", bag, slot)) do
              if text == LOCKED then
                locked = true
                break
              end
            end

            if not locked then
              table.insert(itemListCache, --[[---@type GetContainerItemInfoResult]] {
                Index = 0,
                ID = itemInfo.itemID,
                CD = nil,
                Link = itemInfo.hyperlink,
                Bag = bag,
                Slot = slot,
                Lootable = true,
                Texture = itemInfo.iconFileID })
            end -- not locked
          end -- lootable & sharedState.openLootable
        end -- if itemInfo

      end -- for all bag slots in the current bag
    end -- for all bags
  end

  --Update CD
  for i, items in ipairs(itemListCache) do
    if items.CD then
      items.CD = { envModule.GetContainerItemCooldown(items.Bag, items.Slot) }
    end
  end

  return itemListCache
end
