local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomUnitCacheModule
---@field unitCache table<string, BomUnit>
local unitCacheModule = BuffomatModule.DeclareModule("UnitCache") ---@type BomUnitCacheModule
unitCacheModule.unitCache = {}

---@type BomUnit
local bomPlayerMemberCache --Copy of player info dict

---@type table<number, BomUnit>
local bomPartyCache --Copy of party members, a dict of Member's

---@return BomUnit
---@param unitid string Player name or special name like "raidpet#"
---@param nameGroup string|number
---@param nameRole string MAINTANK?
local function bomGetMember(unitid, nameGroup, nameRole, specialName)
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
    local member = BOM.Class.Member:new({})
    member:Construct(unitid, name, group, class, link, isTank)
    return member
  else
    -- store in cache
    unitCacheModule.unitCache[unitid] = unitCacheModule.unitCache[unitid] or BOM.Class.Member:new({})
    local member = unitCacheModule.unitCache[unitid]
    member:Construct(unitid, name, group, class, link, isTank)
    return member
  end
end

BOM.GetMember = bomGetMember

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

---@return table, BomUnit
---@param player_member BomUnit
local function bomGet5manPartyMembers(player_member)
  local name_group = {}
  local name_role = {}
  local party = {}
  local member ---@type BomUnit

  for groupIndex = 1, 4 do
    member = bomGetMember("party" .. groupIndex)

    if member then
      tinsert(party, member)
    end

    member = bomGetMember("partypet" .. groupIndex, nil, nil, true)

    if member then
      member.group = 9
      member.class = "pet"
      tinsert(party, member)
    end
  end

  player_member = bomGetMember("player")
  tinsert(party, player_member)

  member = bomGetMember("pet", nil, nil, true)

  if member then
    member.group = 9
    member.class = "pet"
    tinsert(party, member)
  end

  return party, player_member
end

---For when player is in raid, retrieve all 40 raid members
---@param player_member BomUnit
---@return table, BomUnit
local function bomGet40manRaidMembers(player_member)
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
    local member = bomGetMember("raid" .. raid_index, name_group, name_role)

    if member then
      if UnitIsUnit(member.unitId, "player") then
        player_member = member
      end
      tinsert(party, member)

      member = bomGetMember("raidpet" .. raid_index, nil, nil, true)
      if member then
        member.group = 9
        member.class = "pet"
        tinsert(party, member)
      end
    end
  end
  return party, player_member
end

---Retrieve a table with party members
---@return table<number, BomUnit>, BomUnit {Party, Player}
function BOM.GetPartyMembers()
  -- and buffs
  local party ---@type table<number, BomUnit>
  local player_member --- @type BomUnit
  BOM.drinkingPersonCount = 0

  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded
          and bomPartyCache ~= nil
          and bomPlayerMemberCache ~= nil then

    if #bomPartyCache == bomGetPartySize() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(bomPartyCache) do
        local name = (UnitFullName(member.unitId))

        if name ~= member.name then
          ok = false
          break
        end
      end

      if ok then
        party = bomPartyCache
        player_member = bomPlayerMemberCache
      end
    end
  end

  -- read party data
  if party == nil or player_member == nil then
    if IsInRaid() then
      party, player_member = bomGet40manRaidMembers(player_member)
    else
      party, player_member = bomGet5manPartyMembers(player_member)
    end

    if BOM.SharedState.BuffTarget
            and UnitExists("target")
            and UnitCanCooperate("player", "target") --is friendly
            and UnitIsPlayer("target") --is friendly player
            and not UnitPlayerOrPetInParty("target") --out of party or raid
            and not UnitPlayerOrPetInRaid("target")
    then
      local member = bomGetMember("target")
      if member then
        member.group = 9 --move them outside of 8 buff groups
        tinsert(party, member)
      end
    end

    bomPartyCache = party
    bomPlayerMemberCache = player_member

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

    BOM.SetForceUpdate("JoinedParty") -- always read all buffs on new party!
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
      member.distance = BOM.Tool.UnitDistanceSquared(member.unitId)
    else
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId)
              or member.hasResurrection
    end

    if BOM.ForceUpdate then
      member:ForceUpdateBuffs(player_member)
    end -- if force update
  end -- for all in party

  -- weapon-buffs
  -- Clear old
  local OldMainHandBuff = player_member.MainHandBuff
  local OldOffHandBuff = player_member.OffHandBuff

  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if hasMainHandEnchant and mainHandEnchantID
          and BOM.EnchantToSpell[mainHandEnchantID] then
    local configId = BOM.EnchantToSpell[mainHandEnchantID]
    local duration

    if BOM.ConfigToSpell[ConfigID] and BOM.ConfigToSpell[ConfigID].singleDuration then
      duration = BOM.ConfigToSpell[ConfigID].singleDuration
    else
      duration = 300
    end

    player_member.buffs[configId] = BOM.Class.Buff:new(
            configId,
            duration,
            GetTime() + mainHandExpiration / 1000,
            "player",
            true)
    player_member.MainHandBuff = configId
  else
    player_member.MainHandBuff = nil
  end

  if hasOffHandEnchant
          and offHandEnchantId
          and BOM.EnchantToSpell[offHandEnchantId] then
    local configId = BOM.EnchantToSpell[offHandEnchantId]
    local duration

    if BOM.ConfigToSpell[ConfigID] and BOM.ConfigToSpell[ConfigID].singleDuration then
      duration = BOM.ConfigToSpell[ConfigID].singleDuration
    else
      duration = 300
    end

    player_member.buffs[-configId] = BOM.Class.Buff:new(
            -configId,
            duration,
            GetTime() + offHandExpiration / 1000,
            "player",
            true)

    player_member.OffHandBuff = configId
  else
    player_member.OffHandBuff = nil
  end

  if OldMainHandBuff ~= player_member.MainHandBuff then
    BOM.SetForceUpdate("MainHandBuff Changed")
  end

  if OldOffHandBuff ~= player_member.OffHandBuff then
    BOM.SetForceUpdate("OffhandBuffChanged")
  end

  BOM.DeclineHasResurrection = false

  return party, player_member
end
