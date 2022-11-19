--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomPartyModule
---@field buffs BomBuffCollectionPerUnit Saved self buffs for everyone
---@field partyCacheInvalidation "clear"|number[]|nil Set 'clear' for full invalidation, number[] array for partial invalidation, nil to validate
local partyModule = BomModuleManager.partyModule ---@type BomPartyModule
partyModule.buffs = --[[---@type BomBuffCollectionPerUnit]] {}

local buffomatModule = BomModuleManager.buffomatModule
local toolboxModule = BomModuleManager.toolboxModule
local unitCacheModule = BomModuleManager.unitCacheModule

---@alias BomUnitDictByGroup {[number]: BomUnit}
---@alias BomUnitDictByUnitGUID {[string]: BomUnit}
---@alias BomUnitDictByName {[string]: BomUnit}

---@class BomParty
---@field byGroup BomUnitDictByGroup Party members by group number
---@field byUnitGUID BomUnitDictByUnitGUID Party members by group number
---@field byName BomUnitDictByName Party members by name
---@field player BomUnit
---@field playerPet BomUnit|nil
local partyClass = {}
partyClass.__index = partyClass

---@return BomParty
function partyModule:New()
  local p = --[[---@type BomParty]] {}
  p.byGroup = --[[---@type BomUnitDictByGroup]] {}
  p.byUnitGUID = --[[---@type BomUnitDictByUnitGUID]] {}
  p.byName = --[[---@type BomUnitDictByName]] {}
  setmetatable(p, partyClass)
  return p
end

---@param member BomUnit
function partyClass:Add(member)
  self.byUnitGUID[member.unitGUID] = member
  self.byGroup[member.group] = member
  self.byName[member.name] = member
end

---@param name string
---@return boolean
function partyClass:IsPartyMember(name)
  return self.byName[name] ~= nil
end

---Drop buffs for names which aren't in our party
---@param party BomParty
function partyModule:CleanUpBuffs(party)
  -- Clean partyModule.buffs up
  for name, val in pairs(self.buffs) do
    local ok = false

    if not party:IsPartyMember(name) then
      self.buffs[name] = nil
    end
  end
end

---@return number Party size including pets
function partyModule:GetPartySize()
  local countTo
  local prefix
  local count

  if IsInRaid() then
    countTo = 40
    prefix = "raid"
    count = 0
  else
    countTo = 4
    prefix = "party"

    if UnitPlayerOrPetInParty("pet") then
      count = 2
    else
      count = 1
    end
  end

  for i = 1, countTo do
    if UnitPlayerOrPetInParty(prefix .. i) then
      count = count + 1

      if UnitPlayerOrPetInParty(prefix .. "pet" .. i) then
        count = count + 1
      end
    end
  end

  return count
end

---@param groups number[]|nil
function partyModule:InvalidatePartyCache(groups)
  self.partyCacheInvalidation = groups or "clear"
end

function partyModule:ValidatePartyCache()
  self.partyCacheInvalidation = nil
end

---@return number[]
function partyModule:GetInvalidGroups()
  if self.partyCacheInvalidation == "clear" then
    return {1, 2, 3, 4, 5, 6, 7, 8}
  end
  if type(self.partyCacheInvalidation) == "table" then
    return --[[---@type number[] ]] self.partyCacheInvalidation
  end
  return {}
end

---@param party BomParty
---@param invalidGroups number[]
function partyModule:RefreshParty(party, invalidGroups)
  if IsInRaid() then
    party:Get40manRaidMembers(invalidGroups)
  else
    party:Get5manPartyMembers()
  end

  if buffomatModule.shared.BuffTarget
          and UnitExists("target")
          and UnitCanCooperate("player", "target") --is friendly
          and UnitIsPlayer("target") --is friendly player
          and not UnitPlayerOrPetInParty("target") --out of party or raid
          and not UnitPlayerOrPetInRaid("target")
  then
    local targetedUnit = unitCacheModule:GetUnit("target", nil, nil, nil)
    if targetedUnit then
      (--[[---@not nil]] targetedUnit).group = 9 --move them outside of 8 buff groups
      party:Add(--[[---@not nil]] targetedUnit)
    end
  end

  unitCacheModule.partyCache = party
  partyModule:CleanUpBuffs(party)
  --buffomatModule:SetForceUpdate("reloadParty") -- always read all buffs on new party!
  return party
end

function partyClass:GetPlayerAndPetUnit()
  -- Get player and get pet
  local playerUnit = unitCacheModule:GetUnit("player", nil, nil, nil)
  self.player = --[[---@not nil]] playerUnit
  self:Add(--[[---@not nil]] playerUnit)

  local playerPet = unitCacheModule:GetUnit("pet", nil, nil, true)
  if playerPet then
    local pet = --[[---@not nil]] playerPet
    pet.owner = playerUnit
    pet.class = "pet"
    self.playerPet = pet
    self:Add(pet)
  else
    self.playerPet = nil
  end
end

function partyClass:Get5manPartyMembers()
  for groupIndex = 1, 4 do
    local partyMember = unitCacheModule:GetUnit("party" .. groupIndex, nil, nil, nil)
    if partyMember then
      self:Add(--[[---@not nil]] partyMember)
    end

    local partyPet = unitCacheModule:GetUnit("partypet" .. groupIndex, nil, nil, true)
    if partyPet then
      local pet = --[[---@not nil]] partyPet
      pet.owner = partyMember
      pet.class = "pet"
      self:Add(pet)
    end
  end

  self:GetPlayerAndPetUnit()
end

---For when player is in raid, retrieve all 40 raid members
---InvalidGroups parameter allows reloading partially 5 members at a time
---@param invalidGroups number[] Groups to reload
function partyClass:Get40manRaidMembers(invalidGroups)
  local nameGroupMap = --[[---@type BomNameGroupMap]] {}
  local nameRoleMap = --[[---@type BomNameRoleMap]] {}

  for _, groupIndex in ipairs(invalidGroups) do
    local raidBegin = (groupIndex - 1) * 5
    local raidEnd = raidBegin + 5
    for raidIndex = raidBegin, raidEnd do
      ---@type string, string, number, number, BomClassName, string, number, boolean, boolean, BomRaidRole, boolean, string
      local name, rank, subgroup, level, class, fileName, zone, online, isDead
      , role, isML, combatRole = GetRaidRosterInfo(raidIndex)

      if name then
        name = toolboxModule:Split(name, "-")[1]
        nameGroupMap[name] = subgroup
        nameRoleMap[name] = role
      end
    end -- each member of invalidated group
  end -- invalidated groups

  self:GetPlayerAndPetUnit()
end
