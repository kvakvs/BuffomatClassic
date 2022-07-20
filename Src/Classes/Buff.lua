local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomBuffModule
local buffModule = BuffomatModule.New("Buff") ---@type BomBuffModule

BOM.Class = BOM.Class or {}

---@class Buff
---@field singleId number Spell id also serving as key
---@field duration number
---@field expirationTime number
---@field source string Unit/player who gave this buff
---@field isSingle boolean

---@type Buff
BOM.Class.Buff = {}
BOM.Class.Buff.__index = BOM.Class.Buff

---Creates a new Buff
---@param singleId number Spell id also serving as key
---@param duration number
---@param expirationTime number
---@param source string
---@param isSingle boolean
---@return Buff
function BOM.Class.Buff:new(singleId, duration, expirationTime, source, isSingle)
  local fields = {
    singleId       = singleId,
    duration       = duration,
    expirationTime = expirationTime,
    source         = source,
    isSingle       = isSingle
  }
  setmetatable(fields, BOM.Class.Buff)
  return fields
end

