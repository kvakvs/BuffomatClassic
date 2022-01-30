---@type BuffomatAddon
local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

local bomSaveSomeoneIsDead = false

BOM.ALL_PROFILES = { "solo", "group", "raid", "battleground" }

local tasklist ---@type TaskList

local function bomIsFlying()
  if BOM.TBC then
    return IsFlying() and not BOM.SharedState.AutoDismountFlying
  end
  return false
end

local function bomIsMountedAndCrusaderAuraRequired()
  return BOM.SharedState.AutoCrusaderAura -- if setting enabled
          and IsSpellKnown(BOM.SpellId.Paladin.CrusaderAura) -- and has the spell
          and (IsMounted() or bomIsFlying()) -- and flying
          and GetShapeshiftForm() ~= 7 -- and not crusader aura
end

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

---@class CachedItem
---@field a boolean Player has item
---@field b number Bag
---@field c number Slot
---@field d number Count

---@type table<string, CachedItem>
BOM.CachedHasItems = {}

---Check whether the player has item
-- TODO: Can move into Buffomat main operation class together with item cache?
---@param list table - the item?
---@param cd boolean - respect the cooldown?
---@return boolean, number|nil, number|nil, number {HasItem, Bag, Slot, Count}
local function bomHasItem(list, cd)
  if list == nil then
    return true, nil, nil, 1 -- spell.items is nil, no items required
  end

  local key = list[1] .. (cd and "CD" or "")
  local cachedItem = BOM.CachedHasItems[key]

  if not cachedItem then
    BOM.CachedHasItems[key] = {}
    cachedItem = BOM.CachedHasItems[key]
    cachedItem.a = false
    cachedItem.d = 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink
        , isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        if tContains(list, itemID) then
          if cd then
            cachedItem.a, cachedItem.b, cachedItem.c = true, bag, slot
            cachedItem.d = cachedItem.d + itemCount

          else
            cachedItem.a = true
            return true
          end
        end
      end
    end
  end

  if cd and cachedItem.b and cachedItem.c then
    local startTime, _, _ = GetContainerItemCooldown(cachedItem.b, cachedItem.c)
    if (startTime or 0) == 0 then
      return cachedItem.a, cachedItem.b, cachedItem.c, cachedItem.d
    else
      return false, cachedItem.b, cachedItem.c, cachedItem.d
    end
  end

  return cachedItem.a
end

---Unused
--local function bom_spell_link_from_spell(spell)
--  return bomFormatSpellLink(BOM.GetSpellInfo(spell))
--end

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

local function bomHunterPetNeedsBuff(spellId)
  if not BOM.TBC then
    return false -- pre-TBC this did not exist
  end

  local pet = BOM.GetMember("pet")
  if not pet then
    return false -- no pet - no problem
  end

  if pet.buffs[spellId] then
    return false -- have pet, have buff
  end

  return true
end

---Check for party, spell and player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param party table<number, Member> - the party
---@param spell SpellDef - the spell to update
---@param playerMember Member - the player
---@param someoneIsDead boolean - the flag that buffing cannot continue while someone is dead
---@return boolean someoneIsDead
local function bomUpdateSpellTargets(party, spell, playerMember, someoneIsDead)
  spell.NeedMember = spell.NeedMember or {}
  spell.NeedGroup = spell.NeedGroup or {}
  spell.DeathGroup = spell.DeathGroup or {}

  local isPlayerBuff = playerMember.buffs[spell.ConfigID]

  wipe(spell.NeedGroup)
  wipe(spell.NeedMember)
  wipe(spell.DeathGroup)

  if not BOM.IsSpellEnabled(spell.ConfigID) then
    --nothing!

  elseif spell.type == "weapon" then
    local weaponSpell = BOM.GetProfileSpell(spell.ConfigID)

    if (weaponSpell.MainHandEnable and playerMember.MainHandBuff == nil)
            or (weaponSpell.OffHandEnable and playerMember.OffHandBuff == nil)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.tbcHunterPetBuff then
    -- NOTE: This must go before spell.IsConsumable clause
    -- For TBC hunter pet buffs we check if the pet is missing the buff
    -- but then the hunter must consume it
    if bomHunterPetNeedsBuff(spell.singleId) then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isConsumable then
    if not isPlayerBuff then
      tinsert(spell.NeedMember, playerMember)
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
    if not playerMember.isDead then
      if spell.lockIfHaveItem then
        if IsSpellKnown(spell.singleId) and not (bomHasItem(spell.lockIfHaveItem)) then
          tinsert(spell.NeedMember, playerMember)
        end
      elseif not (isPlayerBuff
              and bomTimeCheck(isPlayerBuff.expirationTime, isPlayerBuff.duration))
      then
        tinsert(spell.NeedMember, playerMember)
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
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.type == "aura" then
    if BOM.ActivAura ~= spell.ConfigID
            and (BOM.CurrentProfile.LastAura == nil or BOM.CurrentProfile.LastAura == spell.ConfigID)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.type == "seal" then
    if BOM.ActivSeal ~= spell.ConfigID
            and (BOM.CurrentProfile.LastSeal == nil or BOM.CurrentProfile.LastSeal == spell.ConfigID)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isBlessing then
    for i, member in ipairs(party) do
      local ok = false
      local notGroup = false
      local blessing_name = BOM.GetProfileSpell(BOM.BLESSING_ID)
      local blessingSpell = BOM.GetProfileSpell(spell.ConfigID)

      if blessing_name[member.name] == spell.ConfigID
              or (member.isTank
              and blessingSpell.Class["tank"]
              and not blessingSpell.SelfCast)
      then
        ok = true
        notGroup = true

      elseif blessing_name[member.name] == nil then
        if blessingSpell.Class[member.class]
                and (not IsInRaid() or BomCharacterState.WatchGroup[member.group])
                and not blessingSpell.SelfCast then
          ok = true
        end
        if blessingSpell.SelfCast
                and UnitIsUnit(member.unitId, "player") then
          ok = true
        end
      end

      if blessingSpell.ForcedTarget[member.name] then
        ok = true
      end
      if blessingSpell.ExcludedTarget[member.name] then
        ok = false
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        local found = false
        local member_buff = member.buffs[spell.ConfigID]

        if member.isDead then
          if member.group ~= 9 and member.class ~= "pet" then
            someoneIsDead = true
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
      local profileSpell = BOM.CurrentProfile.Spell[spell.ConfigID]

      if profileSpell.Class[member.class]
              and (not IsInRaid() or BomCharacterState.WatchGroup[member.group])
              and not profileSpell.SelfCast then
        ok = true
      end
      if profileSpell.SelfCast
              and UnitIsUnit(member.unitId, "player") then
        ok = true
      end
      if member.isTank and profileSpell.Class["tank"]
              and not profileSpell.SelfCast then
        ok = true
      end
      if profileSpell.ForcedTarget[member.name] then
        ok = true
      end
      if profileSpell.ExcludedTarget[member.name] then
        ok = false
      end

      if member.NeedBuff
              and ok
              and member.isConnected
              and (not BOM.SharedState.SameZone or member.isSameZone) then
        local found = false
        local member_buff = member.buffs[spell.ConfigID]

        if member.isDead then
          someoneIsDead = true
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

      someoneIsDead = false
    end
  end

  return someoneIsDead
end

---Updates the BOM macro
---@param member table - next target to buff
---@param spellId number - spell to cast
---@param command string - bag command
local function bomUpdateMacro(member, spellId, command)
  local macro = BOM.Macro
  macro:Recreate()
  wipe(macro.lines)

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

          for i, id in ipairs(x) do
            if BOM.SharedState.SpellGreatherEqualThan[id] == nil or BOM.SharedState.SpellGreatherEqualThan[id] < level then
              newSpellId = id
            else
              break
            end
            if id == spellId then
              break
            end
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

    if tContains(BOM.cancelForm, spellId) then
      tinsert(macro.lines, "/cancelform [nocombat]")
    end
    tinsert(macro.lines, "/bom _checkforerror")
    tinsert(macro.lines, "/cast [@" .. member.unitId .. ",nocombat]" .. name .. rank)
    macro.icon = BOM.MACRO_ICON
  else
    if command then
      tinsert(macro.lines, command)
    end
    macro.icon = BOM.MACRO_ICON_DISABLED
  end

  macro:UpdateMacro()
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
---@param spellName string
---@param party table<number, Member>
---@param class string
---@param spell SpellDef
local function bomGetClassInRange(spellName, party, class, spell)
  local minDist
  local ret

  for i, member in ipairs(party) do
    if member.class == class then
      if member.isDead then
        return nil

      elseif not (IsSpellInRange(spellName, member.unitId) == 1) then
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
local bomCurrentPlayerMana

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
  if cost > bomCurrentPlayerMana then
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

  -- Cancel buff task scan while mounted
  if not BOM.SharedState.ScanWhileMounted and IsMounted() then
    return false, L.InactiveReason_Mounted
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  if not BOM.SharedState.ScanInStealth and IsStealthed() then
    return false, L.InactiveReason_IsStealthed
  end

  -- Having auto crusader aura enabled and Paladin class, and aura other than
  -- Crusader will block this check temporarily
  if bomIsFlying() and not bomIsMountedAndCrusaderAuraRequired() then
    -- prevent dismount in flight, OUCH!
    return false, L.MsgFlying

  elseif UnitOnTaxi("player") then
    return false, L.MsgOnTaxi
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

  bomSaveSomeoneIsDead = someone_is_dead
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

-----@param spell SpellDef
-----@param groupIndex number
-----@param classColorize boolean
-----@return string
--local function bomFormatGroupBuffText(groupIndex, spell, classColorize)
--  if classColorize then
--    return string.format(L.FORMAT_BUFF_GROUP,
--            "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r",
--            spell.groupLink or spell.group or "")
--  end
--
--  return string.format(L.FORMAT_BUFF_GROUP,
--          BOM.Tool.ClassName[groupIndex] or "?",
--          spell.groupLink or spell.group or "")
--end

-- ---@param prefix string Icon or some sort of string to prepend
-- ---@param member Member
-- ---@param spell SpellDef
-- ---@return string
--local function bomFormatSingleBuffText(prefix, member, spell)
--  return string.format(L.FORMAT_BUFF_SINGLE,
--          (prefix or "") .. member:GetText(),
--          (spell.singleLink or spell.single))
--end

---@param name string Consumable name to show
---@param count number How many of that consumable is available
local function bomFormatItemBuffInactiveText(name, count)
  if count == 0 then
    return string.format("%s (%s)", name, L.OUT_OF_THAT_ITEM)
  end

  return string.format("%s (x%d)", name, count)
end

---@return string
local function bomFormatItemBuffText(bag, slot, count)
  local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
  return string.format(" %s %s (x%d)",
          BOM.FormatTexture(texture),
          item_link,
          count)
end

---Add a paladin blessing
---@param spell SpellDef - spell to cast
---@param party table<number, Member> - the party
---@param playerMember table - player
---@param inRange boolean - spell target is in range
local function bomAddBlessing(spell, party, playerMember, inRange)
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
    -- For each class name WARRIOR, PALADIN, PRIEST, SHAMAN... etc
    for i, eachClassName in ipairs(BOM.Tool.Classes) do
      if spell.NeedGroup[eachClassName]
              and spell.NeedGroup[eachClassName] >= BOM.SharedState.MinBlessing
      then
        BOM.RepeatUpdate = true
        local classInRange = bomGetClassInRange(spell.group, spell.NeedMember, eachClassName, spell)

        if classInRange == nil then
          classInRange = bomGetClassInRange(spell.group, party, eachClassName, spell)
        end

        if classInRange ~= nil
                and (not spell.DeathGroup[eachClassName] or not BOM.SharedState.DeathBlock)
        then
          -- Group buff (Blessing)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  L.TASK_BLESS_GROUP,
                  spell.groupLink or spell.group,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(eachClassName),
                  false)
          inRange = true

          bomQueueSpell(spell.groupMana, spell.groupId, spell.groupLink, classInRange, spell)
        else
          -- Group buff (Blessing) just info text
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  L.TASK_BLESS_GROUP,
                  spell.groupLink or spell.group,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(eachClassName),
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
        inRange = true

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

---Add a generic buff of some sorts, or a group buff
---@param spell SpellDef - spell to cast
---@param party table<number, Member> - the party
---@param playerMember Member - player
---@param inRange boolean - spell target is in range
local function bomAddBuff(spell, party, playerMember, inRange)
  local ok, bag, slot, count

  if spell.reagentRequired then
    ok, bag, slot, count = bomHasItem(spell.reagentRequired, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  ------------------------
  -- Add GROUP BUFF
  ------------------------
  if spell.groupMana ~= nil and not BOM.SharedState.NoGroupBuff then
    for groupIndex = 1, 8 do
      if spell.NeedGroup[groupIndex]
              and spell.NeedGroup[groupIndex] >= BOM.SharedState.MinBuff
      then
        BOM.RepeatUpdate = true
        local Group = bomGetGroupInRange(spell.group, spell.NeedMember, groupIndex, spell)

        if Group == nil then
          Group = bomGetGroupInRange(spell.group, party, groupIndex, spell)
        end

        if Group ~= nil
                and (not spell.DeathGroup[groupIndex] or not BOM.SharedState.DeathBlock)
        then
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  L.BUFF_CLASS_GROUPBUFF,
                  spell.groupLink or spell.group,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(groupIndex),
                  false)
          inRange = true

          bomQueueSpell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)
        else
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  L.BUFF_CLASS_GROUPBUFF,
                  spell.groupLink or spell.group,
                  spell.single,
                  "",
                  BOM.Class.GroupBuffTarget:new(groupIndex),
                  false)
        end -- if group not nil
      end
    end -- for all 8 groups
  end

  ------------------------
  -- Add SINGLE BUFF
  ------------------------
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
        inRange = true
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

  return inRange
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param player_member table - the player
---@param inRange boolean - value for range check
---@return table (bag_title string, bag_command string)
local function bomAddResurrection(spell, player_member, inRange)
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
      local targetIsInRange = (IsSpellInRange(spell.single, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if targetIsInRange then
        inRange = true
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
        -- Text: Range Target "SpellName"
        tasklist:AddWithPrefix(
                L.TASK_CLASS_RESURRECT,
                spell.singleLink or spell.single,
                spell.single,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                true,
                BOM.TaskPriority.Resurrection)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if targetIsInRange or (BOM.SharedState.ResGhost and member.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      end
    end
  end

  return inRange
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell SpellDef - the spell to cast
---@param playerMember Member - the player
local function bomAddSelfbuff(spell, playerMember)
  if spell.requiresWarlockPet then
    if not UnitExists("pet") or UnitCreatureType("pet") ~= "Demon" then
      return -- No demon pet - buff can not be casted
    end
  end

  if (not spell.requiresOutdoors or IsOutdoors())
          and not tContains(spell.SkipList, playerMember.name) then
    -- Text: Target [Spell Name]
    tasklist:AddWithPrefix(
            L.TASK_CAST,
            spell.singleLink or spell.single,
            spell.single,
            L.BUFF_CLASS_SELF_ONLY,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  else
    -- Text: Target "SpellName"
    tasklist:AddWithPrefix(
            L.TASK_CAST,
            spell.singleLink or spell.single,
            spell.single,
            L.BUFF_CLASS_SELF_ONLY,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            true)
  end
end

---Adds a summon spell to the tasks
---@param spell SpellDef - the spell to cast
---@param playerMember Member
local function bomAddSummonSpell(spell, playerMember)
  if spell.sacrificeAuraIds then
    for i, id in ipairs(spell.sacrificeAuraIds) do
      if playerMember.buffExists[id] then
        return
      end
    end -- for each sacrifice aura id
  end

  local add = false

  if not UnitExists("pet") then
    -- No pet? Need summon
    add = true
  else
    -- Have pet? Check pet type
    local ucType = UnitCreatureType("pet")
    local ucFamily = UnitCreatureFamily("pet")

    if ucType ~= spell.creatureType or ucFamily ~= spell.creatureFamily then
      add = true
    end
  end

  if add then
    -- Text: Summon [Spell Name]
    tasklist:AddWithPrefix(
            L.TASK_SUMMON,
            spell.singleLink or spell.single,
            spell.single,
            nil,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  end
end

---Adds a display text for a weapon buff
---@param spell SpellDef - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@param target string Insert this text into macro where [@player] target text would go
---@return string, string {cast_button_title, bag_macro_command}
local function bomAddConsumableSelfbuff(spell, playerMember, castButtonTitle, macroCommand, target)
  local haveItemOffCD, bag, slot, count = bomHasItem(spell.items, true)
  count = count or 0

  local taskText = L.TASK_USE
  if spell.tbcHunterPetBuff then
    taskText = L.TASK_TBC_HUNTER_PET_BUFF
  end

  if haveItemOffCD then
    if BOM.SharedState.DontUseConsumables
            and not IsModifierKeyDown() then
      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
              bomFormatItemBuffText(bag, slot, count),
              nil,
              L.BUFF_CONSUMABLE_REMINDER,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      if target then
        macroCommand = string.format("/use [@%s] %d %d", target, bag, slot)
      else
        macroCommand = string.format("/use %d %d", bag, slot)
      end
      castButtonTitle = L.TASK_USE .. " " .. spell.single

      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
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
              bomFormatItemBuffInactiveText(spell.single, count),
              nil,
              "",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a consumable item
---@param spell SpellDef - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
local function bomAddConsumableWeaponBuff(spell, playerMember,
                                          castButtonTitle, macroCommand)
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
                "(" .. L.TooltipOffHand .. ") " .. L.BUFF_CONSUMABLE_REMINDER,
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Off-hand)
        castButtonTitle = offhand_message()
        macroCommand = "/use " .. bag .. " " .. slot
                .. "\n/use 17" -- offhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. L.TooltipOffHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                false)
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
                "(" .. L.TooltipMainHand .. ") " .. L.BUFF_CONSUMABLE_REMINDER,
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        castButtonTitle = mainhand_message()
        macroCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. L.TooltipMainHand .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                false)
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

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a spell (shamans and paladins)
---@param spell SpellDef - the spell to cast
---@param playerMember Member - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
local function bomAddWeaponEnchant(spell, playerMember,
                                   castButtonTitle, macroCommand)
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
            L.TooltipMainHand,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)
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
              L.TooltipOffHand .. ": " .. L.ShamanEnchantBlocked,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      -- Text: [Spell Name] (Off-hand)
      tasklist:Add(
              spell.singleLink,
              spell.single,
              L.TooltipOffHand,
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              false)
      bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
              playerMember, spell)
    end
  end

  return castButtonTitle, macroCommand
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

  local itemTrinket1, _ = GetInventoryItemID("player", 13)
  local itemTrinket2, _ = GetInventoryItemID("player", 14)

  if BOM.SharedState.ArgentumDawn then
    -- settings to remind to remove AD trinket != instance compatible with AD Commission
    --if playerMember.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.zoneId, instanceID) then
    local hasArgentumDawn = tContains(BOM.ArgentumDawn.itemIds, itemTrinket1) or
            tContains(BOM.ArgentumDawn.itemIds, itemTrinket2)
    if hasArgentumDawn and not tContains(BOM.ArgentumDawn.zoneId, instanceID) then
      -- Text: Unequip [Argent Dawn Commission]
      tasklist:Comment(L.TASK_UNEQUIP .. " " .. L.AD_REPUTATION_REMINDER)
    end
  end

  if BOM.SharedState.Carrot then
    local hasCarrot = tContains(BOM.Carrot.itemIds, itemTrinket1) or
            tContains(BOM.Carrot.itemIds, itemTrinket2)
    if hasCarrot and not tContains(BOM.Carrot.zoneId, instanceID) then
      -- Text: Unequip [Carrot on a Stick]
      tasklist:Comment(L.TASK_UNEQUIP .. " " .. L.RIDING_SPEED_REMINDER)
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
      tasklist:Comment(L.MSG_MAINHAND_ENCHANT_MISSING)
    end
  end

  if BOM.SharedState.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))

    if link then
      tasklist:Comment(L.MSG_OFFHAND_ENCHANT_MISSING)
    end
  end
end

---@param playerMember Member
---@param cast_button_title string
---@param macro_command string
---@return string, string {cast_button_title, macro_command}
local function bomCheckItemsAndContainers(playerMember, cast_button_title, macro_command)
  --itemcheck
  local allPlayerItems = BOM.GetItemList() ---@type table<number, GetContainerItemInfoResult>

  for i, item in ipairs(allPlayerItems) do
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

---@param spell SpellDef
---@param playerMember Member
---@param party table<number, Member>
---@param inRange boolean
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
local function bomScanOneSpell(spell, playerMember, party, inRange,
                               castButtonTitle, macroCommand)
  if #spell.NeedMember > 0
          and not spell.isInfo
          and not spell.isConsumable
  then
    if spell.singleMana < BOM.ManaLimit
            and spell.singleMana > bomCurrentPlayerMana then
      BOM.ManaLimit = spell.singleMana
    end

    if spell.groupMana
            and spell.groupMana < BOM.ManaLimit
            and spell.groupMana > bomCurrentPlayerMana then
      BOM.ManaLimit = spell.groupMana
    end
  end

  if spell.type == "summon" then
    bomAddSummonSpell(spell, playerMember)

  elseif spell.type == "weapon" then
    if #spell.NeedMember > 0 then
      if spell.isConsumable then
        castButtonTitle, macroCommand = bomAddConsumableWeaponBuff(
                spell, playerMember, castButtonTitle, macroCommand)
      else
        castButtonTitle, macroCommand = bomAddWeaponEnchant(spell, playerMember)
      end
    end

  elseif spell.isConsumable then
    if #spell.NeedMember > 0 then
      castButtonTitle, macroCommand = bomAddConsumableSelfbuff(
              spell, playerMember, castButtonTitle, macroCommand, spell.consumableTarget)
      inRange = true
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
    inRange = bomAddResurrection(spell, playerMember, inRange)

  elseif spell.isBlessing then
    inRange = bomAddBlessing(spell, party, playerMember, inRange)

  else
    inRange = bomAddBuff(spell, party, playerMember, inRange)
  end

  return inRange, castButtonTitle, macroCommand
end

---@param playerMember Member
---@param party table<number, Member>
---@param inRange boolean
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
local function bomScanSelectedSpells(playerMember, party, inRange, castButtonTitle, macroCommand)
  for _, spell in ipairs(BOM.SelectedSpells) do
    local profile_spell = BOM.GetProfileSpell(spell.ConfigID)

    if spell.isInfo and profile_spell.Whisper then
      bomWhisperExpired(spell)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if BOM.IsSpellEnabled(spell.ConfigID)
            and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then
      inRange, castButtonTitle, macroCommand = bomScanOneSpell(
              spell, playerMember, party, inRange, castButtonTitle, macroCommand)
    end
  end

  return inRange, castButtonTitle, macroCommand
end

---When a paladin is mounted and AutoCrusaderAura enabled,
---offer player to cast Crusader Aura.
---@return boolean True if the scanning should be interrupted and only crusader aura prompt will be visible
local function bomMountedCrusaderAuraPrompt()
  local playerMember = BOM.GetMember("player")

  if bomIsMountedAndCrusaderAuraRequired() then
    local spell = BOM.CrusaderAuraSpell
    tasklist:AddWithPrefix(
            L.TASK_CAST,
            spell.singleLink or spell.single,
            spell.single,
            L.BUFF_CLASS_SELF_ONLY,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    bomQueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)

    return true -- only show the aura and nothing else
  end

  return false -- continue scanning spells
end

local function bomUpdateScan_Scan()
  local party, playerMember = BOM.GetPartyMembers()

  local someoneIsDead = bomSaveSomeoneIsDead
  if BOM.ForceUpdate then
    someoneIsDead = bomForceUpdate(party, playerMember)
  end

  -- cancel buffs
  bomCancelBuffs(playerMember)

  -- fill list and find cast
  bomCurrentPlayerMana = UnitPower("player", 0) or 0 --mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  bomClearNextCastSpell()

  local macroCommand ---@type string
  local castButtonTitle ---@type string
  local inRange = false

  -- Cast crusader aura when mounted, without condition. Ignore all other buffs
  if bomMountedCrusaderAuraPrompt() then
    -- Do not scan other spells
    castButtonTitle = "Crusader"
    macroCommand = "/cast Crusader Aura"
  else
    -- Otherwise scan all enabled spells
    BOM.ScanModifier = false

    inRange, castButtonTitle, macroCommand = bomScanSelectedSpells(
            playerMember, party, inRange,
            castButtonTitle, macroCommand)

    bomCheckReputationItems(playerMember)
    bomCheckMissingWeaponEnchantments(playerMember) -- if option to warn is enabled

    ---Check if someone has drink buff, print an info message
    if BOM.drinkingPersonCount > 1 then
      tasklist:Comment(string.format(L.InfoMultipleDrinking, BOM.drinkingPersonCount))
    elseif BOM.drinkingPersonCount > 0 then
      tasklist:Comment(L.InfoSomeoneIsDrinking)
    end

    castButtonTitle, macroCommand = bomCheckItemsAndContainers(
            playerMember, castButtonTitle, macroCommand)
  end

  -- Open Buffomat if any cast tasks were added to the task list
  if #tasklist.tasks > 0 or #tasklist.comments > 0 then
    BOM.AutoOpen()
  else
    BOM.AutoClose()
  end

  tasklist:Display() -- Show all tasks and comments

  BOM.ForceUpdate = false

  if BOM.PlayerCasting == "cast" then
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
      if someoneIsDead and BOM.SharedState.DeathBlock then
        bomCastButton(L.InactiveReason_DeadMember, false)
      else
        if inRange then
          -- Range is good but cast is not possible
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

    if castButtonTitle then
      bomCastButton(castButtonTitle, true)
    end

    bomUpdateMacro(nil, nil, macroCommand)
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
  local isBomActive, reasonDisabled = bomIsActive()
  if not isBomActive then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BOM.AutoClose()
    BOM.Macro:Clear()
    bomCastButton(reasonDisabled, false)
    return
  end

  --Choose Profile
  local auto_profile = bomChooseProfile()

  if BOM.CurrentProfile ~= BOM.CharacterState[auto_profile] then
    BOM.CurrentProfile = BOM.CharacterState[auto_profile]
    BOM.UpdateSpellsTab("UpdateScan1")
    BomC_MainWindow_Title:SetText(
            BOM.FormatTexture(BOM.BOM_BEAR_ICON_FULLPATH)
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
