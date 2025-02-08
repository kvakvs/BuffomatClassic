---@alias WowIconId string|number

---Returned from GetContainerItemInfo: string, number, boolean, any, any, any, string, any, any, number, boolean
---@class WowContainerItemInfo
---@field hasLoot boolean
---@field hyperlink string
---@field iconFileID WowIconId
---@field hasNoValue boolean
---@field isLocked boolean
---@field itemID number
---@field isBound boolean
---@field stackCount number
---@field isReadable boolean
---@field quality number

---@class WowCContainer
---@field GetContainerNumSlots fun(bag: number): number
---@field GetContainerNumFreeSlots fun(bag: number): number, number { freeSlots, bagFamily }
---@field GetContainerItemInfo fun(b: number, s: number): WowContainerItemInfo
---@field GetContainerItemCooldown fun(b: number, s: number): number, any, any
---@field GetContainerItemLink fun(b: number, s: number): string
---@field PickupContainerItem fun(bag: number, slot: number)
---@field UseContainerItem fun(bag: number, slot: number, target: string|nil, reagentBankAccessible: boolean|nil)
---@field SplitContainerItem fun(bag: number, slot: number, amount: number)
---@field UseContainerItem fun(bag: number, slot: number)
---@field ContainerIDToInventoryID fun(bag: number): number
C_Container = {}

---@return number, boolean
---@param u string
---@param slot number
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
---@return number, number, boolean
function GetInventorySlotInfo(slot)
  return 0, 0, true
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
---@return string, string, number, number, number, string, string, number, string, number, number, number, number, number, number, number, boolean, number, number
function GetItemInfo(arg)
  return "", "", 0, 0, 0, "", "", 0, "", 0, 0, 0, 0, 0, 0, 0, false, 0, 0
end