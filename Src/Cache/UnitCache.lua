local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomUnitCacheModule
---@field unitCache table<string, BomUnit>
---@field cachedParty BomParty
local unitCacheModule = BomModuleManager.unitCacheModule ---@type BomUnitCacheModule
unitCacheModule.unitCache = {}

local buffModule = BomModuleManager.buffModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local partyModule = BomModuleManager.partyModule
local taskScanModule = BomModuleManager.taskScanModule
local texturesModule = BomModuleManager.texturesModule
local toolboxModule = BomModuleManager.toolboxModule
local unitModule = BomModuleManager.unitModule

---@alias BomRaidRole "MAINTANK"|"MAINASSIST"|"NONE"
---@alias BomNameRoleMap {[string]: BomRaidRole}
---@alias BomNameGroupMap {[string]: number}

---@param unitid string Player name or special name like "raidpet#"
---@param nameGroupMap BomNameGroupMap|number|nil Maps name to group number in raid; Or a group number if number.
---@param nameRoleMap BomNameRoleMap|nil Maps name to role in raid
---@param specialName boolean|nil
---@return BomUnit|nil
function unitCacheModule:GetUnit(unitid, nameGroupMap, nameRoleMap, specialName)
  local name, _unitRealm = UnitFullName(unitid) ---@type string, string
  if name == nil then
    return nil
  end

  local group ---@type number
  if type(nameGroupMap) == "number" then
    group = --[[---@type number]] nameGroupMap
  else
    group = nameGroupMap and (--[[---@type BomNameGroupMap]] nameGroupMap)[name] or 1
  end

  nameRoleMap = nameRoleMap or --[[---@type BomNameRoleMap]] {}
  local isTank = nameRoleMap and ((--[[---@not nil]] nameRoleMap)[name] == "MAINTANK") or false

  local guid = UnitGUID(unitid)
  local _, class, link ---@type any, BomClassName|"", string|nil

  if guid then
    _, class = GetPlayerInfoByGUID(guid)
    if class then
      link = constModule.CLASS_ICONS[--[[---@not ""]] class] .. "|Hunit:" .. guid .. ":" .. name
              .. "|h|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r|h"
    else
      class = ""
      link = BOM.FormatTexture(texturesModule.ICON_PET) .. name
    end
  else
    class = ""
    link = BOM.FormatTexture(texturesModule.ICON_PET) .. name
  end

  if specialName then
    -- do not cache just construct
    local unit1 = unitModule:New({})
    unit1:Construct(unitid, name, group, class, link or "", isTank)
    return unit1
  else
    -- store in cache
    unitCacheModule.unitCache[unitid] = unitCacheModule.unitCache[unitid] or unitModule:New({})
    local unit2 = unitCacheModule.unitCache[unitid]
    unit2:Construct(unitid, name, group, class, link or "", isTank)
    return unit2
  end
end

---@return BomParty Returns party table and player unit
function unitCacheModule:Get5manPartyMembers()
  local party = partyModule:New()

  for groupIndex = 1, 4 do
    local partyMember = self:GetUnit("party" .. groupIndex, nil, nil, nil)
    if partyMember then
      party:Add(--[[---@not nil]] partyMember)
    end

    local partyPet = self:GetUnit("partypet" .. groupIndex, nil, nil, true)
    if partyPet then
      local pet = --[[---@not nil]] partyPet
      pet.owner = partyMember
      pet.class = "pet"
      party:Add(pet)
    end
  end

  -- Get player and get pet
  local playerUnit = self:GetUnit("player", nil, nil, nil)
  party:Add(--[[---@not nil]] playerUnit)
  party.player = --[[---@not nil]] playerUnit

  local playerPet = self:GetUnit("pet", nil, nil, true)
  if playerPet then
    local pet = --[[---@not nil]] playerPet
    pet.owner = playerUnit
    pet.class = "pet"
    party:Add(pet)
  end

  return party
end

---For when player is in raid, retrieve all 40 raid members
---@return BomParty Returns the party
function unitCacheModule:Get40manRaidMembers()
  local nameGroupMap = --[[---@type BomNameGroupMap]] {}
  local nameRoleMap = --[[---@type BomNameRoleMap]] {}
  local party = partyModule:New()
  local numRaidMembers = GetNumGroupMembers() ---@type number

  for raidIndex = 1, numRaidMembers do
    ---@type string, string, number, number, BomClassName, string, number, boolean, boolean, BomRaidRole, boolean, string
    local name, rank, subgroup, level, class, fileName, zone, online, isDead
    , role, isML, combatRole = GetRaidRosterInfo(raidIndex)

    if name then
      name = toolboxModule:Split(name, "-")[1]
      nameGroupMap[name] = subgroup
      nameRoleMap[name] = role
    end
  end

  for raidIndex = 1, numRaidMembers do
    local raidMember = self:GetUnit("raid" .. raidIndex, nameGroupMap, nameRoleMap, nil)

    if raidMember then
      local member = --[[---@not nil]] raidMember
      if UnitIsUnit(member.unitId, "player") then
        party.player = member
      end
      party:Add(member)

      local raidPet = self:GetUnit("raidpet" .. raidIndex, nameGroupMap, nil, true)
      if raidPet then
        local pet = --[[---@not nil]] raidPet
        pet.owner = raidMember
        pet.class = "pet"
        party:Add(pet)
      end
    end
  end
  return party
end

---@return BomParty
function unitCacheModule:GetPartyMembers()
  -- and buffs
  local party ---@type BomParty
  BOM.drinkingPersonCount = 0

  -- check if stored party is correct!
  if not BOM.isPartyUpdateNeeded
          and self.cachedParty ~= nil then

    if #self.cachedParty == partyModule:GetPartySize() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in pairs(self.cachedParty.members) do
        local name = UnitFullName(member.unitId)

        if name ~= member.name then
          ok = false
          break
        end
      end

      if ok then
        party = self.cachedParty
      end
    end
  end

  -- read party data
  if party == nil then
    if IsInRaid() then
      party = self:Get40manRaidMembers()
    else
      party = self:Get5manPartyMembers()
    end

    if buffomatModule.shared.BuffTarget
            and UnitExists("target")
            and UnitCanCooperate("player", "target") --is friendly
            and UnitIsPlayer("target") --is friendly player
            and not UnitPlayerOrPetInParty("target") --out of party or raid
            and not UnitPlayerOrPetInRaid("target")
    then
      local targetedUnit = self:GetUnit("target", nil, nil, nil)
      if targetedUnit then
        (--[[---@not nil]] targetedUnit).group = 9 --move them outside of 8 buff groups
        party:Add(--[[---@not nil]] targetedUnit)
      end
    end

    self.cachedParty = party

    partyModule:CleanUpBuffs(party)
    buffomatModule:SetForceUpdate("joinedParty") -- always read all buffs on new party!
  end

  BOM.isPartyUpdateNeeded = false
  BOM.someBodyIsGhost = false

  local player_zone = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.declineHasResurrection = true
    taskScanModule:ClearSkip()
  end

  -- For every party member which is in same zone, not a ghost or is a target
  for _i, member in pairs(party.members) do
    member.isSameZone = (C_Map.GetBestMapForUnit(member.unitId) == player_zone)
            or member.isGhost
            or member.unitId == "target"

    if not member.isDead
            or BOM.declineHasResurrection
    then
      member.hasResurrection = false
      member.distance = toolboxModule:UnitDistanceSquared(member.unitId)
    else
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId)
              or member.hasResurrection
    end

    if next(buffomatModule.forceUpdateRequestedBy) ~= nil then
      member:ForceUpdateBuffs(party.player)
    end -- if force update
  end -- for all in party

  -- weapon-buffs
  -- Clear old
  local OldMainHandBuff = party.player.MainHandBuff
  local OldOffHandBuff = party.player.OffHandBuff

  ---@type boolean, number, number, BomEnchantmentId, boolean, number, number, BomEnchantmentId
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if hasMainHandEnchant and mainHandEnchantID
          and BOM.enchantToSpellLookup[mainHandEnchantID] then
    local enchantBuffId = BOM.enchantToSpellLookup[mainHandEnchantID]
    local duration

    if BOM.buffFromSpellIdLookup[enchantBuffId] and BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration then
      duration = BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
    else
      duration = 300
    end

    party.player.knownBuffs[enchantBuffId] = buffModule:New(
            enchantBuffId,
            duration,
            GetTime() + mainHandExpiration / 1000,
            "player",
            true)
    party.player.MainHandBuff = enchantBuffId
  else
    party.player.MainHandBuff = nil
  end

  if hasOffHandEnchant
          and offHandEnchantId
          and BOM.enchantToSpellLookup[offHandEnchantId] then
    local enchantBuffId = BOM.enchantToSpellLookup[offHandEnchantId]
    local duration

    if BOM.buffFromSpellIdLookup[enchantBuffId] and BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration then
      duration = BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
    else
      duration = 300
    end

    party.player.knownBuffs[-enchantBuffId] = buffModule:New(
            -enchantBuffId,
            duration,
            GetTime() + offHandExpiration / 1000,
            "player",
            true)

    party.player.OffHandBuff = enchantBuffId
  else
    party.player.OffHandBuff = nil
  end

  if OldMainHandBuff ~= party.player.MainHandBuff then
    buffomatModule:SetForceUpdate("mainHandBuffChanged")
  end

  if OldOffHandBuff ~= party.player.OffHandBuff then
    buffomatModule:SetForceUpdate("offhandBuffChanged")
  end

  BOM.declineHasResurrection = false

  return party
end

function unitCacheModule:ClearCache()
  self.cachedParty = partyModule:New()
end