---@type BuffomatAddon
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

local tasklist ---@type TaskList

function BOM.SetupTasklist()
  tasklist = BOM.Class.TaskList:new()
end

local function bomCancelBuff(list)
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
  return bomCancelBuff(ShapeShiftTravel)
end

BOM.CachedHasItems = {}

---Check whether the player has item
---@param list table - the item?
---@param cd boolean - respect the cooldown?
---@return boolean, number|nil, number|nil, number {HasItem, Bag, Slot, Count}
local function bomHasItem(list, cd)
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

---Formats a spell icon + spell name as a link
---@param spell_info GSICacheItem spell info from the cache via BOM.GetSpellInfo
local function bomFormatSpellLink(spell_info)
  if spell_info == nil then
    return "NIL SPELL"
  end
  if spell_info.spellId == nil then
    return "NIL SPELLID"
  end

  return "|Hspell:" .. spell_info.spellId
          .. "|h|r |cff71d5ff"
          .. BOM.FormatTexture(spell_info.icon)
          .. spell_info.name
          .. "|r|h"
end

---Unused
--local function bom_spell_link_from_spell(spell)
--  return bomFormatSpellLink(BOM.GetSpellInfo(spell))
--end

--Flag set to true when custom spells and cancel-spells were imported from the config
local bom_spells_imported_from_config = false

function BOM.GetSpells()
  for i, profil in ipairs(BOM.ALL_PROFILES) do
    BOM.CharacterState[profil].Spell = BOM.CharacterState[profil].Spell or {}
    BOM.CharacterState[profil].CancelBuff = BOM.CharacterState[profil].CancelBuff or {}
    BOM.CharacterState[profil].Spell[BOM.BLESSING_ID] = BOM.CharacterState[profil].Spell[BOM.BLESSING_ID] or {}
  end

  if not bom_spells_imported_from_config then
    bom_spells_imported_from_config = true

    for x, entry in ipairs(BomSharedState.CustomSpells) do
      tinsert(BOM.AllBuffomatSpells, BOM.Tool.CopyTable(entry))
    end

    for x, entry in ipairs(BomSharedState.CustomCancelBuff) do
      tinsert(BOM.CancelBuffs, BOM.Tool.CopyTable(entry))
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
  BOM.SharedState.Cache.Item2 = BOM.SharedState.Cache.Item2 or {}

  if BOM.ArgentumDawn.Link == nil
          or BOM.Carrot.Link == nil then
    do
      BOM.ArgentumDawn.Link = bomFormatSpellLink(BOM.GetSpellInfo(BOM.ArgentumDawn.spell))
      BOM.Carrot.Link = bomFormatSpellLink(BOM.GetSpellInfo(BOM.Carrot.spell))
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
    local spell_info = BOM.GetSpellInfo(spell.singleId)

    spell.single = spell_info.name
    spell_info.rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = bomFormatSpellLink(spell_info)
    spell.Icon = spell_info.icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for j, profil in ipairs(BOM.ALL_PROFILES) do
      if BOM.CharacterState[profil].CancelBuff[spell.ConfigID] == nil then
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID] = {}
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID].Enable = spell.default or false
      end
    end
  end

  --
  -- Scan all available spells check if they exist (learned) and appropriate
  --
  ---@param spell SpellDef
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
            and not spell.isConsumable
    then
      -- Load spell info and save some good fields for later use
      local spell_info = BOM.GetSpellInfo(spell.singleId)
      if spell_info ~= nil then
        spell.single = spell_info.name
        spell_info.rank = GetSpellSubtext(spell.singleId) or ""
        spell.singleLink = bomFormatSpellLink(spell_info)
        spell.Icon = spell_info.icon

        if spell.type == "tracking" then
          spell.trackingIconId = spell_info.icon
          spell.trackingSpellName = spell_info.name
        end

        if not spell.isInfo
                and not spell.isConsumable
                and spell.singleDuration
                and BOM.SharedState.Duration[spell_info.name] == nil
                and IsSpellKnown(spell.singleId) then
          BOM.SharedState.Duration[spell_info.name] = spell.singleDuration
        end
      end -- spell info returned success
    end

    if spell.groupId then
      local spell_info = BOM.GetSpellInfo(spell.groupId)
      if spell_info ~= nil then
        spell.group = spell_info.name
        spell_info.rank = GetSpellSubtext(spell.groupId) or ""
        spell.groupLink = bomFormatSpellLink(spell_info)

        if spell.groupDuration
                and BOM.SharedState.Duration[spell_info.name] == nil
                and IsSpellKnown(spell.groupId)
        then
          BOM.SharedState.Duration[spell_info.name] = spell.groupDuration
        end
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

    if spell.isConsumable then
      -- call results are cached if they are successful, should not be a performance hit
      local item_info = BOM.GetItemInfo(spell.item)

      if not spell.isScanned and item_info then
        if (not item_info
                or not item_info.itemName
                or not item_info.itemLink
                or not item_info.itemIcon) and BOM.SharedState.Cache.Item2[spell.item]
        then
          item_info = BOM.SharedState.Cache.Item2[spell.item]

        elseif (not item_info
                or not item_info.itemName
                or not item_info.itemLink
                or not item_info.itemIcon) and BOM.ItemCache[spell.item]
        then
          item_info = BOM.ItemCache[spell.item]
        end

        if item_info
                and item_info.itemName
                and item_info.itemLink
                and item_info.itemIcon then
          add = true
          spell.single = item_info.itemName
          spell.singleLink = BOM.FormatTexture(item_info.itemIcon) .. item_info.itemLink
          spell.Icon = item_info.itemIcon
          spell.isScanned = true

          BOM.SharedState.Cache.Item2[spell.item] = item_info
        else
          --BOM.Print("Item not found! Spell=" .. tostring(spell.singleId)
          --      .. " Item=" .. tostring(spell.item))

          -- Go delayed fetch
          local item = Item:CreateFromItemID(spell.item)
          item:ContinueOnItemLoad(function()
            local name = item:GetItemName()
            local link = item:GetItemLink()
            local icon = item:GetItemIcon()
            BOM.SharedState.Cache.Item2[spell.item] = { itemName = name,
                                                        itemLink = link,
                                                        itemIcon = icon }
          end)
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
        ---@type SpellDef
        local spell_ptr = BOM.CharacterState[each_profile].Spell[spell.ConfigID]

        if spell_ptr == nil then
          BOM.CharacterState[each_profile].Spell[spell.ConfigID] = {}
          spell_ptr = BOM.CharacterState[each_profile].Spell[spell.ConfigID]

          spell_ptr.Class = spell_ptr.Class or {}
          spell_ptr.ForcedTarget = spell_ptr.ForcedTarget or {}
          spell_ptr.ExcludedTarget = spell_ptr.ExcludedTarget or {}
          spell_ptr.Enable = spell.default or false

          if spell:HasClasses() then
            local SelfCast = true
            spell_ptr.SelfCast = false

            for ci, class in ipairs(BOM.Tool.Classes) do
              spell_ptr.Class[class] = tContains(spell.targetClasses, class)
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

---Checks whether a tracking spell is now active
---@param spell SpellDef The tracking spell which might have tracking enabled
local function bomIsTrackingActive(spell)
  if BOM.TBC then
    for i = 1, GetNumTrackingTypes() do
      local _name, _texture, active, _category, _nesting, spellId = GetTrackingInfo(i)
      if spellId == spell.singleId then
        return active
      end
    end
    -- not found
    return false
  else
    return GetTrackingTexture() == spell.trackingIconId
  end
end

---Tries to activate tracking described by `spell`
---@param spell SpellDef The tracking spell to activate
---@param value boolean Whether tracking should be enabled
local function bomSetTracking(spell, value)
  if BOM.TBC then
    for i = 1, GetNumTrackingTypes() do
      local name, texture, active, _category, _nesting, spellId = GetTrackingInfo(i)
      if spellId == spell.singleId then
        -- found, compare texture with spell icon
        --BOM.Print(BOM.L.ActivateTracking .. " " .. name)
        SetTracking(i, value)
        return
      end
    end
  else
    --BOM.Print(BOM.L.ActivateTracking .. " " .. spell.trackingSpellName)
    CastSpellByID(spell.singleId)
  end
end

---@param expiration_time number Buff expiration time
---@param max_duration number Max buff duration
local function bomTimeCheck(expiration_time, max_duration)
  if expiration_time == nil
          or max_duration == nil
          or expiration_time == 0
          or max_duration == 0 then
    return true
  end

  local dif

  if max_duration <= 60 then
    dif = BOM.SharedState.Time60
  elseif max_duration <= 300 then
    dif = BOM.SharedState.Time300
  elseif max_duration <= 600 then
    dif = BOM.SharedState.Time600
  elseif max_duration <= 1800 then
    dif = BOM.SharedState.Time1800
  else
    dif = BOM.SharedState.Time3600
  end

  if dif + GetTime() < expiration_time then
    expiration_time = expiration_time - dif
    if expiration_time < BOM.MinTimer then
      BOM.MinTimer = expiration_time
    end
    return true
  end

  return false
end

---Check for party, spell and player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param party table<number, Member> - the party
---@param spell SpellDef - the spell to update
---@param player_member Member - the player
---@param someone_is_dead boolean - the flag that buffing cannot continue while someone is dead
---@return boolean someone_is_dead
local function bomUpdateSpellTargets(party, spell, player_member, someone_is_dead)
  spell.NeedMember = spell.NeedMember or {}
  spell.NeedGroup = spell.NeedGroup or {}
  spell.DeathGroup = spell.DeathGroup or {}

  local player_buff = player_member.buffs[spell.ConfigID]

  wipe(spell.NeedGroup)
  wipe(spell.NeedMember)
  wipe(spell.DeathGroup)

  if not BOM.IsSpellEnabled(spell.ConfigID) then
    --nothing!
  elseif spell.type == "weapon" then
    local weapon_spell = BOM.GetProfileSpell(spell.ConfigID)

    if (weapon_spell.MainHandEnable and player_member.MainHandBuff == nil)
            or (weapon_spell.OffHandEnable and player_member.OffHandBuff == nil)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isConsumable then
    if not player_buff then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isInfo then
    spell.playerActiv = false

    for i, member in ipairs(party) do
      local member_buff = member.buffs[spell.ConfigID]

      if member_buff then
        tinsert(spell.NeedMember, member)

        if member.isPlayer then
          spell.playerActiv = true
          spell.wasPlayerActiv = true
          spell.buffSource = member_buff.source
        end

        if UnitIsUnit("player", member_buff.source or "") then
          BOM.ItemListTarget[spell.ConfigID] = member.name
        end

      end
    end
  elseif spell.isOwn then
    if not player_member.isDead then
      if spell.lockIfHaveItem then
        if IsSpellKnown(spell.singleId) and not (bomHasItem(spell.lockIfHaveItem)) then
          tinsert(spell.NeedMember, player_member)
        end
      elseif not (player_buff
              and bomTimeCheck(player_buff.expirationTime, player_buff.duration))
      then
        tinsert(spell.NeedMember, player_member)
      end
    end

  elseif spell.type == "resurrection" then
    for i, member in ipairs(party) do
      if member.isDead
              and not member.hasResurrection
              and member.isConnected
              and member.group ~= 9
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        tinsert(spell.NeedMember, member)
      end
    end

  elseif spell.type == "tracking" then
    -- Special handling: Having find herbs and find ore will be ignored if
    -- in cat form and track humanoids is enabled
    if (spell.singleId == BOM.SpellId.FindHerbs or
            spell.singleId == BOM.SpellId.FindMinerals)
            and GetShapeshiftFormID() == CAT_FORM
            and BOM.IsSpellEnabled(BOM.SpellId.Druid.TrackHumanoids) then
      -- Do nothing - ignore herbs and minerals in catform if enabled track humanoids
    elseif not bomIsTrackingActive(spell)
            and (BOM.ForceTracking == nil
            or BOM.ForceTracking == spell.trackingIconId)
    then
      --print("Need tracking: ", spell.singleId)
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.type == "aura" then
    if BOM.ActivAura ~= spell.ConfigID
            and (BOM.CurrentProfile.LastAura == nil or BOM.CurrentProfile.LastAura == spell.ConfigID)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.type == "seal" then
    if BOM.ActivSeal ~= spell.ConfigID
            and (BOM.CurrentProfile.LastSeal == nil or BOM.CurrentProfile.LastSeal == spell.ConfigID)
    then
      tinsert(spell.NeedMember, player_member)
    end

  elseif spell.isBlessing then
    for i, member in ipairs(party) do
      local ok = false
      local notGroup = false
      local blessing_name = BOM.GetProfileSpell(BOM.BLESSING_ID)
      local blessing_spell = BOM.GetProfileSpell(spell.ConfigID)

      if blessing_name[member.name] == spell.ConfigID
              or (member.isTank
              and blessing_spell.Class["tank"]
              and not blessing_spell.SelfCast)
      then
        ok = true
        notGroup = true

      elseif blessing_name[member.name] == nil then
        if blessing_spell.Class[member.class]
                and (not IsInRaid() or BomCharacterState.WatchGroup[member.group])
                and not blessing_spell.SelfCast then
          ok = true
        end
        if blessing_spell.SelfCast
                and UnitIsUnit(member.unitId, "player") then
          ok = true
        end
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        local found = false
        local member_buff = member.buffs[spell.ConfigID]

        if member.isDead then
          if member.group ~= 9 and member.class ~= "pet" then
            someone_is_dead = true
            spell.DeathGroup[member.class] = true
          end

        elseif member_buff then
          found = bomTimeCheck(member_buff.expirationTime, member_buff.duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          if not notGroup then
            spell:IncrementNeedGroupBuff(member.class)
          end
        elseif not notGroup
                and BOM.SharedState.ReplaceSingle
                and member_buff
                and member_buff.isSingle then
          spell:IncrementNeedGroupBuff(member.class)
        end

      end
    end

  else
    --spells
    for i, member in ipairs(party) do
      local ok = false
      ---@type SpellDef
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
        local member_buff = member.buffs[spell.ConfigID]

        if member.isDead then
          someone_is_dead = true
          spell.DeathGroup[member.group] = true

        elseif member_buff then
          found = bomTimeCheck(member_buff.expirationTime, member_buff.duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          spell.NeedGroup[member.group] = (spell.NeedGroup[member.group] or 0) + 1
        elseif BOM.SharedState.ReplaceSingle
                and member_buff
                and member_buff.isSingle
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

      someone_is_dead = false
    end
  end

  return someone_is_dead
end

local function bomRecreateMacro()
  if (GetMacroInfo(BOM.MACRO_NAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar

    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      BOM.Print(L.MsgNeedOneMacroSlot)
      return
    end

    CreateMacro(BOM.MACRO_NAME, BOM.MACRO_ICON, "", isChar)
  end
end

--- Does same as call to BOM.UpdateMacro with command and when member/spellid are nil
local function bomClearMacro()
  if InCombatLockdown() then
    return
  end
  bomRecreateMacro()
  local macroText = "#showtooltip\n/bom update\n"
  icon = BOM.MACRO_ICON_DISABLED
  EditMacro(BOM.MACRO_NAME, nil, icon, macroText)
end

---Updates the BOM macro
---@param member table - next target to buff
---@param spellId number - spell to cast
---@param command string - bag command
local function bomUpdateMacro(member, spellId, command)
  bomRecreateMacro()

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

local function bomGetGroupInRange(SpellName, party, groupNb, spell)
  local minDist
  local ret
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
local function bomGetClassInRange(spell_name, party, class, spell)
  local minDist
  local ret

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

---@class BomScan_NextCastSpell
---@field Spell SpellDef
---@field Link string|nil
---@field Member string|nil
---@field SpellId number|nil
---@field manaCost number
local next_cast_spell = {}

---@type number
local bom_current_player_mana

---@param link string Clickable spell link with icon
---@param inactiveText string Spell name as text
---@param member Member
---@return boolean True if spell cast is prevented by PvP guard, false if spell can be casted
local function bomPreventPvpTagging(link, inactiveText, member)
  if BOM.SharedState.PreventPVPTag then
    -- TODO: Move Player PVP check and instance check outside
    local _in_instance, instance_type = IsInInstance()
    if instance_type == "none"
            and not UnitIsPVP("player")
            and UnitIsPVP(member.name) then
      -- Text: [Spell Name] Player is PvP
      tasklist:Add(link, inactiveText,
              L.PreventPVPTagBlocked, member, true)
      return true
    end
  end
  return false
end

---Stores a spell with cost/id/spell link to be casted in the `cast` global
---@param cost number Resource cost (mana cost)
---@param id number Spell id to capture
---@param link string Spell link for a picture
---@param member Member player to benefit from the spell
---@param spell SpellDef the spell to be added
local function bomQueueSpell(cost, id, link, member, spell)
  if cost > bom_current_player_mana then
    return -- ouch
  end

  if not spell.type == "resurrection" and member.isDead then
    -- Cannot cast resurrections on deads
    return
  elseif next_cast_spell.Spell and spell.type ~= "tracking" then
    if next_cast_spell.Spell.type == "tracking" then
      return
    elseif spell.type == "resurrection" then
      --------------------
      -- If resurrection
      --------------------
      if next_cast_spell.Spell.type == "resurrection" then
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
local function bomClearNextCastSpell()
  next_cast_spell.manaCost = -1
  next_cast_spell.SpellId = nil
  next_cast_spell.Member = nil
  next_cast_spell.Spell = nil
  next_cast_spell.Link = nil
end

---Run checks to see if BOM should not be scanning buffs
---@return boolean, string {Active, WhyNotActive: string}
local function bomIsActive()
  local in_instance, instance_type = IsInInstance()

  -- Cancel buff tasks if in combat (ALWAYS FIRST CHECK)
  if InCombatLockdown() then
    return false, L.InactiveReason_InCombat
  end

  if UnitIsDeadOrGhost("player") then
    return false, L.InactiveReason_PlayerDead
  end

  if instance_type == "pvp" or instance_type == "arena" then
    if not BOM.SharedState.InPVP then
      return false, L.InactiveReason_PvpZone
    end

  elseif instance_type == "party"
          or instance_type == "raid"
          or instance_type == "scenario"
  then
    if not BOM.SharedState.InInstance then
      return false, L.InactiveReason_Instance
    end
  else
    if not BOM.SharedState.InWorld then
      return false, L.InactiveReason_OpenWorld
    end
  end

  -- Cancel buff tasks if is in a resting area, and option to scan is not set
  if not BOM.SharedState.ScanInRestArea and IsResting() then
    return false, L.InactiveReason_RestArea
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  if not BOM.SharedState.ScanInStealth and IsStealthed() then
    return false, L.InactiveReason_IsStealthed
  end

  return true, nil
end

---Based on profile settings and current PVE or PVP instance choose the mode
---of operation
---@return string
local function bomChooseProfile()
  local in_instance, instance_type = IsInInstance()
  local auto_profile = "solo"

  if IsInRaid() then
    auto_profile = "raid"
  elseif IsInGroup() then
    auto_profile = "group"
  end

  -- TODO: Refactor isDisabled into a function, also return reason why is disabled
  if BOM.ForceProfile then
    auto_profile = BOM.ForceProfile
  elseif not BOM.CharacterState.UseProfiles then
    auto_profile = "solo"
  elseif instance_type == "pvp" or instance_type == "arena" then
    auto_profile = "battleground"
  end

  return auto_profile
end

---Activate tracking spells
local function bomActivateSelectedTracking()
  --reset tracking
  BOM.ForceTracking = nil

  ---@param spell SpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "tracking" then
      if BOM.IsSpellEnabled(spell.ConfigID) then
        if spell.needForm ~= nil then
          if GetShapeshiftFormID() == spell.needForm
                  and BOM.ForceTracking ~= spell.trackingIconId then
            BOM.ForceTracking = spell.trackingIconId
            BOM.UpdateSpellsTab("ForceUp1")
          end
        elseif bomIsTrackingActive(spell)
                and BOM.CharacterState.LastTracking ~= spell.trackingIconId then
          BOM.CharacterState.LastTracking = spell.trackingIconId
          BOM.UpdateSpellsTab("ForceUp2")
        end
      else
        if BOM.CharacterState.LastTracking == spell.trackingIconId
                and BOM.CharacterState.LastTracking ~= nil then
          BOM.CharacterState.LastTracking = nil
          BOM.UpdateSpellsTab("ForceUp3")
        end
      end -- if spell.enable
    end -- if tracking
  end -- for all spells

  if BOM.ForceTracking == nil then
    BOM.ForceTracking = BOM.CharacterState.LastTracking
  end
end

---@param player_member Member
local function bomGetActiveAuraAndSeal(player_member)
  --find activ aura / seal
  BOM.ActivAura = nil
  BOM.ActivSeal = nil

  ---@param spell SpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    local player_buff = player_member.buffs[spell.ConfigID]

    if player_buff then
      if spell.type == "aura" then
        if (BOM.ActivAura == nil and BOM.LastAura == spell.ConfigID)
                or UnitIsUnit(player_buff.source, "player")
        then
          if bomTimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivAura = spell.ConfigID
          end
        end

      elseif spell.type == "seal" then
        if UnitIsUnit(player_buff.source, "player") then
          if bomTimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivSeal = spell.ConfigID
          end
        end
      end -- if is aura
    end -- if player.buffs[config.id]
  end -- for all spells
end

local function bomCheckChangesAndUpdateSpelltab()
  --reset aura/seal
  ---@param spell SpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "aura" then
      if BOM.IsSpellEnabled(spell.ConfigID) then
        if BOM.ActivAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= spell.ConfigID then
          BOM.CurrentProfile.LastAura = spell.ConfigID
          BOM.UpdateSpellsTab("ForceUp4")
        end
      else
        if BOM.CurrentProfile.LastAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= nil then
          BOM.CurrentProfile.LastAura = nil
          BOM.UpdateSpellsTab("ForceUp5")
        end
      end -- if currentprofile.spell.enable

    elseif spell.type == "seal" then
      if BOM.IsSpellEnabled(spell.ConfigID) then
        if BOM.ActivSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= spell.ConfigID then
          BOM.CurrentProfile.LastSeal = spell.ConfigID
          BOM.UpdateSpellsTab("ForceUp6")
        end
      else
        if BOM.CurrentProfile.LastSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= nil then
          BOM.CurrentProfile.LastSeal = nil
          BOM.UpdateSpellsTab("ForceUp7")
        end
      end -- if currentprofile.spell.enable
    end -- if is aura
  end
end

---@param party table<number, Member> - the party
---@param player_member Member - the player
local function bomForceUpdate(party, player_member)
  bomActivateSelectedTracking()

  -- Get the running aura and the running seal
  bomGetActiveAuraAndSeal(player_member)

  -- Check changes to auras and seals and update the spell tab
  bomCheckChangesAndUpdateSpelltab()

  -- who needs a buff!
  -- for each spell update spell potential targets
  local someone_is_dead = false -- the flag that buffing cannot continue while someone is dead

  -- For each selected spell check the targets
  ---@param spell SpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    someone_is_dead = bomUpdateSpellTargets(party, spell, player_member, someone_is_dead)
  end

  bom_save_someone_is_dead = someone_is_dead
  return someone_is_dead
end

local function bomCancelBuffs(player_member)
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and not spell.OnlyCombat
    then
      local player_buff = player_member.buffs[spell.ConfigID]

      if player_buff then
        BOM.Print(string.format(L.MsgCancelBuff,
                spell.singleLink or spell.single,
                UnitName(player_buff.source or "") or ""))
        bomCancelBuff(spell.singleFamily)
      end
    end
  end
end

---Whisper to the spell caster when the buff expired on yourself
local function bomWhisperExpired(spell)
  if spell.wasPlayerActiv and not spell.playerActiv then
    spell.wasPlayerActiv = false

    local name = UnitName(spell.buffSource or "")

    if name then
      local msg = string.format(L.MsgSpellExpired, spell.single)
      SendChatMessage(msg, "WHISPER", nil, name)

      BOM.Print(msg, "WHISPER", nil, name)
    end
  end
end

---@param spell SpellDef
---@param groupIndex number
---@param classColorize boolean
---@return string
local function bomFormatGroupBuffText(groupIndex, spell, classColorize)
  if classColorize then
    return string.format(L["FORMAT_BUFF_GROUP"],
            "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r",
            spell.groupLink or spell.group or "?")
  end

  return string.format(L.FORMAT_BUFF_GROUP,
          BOM.Tool.ClassName[groupIndex] or "?",
          spell.groupLink or spell.group or "?")
end

-- ---@param prefix string Icon or some sort of string to prepend
-- ---@param member Member
-- ---@param spell SpellDef
-- ---@return string
--local function bomFormatSingleBuffText(prefix, member, spell)
--  return string.format(L.FORMAT_BUFF_SINGLE,
--          (prefix or "") .. member:GetText(),
--          (spell.singleLink or spell.single))
--end

---@return string
local function bomFormatItemBuffText(bag, slot, count)
  local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
  return string.format(" %s %s x%d",
          BOM.FormatTexture(texture),
          item_link,
          count)
end

---Add a paladin blessing
---@param spell SpellDef - spell to cast
---@param player_member table - player
---@param in_range boolean - spell target is in range
local function bomAddBlessing(spell, player_member, in_range)
  local ok, bag, slot, count
  if spell.reagentRequired then
    ok, bag, slot, count = bomHasItem(spell.reagentRequired, true)
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
        local class_in_range = bomGetClassInRange(spell.group, spell.NeedMember, groupIndex, spell)

        if class_in_range == nil then
          class_in_range = bomGetClassInRange(spell.group, party, groupIndex, spell)
        end

        if class_in_range ~= nil
                and (not spell.DeathGroup[member.group] or not BOM.SharedState.DeathBlock)
        then
          -- Group buff
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  L.TASK_BLESS_GROUP,
                  bomFormatGroupBuffText(groupIndex, spell, true) .. count,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(groupIndex),
                  false)
          in_range = true

          bomQueueSpell(spell.groupMana, spell.groupId, spell.groupLink, class_in_range, spell)
        else
          -- Group buff (just text)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  L.TASK_BLESS_GROUP,
                  bomFormatGroupBuffText(groupIndex, spell, false) .. count,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(groupIndex),
                  true)
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
      local blessing_name = BOM.GetProfileSpell(BOM.BLESSING_ID)
      if blessing_name[member.name] ~= nil then
        add = string.format(BOM.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local test_in_range = IsSpellInRange(spell.single, member.unitId) == 1
              and not tContains(spell.SkipList, member.name)
      if bomPreventPvpTagging(spell.singleLink, spell.single, member) then
        -- Nothing, prevent poison function has already added the text
      elseif test_in_range then
        -- Single buff on group member
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                L.TASK_BLESS,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
        in_range = true

        bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        -- Single buff on group member (inactive just text)
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                L.TASK_BLESS,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                true)
      end -- if in range
    end -- if not dead
  end -- for all NeedMember
end

---Add a paladin blessing
---@param spell SpellDef - spell to cast
---@param party table - the party
---@param player_member table - player
---@param in_range boolean - spell target is in range
local function bomAddBuff(spell, party, player_member, in_range)
  local ok, bag, slot, count

  if spell.reagentRequired then
    ok, bag, slot, count = bomHasItem(spell.reagentRequired, true)
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
        local Group = bomGetGroupInRange(spell.group, spell.NeedMember, group_index, spell)

        if Group == nil then
          Group = bomGetGroupInRange(spell.group, party, group_index, spell)
        end

        if Group ~= nil
                and (not spell.DeathGroup[group_index] or not BOM.SharedState.DeathBlock)
        then
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  L.BUFF_CLASS_GROUPBUFF,
                  bomFormatGroupBuffText(group_index, spell, false) .. count,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(group_index),
                  false)
          in_range = true

          bomQueueSpell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)
        else
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  L.BUFF_CLASS_GROUPBUFF,
                  bomFormatGroupBuffText(group_index, spell, false) .. count,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(group_index),
                  false)
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
      local profile_spell = BOM.GetProfileSpell(spell.ConfigID)

      if profile_spell.ForcedTarget[member.name] then
        add = string.format(BOM.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local is_in_range = (IsSpellInRange(spell.single, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if bomPreventPvpTagging(spell.singleLink, spell.single, member) then
        -- Nothing, prevent poison function has already added the text
      elseif is_in_range then
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                L.BUFF_CLASS_REGULAR,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
        in_range = true
        bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                L.BUFF_CLASS_REGULAR,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
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
local function bomAddResurrection(spell, player_member, in_range)
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
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                L.TASK_CLASS_RESURRECT,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false,
                BOM.TaskPriority.Resurrection)
      else
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                L.TASK_CLASS_RESURRECT,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false,
                BOM.TaskPriority.Resurrection)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if is_in_range or (BOM.SharedState.ResGhost and member.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      end
    end
  end

  return in_range
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell SpellDef - the spell to cast
---@param playerMember table - the player
local function bomAddSelfbuff(spell, playerMember)
  if (not spell.requiresOutdoors or IsOutdoors())
          and not tContains(spell.SkipList, playerMember.name) then
    -- Text: Target [Spell Name]
    tasklist:AddWithPrefix(
            L.BUFF_CLASS_REGULAR,
            spell.singleLink or spell.single,
            spell.single,
            L.BUFF_CLASS_SELF_ONLY,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)
    --inRange = true

    bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  else
    -- Text: Target "SpellName"
    tasklist:AddWithPrefix(
            L.BUFF_CLASS_REGULAR,
            spell.singleLink or spell.single,
            spell.single,
            L.BUFF_CLASS_SELF_ONLY,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)
  end
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param playerMember table - the player
---@param bag_title string - if not empty, is item name from the bag
---@param bag_command string - console command to use item from the bag
---@return table (bag_title string, bag_command string)
local function bomAddConsumableSelfbuff(spell, playerMember, bag_title, bag_command)
  local ok, bag, slot, count = bomHasItem(spell.items, true)
  count = count or 0

  if ok then
    if BOM.SharedState.DontUseConsumables
            and not IsModifierKeyDown() then
      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              L.TASK_USE,
              bomFormatItemBuffText(bag, slot, count),
              nil,
              L.BUFF_CONSUMABLE_REMINDER,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      bag_command = "/use " .. bag .. " " .. slot

      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              L.TASK_USE,
              bomFormatItemBuffText(bag, slot, count),
              nil,
              "",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              false)
    end

    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    -- Text: "ConsumableName" x Count
    if spell.single then
      -- safety, can crash on load
      tasklist:AddWithPrefix(
              L.TASK_USE,
              spell.single .. "x" .. count,
              nil,
              "",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    end
  end

  return bag_title, bag_command
end

---Adds a display text for a weapon buff created by a consumable item
---@param spell SpellDef - the spell to cast
---@param playerMember table - the player
---@param cast_button_title string - if not empty, is item name from the bag
---@param macro_command string - console command to use item from the bag
---@return string, string cast button title and macro command
local function bomAddConsumableWeaponBuff(spell, playerMember,
                                          cast_button_title, macro_command)
  -- count - reagent count remaining for the spell
  local have_item, bag, slot, count = bomHasItem(spell.items, true)
  count = count or 0

  if have_item then
    -- Have item, display the cast message and setup the cast button
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
    local profile_spell = BOM.GetProfileSpell(spell.ConfigID)

    if profile_spell.OffHandEnable
            and playerMember.OffHandBuff == nil then
      local function offhand_message()
        return BOM.FormatTexture(texture) .. item_link .. "x" .. count
      end

      if BOM.SharedState.DontUseConsumables
              and not IsModifierKeyDown() then
        -- Text: [Icon] [Consumable Name] x Count (Off-hand)
        tasklist:Add(
                offhand_message(),
                nil,
                "(" .. L.TooltipOffHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Off-hand)
        cast_button_title = offhand_message()
        macro_command = "/use " .. bag .. " " .. slot
                .. "\n/use 17" -- offhand
        tasklist:Add(
                cast_button_title,
                nil,
                "(" .. L.TooltipOffHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      end
    end

    if profile_spell.MainHandEnable
            and playerMember.MainHandBuff == nil then
      local function mainhand_message()
        return BOM.FormatTexture(texture) .. item_link .. "x" .. count
      end

      if BOM.SharedState.DontUseConsumables
              and not IsModifierKeyDown() then
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        tasklist:Add(
                mainhand_message(),
                nil,
                "(" .. L.TooltipMainHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        cast_button_title = mainhand_message()
        macro_command = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        tasklist:Add(
                cast_button_title,
                nil,
                "(" .. L.TooltipMainHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      end
    end
    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    -- Don't have item but display the intent
    -- Text: [Icon] [Consumable Name] x Count
    if spell.single then
      -- spell.single can be nil on addon load
      tasklist:Add(
              spell.single .. "x" .. count,
              nil,
              L.TASK_CLASS_MISSING_CONSUM,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      BOM.SetForceUpdate("WeaponConsumableBuff display text") -- try rescan?
    end
  end

  return cast_button_title, macro_command
end

---Adds a display text for a weapon buff created by a spell (shamans and paladins)
---@param spell SpellDef - the spell to cast
---@param playerMember Member - the player
---@param cast_button_title string - if not empty, is item name from the bag
---@param macro_command string - console command to use item from the bag
---@return string, string cast button title and macro command
local function bomAddWeaponEnchant(spell, playerMember,
                                   cast_button_title, macro_command)
  local block_offhand_enchant = false -- set to true to block temporarily

  local _, self_class, _ = UnitClass("player")
  if BOM.TBC and self_class == "SHAMAN" then
    -- Special handling for TBC shamans, you cannot specify slot for enchants,
    -- and it goes into main then offhand
    local has_mh, _mh_expire, _mh_charges, _mh_enchantid, has_oh, _oh_expire
    , _oh_charges, _oh_enchantid = GetWeaponEnchantInfo()

    if not has_mh then
      -- shamans in TBC can't enchant offhand if MH enchant is missing
      block_offhand_enchant = true
    end

    if has_oh then
      block_offhand_enchant = true
    end
  end

  local profile_spell = BOM.GetProfileSpell(spell.ConfigID)

  if profile_spell.MainHandEnable
          and playerMember.MainHandBuff == nil then
    -- Text: [Spell Name] (Main hand)
    tasklist:Add(
            spell.singleLink,
            spell.single,
            "(" .. L.TooltipOffHand .. ")",
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            true)
    bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  end

  if profile_spell.OffHandEnable
          and playerMember.OffHandBuff == nil then
    if block_offhand_enchant then
      -- Text: [Spell Name] (Off-hand) Blocked waiting
      tasklist:Add(
              spell.singleLink,
              spell.single,
              "(" .. L.TooltipOffHand .. ") " .. L.ShamanEnchantBlocked,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      -- Text: [Spell Name] (Off-hand)
      tasklist:Add(
              spell.singleLink,
              spell.single,
              "(" .. L.TooltipOffHand .. ")",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
      bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
              playerMember, spell)
    end
  end

  return cast_button_title, macro_command
end

---Set text and enable the cast button (or disable)
---@param t string - text for the cast button
---@param enable boolean - whether to enable the button or not
local function bomCastButton(t, enable)
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

---Check if player has rep items equipped where they should not have them
---@param playerMember Member
local function bomCheckReputationItems(playerMember)
  local name, instanceType, difficultyID, difficultyName, maxPlayers
  , dynamicDifficulty, isDynamic, instanceID, instanceGroupSize
  , LfgDungeonID = GetInstanceInfo()

  if BOM.SharedState.ArgentumDawn then
    -- settings to remind to remove AD trinket != instance compatible with AD Commission
    if playerMember.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.zoneId, instanceID) then
      -- Text: [Argent Dawn Commission]
      tasklist:Add(
              BOM.ArgentumDawn.Link,
              nil,
              L.TASK_CLASS_REMINDER,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    end
  end

  if BOM.SharedState.Carrot then
    if playerMember.hasCarrot and not tContains(BOM.Carrot.zoneId, instanceID) then
      -- Text: [Carrot on a Stick]
      tasklist:Add(
              BOM.Carrot.Link,
              nil,
              L.TASK_CLASS_REMINDER,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    end
  end
end

---Check player weapons and report if they have the "Warn about missing enchants" option enabled
---@param player_member Member
local function bomCheckMissingWeaponEnchantments(player_member)
  -- enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges
  , offHandEnchantId = GetWeaponEnchantInfo()

  if BOM.SharedState.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

    if link then
      -- Text: [Consumable Enchant Link]
      tasklist:Comment(
              link,
              "Missing main hand temporary enchant",
              player_member,
              true)
    end
  end

  if BOM.SharedState.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))

    if link then
      tasklist:Comment(
              link,
              "Missing off-hand temporary enchant",
              player_member,
              true)
    end
  end
end

---@param playerMember Member
---@param cast_button_title string
---@param macro_command string
---@return string, string {cast_button_title, macro_command}
local function bomCheckItemsAndContainers(playerMember, cast_button_title, macro_command)
  --itemcheck
  local item_list = BOM.GetItemList() ---@type table<number, GetContainerItemInfoResult>

  for i, item in ipairs(item_list) do
    local ok = false
    local target

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
      local extra_msg = "" -- tell user they need to hold Alt or something
      if BOM.SharedState.DontUseConsumables and not IsModifierKeyDown() then
        extra_msg = L.BUFF_CONSUMABLE_REMINDER
      end

      macro_command = (target and ("/target " .. target .. "/n") or "")
              .. "/use " .. item.Bag .. " " .. item.Slot
      cast_button_title = BOM.FormatTexture(item.Texture)
              .. item.Link
              .. (target and (" @" .. target) or "")
      -- Text: [Icon] [Item Link] @Target
      tasklist:Add(
              cast_button_title,
              nil,
              "(" .. L.MsgOpenContainer .. ") " .. extra_msg,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)

      if BOM.SharedState.DontUseConsumables and not IsModifierKeyDown() then
        macro_command = nil
        cast_button_title = nil
      end
      BOM.ScanModifier = BOM.SharedState.DontUseConsumables
    end
  end

  return cast_button_title, macro_command
end

---@param playerMember Member
---@param party table<number, Member>
---@param in_range boolean
---@param cast_button_title string
---@param macro_command string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
local function bomScanSelectedSpells(playerMember, party, in_range, cast_button_title, macro_command)
  for _, spell in ipairs(BOM.SelectedSpells) do
    local profile_spell = BOM.GetProfileSpell(spell.ConfigID)

    if spell.isInfo and profile_spell.Whisper then
      bomWhisperExpired(spell)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if BOM.IsSpellEnabled(spell.ConfigID)
            and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then
      if #spell.NeedMember > 0
              and not spell.isInfo
              and not spell.isConsumable
      then
        if spell.singleMana < BOM.ManaLimit
                and spell.singleMana > bom_current_player_mana then
          BOM.ManaLimit = spell.singleMana
        end

        if spell.groupMana
                and spell.groupMana < BOM.ManaLimit
                and spell.groupMana > bom_current_player_mana then
          BOM.ManaLimit = spell.groupMana
        end
      end

      if spell.type == "weapon" then
        if #spell.NeedMember > 0 then
          if spell.isConsumable then
            cast_button_title, macro_command = bomAddConsumableWeaponBuff(
                    spell, playerMember, cast_button_title, macro_command)
          else
            cast_button_title, macro_command = bomAddWeaponEnchant(spell, playerMember)
          end
        end

      elseif spell.isConsumable then
        if #spell.NeedMember > 0 then
          cast_button_title, macro_command = bomAddConsumableSelfbuff(
                  spell, playerMember, cast_button_title, macro_command)
        end

      elseif spell.isInfo then
        if #spell.NeedMember then
          for memberIndex, member in ipairs(spell.NeedMember) do
            -- Text: [Player Link] [Spell Link]
            tasklist:Add(
                    spell.singleLink or spell.single,
                    spell.single,
                    "Info",
                    BOM.Class.MemberBuffTarget:fromMember(member),
                    true)
          end
        end

      elseif spell.type == "tracking" then
        -- TODO: Move this to its own periodic timer
        if #spell.NeedMember > 0 then
          if BOM.PlayerCasting == nil then
            bomSetTracking(spell, true)
          else
            -- Text: "Player" "Spell Name"
            tasklist:AddWithPrefix(
                    L.TASK_ACTIVATE,
                    spell.singleLink or spell.single,
                    spell.single,
                    L.BUFF_CLASS_TRACKING,
                    BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                    false)
          end
        end

      elseif (spell.isOwn
              or spell.type == "tracking"
              or spell.type == "aura"
              or spell.type == "seal")
      then
        if spell.shapeshiftFormId and GetShapeshiftFormID() == spell.shapeshiftFormId then
          -- if spell is shapeshift, and is already active, skip it
        elseif #spell.NeedMember > 0 then
          -- self buffs are not pvp-guarded
          bomAddSelfbuff(spell, playerMember)
        end

      elseif spell.type == "resurrection" then
        in_range = bomAddResurrection(spell, playerMember, in_range)

      elseif spell.isBlessing then
        in_range = bomAddBlessing(spell, playerMember, in_range)

      else
        in_range = bomAddBuff(spell, party, playerMember, in_range)
      end
    end
  end

  return in_range, cast_button_title, macro_command
end

local function bomUpdateScan_Scan()
  local party, player_member = BOM.GetPartyMembers()

  local someone_is_dead = bom_save_someone_is_dead
  if BOM.ForceUpdate then
    someone_is_dead = bomForceUpdate(party, player_member)
  end

  -- cancel buffs
  bomCancelBuffs(player_member)

  -- fill list and find cast
  bom_current_player_mana = UnitPower("player", 0) or 0 --mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  bomClearNextCastSpell()

  local macro_command ---@type string
  local cast_button_title ---@type string
  local in_range = false

  BOM.ScanModifier = false

  in_range, cast_button_title, macro_command = bomScanSelectedSpells(
          player_member, party, in_range,
          cast_button_title, macro_command)

  bomCheckReputationItems(player_member)
  bomCheckMissingWeaponEnchantments(player_member) -- if option to warn is enabled

  cast_button_title, macro_command = bomCheckItemsAndContainers(
          player_member, cast_button_title, macro_command)

  -- Open Buffomat if any cast tasks were added to the task list
  if #tasklist.tasks > 0 or #tasklist.comments > 0
  then
    BOM.AutoOpen()
  else
    BOM.AutoClose()
  end

  tasklist:Display() -- Show all tasks and comments

  BOM.ForceUpdate = false

  local flying = false -- prevent dismount in flight, OUCH!
  if BOM.TBC then
    flying = IsFlying() and not BOM.SharedState.AutoDismountFlying
  end

  if flying then
    --Print player is flying, do not dismount, OUCH!
    bomCastButton(L.MsgFlying, false)
    bomUpdateMacro()

  elseif BOM.PlayerCasting == "cast" then
    --Print player is busy (casting normal spell)
    bomCastButton(L.MsgBusy, false)
    bomUpdateMacro()

  elseif BOM.PlayerCasting == "channel" then
    --Print player is busy (casting channeled spell)
    bomCastButton(L.MsgBusyChanneling, false)
    bomUpdateMacro()

  elseif next_cast_spell.Member and next_cast_spell.SpellId then
    --Next cast is already defined - update the button text
    bomCastButton(next_cast_spell.Link, true)
    bomUpdateMacro(next_cast_spell.Member, next_cast_spell.SpellId)

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
    if #tasklist.tasks == 0 then
      --If don't have any strings to display, and nothing to do -
      --Clear the cast button
      bomCastButton(L.MsgNothingToDo, true)

      for spellIndex, spell in ipairs(BOM.SelectedSpells) do
        if #spell.SkipList > 0 then
          wipe(spell.SkipList)
        end
      end

    else
      if someone_is_dead and BOM.SharedState.DeathBlock then
        bomCastButton(L.InactiveReason_DeadMember, false)
      else
        if in_range then
          bomCastButton(ERR_OUT_OF_MANA, false)
        else
          bomCastButton(ERR_SPELL_OUT_OF_RANGE, false)
          local skipreset = false

          for spellIndex, spell in ipairs(BOM.SelectedSpells) do
            if #spell.SkipList > 0 then
              skipreset = true
              wipe(spell.SkipList)
            end
          end

          if skipreset then
            BOM.FastUpdateTimer()
            BOM.SetForceUpdate("SkipReset")
          end
        end -- if inrange
      end -- if somebodydeath and deathblock
    end -- if #display == 0

    if cast_button_title then
      bomCastButton(cast_button_title, true)
    end

    bomUpdateMacro(nil, nil, macro_command)
  end -- if not player casting

end -- end function bomUpdateScan_Scan()

local function bomUpdateScan_PreCheck(from)
  if BOM.SelectedSpells == nil then
    return
  end

  if BOM.InLoading then
    return
  end

  BOM.MinTimer = GetTime() + 36000 -- 10 hours
  tasklist:Clear()
  BOM.RepeatUpdate = false

  -- Check whether BOM is disabled due to some option and a matching condition
  local is_bom_active, why_disabled = bomIsActive()
  if not is_bom_active then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BOM.AutoClose()
    bomClearMacro()
    bomCastButton(why_disabled, false)
    return
  end

  --Choose Profile
  local auto_profile = bomChooseProfile()

  if BOM.CurrentProfile ~= BOM.CharacterState[auto_profile] then
    BOM.CurrentProfile = BOM.CharacterState[auto_profile]
    BOM.UpdateSpellsTab("UpdateScan1")
    BomC_MainWindow_Title:SetText(
            BOM.FormatTexture(BOM.MACRO_ICON_FULLPATH)
                    .. " " .. BOM.TOC_TITLE .. " - "
                    .. L["profile_" .. auto_profile])
    BOM.SetForceUpdate("ProfileChanged")
  end

  -- All pre-checks passed
  bomUpdateScan_Scan()
end -- end function bomUpdateScan_PreCheck()

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
---@param from string Debug value to trace the caller of this function
function BOM.UpdateScan(from)
  --BOM.Tool.Profile("UpdScan " .. from, function()
  bomUpdateScan_PreCheck(from)
  --end)
end

---If a spell cast failed, the member is temporarily added to skip list, to
---continue casting buffs on other members
function BOM.AddMemberToSkipList()
  if BOM.CastFailedSpell
          and BOM.CastFailedSpell.SkipList
          and BOM.CastFailedSpellTarget then
    tinsert(BOM.CastFailedSpell.SkipList, BOM.CastFailedSpellTarget.name)
    BOM.FastUpdateTimer()
    BOM.SetForceUpdate("SkipListMemberAdded")
  end
end

function BOM.ClearSkip()
  for spellIndex, spell in ipairs(BOM.SelectedSpells) do
    if spell.SkipList then
      wipe(spell.SkipList)
    end
  end
end

---On Combat Start go through cancel buffs list and cancel those bufs
function BOM.DoCancelBuffs()
  if BOM.SelectedSpells == nil or BOM.CurrentProfile == nil then
    return
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and bomCancelBuff(spell.singleFamily)
    then
      BOM.Print(string.format(L.MsgCancelBuff, spell.singleLink or spell.single,
              UnitName(BOM.CancelBuffSource) or ""))
    end
  end
end
