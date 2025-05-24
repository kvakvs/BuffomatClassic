---@class BomBuffModule

local buffModule = --[[@as BomBuffModule]] LibStub("Buffomat-Buff")

---@class BomUnitBuff
---@field singleId WowSpellId Spell id also serving as key
---@field duration number
---@field expirationTime number
---@field source string Unit/player who gave this buff
---@field isSingle boolean

local buffClass = {}
buffClass.__index = buffClass

---Describes a Buff found on an unit (player or pet)
---@param singleId WowSpellId Spell id also serving as key
---@param duration number
---@param expirationTime number
---@param source string
---@param isSingle boolean
---@return BomUnitBuff
function buffModule:New(singleId, duration, expirationTime, source, isSingle)
  local fields = --[[@as BomUnitBuff]] {
    singleId       = singleId,
    duration       = duration,
    expirationTime = expirationTime,
    source         = source,
    isSingle       = isSingle,
  }

  setmetatable(fields, buffClass)
  return fields
end
