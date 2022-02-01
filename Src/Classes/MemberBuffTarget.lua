local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

BOM.Class = BOM.Class or {}

---@class MemberBuffTarget
---@field unitName string Just the name
---@field link string|nil Colored unit name with class icon

---@type MemberBuffTarget
BOM.Class.MemberBuffTarget = {}
BOM.Class.MemberBuffTarget.__index = BOM.Class.MemberBuffTarget

local G_CLASS_TAG = "memberBuffTarget"

function BOM.Class.MemberBuffTarget:new(unitName, link)
  local fields = {}
  setmetatable(fields, BOM.Class.MemberBuffTarget)

  fields.t = G_CLASS_TAG
  fields.unitName = unitName
  fields.link = link

  return fields
end

---@param m Member
function BOM.Class.MemberBuffTarget:fromMember(m)
  return BOM.Class.MemberBuffTarget:new(m.unitId, m.link)
end

---@param m Member
function BOM.Class.MemberBuffTarget:fromSelf(m)
  return BOM.Class.MemberBuffTarget:new("player", m.link)
end

function BOM.Class.MemberBuffTarget.GetDistance(self)
  if self.unitName == "player" then
    return 0
  end

  return BOM.Tool.UnitDistanceSquared(self.unitName)
  --local result = BOM.Tool.UnitDistanceSquared(self.unitName)
  --return result
end

function BOM.Class.MemberBuffTarget.GetText(self)
  if self.unitName == "player" then
    return BOM.Color("999999", BOM.L.SELF)
  end
  return self.link or self.unitName
end
