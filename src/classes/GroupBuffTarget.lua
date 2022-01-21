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

local TOO_FAR = 1000000

function BOM.Class.GroupBuffTarget.GetDistance(self)
  local nearestDist = TOO_FAR
  local nearestCount = 0

  if IsInRaid() then
    for raidIndex = 1, 40 do
      local name, rank, subgroup, level, class, fileName
      , zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex);
      local rName = "raid" .. raidIndex

      if subgroup == self.groupIndex and UnitExists(rName) and UnitIsConnected(rName) then
        local memberDistance = BOM.Tool.UnitDistanceSquared(rName)
        if memberDistance < nearestDist then
          nearestDist = memberDistance
          nearestCount = nearestCount + 1
        end
      end
    end -- for all raid members, searching for group
  else
    -- Search for nearest of 4 party members, who is not myself
    for partyIndex = 1, 4 do
      local pName = "party" .. partyIndex
      if UnitExists(pName) and UnitIsConnected(pName) then -- skip offlines and missing
        local memberDistance = BOM.Tool.UnitDistanceSquared(pName)
        if not UnitIsDead(pName) and memberDistance < nearestDist then
          nearestDist = memberDistance
          nearestCount = nearestCount + 1
        end
      end
    end -- for party members
  end

  return nearestDist
end

function BOM.Class.GroupBuffTarget.GetText(self)
  return string.format(BOM.L.FORMAT_GROUP_NUM, self.groupIndex)
end
