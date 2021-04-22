local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

local bom_save_someone_is_dead = false

BOM.ALL_PROFILES = { "solo", "group", "raid", "battleground" }

function BOM.CancelBuff(list)
  local ret = false
  if not InCombatLockdown() and list then
    for i = 1, 40 do
      --name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId,
      local _, _, _, _, _, _, source, _, _, spellId = UnitBuff("player", i, "CANCELABLE")
      if tContains(list, spellId) then
        ret = true
        BOM.CancelBuffSource = source or "player"
        CancelUnitBuff("player", i)
        break
      end
    end
  end
  return ret
end

function BOM.CancelShapeShift()
  return BOM.CancelBuff(ShapeShiftTravel)
end

BOM.CachedHasItems = {}

---Check whether the player has item
---@param list table - the item?
---@param cd boolean - respect the cooldown?
function BOM.HasItem(list, cd)
  if list == nil then
    return true, nil, nil, 1 -- spell.items is nil, no items required
  end

  local key = list[1] .. (cd and "CD" or "")
  local x = BOM.CachedHasItems[key]

  if not x then
    BOM.CachedHasItems[key] = {}
    x = BOM.CachedHasItems[key]
    x.a = false
    x.d = 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink
        , isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        if tContains(list, itemID) then
          if cd then
            x.a, x.b, x.c = true, bag, slot
            x.d = x.d + itemCount

          else
            x.a = true
            return true
          end
        end
      end
    end
  end

  if cd and x.b and x.c then
    local startTime, _, _ = GetContainerItemCooldown(x.b, x.c)
    if (startTime or 0) == 0 then
      return x.a, x.b, x.c, x.d
    else
      return false, x.b, x.c, x.d
    end
  end

  return x.a
end

BOM.WipeCachedItems = true

-- Stores copies of GetContainerItemInfo parse results
local _GetItemListCached = {}

function BOM.GetItemList()
  if BOM.WipeCachedItems then
    wipe(_GetItemListCached)
    BOM.WipeCachedItems = false

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)

        local icon, itemCount, _locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        for iList, list in ipairs(BOM.ItemList) do
          if tContains(list, itemID) then
            tinsert(_GetItemListCached, { Index   = iList,
                                          ID      = itemID,
                                          CD      = { },
                                          Link    = itemLink,
                                          Bag     = bag,
                                          Slot    = slot,
                                          Texture = icon })
          end
        end

        if lootable and BOM.SharedState.OpenLootable then
          local locked = false

          for i, text in ipairs(BOM.Tool.ScanToolTip("SetBagItem", bag, slot)) do
            if text == LOCKED then
              locked = true
              break
            end
          end

          if not locked then
            tinsert(_GetItemListCached, { Index    = 0,
                                          ID       = itemID,
                                          CD       = nil,
                                          Link     = itemLink,
                                          Bag      = bag,
                                          Slot     = slot,
                                          Lootable = true,
                                          Texture  = icon })
          end -- not locked
        end -- lootable & sharedState.openLootable
      end -- for all bag slots in the current bag
    end -- for all bags
  end

  --Update CD
  for i, items in ipairs(_GetItemListCached) do
    if items.CD then
      items.CD = { GetContainerItemCooldown(items.Bag, items.Slot) }
    end
  end

  return _GetItemListCached
end

---Formats a spell icon + spell name as a link
---@param spellId number - spell id
---@param icon string - spell icon, formatted as texture escape sequence
---@param name string - spell name
---@param rank string - ignored
local function bom_format_spell_link(spellId, icon, name, rank)
  --local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  if spellId == nil then
    return "NIL SPELLID"
  end

  name = name or "MISSING NAME"
  icon = icon or "MISSING ICON"

  return "|Hspell:" .. spellId
          .. "|h|r |cff71d5ff"
          .. BOM.FormatTexture(icon)
          .. name
          .. "|r|h"
end

---Unused
local function bom_spell_link_from_spell(spell)
  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  return bom_format_spell_link(spellId, icon, name)
end

--Flag set to true when custom spells and cancel-spells were imported from the config
local SpellsIncluded = false

function BOM.GetSpells()
  for i, profil in ipairs(BOM.ALL_PROFILES) do
    BOM.CharacterState[profil].Spell = BOM.CharacterState[profil].Spell or {}
    BOM.CharacterState[profil].CancelBuff = BOM.CharacterState[profil].CancelBuff or {}
    BOM.CharacterState[profil].Spell[BOM.BLESSING_ID] = BOM.CharacterState[profil].Spell[BOM.BLESSING_ID] or {}
  end

  if not SpellsIncluded then
    SpellsIncluded = true

    for x, entry in ipairs(BomSharedState.CustomSpells) do
      tinsert(BOM.AllBuffomatSpells, BOM.Tool.CopyTable(entry))
    end

    for x, entry in ipairs(BomSharedState.CustomCancelBuff) do
      tinsert(BOM.CancelBuff, BOM.Tool.CopyTable(entry))
    end
  end

  --Spells selected for the current class/settings/profile etc
  BOM.SelectedSpells = {}
  BOM.cancelForm = {}
  BOM.AllSpellIds = {}
  BOM.SpellIdtoConfig = {}
  BOM.SpellIdIsSingle = {}
  BOM.ConfigToSpell = {}

  BOM.SharedState.Cache = BOM.SharedState.Cache or {}
  BOM.SharedState.Cache.Item = BOM.SharedState.Cache.Item or {}

  if BOM.ArgentumDawn.Link == nil
          or BOM.Carrot.Link == nil then
    do
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.ArgentumDawn.spell)
      BOM.ArgentumDawn.Link = bom_format_spell_link(spellId, icon, name, rank)
      name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.Carrot.spell)
      BOM.Carrot.Link = bom_format_spell_link(spellId, icon, name, rank)
    end
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    -- save "ConfigID"
    --spell.ConfigID = spell.ConfigID or spell.singleId

    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
      end
    end

    -- GetSpellNames and set default duration
    local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.singleId)
    spell.single = name
    rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = bom_format_spell_link(spellId, icon, name, rank)
    spell.Icon = icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for i, profil in ipairs(BOM.ALL_PROFILES) do
      if BOM.CharacterState[profil].CancelBuff[spell.ConfigID] == nil then
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID] = {}
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID].Enable = spell.default or false
      end
    end
  end

  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    spell.SkipList = {}
    BOM.ConfigToSpell[spell.ConfigID] = spell

    -- get highest rank and store SpellID=ConfigID
    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
        BOM.SpellIdIsSingle[sID] = true
        BOM.ConfigToSpell[sID] = spell

        if IsSpellKnown(sID) then
          spell.singleId = sID
        end
      end
    end

    if spell.singleId then
      BOM.SpellIdtoConfig[spell.singleId] = spell.ConfigID
      BOM.SpellIdIsSingle[spell.singleId] = true
      BOM.ConfigToSpell[spell.singleId] = spell
    end

    if spell.groupFamily then
      for sindex, sID in ipairs(spell.groupFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
        BOM.ConfigToSpell[sID] = spell

        if IsSpellKnown(sID) then
          spell.groupId = sID
        end
      end
    end

    if spell.groupId then
      BOM.SpellIdtoConfig[spell.groupId] = spell.ConfigID
      BOM.ConfigToSpell[spell.groupId] = spell
    end

    -- GetSpellNames and set default duration
    if spell.singleId
            and not spell.isBuff
    then
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.singleId)
      spell.single = name
      rank = GetSpellSubtext(spell.singleId) or ""
      spell.singleLink = bom_format_spell_link(spellId, icon, name, rank)
      spell.Icon = icon

      if spell.isTracking then
        spell.TrackingIcon = icon
      end

      if not spell.isInfo
              and not spell.isBuff
              and spell.singleDuration
              and BOM.SharedState.Duration[name] == nil
              and IsSpellKnown(spell.singleId) then
        BOM.SharedState.Duration[name] = spell.singleDuration
      end
    end

    if spell.groupId then
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.groupId)
      spell.group = name
      rank = GetSpellSubtext(spell.groupId) or ""
      spell.groupLink = bom_format_spell_link(spellId, icon, name, rank)

      if spell.groupDuration
              and BOM.SharedState.Duration[name] == nil
              and IsSpellKnown(spell.groupId)
      then
        BOM.SharedState.Duration[name] = spell.groupDuration
      end
    end

    -- has Spell? Manacost?
    local add = false

    if IsSpellKnown(spell.singleId) then
      add = true
      spell.singleMana = 0
      local cost = GetSpellPowerCost(spell.single)

      if type(cost) == "table" then
        for j = 1, #cost do
          if cost[j] and cost[j].name == "MANA" then
            spell.singleMana = cost[j].cost or 0
          end
        end
      end
    end

    if spell.group
            and IsSpellKnown(spell.groupId)
    then
      add = true
      spell.groupMana = 0
      local cost = GetSpellPowerCost(spell.group)

      if type(cost) == "table" then
        for j = 1, #cost do
          if cost[j] and cost[j].name == "MANA" then
            spell.groupMana = cost[j].cost or 0
          end
        end
      end
    end

    if spell.isBuff then
      if not spell.isScanned then
        local itemName, itemLink, _rarity, _ilvl, _minLevel, _itType, _itSubtype
        , _itStackCount, _itemEquipLoc, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(spell.item)

        if (not itemName or not itemLink or not itemIcon)
                and BOM.SharedState.Cache.Item[spell.item]
        then
          itemName, itemLink, itemIcon = unpack(BOM.SharedState.Cache.Item[spell.item])

        elseif (not itemName or not itemLink or not itemIcon)
                and BOM.ItemCache[spell.item]
        then
          itemName, itemLink, itemIcon = unpack(BOM.ItemCache[spell.item])
        end

        if itemName and itemLink and itemIcon then
          add = true
          spell.single = itemName
          spell.singleLink = BOM.FormatTexture(itemIcon) .. itemLink
          spell.Icon = itemIcon
          spell.isScanned = true

          BOM.SharedState.Cache.Item[spell.item] = {
            itemName, itemLink, itemIcon
          }
        else
          BOM.Print("Item not found! " ..
                  spell.single .. " " .. spell.singleId ..
                  spell.item .. "x" .. BOM.ItemCache[spell.item])
        end
      else
        add = true
      end

      if spell.items == nil then
        spell.items = { spell.item }
      end
    end -- if buff

    if spell.isInfo then
      add = true
    end

    --|--------------------------
    --| Add
    --|--------------------------
    if add then
      tinsert(BOM.SelectedSpells, spell)
      BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily, spell.groupFamily,
              spell.singleId, spell.groupId)

      if spell.cancelForm then
        BOM.Tool.iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily,
                spell.singleId, spell.groupId)
      end

      --setDefaultValues!
      for j, each_profile in ipairs(BOM.ALL_PROFILES) do
        local spell_ptr = BOM.CharacterState[each_profile].Spell[spell.ConfigID]

        if spell_ptr == nil then
          BOM.CharacterState[each_profile].Spell[spell.ConfigID] = {}
          spell_ptr = BOM.CharacterState[each_profile].Spell[spell.ConfigID]

          spell_ptr.Class = spell_ptr.Class or {}
          spell_ptr.ForcedTarget = spell_ptr.ForcedTarget or {}
          spell_ptr.ExcludedTarget = spell_ptr.ExcludedTarget or {}
          spell_ptr.Enable = spell.default or false

          if BOM.SpellHasClasses(spell) then
            local SelfCast = true
            spell_ptr.SelfCast = false

            for ci, class in ipairs(BOM.Tool.Classes) do
              spell_ptr.Class[class] = tContains(spell.classes, class)
              SelfCast = spell_ptr.Class[class] and false or SelfCast
            end

            spell_ptr.ForcedTarget = {}
            spell_ptr.ExcludedTarget = {}
            spell_ptr.SelfCast = SelfCast
          end
        else
          spell_ptr.Class = spell_ptr.Class or {}
          spell_ptr.ForcedTarget = spell_ptr.ForcedTarget or {}
          spell_ptr.ExcludedTarget = spell_ptr.ExcludedTarget or {}
        end

      end -- for all profile names
    end -- if spell is OK to be added
  end -- for all BOM-supported spells
end

---Table<UnitID: string, Table<>> with keys
---  .distance - 10k yards default
---  .unitId
---  .name
---  .group: number
---  .hasResurrection: boolean
---  .class: string
---  .link: string
---  .isTank: boolean
---  .buffs: table
local MemberCache = {}

local function bom_get_member(unitid, NameGroup, NameRole)
  local name = (UnitFullName(unitid))

  if name == nil then
    return nil
  end

  local group = NameGroup and NameGroup[name] or 1
  local isTank = NameRole and (NameRole[name] == "MAINTANK") or false

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

  MemberCache[unitid] = MemberCache[unitid] or {}

  local member = MemberCache[unitid]
  member.distance = 100000
  member.unitId = unitid
  member.name = name
  member.group = group
  member.hasResurrection = member.hasResurrection or false
  member.class = class
  member.link = link
  member.isTank = isTank
  member.buffs = member.buffs or {}

  return member
end

local PartyCache --Copy of party members, a dict of dicts

---table(duration, expirationTime, source, isSingle)
local PlayerMemberCache --Copy of player info dict

local function bom_count_members()
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

---If player just left the raid or party, reset watched frames to "watch all 8"
function BOM.MaybeResetWatchGroups()
  if UnitPlayerOrPetInParty("player") == false then
    -- We have left the party - can clear monitored groups
    local need_to_report = false

    for i = 1, 8 do
      if not BomCharacterState.WatchGroup[i] then
        BomCharacterState.WatchGroup[i] = true
        BOM.SpellSettingsFrames[i]:SetState(true)
        need_to_report = true
      end
    end

    BOM.UpdateBuffTabText()

    if need_to_report then
      BOM.Print(L.ResetWatchGroups)
    end
  end
end

---@return table - pair (party: table, player_member: table)
local function bom_get_5man_members(player_member)
  local name_group = {}
  local name_role = {}
  local party = {}
  local member

  for groupIndex = 1, 4 do
    member = bom_get_member("party" .. groupIndex)

    if member then
      tinsert(party, member)
    end

    member = bom_get_member("partypet" .. groupIndex)

    if member then
      member.group = 9
      member.class = "pet"
      tinsert(party, member)
    end
  end

  player_member = bom_get_member("player")
  tinsert(party, player_member)
  member = bom_get_member("pet")

  if member then
    member.group = 9
    member.class = "pet"
    tinsert(party, member)
  end

  return party, player_member
end

---For when player is in raid, retrieve all 40 raid members
---@return table - pair (party: table, player_member: table)
local function bom_get_40man_raid_members(player_member)
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
    local member = bom_get_member("raid" .. raid_index, name_group, name_role)

    if member then
      if UnitIsUnit(member.unitId, "player") then
        player_member = member
      end
      tinsert(party, member)

      member = bom_get_member("raidpet" .. raid_index)
      if member then
        member.group = 9
        member.class = "pet"
        tinsert(party, member)
      end
    end
  end
  return party, player_member
end

--Force updates party member buffs (vs. current player?)
local function bom_get_party_members_force_update(member, player_member)
  member.isPlayer = (member == player_member)
  member.isDead = UnitIsDeadOrGhost(member.unitId) and not UnitIsFeignDeath(member.unitId)
  member.isGhost = UnitIsGhost(member.unitId)
  member.isConnected = UnitIsConnected(member.unitId)

  member.NeedBuff = true

  wipe(member.buffs)

  BOM.SomeBodyGhost = BOM.SomeBodyGhost or member.isGhost

  if member.isDead then
    BOM.PlayerBuffs[member.name] = nil
  else
    member.hasArgentumDawn = false
    member.hasCarrot = false

    local buffIndex = 0

    repeat
      buffIndex = buffIndex + 1

      local name, icon, count, debuffType, duration, expirationTime, source, isStealable
      , nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer
      , nameplateShowAll, timeMod = BOM.UnitAura(member.unitId, buffIndex, "HELPFUL")

      spellId = BOM.SpellToSpell[spellId] or spellId

      if spellId then
        if tContains(BOM.BuffIgnoreAll, spellId) then
          wipe(member.buffs)
          member.NeedBuff = false
          break
        end

        if spellId == BOM.ArgentumDawn.spell then
          member.hasArgentumDawn = true
        end

        if spellId == BOM.Carrot.spell then
          member.hasCarrot = true
        end

        if tContains(BOM.AllSpellIds, spellId) then
          member.buffs[BOM.SpellIdtoConfig[spellId]] = {
            ["duration"]       = duration,
            ["expirationTime"] = expirationTime,
            ["source"]         = source,
            ["isSingle"]       = BOM.SpellIdIsSingle[spellId],
          }
        end
      end

    until (not name)
  end -- if is not dead
end

---Retrieve a table with party members
local function bom_get_party_members()
  -- and buffs
  local party
  local player_member --table(duration, expirationTime, source, isSingle)

  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded
          and PartyCache ~= nil
          and PlayerMemberCache ~= nil then

    if #PartyCache == bom_count_members() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(PartyCache) do
        local name = (UnitFullName(member.unitId))
        if name ~= member.name then
          ok = false
          break
        end
      end
      if ok then
        party = PartyCache
        player_member = PlayerMemberCache
      end
    end
  end

  -- read party data
  if party == nil or player_member == nil then
    if IsInRaid() then
      party, player_member = bom_get_40man_raid_members(player_member)
    else
      party, player_member = bom_get_5man_members(player_member)
    end

    if BOM.SharedState.BuffTarget
            and UnitExists("target")
            and UnitCanCooperate("player", "target") --is friendly
            and UnitIsPlayer("target") --is friendly player
            and not UnitPlayerOrPetInParty("target") --out of party or raid
            and not UnitPlayerOrPetInRaid("target")
    then
      local member = bom_get_member("target")
      if member then
        member.group = 9 --move them outside of 8 buff groups
        tinsert(party, member)
      end
    end

    PartyCache = party
    PlayerMemberCache = player_member

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

    BOM.ForceUpdate = true -- always read all buffs on new party!
  end

  BOM.PartyUpdateNeeded = false
  BOM.SomeBodyGhost = false

  local player_zone = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.DeclineHasResurrection = true
    BOM.ClearSkip()
  end

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
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId) or member.hasResurrection
    end

    if BOM.ForceUpdate then
      bom_get_party_members_force_update(member, player_member)
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

    player_member.buffs[configId] = {
      ["duration"]       = duration,
      ["expirationTime"] = GetTime() + mainHandExpiration / 1000,
      ["source"]         = "player",
      ["isSingle"]       = true,
    }
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

    player_member.buffs[-configId] = {
      ["duration"]       = duration,
      ["expirationTime"] = GetTime() + offHandExpiration / 1000,
      ["source"]         = "player",
      ["isSingle"]       = true,
    }
    player_member.OffHandBuff = configId
  else
    player_member.OffHandBuff = nil
  end

  if OldMainHandBuff ~= player_member.MainHandBuff then
    BOM.ForceUpdate = true
  end

  if OldOffHandBuff ~= player_member.OffHandBuff then
    BOM.ForceUpdate = true
  end

  BOM.DeclineHasResurrection = false

  return party, player_member
end

---Check for party, spell and player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param party table - the party
---@param spell SpellDef - the spell to update
---@param player_member table - the player
---@param someone_is_dead boolean - the flag that buffing cannot continue while someone is dead
---@return boolean - updated someone_is_dead
function bom_update_spell_targets(party, spell, player_member, someone_is_dead)
  spell.NeedMember = spell.NeedMember or {}
  spell.NeedGroup = spell.NeedGroup or {}
  spell.DeathGroup = spell.DeathGroup or {}

  wipe(spell.NeedGroup)
  wipe(spell.NeedMember)
  wipe(spell.DeathGroup)

  local SomeBodyDeath = false

  if not BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
    --nothing!
  elseif spell.isWeapon then
    if (BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable and player_member.MainHandBuff == nil)
            or (BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable and player_member.OffHandBuff == nil)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isBuff then
    if not player_member.buffs[spell.ConfigID] then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isInfo then
    spell.playerActiv = false

    for i, member in ipairs(party) do
      if member.buffs[spell.ConfigID] then
        tinsert(spell.NeedMember, member)
        if member.isPlayer then
          spell.playerActiv = true
          spell.wasPlayerActiv = true
          spell.buffSource = member.buffs[spell.ConfigID].source
        end

        if UnitIsUnit("player", member.buffs[spell.ConfigID].source or "") then
          BOM.ItemListTarget[spell.ConfigID] = member.name
        end

      end
    end
  elseif spell.isOwn then
    if not player_member.isDead then
      if spell.ItemLock then
        if IsSpellKnown(spell.singleId) and not (BOM.HasItem(spell.ItemLock)) then
          tinsert(spell.NeedMember, player_member)
        end
      elseif not (player_member.buffs[spell.ConfigID]
              and BOM.TimeCheck(player_member.buffs[spell.ConfigID].expirationTime, player_member.buffs[spell.ConfigID].duration))
      then
        tinsert(spell.NeedMember, player_member)
      end
    end

  elseif spell.isResurrection then
    for i, member in ipairs(party) do
      if member.isDead
              and not member.hasResurrection
              and member.isConnected
              and member.group ~= 9
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        tinsert(spell.NeedMember, member)
      end
    end

  elseif spell.isTracking then
    if GetTrackingTexture() ~= spell.TrackingIcon
            and (BOM.ForceTracking == nil or BOM.ForceTracking == spell.TrackingIcon)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isAura then
    if BOM.ActivAura ~= spell.ConfigID
            and (BOM.CurrentProfile.LastAura == nil or BOM.CurrentProfile.LastAura == spell.ConfigID)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isSeal then
    if BOM.ActivSeal ~= spell.ConfigID
            and (BOM.CurrentProfile.LastSeal == nil or BOM.CurrentProfile.LastSeal == spell.ConfigID)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isBlessing then
    for i, member in ipairs(party) do
      local ok = false
      local notGroup = false

      if BOM.CurrentProfile.Spell[BOM.BLESSING_ID][member.name] == spell.ConfigID
              or (member.isTank
              and BOM.CurrentProfile.Spell[spell.ConfigID].Class["tank"]
              and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast)
      then
        ok = true
        notGroup = true

      elseif BOM.CurrentProfile.Spell[BOM.BLESSING_ID][member.name] == nil then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Class[member.class]
                and (not IsInRaid() or BomCharacterState.WatchGroup[member.group])
                and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
          ok = true
        end
        if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast and UnitIsUnit(member.unitId, "player") then
          ok = true
        end
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        local found = false

        if member.isDead then
          if member.group ~= 9 and member.class ~= "pet" then
            SomeBodyDeath = true
            spell.DeathGroup[member.class] = true
          end

        elseif member.buffs[spell.ConfigID] then
          found = BOM.TimeCheck(member.buffs[spell.ConfigID].expirationTime, member.buffs[spell.ConfigID].duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          if not notGroup then
            spell.NeedGroup[member.class] = (spell.NeedGroup[member.class] or 0) + 1
          end
        elseif not notGroup
                and BOM.SharedState.ReplaceSingle
                and member.buffs[spell.ConfigID]
                and member.buffs[spell.ConfigID].isSingle then
          spell.NeedGroup[member.class] = (spell.NeedGroup[member.class] or 0) + 1
        end

      end
    end

  else
    --spells
    for i, member in ipairs(party) do
      local ok = false
      local profile_spell = BOM.CurrentProfile.Spell[spell.ConfigID]

      if profile_spell.Class[member.class]
              and (not IsInRaid() or BomCharacterState.WatchGroup[member.group])
              and not profile_spell.SelfCast then
        ok = true
      end
      if profile_spell.SelfCast
              and UnitIsUnit(member.unitId, "player") then
        ok = true
      end
      if profile_spell.ForcedTarget[member.name] then
        ok = true
      end
      if member.isTank and profile_spell.Class["tank"]
              and not profile_spell.SelfCast then
        ok = true
      end
      if profile_spell.ExcludedTarget[member.name] then
        ok = false
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        local found = false

        if member.isDead then
          SomeBodyDeath = true
          spell.DeathGroup[member.group] = true

        elseif member.buffs[spell.ConfigID] then
          found = BOM.TimeCheck(member.buffs[spell.ConfigID].expirationTime, member.buffs[spell.ConfigID].duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          spell.NeedGroup[member.group] = (spell.NeedGroup[member.group] or 0) + 1
        elseif BOM.SharedState.ReplaceSingle
                and member.buffs[spell.ConfigID]
                and member.buffs[spell.ConfigID].isSingle
        then
          spell.NeedGroup[member.group] = (spell.NeedGroup[member.group] or 0) + 1
        end
      end -- if needbuff and connected and samezone
    end -- for all in party
  end

  -- Check Spell CD
  if spell.hasCD and #spell.NeedMember > 0 then
    local startTime, duration = GetSpellCooldown(spell.singleId)
    if duration ~= 0 then
      wipe(spell.NeedGroup)
      wipe(spell.NeedMember)
      wipe(spell.DeathGroup)
      startTime = startTime + duration

      if BOM.MinTimer > startTime then
        BOM.MinTimer = startTime
      end

      SomeBodyDeath = false
    end
  end

  return SomeBodyDeath
end

---Updates the BOM macro
---@param member table - next target to buff
---@param spellId number - spell to cast
---@param command string - bag command
function BOM.UpdateMacro(member, spellId, command)
  if (GetMacroInfo(BOM.MACRO_NAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar = nil

    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      BOM.Print(L.MsgNeedOneMacroSlot)
      return
    end

    CreateMacro(BOM.MACRO_NAME, BOM.MACRO_ICON, "", isChar)
  end

  local macroText, icon
  if member and spellId then

    --Downgrade-Check
    local spell = BOM.ConfigToSpell[spellId]
    local rank = ""

    if spell == nil then
      print("NIL SPELL:", spellId)
    end

    if BOM.SharedState.UseRank or member.unitId == "target" then
      local level = UnitLevel(member.unitId)

      if spell and level ~= nil and level > 0 then
        local x

        if spell.singleFamily and tContains(spell.singleFamily, spellId) then
          x = spell.singleFamily
        elseif spell.groupFamily and tContains(spell.groupFamily, spellId) then
          x = spell.groupFamily
        end

        if x then
          local newSpellId
          --print("Dodowngrade",spell.DownGrade[member.name])
          for i, id in ipairs(x) do
            --print(id)
            if BOM.SharedState.SpellGreatherEqualThan[id] == nil or BOM.SharedState.SpellGreatherEqualThan[id] < level then
              newSpellId = id
            else
              break
            end
            if id == spellId then
              break
            end
            --print(newSpellId,spellId,"Set")
          end
          spellId = newSpellId or spellId
        end
      end -- if spell and level

      rank = GetSpellSubtext(spellId) or ""

      if rank ~= "" then
        rank = "(" .. rank .. ")"
      end
    end

    BOM.CastFailedSpellId = spellId
    local name = GetSpellInfo(spellId)

    macroText = "#showtooltip\n/bom update\n" ..
            (tContains(BOM.cancelForm, spellId) and "/cancelform [nocombat]\n" or "") ..
            "/bom _checkforerror\n" ..
            "/cast [@" .. member.unitId .. ",nocombat]" .. name .. rank .. "\n"
    icon = BOM.MACRO_ICON
  else
    macroText = "#showtooltip\n/bom update\n"
    if command then
      macroText = macroText .. command
    end
    icon = BOM.MACRO_ICON_DISABLED
  end

  EditMacro(BOM.MACRO_NAME, nil, icon, macroText)
  BOM.MinimapButton.SetTexture("Interface\\ICONS\\" .. icon)
end

local function bom_get_group_in_range(SpellName, party, groupNb, spell)
  local minDist
  local ret = nil
  for i, member in ipairs(party) do
    if member.group == groupNb then
      if not (IsSpellInRange(SpellName, member.unitId) == 1 or member.isDead) then
        if member.distance > 2000 then
          return nil
        end
      elseif (minDist == nil or member.distance < minDist)
              and not tContains(spell.SkipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end
  end

  return ret
end

---Return list of members of class in spell range
---@param spell_name string
---@param party table
---@param class string
---@param spell SpellDef
local function bom_get_class_in_range(spell_name, party, class, spell)
  local minDist
  local ret = nil

  for i, member in ipairs(party) do
    if member.class == class then
      if member.isDead then
        return nil

      elseif not (IsSpellInRange(spell_name, member.unitId) == 1) then
        if member.distance > 2000 then
          return nil
        end

      elseif (minDist == nil or member.distance < minDist)
              and not tContains(spell.SkipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end -- if class
  end

  return ret
end

function BOM.TimeCheck(ti, duration)
  if ti == nil or duration == nil or ti == 0 or duration == 0 then
    return true
  end

  local dif

  if duration <= 60 then
    dif = BOM.SharedState.Time60
  elseif duration <= 300 then
    dif = BOM.SharedState.Time300
  elseif duration <= 600 then
    dif = BOM.SharedState.Time600
  elseif duration <= 1800 then
    dif = BOM.SharedState.Time1800
  else
    dif = BOM.SharedState.Time3600
  end

  if dif + GetTime() < ti then
    ti = ti - dif
    if ti < BOM.MinTimer then
      BOM.MinTimer = ti
    end
    return true
  end

  return false
end

---@type table - pairs of [1]=text, [2]=distance - list of all strings to be displayed
local bom_messages_cache = {}
---@type table - list of text strings to be displayed (spell and target)
local bom_cast_messages = {}
---@type table - list of info strings to be displayed (yellow)
local bom_info_messages = {}
---@type number - index to insert another line
local bom_insert_index

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param text string - Text to display
---@param distance number - Distance
---@param isInfo boolean - Whether the text is info text
local function bom_display_text(text, distance, isInfo)
  bom_insert_index = bom_insert_index + 1
  bom_messages_cache[bom_insert_index] = bom_messages_cache[bom_insert_index] or {}
  bom_messages_cache[bom_insert_index][1] = text
  bom_messages_cache[bom_insert_index][2] = distance

  if not isInfo then
    tinsert(bom_cast_messages, bom_messages_cache[bom_insert_index])
  else
    tinsert(bom_info_messages, bom_messages_cache[bom_insert_index])
  end
end

---Clear the cached text, and clear the message frame
local function bom_clear_display_cache()
  BomC_ListTab_MessageFrame:Clear()
  bom_insert_index = 0
  wipe(bom_cast_messages)
  wipe(bom_info_messages)
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
local function bom_display_text_in_messageframe()
  table.sort(bom_cast_messages, function(a, b)
    return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  end)

  table.sort(bom_info_messages, function(a, b)
    return a[1] > b[1]
  end)

  for i, txt in ipairs(bom_info_messages) do
    BomC_ListTab_MessageFrame:AddMessage(txt[1])
  end

  for i, txt in ipairs(bom_cast_messages) do
    BomC_ListTab_MessageFrame:AddMessage(txt[1])
  end
end

local next_cast_spell = {}
local player_mana

---Stores a spell with cost/id/spell link to be casted in the `cast` global
---@param cost number - Resource cost (mana cost)
---@param id number - Spell id to capture
---@param link string
---@param member table
---@param spell SpellDef - Spell to capture
local function bom_catch_a_spell(cost, id, link, member, spell)
  if cost > player_mana then
    return -- ouch
  end

  if not spell.isResurrection and member.isDead then
    -- Cannot cast resurrections on deads
    return
  elseif next_cast_spell.Spell and not spell.isTracking then
    if next_cast_spell.Spell.isTracking then
      return
    elseif spell.isResurrection then
      --------------------
      -- If resurrection
      --------------------
      if next_cast_spell.Spell.isResurrection then
        if (tContains(BOM.RESURRECT_CLASS, next_cast_spell.Member.class) and not tContains(BOM.RESURRECT_CLASS, member.class))
                or (tContains(BOM.MANA_CLASSES, next_cast_spell.Member.class) and not tContains(BOM.MANA_CLASSES, member.class))
                or (not next_cast_spell.Member.isGhost and member.isGhost)
                or (next_cast_spell.Member.distance < member.distance) then
          return
        end
      end
    else
      if (BOM.SharedState.SelfFirst and next_cast_spell.Member.isPlayer and not member.isPlayer)
              or (next_cast_spell.Member.group ~= 9 and member.group == 9) then
        return
      elseif (not BOM.SharedState.SelfFirst or (next_cast_spell.Member.isPlayer == member.isPlayer))
              and ((next_cast_spell.Member.group == 9) == (member.group == 9))
              and next_cast_spell.manaCost > cost then
        return
      end
    end
  end

  next_cast_spell.manaCost = cost
  next_cast_spell.SpellId = id
  next_cast_spell.Link = link
  next_cast_spell.Member = member
  next_cast_spell.Spell = spell
end

---Cleares the spell from `cast` global
local function bom_clear_spell()
  next_cast_spell.manaCost = -1
  next_cast_spell.SpellId = nil
  next_cast_spell.Member = nil
  next_cast_spell.Spell = nil
  next_cast_spell.Link = nil
end

---Based on profile settings and current PVE or PVP instance choose the mode
---of operation
---@return table - (is_bom_disabled boolean, auto_profile string)
local function bom_choose_profile()
  local in_instance, instance_type = IsInInstance()
  local is_bom_disabled
  local auto_profile = "solo"

  if IsInRaid() then
    auto_profile = "raid"
  elseif IsInGroup() then
    auto_profile = "group"
  end

  if instance_type == "pvp" or instance_type == "arena" then
    is_bom_disabled = not BOM.SharedState.InPVP
    auto_profile = "battleground"

  elseif instance_type == "party"
          or instance_type == "raid"
          or instance_type == "scenario"
  then
    is_bom_disabled = not BOM.SharedState.InInstance
  else
    is_bom_disabled = not BOM.SharedState.InWorld
  end

  if BOM.ForceProfile then
    auto_profile = BOM.ForceProfile
  end

  if not BOM.CharacterState.UseProfiles then
    auto_profile = "solo"
  end

  return is_bom_disabled, auto_profile
end

---@param party table - the party
---@param player_member table - the player
local function bom_force_update(party, player_member)
  --reset tracking
  BOM.ForceTracking = nil

  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.isTracking then
      if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
        if spell.needForm ~= nil then
          if GetShapeshiftFormID() == spell.needForm
                  and BOM.ForceTracking ~= spell.TrackingIcon then
            BOM.ForceTracking = spell.TrackingIcon
            BOM.UpdateSpellsTab()
          end
        elseif GetTrackingTexture() == spell.TrackingIcon
                and BOM.CharacterState.LastTracking ~= spell.TrackingIcon then
          BOM.CharacterState.LastTracking = spell.TrackingIcon
          BOM.UpdateSpellsTab()
        end
      else
        if BOM.CharacterState.LastTracking == spell.TrackingIcon
                and BOM.CharacterState.LastTracking ~= nil then
          BOM.CharacterState.LastTracking = nil
          BOM.UpdateSpellsTab()
        end
      end -- if spell.enable
    end -- if tracking
  end -- for all spells

  if BOM.ForceTracking == nil then
    BOM.ForceTracking = BOM.CharacterState.LastTracking
  end

  --find activ aura / seal
  BOM.ActivAura = nil
  BOM.ActivSeal = nil

  for i, spell in ipairs(BOM.SelectedSpells) do
    if player_member.buffs[spell.ConfigID] then
      if spell.isAura then
        if (BOM.ActivAura == nil and BOM.LastAura == spell.ConfigID)
                or UnitIsUnit(player_member.buffs[spell.ConfigID].source, "player")
        then
          if BOM.TimeCheck(player_member.buffs[spell.ConfigID].expirationTime, player_member.buffs[spell.ConfigID].duration) then
            BOM.ActivAura = spell.ConfigID
          end
        end

      elseif spell.isSeal then
        if UnitIsUnit(player_member.buffs[spell.ConfigID].source, "player") then
          if BOM.TimeCheck(player_member.buffs[spell.ConfigID].expirationTime, player_member.buffs[spell.ConfigID].duration) then
            BOM.ActivSeal = spell.ConfigID
          end
        end
      end -- if is aura
    end -- if player.buffs[config.id]
  end -- for all spells

  --reset aura/seal
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.isAura then
      if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
        if BOM.ActivAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= spell.ConfigID then
          BOM.CurrentProfile.LastAura = spell.ConfigID
          BOM.UpdateSpellsTab()
        end
      else
        if BOM.CurrentProfile.LastAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= nil then
          BOM.CurrentProfile.LastAura = nil
          BOM.UpdateSpellsTab()
        end
      end -- if currentprofile.spell.enable

    elseif spell.isSeal then
      if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
        if BOM.ActivSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= spell.ConfigID then
          BOM.CurrentProfile.LastSeal = spell.ConfigID
          BOM.UpdateSpellsTab()
        end
      else
        if BOM.CurrentProfile.LastSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= nil then
          BOM.CurrentProfile.LastSeal = nil
          BOM.UpdateSpellsTab()
        end
      end -- if currentprofile.spell.enable
    end -- if is aura
  end

  -- who needs a buff!
  -- for each spell update spell potential targets
  local someone_is_dead = false -- the flag that buffing cannot continue while someone is dead
  for i, spell in ipairs(BOM.SelectedSpells) do
    someone_is_dead = bom_update_spell_targets(party, spell, player_member, someone_is_dead)
  end

  bom_save_someone_is_dead = someone_is_dead
  return someone_is_dead
end

local function bom_cancel_buffs(player_member)
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and not spell.OnlyCombat
    then
      if player_member.buffs[spell.ConfigID] then
        BOM.Print(string.format(
                L.MsgCancelBuff, spell.singleLink or spell.single,
                UnitName(player_member.buffs[spell.ConfigID].source or "") or ""))
        BOM.CancelBuff(spell.singleFamily)
      end
    end
  end
end

---Whisper to the spell caster when the buff expired on yourself
local function bom_whisper_expired(spell)
  if spell.wasPlayerActiv and not spell.playerActiv then
    spell.wasPlayerActiv = false

    local name = UnitName(spell.buffSource or "")

    if name then
      BOM.Print(string.format(L.MsgSpellExpired, spell.single),
              "WHISPER",
              nil,
              name)
    end
  end
end

---Add a paladin blessing
---@param spell SpellDef - spell to cast
---@param player_member table - player
---@param in_range boolean - spell target is in range
local function bom_add_blessing(spell, player_member, in_range)
  local ok, bag, slot, count
  if spell.NeededGroupItem then
    ok, bag, slot, count = BOM.HasItem(spell.NeededGroupItem, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  if spell.groupMana ~= nil
          and not BOM.SharedState.NoGroupBuff
  then
    for i, groupIndex in ipairs(BOM.Tool.Classes) do
      if spell.NeedGroup[groupIndex]
              and spell.NeedGroup[groupIndex] >= BOM.SharedState.MinBlessing
      then
        BOM.RepeatUpdate = true
        local class_in_range = bom_get_class_in_range(spell.group, spell.NeedMember, groupIndex, spell)

        if class_in_range == nil then
          class_in_range = bom_get_class_in_range(spell.group, party, groupIndex, spell)
        end

        if class_in_range ~= nil
                and (not spell.DeathGroup[member.group] or not BOM.SharedState.DeathBlock)
        then
          bom_display_text(
                  string.format(L["FORMAT_BUFF_GROUP"],
                          "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r",
                          (spell.groupLink or spell.group))
                          .. count,
                  "!" .. groupIndex)
          in_range = true

          bom_catch_a_spell(spell.groupMana, spell.groupId, spell.groupLink, class_in_range, spell)
        else
          bom_display_text(string.format(L["FORMAT_BUFF_GROUP"], BOM.Tool.ClassName[groupIndex], spell.group .. count), "!" .. groupIndex)
        end
      end -- if needgroup >= minblessing
    end -- for all classes
  end

  -- SINGLE BUFF
  for memberIndex, member in ipairs(spell.NeedMember) do
    if not member.isDead
            and spell.singleMana ~= nil
            and (BOM.SharedState.NoGroupBuff
            or spell.groupMana == nil
            or member.class == "pet"
            or spell.NeedGroup[member.class] == nil
            or spell.NeedGroup[member.class] < BOM.SharedState.MinBlessing) then

      if not member.isPlayer then
        BOM.RepeatUpdate = true
      end

      local add = ""
      if BOM.CurrentProfile.Spell[BOM.BLESSING_ID][member.name] ~= nil then
        add = string.format(BOM.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local test_in_range = (IsSpellInRange(spell.single, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if test_in_range then
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], add .. member.link, spell.singleLink),
                member.name)

        in_range = true

        bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], add .. member.name, spell.single),
                member.name)
      end -- if in range
    end -- if not dead
  end -- for all NeedMember
end

---Add a paladin blessing
---@param spell SpellDef - spell to cast
---@param party table - the party
---@param player_member table - player
---@param in_range boolean - spell target is in range
local function bom_add_buff(spell, party, player_member, in_range)
  local ok, bag, slot, count

  if spell.NeededGroupItem then
    ok, bag, slot, count = BOM.HasItem(spell.NeededGroupItem, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  --Group buff
  if spell.groupMana ~= nil and not BOM.SharedState.NoGroupBuff then
    for group_index = 1, 8 do
      if spell.NeedGroup[group_index]
              and spell.NeedGroup[group_index] >= BOM.SharedState.MinBuff
      then
        BOM.RepeatUpdate = true
        local Group = bom_get_group_in_range(spell.group, spell.NeedMember, group_index, spell)

        if Group == nil then
          Group = bom_get_group_in_range(spell.group, party, group_index, spell)
        end

        if Group ~= nil
                and (not spell.DeathGroup[group_index] or not BOM.SharedState.DeathBlock)
        then
          bom_display_text(string.format(L["FORMAT_BUFF_GROUP"], group_index, (spell.groupLink or spell.group) .. count),
                  "!" .. group_index)
          in_range = true

          bom_catch_a_spell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)

        else
          bom_display_text(string.format(L["FORMAT_BUFF_GROUP"], group_index, spell.group .. count),
                  "!" .. group_index)
        end -- if group not nil
      end
    end -- for all 8 groups
  end

  -- SINGLE BUFF
  for memberIndex, member in ipairs(spell.NeedMember) do
    if not member.isDead
            and spell.singleMana ~= nil
            and (BOM.SharedState.NoGroupBuff
            or spell.groupMana == nil
            or member.group == 9
            or spell.NeedGroup[member.group] == nil
            or spell.NeedGroup[member.group] < BOM.SharedState.MinBuff)
    then
      if not member.isPlayer then
        BOM.RepeatUpdate = true
      end

      local add = ""
      if BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget[member.name] then
        add = string.format(BOM.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if isInRange then
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], add .. member.link, spell.singleLink),
                member.name)
        in_range = true
        bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], add .. member.name, spell.single),
                member.name)
      end
    end
  end -- for all spell.needmember

  return in_range
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param player_member table - the player
---@param in_range boolean - value for range check
---@return table (bag_title string, bag_command string)
local function bom_add_resurrection(spell, player_member, in_range)
  local clearskip = true

  for memberIndex, member in ipairs(spell.NeedMember) do
    if not tContains(spell.SkipList, member.name) then
      clearskip = false
      break
    end
  end

  if clearskip then
    wipe(spell.SkipList)
  end

  --Prefer resurrection classes first
  --TODO: This also modifies all subsequent operations on this table preferring those classes first
  table.sort(spell.NeedMember, function(a, b)
    local a_resser = tContains(BOM.RESURRECT_CLASS, a.class)
    local b_resser = tContains(BOM.RESURRECT_CLASS, b.class)
    if a_resser then
      return not b_resser
    end
    return false
  end)

  for memberIndex, member in ipairs(spell.NeedMember) do
    if not tContains(spell.SkipList, member.name) then
      BOM.RepeatUpdate = true

      -- Is the body in range?
      local is_in_range = (IsSpellInRange(spell.single, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if is_in_range then
        in_range = true
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], member.link, spell.singleLink),
                member.name)
      else
        bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], member.name, spell.single),
                member.name)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if is_in_range or (BOM.SharedState.ResGhost and member.isGhost) then
        bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      end
    end
  end

  return in_range
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell SpellDef - the spell to cast
---@param player_member table - the player
---@param bag_title string - if not empty, is item name from the bag
---@param bag_command string - console command to use item from the bag
---@return table (bag_title string, bag_command string)
local function bom_add_self_buff(spell, player_member)
  if (not spell.NeedOutdoors or IsOutdoors())
          and not tContains(spell.SkipList, player_member.name) then
    bom_display_text(
            string.format(L["FORMAT_BUFF_SINGLE"], player_member.link, spell.singleLink),
            player_member.name)
    inRange = true

    bom_catch_a_spell(
            spell.singleMana, spell.singleId, spell.singleLink,
            player_member, spell)
  else
    bom_display_text(string.format(L["FORMAT_BUFF_SINGLE"], player_member.name, spell.single),
            player_member.name)
  end
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param player_member table - the player
---@param bag_title string - if not empty, is item name from the bag
---@param bag_command string - console command to use item from the bag
---@return table (bag_title string, bag_command string)
local function bom_add_regular_buff(spell, player_member, bag_title, bag_command)
  local ok, bag, slot, count = BOM.HasItem(spell.items, true)
  count = count or 0

  if ok then
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)

    if BOM.SharedState.DontUseConsumables
            and not IsModifierKeyDown() then
      bom_display_text(
              BOM.FormatTexture(texture)
                      .. item_link .. "x" .. count,
              player_member.distance,
              true)
    else
      bag_title = BOM.FormatTexture(texture) .. item_link .. "x" .. count
      bag_command = "/use " .. bag .. " " .. slot
      bom_display_text(bag_title, player_member.distance, true)
    end

    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    bom_display_text(spell.single .. "x" .. count,
            player_member.distance,
            true)
  end

  return bag_title, bag_command
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param player_member table - the player
---@param bag_title string - if not empty, is item name from the bag
---@param bag_command string - console command to use item from the bag
---@return table (bag_title string, bag_command string)
local function bom_add_weapon_buff(spell, player_member, bag_title, bag_command)
  -- count - reagent count remaining for the spell
  local ok, bag, slot, count = BOM.HasItem(spell.items, true)
  count = count or 0

  if ok then
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)

    if BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable
            and player_member.OffHandBuff == nil then
      if BOM.SharedState.DontUseConsumables
              and not IsModifierKeyDown() then
        bom_display_text(
                BOM.FormatTexture(texture)
                        .. item_link .. "x" .. count
                        .. " (" .. L.TooltipOffHand .. ")",
                player_member.distance,
                true)
      else
        bag_title = BOM.FormatTexture(texture)
                .. item_link .. "x" .. count .. " (" .. L.TooltipOffHand .. ")"
        bag_command = "/use " .. bag .. " " .. slot
                .. "\n/use 17" -- offhand
        bom_display_text(bag_title, player_member.distance, true)
      end
    end

    if BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable
            and player_member.MainHandBuff == nil then
      if BOM.SharedState.DontUseConsumables
              and not IsModifierKeyDown() then
        bom_display_text(
                BOM.FormatTexture(texture)
                        .. item_link .. "x" .. count
                        .. " (" .. L.TooltipMainHand .. ")",
                player_member.distance,
                true)
      else
        bag_title = BOM.FormatTexture(texture)
                .. item_link .. "x" .. count
                .. " (" .. L.TooltipMainHand .. ")"
        bag_command = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        bom_display_text(bag_title, player_member.distance, true)
      end
    end
    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    bom_display_text(spell.single .. "x" .. count,
            player_member.distance,
            true)
  end

  return bag_title, bag_command
end

---Set text and enable the cast button (or disable)
---@param t string - text for the cast button
---@param enable boolean - whether to enable the button or not
function bom_cast_button(t, enable)
  -- not really a necessary check but for safety
  if InCombatLockdown()
          or BomC_ListTab_Button == nil
          or BomC_ListTab_Button.SetText == nil then
    return
  end

  BomC_ListTab_Button:SetText(t)
  if enable then
    BomC_ListTab_Button:Enable()
  else
    BomC_ListTab_Button:Disable()
  end
end

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
function BOM.UpdateScan()
  if BOM.SelectedSpells == nil then
    return
  end

  if BOM.InLoading then
    return
  end

  BOM.MinTimer = GetTime() + 36000 -- 10 hours
  bom_clear_display_cache()
  BOM.RepeatUpdate = false

  if InCombatLockdown() then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    bom_cast_button(L.MsgCombat, true)
    return
  end

  if UnitIsDeadOrGhost("player") then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BOM.UpdateMacro()
    bom_cast_button(L.MsgDead, false)
    BOM.AutoClose()
    return
  end

  --Choose Profile
  local is_bom_disabled, auto_profile = bom_choose_profile()

  if BOM.CurrentProfile ~= BOM.CharacterState[auto_profile] then
    BOM.CurrentProfile = BOM.CharacterState[auto_profile]
    BOM.UpdateSpellsTab()
    BomC_MainWindow_Title:SetText(
            BOM.FormatTexture(BOM.MACRO_ICON_FULLPATH)
                    .. " " .. BOM.TOC_TITLE .. " - "
                    .. L["profile_" .. auto_profile])
    BOM.ForceUpdate = true
  end

  if is_bom_disabled then
    BOM.CheckForError = false
    BOM.ForceUpdate = false
    BOM.UpdateMacro()
    bom_cast_button(L.MsgDisabled, false)
    BOM.AutoClose()
    return
  end

  local party, player_member = bom_get_party_members()
  local someone_is_dead

  if BOM.ForceUpdate then
    someone_is_dead = bom_force_update(party, player_member)
  else
    someone_is_dead = bom_save_someone_is_dead
  end

  -- cancel buffs
  bom_cancel_buffs(player_member)

  -- fill list and find cast
  player_mana = UnitPower("player", 0) or 0 --mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  bom_clear_spell()

  local bag_command
  local bag_title
  local in_range = false

  BOM.ScanModifier = false

  --<<---------------------------
  for _, spell in ipairs(BOM.SelectedSpells) do
    if spell.isInfo and BOM.CurrentProfile.Spell[spell.ConfigID].Whisper then
      bom_whisper_expired(spell)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if BOM.CurrentProfile.Spell[spell.ConfigID].Enable
            and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then
      if #spell.NeedMember > 0
              and not spell.isInfo
              and not spell.isBuff
      then
        if spell.singleMana < BOM.ManaLimit
                and spell.singleMana > player_mana then
          BOM.ManaLimit = spell.singleMana
        end

        if spell.groupMana
                and spell.groupMana < BOM.ManaLimit
                and spell.groupMana > player_mana then
          BOM.ManaLimit = spell.groupMana
        end
      end

      if spell.isWeapon then
        if #spell.NeedMember > 0 then
          bag_title, bag_command = bom_add_weapon_buff(
                  spell, player_member, bag_title, bag_command)
        end

      elseif spell.isBuff then
        if #spell.NeedMember > 0 then
          bag_title, bag_command = bom_add_regular_buff(
                  spell, player_member, bag_title, bag_command)
        end

      elseif spell.isInfo then
        if #spell.NeedMember then
          for memberIndex, member in ipairs(spell.NeedMember) do
            bom_display_text(
                    string.format(L["FORMAT_BUFF_SINGLE"], member.link, spell.singleLink),
                    member.distance,
                    true)
          end
        end

      elseif spell.isTracking then
        if #spell.NeedMember > 0 then
          if not BOM.PlayerCasting then
            CastSpellByID(spell.singleId)
          else
            bom_display_text(
                    string.format(L["FORMAT_BUFF_SINGLE"], player_member.name, spell.single),
                    player_member.name)
          end
        end

      elseif (spell.isOwn
              or spell.isTracking
              or spell.isAura
              or spell.isSeal)
      then
        if #spell.NeedMember > 0 then
          bom_add_self_buff(spell, player_member)
        end

      elseif spell.isResurrection then
        in_range = bom_add_resurrection(spell, player_member, in_range)

      elseif spell.isBlessing then
        in_range = bom_add_blessing(spell, player_member, in_range)

      else
        in_range = bom_add_buff(spell, party, player_member, in_range)
      end
    end
  end -- for all selected spells
  -->>--------------------------

  -- check argent dawn
  do
    local name, instanceType, difficultyID, difficultyName, maxPlayers
    , dynamicDifficulty, isDynamic, instanceID, instanceGroupSize
    , LfgDungeonID = GetInstanceInfo()

    if BOM.SharedState.ArgentumDawn then
      -- settings to remind to remove AD trinket != instance compatible with AD Commission
      if player_member.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.dungeon, instanceID) then
        bom_display_text(BOM.ArgentumDawn.Link, player_member.distance, true)
      end
    end

    if BOM.SharedState.Carrot then
      if player_member.hasCarrot and not tContains(BOM.Carrot.dungeon, instanceID) then
        bom_display_text(BOM.Carrot.Link, player_member.distance, true)
      end
    end
  end

  -- enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges
  , offHandEnchantId = GetWeaponEnchantInfo()

  if BOM.SharedState.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

    if link then
      bom_display_text(link, player_member.distance, true)
    end
  end

  if BOM.SharedState.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))

    if link then
      bom_display_text(link, player_member.distance, true)
    end
  end

  --itemcheck
  local ItemList = BOM.GetItemList()

  for i, item in ipairs(ItemList) do
    local ok = false
    local target = nil

    if item.CD then
      if (item.CD[1] or 0) ~= 0 then
        local ti = item.CD[1] + item.CD[2] - GetTime() + 1
        if ti < BOM.MinTimer then
          BOM.MinTimer = ti
        end
      elseif item.Link then
        ok = true

        if BOM.ItemListSpell[item.ID] then
          if BOM.ItemListTarget[BOM.ItemListSpell[item.ID]] then
            target = BOM.ItemListTarget[BOM.ItemListSpell[item.ID]]
          end
        end

      end
    elseif item.Lootable then
      ok = true
    end

    if ok then
      bag_title = BOM.FormatTexture(item.Texture)
              .. item.Link
              .. (target and (" @" .. target) or "")
      bag_command = (target and ("/target " .. target .. "/n") or "")
              .. "/use " .. item.Bag .. " " .. item.Slot
      bom_display_text(bag_title, player_member.distance, true)

      if BOM.SharedState.DontUseConsumables and not IsModifierKeyDown() then
        bag_command = nil
        bag_title = nil
      end
      BOM.ScanModifier = BOM.SharedState.DontUseConsumables
    end
  end

  if #bom_cast_messages > 0
          or #bom_info_messages > 0 then
    BOM.AutoOpen()
  else
    BOM.AutoClose()
  end

  bom_display_text_in_messageframe()

  BOM.ForceUpdate = false

  if BOM.PlayerCasting then
    --Print player is busy (casting)
    bom_cast_button(L.MsgBusy, false)
    BOM.UpdateMacro()

  elseif next_cast_spell.Member and next_cast_spell.SpellId then
    --Next cast is already defined - update the button text
    --bom_cast_button(
    --        string.format(L["MsgNextCast"],
    --                next_cast_spell.Link,
    --                next_cast_spell.Member.link),
    --        true)
    bom_cast_button(next_cast_spell.Link, true)

    BOM.UpdateMacro(next_cast_spell.Member, next_cast_spell.SpellId)

    local cdtest = GetSpellCooldown(next_cast_spell.SpellId) or 0

    if cdtest ~= 0 then
      BOM.CheckCoolDown = next_cast_spell.SpellId
      BomC_ListTab_Button:Disable()
    else
      BomC_ListTab_Button:Enable()
    end

    BOM.CastFailedSpell = next_cast_spell.Spell
    BOM.CastFailedSpellTarget = next_cast_spell.Member
  else
    if #bom_cast_messages == 0 then
      --If don't have any strings to display, and nothing to do -
      --Clear the cast button
      bom_cast_button(L.MsgEmpty, true)

      for spellIndex, spell in ipairs(BOM.SelectedSpells) do
        if #spell.SkipList > 0 then
          wipe(spell.SkipList)
        end
      end

    else
      if someone_is_dead and BOM.SharedState.DeathBlock then
        bom_cast_button(L.MsgSomebodyDead, false)
      else
        if in_range then
          bom_cast_button(ERR_OUT_OF_MANA, false)
        else
          bom_cast_button(ERR_SPELL_OUT_OF_RANGE, false)
          local skipreset = false

          for spellIndex, spell in ipairs(BOM.SelectedSpells) do
            if #spell.SkipList > 0 then
              skipreset = true
              wipe(spell.SkipList)
            end
          end

          if skipreset then
            BOM.FastUpdateTimer()
            BOM.ForceUpdate = true
          end
        end -- if inrange
      end -- if somebodydeath and deathblock
    end -- if #display == 0

    if bag_title then
      bom_cast_button(bag_title, true)
    end

    BOM.UpdateMacro(nil, nil, bag_command)
  end -- if not player casting

end -- end function UpdateScan()

---If a spell cast failed, the member is temporarily added to skip list, to
---continue casting buffs on other members
function BOM.AddMemberToSkipList()
  if BOM.CastFailedSpell
          and BOM.CastFailedSpell.SkipList
          and BOM.CastFailedSpellTarget then
    tinsert(BOM.CastFailedSpell.SkipList, BOM.CastFailedSpellTarget.name)
    BOM.FastUpdateTimer()
    BOM.ForceUpdate = true
  end
end

function BOM.DownGrade()
  if BOM.CastFailedSpell
          and BOM.CastFailedSpell.SkipList
          and BOM.CastFailedSpellTarget then
    local level = UnitLevel(BOM.CastFailedSpellTarget.unitId)

    if level ~= nil and level > -1 then
      if BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] == nil
              or BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] < level
      then
        BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] = level
        BOM.FastUpdateTimer()
        BOM.ForceUpdate = true
        BOM.Print(string.format(L.MsgDownGrade,
                BOM.CastFailedSpell.single,
                BOM.CastFailedSpellTarget.name))

      elseif BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] >= level then
        BOM.AddMemberToSkipList()
      end
    else
      BOM.AddMemberToSkipList()
    end
  end
end

function BOM.ClearSkip()
  for spellIndex, spell in ipairs(BOM.SelectedSpells) do
    if spell.SkipList then
      wipe(spell.SkipList)
    end
  end
end

function BOM.BattleCancelBuffs()
  if BOM.SelectedSpells == nil or BOM.CurrentProfile == nil then
    return
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and BOM.CancelBuff(spell.singleFamily)
    then
      BOM.Print(string.format(L.MsgCancelBuff, spell.singleLink or spell.single,
              UnitName(BOM.CancelBuffSource) or ""))
    end
  end
end

function BOM.SpellHasClasses(spell)
  return not (spell.isBuff
          or spell.isOwn
          or spell.isResurrection
          or spell.isSeal
          or spell.isTracking
          or spell.isAura
          or spell.isInfo)
end
