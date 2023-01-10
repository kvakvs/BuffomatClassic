---@param bag number
---@param slot number
function PickupContainerItem(bag, slot)
end
---@param bag number
---@return number
function GetContainerNumSlots(bag)
  return 0
end
---@return number, boolean
function GetInventoryItemID(u, slot)
  return 0, false
end
---@param u string
---@param slot number
---@return string
function GetInventoryItemLink(u, slot)
  return ""
end
---@param slot string
---@return number
function GetInventorySlotInfo(slot)
  return 0
end
---https://wowpedia.fandom.com/wiki/API_GetContainerItemInfo
---@param b number bag
---@param s number slot
---@return string, number, boolean, any, any, any, string, any, any, number {icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound}
function GetContainerItemInfo(b, s)
  return "", 0, false, nil, nil, nil, "", nil, nil, 0
end
---@param name number|string Item id or item name or link
---@param includeBank boolean
---@param includeCharges boolean
function GetItemCount(name, includeBank, includeCharges)
  return 0
end
---@return number Count of merchant offerings
function GetMerchantNumItems()
  return 0
end
---https://wowwiki-archive.fandom.com/wiki/API_GetMerchantItemInfo
---@param i number
---@return string, string, number, number, number, boolean, number {name, texture, price, stackCount, numAvailable, isUsable, extendedCost}
function GetMerchantItemInfo(i)
  return "", "", 0, 0, 0, false, 0
end
---@param i number
---@return string
function GetMerchantItemLink(i)
  return ""
end
---@param i number
---@param count number
function BuyMerchantItem(i, count)
end
---@param arg number|string
---@return string, string, number, number, number, string, string, number, string, number, number, number, number, number, number, number, boolean
function GetItemInfo(arg)
  return "", "", 0, 0, 0, "", "", 0, "", 0, 0, 0, 0, 0, 0, 0, false
end
---@param bag number
---@return number, number {freeSlots, bagType}
function GetContainerNumFreeSlots(bag)
  return 0, 0
end
---@param bag number
---@param slot number
function UseContainerItem(bag, slot)
end
