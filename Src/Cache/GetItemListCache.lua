local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

BOM.WipeCachedItems = true

---@class GetContainerItemInfoResult
---@field Index number
---@field ID number
---@field CD table
---@field Link string
---@field Bag number
---@field Slot number
---@field Texture number|string

-- Stores copies of GetContainerItemInfo parse results
---@type table<number, GetContainerItemInfoResult>
local _GetItemListCached = {}

function BOM.GetItemList()
  if BOM.WipeCachedItems then
    wipe(_GetItemListCached)
    BOM.WipeCachedItems = false

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)

        local icon, itemCount, _locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        for iList, list in ipairs(BOM.ItemList) do
          if tContains(list, itemID) then
            tinsert(_GetItemListCached, { Index   = iList,
                                          ID      = itemID,
                                          CD      = { },
                                          Link    = itemLink,
                                          Bag     = bag,
                                          Slot    = slot,
                                          Texture = icon })
          end
        end

        if lootable and BOM.SharedState.OpenLootable then
          local locked = false

          for i, text in ipairs(BOM.Tool.ScanToolTip("SetBagItem", bag, slot)) do
            if text == LOCKED then
              locked = true
              break
            end
          end

          if not locked then
            tinsert(_GetItemListCached, { Index    = 0,
                                          ID       = itemID,
                                          CD       = nil,
                                          Link     = itemLink,
                                          Bag      = bag,
                                          Slot     = slot,
                                          Lootable = true,
                                          Texture  = icon })
          end -- not locked
        end -- lootable & sharedState.openLootable
      end -- for all bag slots in the current bag
    end -- for all bags
  end

  --Update CD
  for i, items in ipairs(_GetItemListCached) do
    if items.CD then
      items.CD = { GetContainerItemCooldown(items.Bag, items.Slot) }
    end
  end

  return _GetItemListCached
end
