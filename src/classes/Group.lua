---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Group
---@field groupNum number

---@type Group
BOM.Class.Group = {}
BOM.Class.Group.__index = BOM.Class.Group

local G_CLASS_TAG = "group"

function BOM.Class.Group:new(groupNum)
  local fields = {}
  setmetatable(fields, BOM.Class.Group)

  fields.t = G_CLASS_TAG
  fields.groupNum = groupNum

  return fields
end

function BOM.Class.Group.GetDistance(self)
  local nearest = nil
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
      if member and member.distance < nearest_dist then
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
