---@type BuffomatAddon
local TOCNAME, BOM = ...

---@type table<string, Member>
local bom_member_cache = {}

---@return Member
---@param unitid string
---@param name_group string
---@param name_role string MAINTANK?
function BOM.GetMember(unitid, name_group, name_role)
  local name = (UnitFullName(unitid))

  if name == nil then
    return nil
  end

  local group = name_group and name_group[name] or 1
  local isTank = name_role and (name_role[name] == "MAINTANK") or false

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

  bom_member_cache[unitid] = bom_member_cache[unitid] or BOM.Class.Member:new({})

  local member = bom_member_cache[unitid]
  member:Construct(unitid, name, group, class, link, isTank)

  return member
end

---@type Member
local bom_player_member_cache --Copy of player info dict

---@type table<table>
local bom_party_cache --Copy of party members, a dict of dicts

local function bomGetMembersCount()
  local countTo
  local prefix
  local count

  if IsInRaid() then
    countTo = 40
    prefix = "raid"
    count = 0
  else
    countTo = 4
    prefix = "group"

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

---@return table, Member
---@param player_member Member
local function bomGet5manPartyMembers(player_member)
  local name_group = {}
  local name_role = {}
  local party = {}
  local member ---@type Member

  for groupIndex = 1, 4 do
    member = BOM.GetMember("party" .. groupIndex)

    if member then
      tinsert(party, member)
    end

    member = BOM.GetMember("partypet" .. groupIndex)

    if member then
      member.group = 9
      member.class = "pet"
      tinsert(party, member)
    end
  end

  player_member = BOM.GetMember("player")
  tinsert(party, player_member)

  member = BOM.GetMember("pet")

  if member then
    member.group = 9
    member.class = "pet"
    tinsert(party, member)
  end

  return party, player_member
end

---For when player is in raid, retrieve all 40 raid members
---@param player_member Member
---@return table, Member
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
    local member = BOM.GetMember("raid" .. raid_index, name_group, name_role)

    if member then
      if UnitIsUnit(member.unitId, "player") then
        player_member = member
      end
      tinsert(party, member)

      member = BOM.GetMember("raidpet" .. raid_index)
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
---@return table<number, Member>, Member A pair of Party and Player
function BOM.GetPartyMembers()
  -- and buffs
  local party
  local player_member --- @type Member

  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded
          and bom_party_cache ~= nil
          and bom_player_member_cache ~= nil then

    if #bom_party_cache == bomGetMembersCount() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(bom_party_cache) do
        local name = (UnitFullName(member.unitId))

        if name ~= member.name then
          ok = false
          break
        end
      end

      if ok then
        party = bom_party_cache
        player_member = bom_player_member_cache
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
      local member = BOM.GetMember("target")
      if member then
        member.group = 9 --move them outside of 8 buff groups
        tinsert(party, member)
      end
    end

    bom_party_cache = party
    bom_player_member_cache = player_member

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
