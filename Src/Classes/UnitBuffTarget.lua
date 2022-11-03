local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomUnitBuffTargetModule
local buffTargetModule = {}
BomModuleManager.unitBuffTargetModule = unitBuffTargetModule

local toolboxModule = BomModuleManager.toolboxModule
local buffomatModule = BomModuleManager.buffomatModule

---@class BomUnitBuffTarget
---@field unitName string Just the name
---@field link string|nil Colored unit name with class icon

local buffTargetClass = {} ---@type BomUnitBuffTarget
buffTargetClass.__index = buffTargetClass

---@return BomUnitBuffTarget
function buffTargetModule:New(unitName, link)
  local fields = {} ---@type BomUnitBuffTarget
  setmetatable(fields, buffTargetClass)

  fields.unitName = unitName
  fields.link = link

  return fields
end

---@param m BomUnit
---@return BomUnitBuffTarget
function buffTargetModule:FromUnit(m)
  return self:New(m.unitId, m.link)
end

---@param m BomUnit
---@return BomUnitBuffTarget
function buffTargetModule:FromSelf(m)
  return self:New("player", m.link)
end

function buffTargetClass:GetDistance()
  if self.unitName == "player" then
    return 0
  end

  return toolboxModule:UnitDistanceSquared(self.unitName)
end

function buffTargetClass:GetText()
  if self.unitName == "player" then
    return buffomatModule:Color("999999", BOM.L["task.target.Self"])
  end
  return self.link or self.unitName
end
