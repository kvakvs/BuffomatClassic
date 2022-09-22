local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomGroupBuffTargetModule
local groupBuffTargetModule = BuffomatModule.New("GroupBuffTarget") ---@type BomGroupBuffTargetModule

local toolboxModule = BuffomatModule.Import("Toolbox") ---@type BomToolboxModule

---@class BomGroupBuffTarget
---@field groupIndex number
local groupBuffTargetClass = {}

--BOM.Class.GroupBuffTarget = {} ---@type BomGroupBuffTarget
--BOM.Class.GroupBuffTarget.__index = BOM.Class.GroupBuffTarget

---@return BomGroupBuffTarget
function groupBuffTargetModule:New(groupNum)
  local fields = {} ---@type BomGroupBuffTarget
  setmetatable(fields, BOM.Class.GroupBuffTarget)

  fields.groupIndex = groupNum
  return fields
end

local TOO_FAR = 1000000

function groupBuffTargetClass:GetDistanceRaid()
  local nearestDist = TOO_FAR
  local nearestCount = 0

  for raidIndex = 1, 40 do
    local name, rank, subgroup, level, class, fileName
    , zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex);
    local rName = "raid" .. raidIndex

    if subgroup == self.groupIndex and UnitExists(rName) and UnitIsConnected(rName) then
      local unitDistance = toolboxModule:UnitDistanceSquared(rName)
      if unitDistance < nearestDist then
        nearestDist = unitDistance
        nearestCount = nearestCount + 1
      end
    end
  end -- for all raid members, searching for group

  return nearestDist
end

function groupBuffTargetClass:GetDistanceParty()
  local nearestDist = TOO_FAR
  local nearestCount = 0

  -- Search for nearest member of 5man party, that is not myself
  for partyIndex = 1, 4 do
    local pName = "party" .. partyIndex
    if UnitExists(pName) and UnitIsConnected(pName) then -- skip offlines and missing
      local unitDistance = toolboxModule:UnitDistanceSquared(pName)
      if not UnitIsDead(pName) and unitDistance < nearestDist then
        nearestDist = unitDistance
        nearestCount = nearestCount + 1
      end
    end
  end -- for party members

  return nearestDist
end

function groupBuffTargetClass:GetDistance()
  if IsInRaid() then
    return self:GetDistanceRaid()
  else
    return self:GetDistanceParty()
  end
end

function groupBuffTargetClass:GetText()
  return string.format(BOM.L.FORMAT_GROUP_NUM, self.groupIndex)
end
