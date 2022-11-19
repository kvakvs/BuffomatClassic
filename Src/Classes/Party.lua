local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomPartyModule
---@field buffs BomBuffCollectionPerUnit Saved self buffs for everyone
local partyModule = BomModuleManager.partyModule ---@type BomPartyModule
partyModule.buffs = --[[---@type BomBuffCollectionPerUnit]] {}

---@class BomParty
---@field members BomUnit[]
---@field byName {[string]: BomUnit}
---@field player BomUnit
local partyClass = {}
partyClass.__index = partyClass

---@return BomParty
function partyModule:New()
  local p = --[[---@type BomParty]] {}
  p.members = --[[---@type BomUnit[] ]]{}
  p.byName = --[[---@type {[string]: BomUnit}]] {}
  setmetatable(p, partyClass)
  return p
end

---@param member BomUnit
function partyClass:Add(member)
  tinsert(self.members, member)
  self.byName[member.name] = member
end

---@param party BomParty
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
