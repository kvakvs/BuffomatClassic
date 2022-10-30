local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomUnitCacheModule
---@field unitCache table<string, BomUnit>
---@field cachedPlayerUnit BomUnit
---@field cachedParty table<number, BomUnit>
local unitCacheModule = BuffomatModule.New("UnitCache") ---@type BomUnitCacheModule
unitCacheModule.unitCache = {}

local buffModule = BuffomatModule.Import("Buff") ---@type BomBuffModule
local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local unitModule = BuffomatModule.Import("Unit") ---@type BomUnitModule
local toolboxModule = BuffomatModule.Import("Toolbox") ---@type BomToolboxModule

---@param unitid string Player name or special name like "raidpet#"
---@param nameGroup string|number
---@param nameRole string MAINTANK?
---@return BomUnit
function unitCacheModule:GetUnit(unitid, nameGroup, nameRole, specialName)
  local name, _unitRealm = UnitFullName(unitid)
  if name == nil then
    return nil
  end

  local group;
  if type(nameGroup) == "number" then
    group = nameGroup
  else
    group = nameGroup and nameGroup[name] or 1
  end
  
  local isTank = nameRole and (nameRole[name] == "MAINTANK") or false

  local guid = UnitGUID(unitid)
  local _, class, link

  if guid then
    _, class = GetPlayerInfoByGUID(guid)
    if class then
      link = BOM.Tool.IconClass[class] .. "|Hunit:" .. guid .. ":" .. name
              .. "|h|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r|h"
    else
      class = ""
      link = BOM.FormatTexture(BOM.ICON_PET) .. name
    end
  else
    class = ""
    link = BOM.FormatTexture(BOM.ICON_PET) .. name
  end

  if specialName then
    -- do not cache just construct
    local unit1 = unitModule:New({})
    unit1:Construct(unitid, name, group, class, link, isTank)
    return unit1
  else
    -- store in cache
    unitCacheModule.unitCache[unitid] = unitCacheModule.unitCache[unitid] or unitModule:New({})
    local unit2 = unitCacheModule.unitCache[unitid]
    unit2:Construct(unitid, name, group, class, link, isTank)
    return unit2
  end
end

---@return number Party size including pets
local function bomGetPartySize()
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

---@param playerUnit BomUnit
---@return table, BomUnit
function unitCacheModule:Get5manPartyMembers(playerUnit)
  local name_group = {}
  local name_role = {}
  local party = {}
  local partyMember ---@type BomUnit

  for groupIndex = 1, 4 do
    partyMember = self:GetUnit("party" .. groupIndex)

    if partyMember then
      tinsert(party, partyMember)
    end

    partyMember = self:GetUnit("partypet" .. groupIndex, nil, nil, true)

    if partyMember then
      partyMember.owner = self:GetUnit("party" .. groupIndex)
      partyMember.class = "pet"
      tinsert(party, partyMember)
    end
  end

  playerUnit = self:GetUnit("player")
  tinsert(party, playerUnit)

  partyMember = self:GetUnit("pet", nil, nil, true)

  if partyMember then
    partyMember.owner = self:GetUnit("player")
    partyMember.class = "pet"
    tinsert(party, partyMember)
  end

  return party, playerUnit
end

---For when player is in raid, retrieve all 40 raid members
---@param playerUnit BomUnit
---@return table, BomUnit
function unitCacheModule:Get40manRaidMembers(playerUnit)
  local name_group = {}
  local name_role = {}
  local party = {}

  for raid_index = 1, 40 do
    local name, rank, subgroup, level, class, fileName, zone, online, isDead
    , role, isML, combatRole = GetRaidRosterInfo(raid_index)

    if name then
      name = BOM.Tool.Split(name, "-")[1]
      name_group[name] = subgroup
      name_role[name] = role
    end
  end

  for raid_index = 1, 40 do
    local raidMember = self:GetUnit("raid" .. raid_index, name_group, name_role)

    if raidMember then
      if UnitIsUnit(raidMember.unitId, "player") then
        playerUnit = raidMember
      end
      tinsert(party, raidMember)

      raidMember = self:GetUnit("raidpet" .. raid_index, name_group, nil, true)
      if raidMember then
        raidMember.owner = self:GetUnit("raid" .. raid_index, name_group, name_role)
        raidMember.class = "pet"
        tinsert(party, raidMember)
      end
    end
  end
  return party, playerUnit
end

---Retrieve a table with party members
---@return table<number, BomUnit>, BomUnit {Party, Player}
function unitCacheModule:GetPartyMembers()
  -- and buffs
  local party ---@type table<number, BomUnit>
  local playerUnit --- @type BomUnit
  BOM.drinkingPersonCount = 0

  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded
          and self.cachedParty ~= nil
          and self.cachedPlayerUnit ~= nil then

    if #self.cachedParty == bomGetPartySize() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(self.cachedParty) do
        local name = (UnitFullName(member.unitId))

        if name ~= member.name then
          ok = false
          break
        end
      end

      if ok then
        party = self.cachedParty
        playerUnit = self.cachedPlayerUnit
      end
    end
  end

  -- read party data
  if party == nil or playerUnit == nil then
    if IsInRaid() then
      party, playerUnit = self:Get40manRaidMembers(playerUnit)
    else
      party, playerUnit = self:Get5manPartyMembers(playerUnit)
    end

    if buffomatModule.shared.BuffTarget
            and UnitExists("target")
            and UnitCanCooperate("player", "target") --is friendly
            and UnitIsPlayer("target") --is friendly player
            and not UnitPlayerOrPetInParty("target") --out of party or raid
            and not UnitPlayerOrPetInRaid("target")
    then
      local targetedUnit = self:GetUnit("target")
      if targetedUnit then
        targetedUnit.group = 9 --move them outside of 8 buff groups
        tinsert(party, targetedUnit)
      end
    end

    self.cachedParty = party
    self.cachedPlayerUnit = playerUnit

    -- Cleanup BOM.PlayerBuffs
    for name, val in pairs(BOM.PlayerBuffs) do
      local ok = false

      for i, member in ipairs(party) do
        if member.name == name then
          ok = true
        end
      end

      if ok == false then
        BOM.PlayerBuffs[name] = nil
      end
    end

    buffomatModule:SetForceUpdate("joinedParty") -- always read all buffs on new party!
  end

  BOM.PartyUpdateNeeded = false
  BOM.SomeBodyGhost = false

  local player_zone = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.DeclineHasResurrection = true
    BOM.ClearSkip()
  end

  -- For every party member which is in same zone, not a ghost or is a target
  for i, member in ipairs(party) do
    member.isSameZone = (C_Map.GetBestMapForUnit(member.unitId) == player_zone)
            or member.isGhost
            or member.unitId == "target"

    if not member.isDead
            or BOM.DeclineHasResurrection
    then
      member.hasResurrection = false
      member.distance = toolboxModule:UnitDistanceSquared(member.unitId)
    else
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId)
              or member.hasResurrection
    end

    if next(buffomatModule.forceUpdateRequestedBy) ~= nil then
      member:ForceUpdateBuffs(playerUnit)
    end -- if force update
  end -- for all in party

  -- weapon-buffs
  -- Clear old
  local OldMainHandBuff = playerUnit.MainHandBuff
  local OldOffHandBuff = playerUnit.OffHandBuff

  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if hasMainHandEnchant and mainHandEnchantID
          and BOM.EnchantToSpell[mainHandEnchantID] then
    local enchantBuffId = BOM.EnchantToSpell[mainHandEnchantID]
    local duration

    if BOM.ConfigToSpell[enchantBuffId] and BOM.ConfigToSpell[enchantBuffId].singleDuration then
      duration = BOM.ConfigToSpell[enchantBuffId].singleDuration
    else
      duration = 300
    end

    playerUnit.knownBuffs[enchantBuffId] = buffModule:New(
            enchantBuffId,
            duration,
            GetTime() + mainHandExpiration / 1000,
            "player",
            true)
    playerUnit.MainHandBuff = enchantBuffId
  else
    playerUnit.MainHandBuff = nil
  end

  if hasOffHandEnchant
          and offHandEnchantId
          and BOM.EnchantToSpell[offHandEnchantId] then
    local enchantBuffId = BOM.EnchantToSpell[offHandEnchantId]
    local duration

    if BOM.ConfigToSpell[enchantBuffId] and BOM.ConfigToSpell[enchantBuffId].singleDuration then
      duration = BOM.ConfigToSpell[enchantBuffId].singleDuration
    else
      duration = 300
    end

    playerUnit.knownBuffs[-enchantBuffId] = buffModule:New(
            -enchantBuffId,
            duration,
            GetTime() + offHandExpiration / 1000,
            "player",
            true)

    playerUnit.OffHandBuff = enchantBuffId
  else
    playerUnit.OffHandBuff = nil
  end

  if OldMainHandBuff ~= playerUnit.MainHandBuff then
    buffomatModule:SetForceUpdate("mainHandBuffChanged")
  end

  if OldOffHandBuff ~= playerUnit.OffHandBuff then
    buffomatModule:SetForceUpdate("offhandBuffChanged")
  end

  BOM.DeclineHasResurrection = false

  return party, playerUnit
end

function unitCacheModule:ClearCache()
  self.cachedParty = nil
  self.cachedPlayerUnit = nil
end