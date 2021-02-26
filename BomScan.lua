local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

local MAXMANA = 999999

BOM.ProfileNames = { "solo", "group", "raid", "battleground" }

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

function BOM.HasItem(list, cd)
  local key = list[1] .. (cd and "CD" or "")
  local x = BOM.CachedHasItems[key]
  if not x then
    BOM.CachedHasItems[key] = {}
    x = BOM.CachedHasItems[key]
    x.a = false
    x.d = 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

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

local _GetItemListCached = {}

function BOM.GetItemList()
  if BOM.WipeCachedItems then
    wipe(_GetItemListCached)
    BOM.WipeCachedItems = false

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)

        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        for iList, list in ipairs(BOM.ItemList) do
          if tContains(list, itemID) then
            tinsert(_GetItemListCached, { Index = iList, ID = itemID, CD = { }, Link = itemLink, Bag = bag, Slot = slot, Texture = icon })
          end
        end

        if lootable and BOM.DB.OpenLootable then
          local locked = false
          for i, text in ipairs(BOM.Tool.ScanToolTip("SetBagItem", bag, slot)) do
            if text == LOCKED then
              locked = true
              break
            end
          end
          if not locked then
            tinsert(_GetItemListCached, { Index = 0, ID = itemID, CD = nil, Link = itemLink, Bag = bag, Slot = slot, Lootable = true, Texture = icon })
          end

        end

      end
    end
  end

  --Update CD
  for i, items in ipairs(_GetItemListCached) do
    if items.CD then
      items.CD = { GetContainerItemCooldown(items.Bag, items.Slot) }
    end
  end

  return _GetItemListCached
end

local function format_spell_link(spellId, icon, name, rank)
  --local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  if spellId == nil then
    return "NIL SPELLID"
  else
    rank = rank or "MISSING RANK"
    name = name or "MISSING NAME"
    icon = icon or "MISSING ICON"
    if rank ~= "" then
      rank = "(" .. rank .. ")"
    end
    rank = ""
    return "|Hspell:" .. spellId .. "|h|r |cff71d5ff" .. string.format(BOM.TxtEscapeIcon, icon) .. name .. rank .. "|r|h"
  end
end

---Unused? TODO: Rename to lower_case
local function SpellLink(spell)
  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  return format_spell_link(spellId, icon, name)
end

local SpellsIncluded = false

function BOM.GetSpells()
  for i, profil in ipairs(BOM.ProfileNames) do
    BOM.DBChar[profil].Spell = BOM.DBChar[profil].Spell or {}
    BOM.DBChar[profil].CancelBuff = BOM.DBChar[profil].CancelBuff or {}
    BOM.DBChar[profil].Spell[BOM.BLESSINGID] = BOM.DBChar[profil].Spell[BOM.BLESSINGID] or {}
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

  BOM.DB.Cache = BOM.DB.Cache or {}
  BOM.DB.Cache.Item = BOM.DB.Cache.Item or {}

  if BOM.ArgentumDawn.Link == nil
          or BOM.Carrot.Link == nil then
    do
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.ArgentumDawn.spell)
      BOM.ArgentumDawn.Link = format_spell_link(spellId, icon, name, rank)
      name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.Carrot.spell)
      BOM.Carrot.Link = format_spell_link(spellId, icon, name, rank)
    end
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    -- save "ConfigID"
    spell.ConfigID = spell.ConfigID or spell.singleId

    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
      end
    end

    -- GetSpellNames and set default duration
    local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.singleId)
    spell.single = name
    rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = format_spell_link(spellId, icon, name, rank)
    spell.Icon = icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for i, profil in ipairs(BOM.ProfileNames) do
      if BOM.DBChar[profil].CancelBuff[spell.ConfigID] == nil then
        BOM.DBChar[profil].CancelBuff[spell.ConfigID] = {}
        BOM.DBChar[profil].CancelBuff[spell.ConfigID].Enable = spell.default or false
      end
    end
  end

  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    if type(spell) == "table" then
      -- save "ConfigID"
      spell.ConfigID = spell.ConfigID or spell.singleId
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
        spell.singleLink = format_spell_link(spellId, icon, name, rank)
        spell.Icon = icon

        if spell.isTracking then
          spell.TrackingIcon = icon
        end

        if not spell.isInfo
                and not spell.isBuff
                and spell.singleDuration
                and BOM.DB.Duration[name] == nil
                and IsSpellKnown(spell.singleId) then
          BOM.DB.Duration[name] = spell.singleDuration
        end
      end

      if spell.groupId then
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.groupId)
        spell.group = name
        rank = GetSpellSubtext(spell.groupId) or ""
        spell.groupLink = format_spell_link(spellId, icon, name, rank)

        if spell.groupDuration
                and BOM.DB.Duration[name] == nil
                and IsSpellKnown(spell.groupId)
        then
          BOM.DB.Duration[name] = spell.groupDuration
        end
      end

      -- has Spell? Manacost?
      local add = false

      if IsSpellKnown(spell.singleId) then
        add = true
        spell.singleMana = 0
        local cost = GetSpellPowerCost(spell.single)

        if type(cost) == "table" then
          for i = 1, #cost do
            if cost[i] and cost[i].name == "MANA" then
              spell.singleMana = cost[i].cost or 0
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
          for i = 1, #cost do
            if cost[i] and cost[i].name == "MANA" then
              spell.groupMana = cost[i].cost or 0
            end
          end
        end
      end

      if spell.isBuff then
        if not spell.isScanned then
          local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(spell.item)

          if (not itemName or not itemLink or not itemIcon) and BOM.DB.Cache.Item[spell.item] then
            itemName, itemLink, itemIcon = unpack(BOM.DB.Cache.Item[spell.item])
          elseif (not itemName or not itemLink or not itemIcon) and BOM.ItemCache[spell.item] then
            itemName, itemLink, itemIcon = unpack(BOM.ItemCache[spell.item])
          end

          if itemName and itemLink and itemIcon then
            add = true
            spell.single = itemName
            spell.singleLink = string.format(BOM.TxtEscapeIcon, itemIcon) .. itemLink
            spell.Icon = itemIcon
            spell.isScanned = true

            BOM.DB.Cache.Item[spell.item] = {
              itemName, itemLink, itemIcon
            }
          else
            print(BOM.MSGPREFIX, "Item not found!", spell.single, spell.singleId, spell.item, "x", BOM.ItemCache[spell.item])
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
        BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily, spell.groupFamily, spell.singleId, spell.groupId)

        if spell.cancelForm then
          BOM.Tool.iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily, spell.singleId, spell.groupId)
        end

        --setDefaultValues!
        for i, profil in ipairs(BOM.ProfileNames) do

          if BOM.DBChar[profil].Spell[spell.ConfigID] == nil then
            BOM.DBChar[profil].Spell[spell.ConfigID] = {}
            BOM.DBChar[profil].Spell[spell.ConfigID].Class = BOM.DBChar[profil].Spell[spell.ConfigID].Class or {}
            BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget or {}

            BOM.DBChar[profil].Spell[spell.ConfigID].Enable = spell.default or false

            if BOM.SpellHasClasses(spell) then
              local SelfCast = true
              BOM.DBChar[profil].Spell[spell.ConfigID].SelfCast = false
              for ci, class in ipairs(BOM.Tool.Classes) do
                BOM.DBChar[profil].Spell[spell.ConfigID].Class[class] = tContains(spell.classes, class)
                SelfCast = BOM.DBChar[profil].Spell[spell.ConfigID].Class[class] and false or SelfCast
              end
              BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = {}
              BOM.DBChar[profil].Spell[spell.ConfigID].SelfCast = SelfCast
            end
          else
            BOM.DBChar[profil].Spell[spell.ConfigID].Class = BOM.DBChar[profil].Spell[spell.ConfigID].Class or {}
            BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget or {}
          end

        end -- for all profile names
      end -- if spell is OK to be added
    end -- if spell is a 'table' type (dictionary)
  end -- for all BOM-supported spells
end

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
      link = BOM.Tool.IconClass[class] .. "|Hunit:" .. guid .. ":" .. name .. "|h|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r|h"
    else
      class = ""
      link = string.format(BOM.TxtEscapeIcon, BOM.IconPet) .. name
    end
  else
    class = ""
    link = string.format(BOM.TxtEscapeIcon, BOM.IconPet) .. name
  end

  MemberCache[unitid] = MemberCache[unitid] or {}
  member = MemberCache[unitid]
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

local savedParty, savedPlayerMember

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

function BOM.GetPartyMembers()
  -- and buffs

  local party
  local playerMember


  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded
          and savedParty ~= nil
          and savedPlayerMember ~= nil then

    if #savedParty == bom_count_members() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(savedParty) do
        local name = (UnitFullName(member.unitId))
        if name ~= member.name then
          ok = false
          break
        end
      end
      if ok then
        party = savedParty
        playerMember = savedPlayerMember
      end
    end
  end

  -- read party data
  if party == nil or playerMember == nil then
    party = {}

    if IsInRaid() then
      local NameGroup = {}
      local NameRole = {}

      for raidIndex = 1, 40 do
        local name, rank, subgroup, level, class, fileName,
        zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex)

        if name then
          name = BOM.Tool.Split(name, "-")[1]
          NameGroup[name] = subgroup
          NameRole[name] = role
        end
      end

      for raidIndex = 1, 40 do
        local member = bom_get_member("raid" .. raidIndex, NameGroup, NameRole)

        if member then
          if UnitIsUnit(member.unitId, "player") then
            playerMember = member
          end
          tinsert(party, member)

          member = bom_get_member("raidpet" .. raidIndex)
          if member then
            member.group = 9
            member.class = "pet"
            tinsert(party, member)
          end
        end
      end

    else
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
      playerMember = bom_get_member("player")
      tinsert(party, playerMember)
      member = bom_get_member("pet")
      if member then
        member.group = 9
        member.class = "pet"
        tinsert(party, member)
      end
    end

    if BOM.DB.BuffTarget
            and UnitExists("target")
            and UnitCanCooperate("player", "target")
            and UnitIsPlayer("target")
            and not UnitPlayerOrPetInParty("target")
            and not UnitPlayerOrPetInRaid("target") then
      local member = bom_get_member("target")
      if member then
        member.group = 9
        tinsert(party, member)
      end
    end

    savedParty = party
    savedPlayerMember = playerMember

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
  local zonePlayer = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.DeclineHasResurrection = true
    BOM.ClearSkip()
  end

  for i, member in ipairs(party) do
    member.isSameZone = (C_Map.GetBestMapForUnit(member.unitId) == zonePlayer) or member.isGhost or member.unitId == "target"
    if not member.isDead or BOM.DeclineHasResurrection then
      member.hasResurrection = false
      member.distance = BOM.Tool.UnitDistanceSquared(member.unitId)
    else
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId) or member.hasResurrection
    end

    if BOM.ForceUpdate then
      member.isPlayer = (member == playerMember)
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

          local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
          nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = BOM.UnitAura(member.unitId, buffIndex, "HELPFUL")

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
      end
    end
  end

  -- weapon-buffs
  -- Clear old
  local OldMainHandBuff = playerMember.MainHandBuff
  local OldOffHandBuff = playerMember.OffHandBuff

  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if hasMainHandEnchant and mainHandEnchantID
          and BOM.EnchantToSpell[mainHandEnchantID] then
    local configId = BOM.EnchantToSpell[mainHandEnchantID]
    local duration

    if BOM.ConfigToSpell[ConfigID] and BOM.ConfigToSpell[ConfigID].singleDuration then
      duration = BOM.ConfigToSpell[ConfigID].singleDuration
    else
      duration = 300
    end

    playerMember.buffs[configId] = {
      ["duration"]       = duration,
      ["expirationTime"] = GetTime() + mainHandExpiration / 1000,
      ["source"]         = "player",
      ["isSingle"]       = true,
    }
    playerMember.MainHandBuff = configId
  else
    playerMember.MainHandBuff = nil
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

    playerMember.buffs[-configId] = {
      ["duration"]       = duration,
      ["expirationTime"] = GetTime() + offHandExpiration / 1000,
      ["source"]         = "player",
      ["isSingle"]       = true,
    }
    playerMember.OffHandBuff = configId
  else
    playerMember.OffHandBuff = nil
  end

  if OldMainHandBuff ~= playerMember.MainHandBuff then
    BOM.ForceUpdate = true
  end

  if OldOffHandBuff ~= playerMember.OffHandBuff then
    BOM.ForceUpdate = true
  end

  BOM.DeclineHasResurrection = false

  return party, playerMember
end

function BOM.GetNeedBuff(party, spell, playerMember)
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
    if (BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable and playerMember.MainHandBuff == nil)
            or (BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable and playerMember.OffHandBuff == nil)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isBuff then
    if not playerMember.buffs[spell.ConfigID] then
      tinsert(spell.NeedMember, playerMember)
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
    if not playerMember.isDead then
      if spell.ItemLock then
        if IsSpellKnown(spell.singleId) and not (BOM.HasItem(spell.ItemLock)) then
          tinsert(spell.NeedMember, playerMember)
        end
      elseif not (playerMember.buffs[spell.ConfigID]
              and BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration))
      then
        tinsert(spell.NeedMember, playerMember)
      end
    end

  elseif spell.isResurrection then
    for i, member in ipairs(party) do
      if member.isDead
              and not member.hasResurrection
              and member.isConnected
              and member.group ~= 9
              and (not BOM.DB.SameZone or member.isSameZone) then
        tinsert(spell.NeedMember, member)
      end
    end

  elseif spell.isTracking then
    if GetTrackingTexture() ~= spell.TrackingIcon
            and (BOM.ForceTracking == nil or BOM.ForceTracking == spell.TrackingIcon)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isAura then
    if BOM.ActivAura ~= spell.ConfigID
            and (BOM.CurrentProfile.LastAura == nil or BOM.CurrentProfile.LastAura == spell.ConfigID)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isSeal then
    if BOM.ActivSeal ~= spell.ConfigID
            and (BOM.CurrentProfile.LastSeal == nil or BOM.CurrentProfile.LastSeal == spell.ConfigID)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isBlessing then
    for i, member in ipairs(party) do
      local ok = false
      local notGroup = false

      if BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] == spell.ConfigID
              or (member.isTank
              and BOM.CurrentProfile.Spell[spell.ConfigID].Class["tank"]
              and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast)
      then
        ok = true
        notGroup = true

      elseif BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] == nil then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Class[member.class]
                and (not IsInRaid() or BOM.WatchGroup[member.group])
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
              and (not BOM.DB.SameZone or member.isSameZone) then
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
                and BOM.DB.ReplaceSingle
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

      if BOM.CurrentProfile.Spell[spell.ConfigID].Class[member.class]
              and (not IsInRaid() or BOM.WatchGroup[member.group])
              and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        ok = true
      end
      if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast
              and UnitIsUnit(member.unitId, "player") then
        ok = true
      end
      if BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget[member.name] then
        ok = true
      end
      if member.isTank and BOM.CurrentProfile.Spell[spell.ConfigID].Class["tank"]
              and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        ok = true
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.DB.SameZone or member.isSameZone) then
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
        elseif BOM.DB.ReplaceSingle
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

function BOM.UpdateMacro(member, spellId, command)
  if (GetMacroInfo(BOM.MACRONAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar = nil

    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      print(BOM.MSGPREFIX .. L.MsgNeedOneMacroSlot)
      return
    end

    CreateMacro(BOM.MACRONAME, BOM.Icon, "", isChar)
  end

  local macroText, icon
  if member and spellId then

    --Downgrade-Check
    local spell = BOM.ConfigToSpell[spellId]
    local rank = ""

    if spell == nil then
      print("NIL SPELL:", spellId)
    end

    if BOM.DB.UseRank or member.unitId == "target" then
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
            if BOM.DB.SpellGreatherEqualThan[id] == nil or BOM.DB.SpellGreatherEqualThan[id] < level then
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

    BOM.ERRSpellId = spellId
    local name = GetSpellInfo(spellId)

    macroText = "#showtooltip\n/bom update\n" ..
            (tContains(BOM.cancelForm, spellId) and "/cancelform [nocombat]\n" or "") ..
            "/bom _checkforerror\n" ..
            "/cast [@" .. member.unitId .. ",nocombat]" .. name .. rank .. "\n"
    icon = BOM.Icon
  else
    macroText = "#showtooltip\n/bom update\n"
    if command then
      macroText = macroText .. command
    end
    icon = BOM.IconOff
  end

  EditMacro(BOM.MACRONAME, nil, icon, macroText)
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

local function bom_get_class_in_range(SpellName, party, class, spell)
  local minDist
  local ret = nil

  for i, member in ipairs(party) do
    if member.class == class then
      if member.isDead then
        return nil

      elseif not (IsSpellInRange(SpellName, member.unitId) == 1) then
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
    dif = BOM.DB.Time60
  elseif duration <= 300 then
    dif = BOM.DB.Time300
  elseif duration <= 600 then
    dif = BOM.DB.Time600
  elseif duration <= 1800 then
    dif = BOM.DB.Time1800
  else
    dif = BOM.DB.Time3600
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

local displayCache = {}
local display = {}
local displayInfo = {}
local displayI

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param text string - Text to display
---@param distance number - Distance
---@param isInfo boolean - Whether the text is info text
local function bom_display_text(text, distance, isInfo)
  displayI = displayI + 1
  displayCache[displayI] = displayCache[displayI] or {}
  displayCache[displayI][1] = text
  displayCache[displayI][2] = distance

  if not isInfo then
    tinsert(display, displayCache[displayI])
  else
    tinsert(displayInfo, displayCache[displayI])
  end
end

---Clear the cached text, and clear the message frame
local function bom_clear_display_cache()
  BomC_ListTab_MessageFrame:Clear()
  displayI = 0
  wipe(display)
  wipe(displayInfo)
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
local function bom_display_text_in_messageframe()
  table.sort(display, function(a, b)
    return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  end)

  table.sort(displayInfo, function(a, b)
    return a[1] > b[1]
  end)

  for i, txt in ipairs(displayInfo) do
    BomC_ListTab_MessageFrame:AddMessage(txt[1])
  end

  for i, txt in ipairs(display) do
    BomC_ListTab_MessageFrame:AddMessage(txt[1])
  end
end

local cast = {}
local PlayerMana

---Stores a spell with cost/id/spell link to be casted in the `cast` global
local function bom_catch_a_spell(cost, id, link, member, spell)
  if cost > PlayerMana then
    return -- ouch
  end

  if not spell.isResurrection and member.isDead then
    return
  elseif cast.Spell and not spell.isTracking then
    if cast.Spell.isTracking then
      return
    elseif spell.isResurrection then
      if cast.Spell.isResurrection then
        if (tContains(ResurrectionClass, cast.Member.class) and not tContains(ResurrectionClass, member.class))
                or (tContains(ManaClass, cast.Member.class) and not tContains(ManaClass, member.class))
                or (not cast.Member.isGhost and member.isGhost)
                or (cast.Member.distance < member.distance) then
          return
        end
      end
    else
      if (BOM.DB.SelfFirst and cast.Member.isPlayer and not member.isPlayer)
              or (cast.Member.group ~= 9 and member.group == 9) then
        return
      elseif (not BOM.DB.SelfFirst or (cast.Member.isPlayer == member.isPlayer))
              and ((cast.Member.group == 9) == (member.group == 9))
              and cast.manaCost > cost then
        return
      end
    end
  end

  cast.manaCost = cost
  cast.SpellId = id
  cast.Link = link
  cast.Member = member
  cast.Spell = spell
end

---Cleares the spell from `cast` global
local function bom_clear_spell()
  cast.manaCost = -1
  cast.SpellId = nil
  cast.Member = nil
  cast.Spell = nil
  cast.Link = nil
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
    BomC_ListTab_Button:SetText(L.MsgCombat)
    return
  end

  if UnitIsDeadOrGhost("player") then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BOM.UpdateMacro()
    BomC_ListTab_Button:SetText(L.MsgDead)
    BomC_ListTab_Button:Disable()
    BOM.AutoClose()
    return
  end

  --Choose Profile
  local inInstance, instanceType = IsInInstance()
  local InDisabled

  local chooseProfile = "solo"
  if IsInRaid() then
    chooseProfile = "raid"
  elseif IsInGroup() then
    chooseProfile = "group"
  end

  if instanceType == "pvp" or instanceType == "arena" then
    InDisabled = not BOM.DB.InPVP
    chooseProfile = "battleground"

  elseif instanceType == "party"
          or instanceType == "raid"
          or instanceType == "scenario"
  then
    InDisabled = not BOM.DB.InInstance
  else
    InDisabled = not BOM.DB.InWorld
  end

  if BOM.ForceProfile then
    chooseProfile = BOM.ForceProfile
  end

  if not BOM.DBChar.UseProfiles then
    chooseProfile = "solo"
  end

  if BOM.CurrentProfile ~= BOM.DBChar[chooseProfile] then
    BOM.CurrentProfile = BOM.DBChar[chooseProfile]
    BOM.UpdateSpellsTab()
    BomC_MainWindow_Title:SetText(
            string.format(BOM.TxtEscapeIcon, BOM.FullIcon)
                    .. " " .. BOM.Title .. " - " .. L["profile_" .. chooseProfile])
    BOM.ForceUpdate = true
  end

  if InDisabled then
    BOM.CheckForError = false
    BOM.ForceUpdate = false
    BOM.UpdateMacro()
    BomC_ListTab_Button:SetText(L.MsgDisabled)
    BomC_ListTab_Button:Disable()
    BOM.AutoClose()
    return
  end

  local party, playerMember = BOM.GetPartyMembers()

  if BOM.ForceUpdate then
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
                  and BOM.DBChar.LastTracking ~= spell.TrackingIcon then
            BOM.DBChar.LastTracking = spell.TrackingIcon
            BOM.UpdateSpellsTab()
          end
        else
          if BOM.DBChar.LastTracking == spell.TrackingIcon
                  and BOM.DBChar.LastTracking ~= nil then
            BOM.DBChar.LastTracking = nil
            BOM.UpdateSpellsTab()
          end
        end -- if spell.enable
      end -- if tracking
    end -- for all spells

    if BOM.ForceTracking == nil then
      BOM.ForceTracking = BOM.DBChar.LastTracking
    end

    --find activ aura / seal
    BOM.ActivAura = nil
    BOM.ActivSeal = nil

    for i, spell in ipairs(BOM.SelectedSpells) do
      if playerMember.buffs[spell.ConfigID] then
        if spell.isAura then
          if (BOM.ActivAura == nil and BOM.LastAura == spell.ConfigID)
                  or UnitIsUnit(playerMember.buffs[spell.ConfigID].source, "player") then
            if BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration) then
              BOM.ActivAura = spell.ConfigID
            end
          end
        elseif spell.isSeal then
          if UnitIsUnit(playerMember.buffs[spell.ConfigID].source, "player") then
            if BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration) then
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
    local SomeBodyDeath = false
    for i, spell in ipairs(BOM.SelectedSpells) do
      SomeBodyDeath = BOM.GetNeedBuff(party, spell, playerMember) or SomeBodyDeath
    end

    BOM.OldSomeBodyDeath = SomeBodyDeath
  else
    SomeBodyDeath = BOM.OldSomeBodyDeath
  end

  -- cancel buffs
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and not spell.OnlyCombat
    then
      if playerMember.buffs[spell.ConfigID] then
        print(BOM.MSGPREFIX,
                string.format(L.MsgCancelBuff, spell.singleLink or spell.single, UnitName(playerMember.buffs[spell.ConfigID].source or "") or ""))
        BOM.CancelBuff(spell.singleFamily)
      end
    end
  end

  -- fill list and find cast
  PlayerMana = UnitPower("player", 0) or 0 --mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  bom_clear_spell()

  local BagCommand
  local BagTitel

  BOM.ScanModifier = false

  local inRange = false

  for spellIndex, spell in ipairs(BOM.SelectedSpells) do
    if spell.isInfo
            and BOM.CurrentProfile.Spell[spell.ConfigID].Whisper
    then
      if spell.wasPlayerActiv
              and not spell.playerActiv then
        spell.wasPlayerActiv = false
        local name = UnitName(spell.buffSource or "")

        if name then
          SendChatMessage(BOM.MSGPREFIX .. string.format(L.MsgSpellExpired, spell.single),
                  "WHISPER", nil, name)
        end
      end
    end

    if BOM.CurrentProfile.Spell[spell.ConfigID].Enable
            and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then

      if #spell.NeedMember > 0
              and not spell.isInfo
              and not spell.isBuff
      then
        if spell.singleMana < BOM.ManaLimit
                and spell.singleMana > PlayerMana then
          BOM.ManaLimit = spell.singleMana
        end

        if spell.groupMana
                and spell.groupMana < BOM.ManaLimit
                and spell.groupMana > PlayerMana then
          BOM.ManaLimit = spell.groupMana
        end
      end

      if spell.isWeapon then
        if #spell.NeedMember > 0 then
          local ok, bag, slot, count = BOM.HasItem(spell.items, true)
          count = count or 0

          if ok then
            local texture, _, _, _, _, _, itemLink, _, _, _ = GetContainerItemInfo(bag, slot)

            if BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable
                    and playerMember.OffHandBuff == nil then
              if BOM.DB.DontUseConsumables
                      and not IsModifierKeyDown() then
                bom_display_text(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTOffHand .. ")", playerMember.distance, true)
              else
                BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTOffHand .. ")"
                BagCommand = "/use " .. bag .. " " .. slot .. "\n/use 17" -- offhand
                bom_display_text(BagTitel, playerMember.distance, true)
              end
            end

            if BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable
                    and playerMember.MainHandBuff == nil then
              if BOM.DB.DontUseConsumables
                      and not IsModifierKeyDown() then
                bom_display_text(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTMainHand .. ")", playerMember.distance, true)
              else
                BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTMainHand .. ")"
                BagCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
                bom_display_text(BagTitel, playerMember.distance, true)
              end
            end
            BOM.ScanModifier = BOM.DB.DontUseConsumables
          else
            bom_display_text(spell.single .. "x" .. count, playerMember.distance, true)
          end
        end

      elseif spell.isBuff then
        if #spell.NeedMember > 0 then
          local ok, bag, slot, count = BOM.HasItem(spell.items, true)
          count = count or 0

          if ok then
            local texture, _, _, _, _, _, itemLink, _, _, _ = GetContainerItemInfo(bag, slot)

            if BOM.DB.DontUseConsumables
                    and not IsModifierKeyDown() then
              bom_display_text(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count, playerMember.distance, true)
            else
              BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count
              BagCommand = "/use " .. bag .. " " .. slot
              bom_display_text(BagTitel, playerMember.distance, true)
            end

            BOM.ScanModifier = BOM.DB.DontUseConsumables
          else
            bom_display_text(spell.single .. "x" .. count, playerMember.distance, true)
          end
        end

      elseif spell.isInfo then
        if #spell.NeedMember then
          for memberIndex, member in ipairs(spell.NeedMember) do
            bom_display_text(string.format(L["MsgBuffSingle"], member.link, spell.singleLink),
                    member.distance,
                    true)
          end
        end

      elseif spell.isTracking then
        if #spell.NeedMember > 0 then
          if not BOM.PlayerCasting then
            CastSpellByID(spell.singleId)
          else
            bom_display_text(string.format(L["MsgBuffSingle"], playerMember.name, spell.single),
                    playerMember.name)
          end
        end

      elseif (spell.isOwn
              or spell.isTracking
              or spell.isAura
              or spell.isSeal)
      then
        if #spell.NeedMember > 0 then
          if (not spell.NeedOutdoors or IsOutdoors())
                  and not tContains(spell.SkipList, member.name) then
            bom_display_text(string.format(L["MsgBuffSingle"], playerMember.link, spell.singleLink),
                    playerMember.name)
            inRange = true

            bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, playerMember, spell)
          else
            bom_display_text(string.format(L["MsgBuffSingle"], playerMember.name, spell.single),
                    playerMember.name)
          end
        end

      elseif spell.isResurrection then
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

        for memberIndex, member in ipairs(spell.NeedMember) do
          if not tContains(spell.SkipList, member.name) then
            BOM.RepeatUpdate = true

            -- Is the body in range?
            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1)
                    and not tContains(spell.SkipList, member.name)

            if isInRange then
              inRange = true
              bom_display_text(string.format(L["MsgBuffSingle"], member.link, spell.singleLink),
                      member.name)
            else
              bom_display_text(string.format(L["MsgBuffSingle"], member.name, spell.single),
                      member.name)
            end

            -- If in range, we can res?
            -- Should we try and resurrect ghosts when their corpse is not targetable?
            if isInRange
                    or (BOM.DB.ResGhost and member.isGhost) then
              bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
            end
          end
        end

      elseif spell.isBlessing then
        --Group buff
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
                and not BOM.DB.NoGroupBuff
        then
          for i, groupIndex in ipairs(BOM.Tool.Classes) do
            if spell.NeedGroup[groupIndex]
                    and spell.NeedGroup[groupIndex] >= BOM.DB.MinBlessing
            then
              BOM.RepeatUpdate = true
              local Group = bom_get_class_in_range(spell.group, spell.NeedMember, groupIndex, spell)

              if Group == nil then
                Group = bom_get_class_in_range(spell.group, party, groupIndex, spell)
              end

              if Group ~= nil
                      and (not spell.DeathGroup[member.group] or not BOM.DB.DeathBlock)
              then
                bom_display_text(
                        string.format(L["MsgBuffGroup"],
                                "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r",
                                (spell.groupLink or spell.group))
                                .. count,
                        "!" .. groupIndex)
                inRange = true

                bom_catch_a_spell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)
              else
                bom_display_text(string.format(L["MsgBuffGroup"], BOM.Tool.ClassName[groupIndex], spell.group .. count), "!" .. groupIndex)
              end
            end -- if needgroup >= minblessing
          end -- for all classes
        end

        -- SINGLE BUFF
        for memberIndex, member in ipairs(spell.NeedMember) do
          if not member.isDead
                  and spell.singleMana ~= nil
                  and (BOM.DB.NoGroupBuff
                  or spell.groupMana == nil
                  or member.class == "pet"
                  or spell.NeedGroup[member.class] == nil
                  or spell.NeedGroup[member.class] < BOM.DB.MinBlessing) then

            if not member.isPlayer then
              BOM.RepeatUpdate = true
            end

            local add = ""
            if BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] ~= nil then
              add = string.format(BOM.TxtEscapePicture, BOM.IconTargetOn)
            end

            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1)
                    and not tContains(spell.SkipList, member.name)

            if isInRange then
              bom_display_text(string.format(L["MsgBuffSingle"], add .. member.link, spell.singleLink),
                      member.name)

              inRange = true

              bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
            else
              bom_display_text(string.format(L["MsgBuffSingle"], add .. member.name, spell.single),
                      member.name)
            end -- if in range
          end -- if not dead
        end -- for all NeedMember

      else
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
        if spell.groupMana ~= nil and not BOM.DB.NoGroupBuff then
          for groupIndex = 1, 8 do
            if spell.NeedGroup[groupIndex] and spell.NeedGroup[groupIndex] >= BOM.DB.MinBuff then
              BOM.RepeatUpdate = true
              local Group = bom_get_group_in_range(spell.group, spell.NeedMember, groupIndex, spell)
              if Group == nil then
                Group = bom_get_group_in_range(spell.group, party, groupIndex, spell)
              end

              if Group ~= nil
                      and (not spell.DeathGroup[groupIndex] or not BOM.DB.DeathBlock) then
                bom_display_text(string.format(L["MsgBuffGroup"], groupIndex, (spell.groupLink or spell.group) .. count),
                        "!" .. groupIndex)
                inRange = true

                bom_catch_a_spell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)

              else
                bom_display_text(string.format(L["MsgBuffGroup"], groupIndex, spell.group .. count),
                        "!" .. groupIndex)
              end

            end
          end
        end

        -- SINGLE BUFF
        for memberIndex, member in ipairs(spell.NeedMember) do
          if not member.isDead
                  and spell.singleMana ~= nil
                  and (BOM.DB.NoGroupBuff
                  or spell.groupMana == nil
                  or member.group == 9
                  or spell.NeedGroup[member.group] == nil
                  or spell.NeedGroup[member.group] < BOM.DB.MinBuff)
          then
            if not member.isPlayer then
              BOM.RepeatUpdate = true
            end

            local add = ""
            if BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget[member.name] then
              add = string.format(BOM.TxtEscapePicture, BOM.IconTargetOn)
            end

            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1)
                    and not tContains(spell.SkipList, member.name)

            if isInRange then
              bom_display_text(string.format(L["MsgBuffSingle"], add .. member.link, spell.singleLink),
                      member.name)
              inRange = true
              bom_catch_a_spell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
            else
              bom_display_text(string.format(L["MsgBuffSingle"], add .. member.name, spell.single),
                      member.name)
            end
          end
        end -- for all spell.needmember

      end
    end
  end

  -- check argent dawn
  do
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

    if BOM.DB.ArgentumDawn then
      if playerMember.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.dungeon, instanceID) then
        bom_display_text(BOM.ArgentumDawn.Link, playerMember.distance, true)
      end
    end

    if BOM.DB.Carrot then
      if playerMember.hasCarrot and not tContains(BOM.Carrot.dungeon, instanceID) then
        bom_display_text(BOM.Carrot.Link, playerMember.distance, true)
      end
    end
  end

  -- enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
  if BOM.DB.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    if link then
      bom_display_text(link, playerMember.distance, true)
    end
  end
  if BOM.DB.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))
    if link then
      bom_display_text(link, playerMember.distance, true)
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
      BagTitel = string.format(BOM.TxtEscapeIcon, item.Texture) .. item.Link .. (target and (" @" .. target) or "")
      BagCommand = (target and ("/target " .. target .. "/n") or "") .. "/use " .. item.Bag .. " " .. item.Slot
      bom_display_text(BagTitel, playerMember.distance, true)

      if BOM.DB.DontUseConsumables and not IsModifierKeyDown() then
        BagCommand = nil
        BagTitel = nil
      end
      BOM.ScanModifier = BOM.DB.DontUseConsumables
    end
  end

  if #display > 0
          or #displayInfo > 0 then
    BOM.AutoOpen()
  else
    BOM.AutoClose()
  end

  bom_display_text_in_messageframe()

  BOM.ForceUpdate = false

  if BOM.PlayerCasting then
    BomC_ListTab_Button:SetText(L.MsgBusy)
    BOM.UpdateMacro()
    BomC_ListTab_Button:Disable()

  elseif cast.Member and cast.SpellId then
    BomC_ListTab_Button:SetText(string.format(L["MsgNextCast"], cast.Link, cast.Member.link))

    BOM.UpdateMacro(cast.Member, cast.SpellId)
    local cdtest = GetSpellCooldown(cast.SpellId) or 0

    if cdtest ~= 0 then
      BOM.CheckCoolDown = cast.SpellId
      BomC_ListTab_Button:Disable()
    else
      BomC_ListTab_Button:Enable()
    end

    BOM.ERRSpell = cast.Spell
    BOM.ERRMember = cast.Member
  else
    if #display == 0 then
      BomC_ListTab_Button:SetText(L.MsgEmpty)

      for spellIndex, spell in ipairs(BOM.SelectedSpells) do
        if #spell.SkipList > 0 then
          wipe(spell.SkipList)
        end
      end

    else
      if SomeBodyDeath and BOM.DB.DeathBlock then
        BomC_ListTab_Button:SetText(L.MsgSomebodyDead)
      else
        if inRange then
          BomC_ListTab_Button:SetText(ERR_OUT_OF_MANA)
        else
          BomC_ListTab_Button:SetText(ERR_SPELL_OUT_OF_RANGE)
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

    if BagTitel then
      BomC_ListTab_Button:SetText(BagTitel)
    end

    BomC_ListTab_Button:Enable()
    BOM.UpdateMacro(nil, nil, BagCommand)
  end

end -- end function UpdateScan()

function BOM.ADDSKIP()
  if BOM.ERRSpell
          and BOM.ERRSpell.SkipList
          and BOM.ERRMember then
    tinsert(BOM.ERRSpell.SkipList, BOM.ERRMember.name)
    BOM.FastUpdateTimer()
    BOM.ForceUpdate = true
  end
end

function BOM.DownGrade()
  if BOM.ERRSpell
          and BOM.ERRSpell.SkipList
          and BOM.ERRMember then
    local level = UnitLevel(BOM.ERRMember.unitId)

    if level ~= nil and level > -1 then
      if BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] == nil
              or BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] < level then
        BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] = level
        BOM.FastUpdateTimer()
        BOM.ForceUpdate = true
        print(BOM.MSGPREFIX, string.format(L.MsgDownGrade, BOM.ERRSpell.single, BOM.ERRMember.name))
      elseif BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] >= level then
        BOM.ADDSKIP()
      end
    else
      BOM.ADDSKIP()
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
            and BOM.CancelBuff(spell.singleFamily) then
      print(BOM.MSGPREFIX,
              string.format(L.MsgCancelBuff, spell.singleLink or spell.single,
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
