--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomBuffModule
local buffModule = BomModuleManager.buffModule ---@type BomBuffModule

---@class BomUnitBuff
---@field singleId number Spell id also serving as key
---@field duration number
---@field expirationTime number
---@field source string Unit/player who gave this buff
---@field isSingle boolean

local buffClass = {}
buffClass.__index = buffClass

---@alias BomBuffidBuffLookup {[BomBuffId]: BomUnitBuff}

---Creates a new Buff
---@param singleId number Spell id also serving as key
---@param duration number
---@param expirationTime number
---@param source string
---@param isSingle boolean
---@return BomUnitBuff
function buffModule:New(singleId, duration, expirationTime, source, isSingle)
  local fields = --[[---@type BomUnitBuff]] {
    singleId       = singleId,
    duration       = duration,
    expirationTime = expirationTime,
    source         = source,
    isSingle       = isSingle,
  }

  setmetatable(fields, buffClass)
  return fields
end
