---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class GroupBuffTarget
---@field groupIndex number

---@type GroupBuffTarget
BOM.Class.GroupBuffTarget = {}
BOM.Class.GroupBuffTarget.__index = BOM.Class.GroupBuffTarget

local G_CLASS_TAG = "groupBuffTarget"

function BOM.Class.GroupBuffTarget:new(groupNum)
  local fields = {}
  setmetatable(fields, BOM.Class.GroupBuffTarget)

  fields.t = G_CLASS_TAG
  fields.groupIndex = groupNum

  return fields
end

function BOM.Class.GroupBuffTarget.GetDistance(self)
  local nearest
  local nearest_dist = 100000

  if IsInRaid() then
    for raid_index = 1, 40 do
      local member = BOM.GetMember("raid" .. raid_index, self.groupIndex)
      if member and member.distance < nearest_dist then
        nearest_dist = member.distance
        nearest = member
      end
    end -- for all raid members, searching for group
  else
    -- Search for nearest of 4 party members, who is not myself
    for groupIndex = 1, 4 do
      local member = BOM.GetMember("party" .. groupIndex)
      local member_distance = BOM.Tool.UnitDistanceSquared(member.unitId)

      if member and not member.isDead and member_distance < nearest_dist then
        nearest_dist = member.distance
        nearest = member
      end
    end -- for party members
  end

  if nearest then
    return nearest.distance
  else
    return 100000
  end
end

function BOM.Class.GroupBuffTarget.GetText(self)
  return string.format(BOM.L.FORMAT_GROUP_NUM, self.groupIndex)
end
