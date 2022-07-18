local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomTaskScanModule
local taskScanModule = BuffomatModule.DeclareModule("TaskScan") ---@type BomTaskScanModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local spellButtonsTabModule = BuffomatModule.Import("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

taskScanModule.saveSomeoneIsDead = false

BOM.ALL_PROFILES = { "solo", "group", "raid", "battleground" }

local tasklist ---@type TaskList

function taskScanModule:IsFlying()
  if BOM.TBC then
    return IsFlying() and not BOM.SharedState.AutoDismountFlying
  end
  return false
end

function taskScanModule:IsMountedAndCrusaderAuraRequired()
  return BOM.SharedState.AutoCrusaderAura -- if setting enabled
          and IsSpellKnown(BOM.SpellId.Paladin.CrusaderAura) -- and has the spell
          and (IsMounted() or self:IsFlying()) -- and flying
          and GetShapeshiftForm() ~= 7 -- and not crusader aura
end

function taskScanModule:SetupTasklist()
  tasklist = BOM.Class.TaskList:new()
end

function taskScanModule:CancelBuff(list)
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
  return taskScanModule:CancelBuff(ShapeShiftTravel)
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
function taskScanModule:HasItem(list, cd)
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
function taskScanModule:MaybeResetWatchGroups()
  if UnitPlayerOrPetInParty("player") == false then
    -- We have left the party - can clear monitored groups
    local need_to_report = false

    for i = 1, 8 do
      if not BomCharacterState.WatchGroup[i] then
        BomCharacterState.WatchGroup[i] = true
        spellButtonsTabModule.spellSettingsFrames[i]:SetState(true)
        need_to_report = true
      end
    end

    buffomatModule:UpdateBuffTabText()

    if need_to_report then
      BOM:Print(_t("ResetWatchGroups"))
    end
  end
end

---Checks whether a tracking spell is now active
---@param spell BomSpellDef The tracking spell which might have tracking enabled
function taskScanModule:IsTrackingActive(spell)
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
---@param spell BomSpellDef The tracking spell to activate
---@param value boolean Whether tracking should be enabled
function taskScanModule:SetTracking(spell, value)
  if BOM.TBC then
    for i = 1, GetNumTrackingTypes() do
      local name, texture, active, _category, _nesting, spellId = GetTrackingInfo(i)
      if spellId == spell.singleId then
        -- found, compare texture with spell icon
        --BOM:Print(_t("ActivateTracking") .. " " .. name)
        SetTracking(i, value)
        return
      end
    end
  else
    --BOM:Print(_t("ActivateTracking") .. " " .. spell.trackingSpellName)
    CastSpellByID(spell.singleId)
  end
end

---@param expirationTime number Buff expiration time
---@param maxDuration number Max buff duration
function taskScanModule:TimeCheck(expirationTime, maxDuration)
  if expirationTime == nil
          or maxDuration == nil
          or expirationTime == 0
          or maxDuration == 0 then
    return true
  end

  local remainingTimeTrigger

  if maxDuration <= 60 then
    remainingTimeTrigger = BOM.SharedState.Time60 or 10
  elseif maxDuration <= 300 then
    remainingTimeTrigger = BOM.SharedState.Time300 or 90
  elseif maxDuration <= 600 then
    remainingTimeTrigger = BOM.SharedState.Time600 or 120
  elseif maxDuration <= 1800 then
    remainingTimeTrigger = BOM.SharedState.Time1800 or 180
  else
    remainingTimeTrigger = BOM.SharedState.Time3600 or 180
  end

  if remainingTimeTrigger + GetTime() < expirationTime then
    expirationTime = expirationTime - remainingTimeTrigger
    if expirationTime < BOM.MinTimer then
      BOM.MinTimer = expirationTime
    end
    return true
  end

  return false
end

function taskScanModule:HunterPetNeedsBuff(spellId)
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
---@param party table<number, BomUnit> - the party
---@param spell BomSpellDef - the spell to update
---@param playerMember BomUnit - the player
---@param someoneIsDead boolean - the flag that buffing cannot continue while someone is dead
---@return boolean someoneIsDead
function taskScanModule:UpdateSpellTargets(party, spell, playerMember, someoneIsDead)
  spell.NeedMember = spell.NeedMember or {}
  spell.NeedGroup = spell.NeedGroup or {}
  spell.DeathGroup = spell.DeathGroup or {}

  local isPlayerBuff = playerMember.buffs[spell.ConfigID]

  wipe(spell.NeedGroup)
  wipe(spell.NeedMember)
  wipe(spell.DeathGroup)

  if not spellDefModule:IsSpellEnabled(spell.ConfigID) then
    --nothing, the spell is not enabled!

  elseif spellButtonsTabModule:CategoryIsHidden(spell.category) then
    --nothing, the category is not showing!

  elseif spell.type == "weapon" then
    local weaponSpell = spellDefModule:GetProfileSpell(spell.ConfigID)

    if (weaponSpell.MainHandEnable and playerMember.MainHandBuff == nil)
            or (weaponSpell.OffHandEnable and playerMember.OffHandBuff == nil)
    then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.tbcHunterPetBuff then
    -- NOTE: This must go before spell.IsConsumable clause
    -- For TBC hunter pet buffs we check if the pet is missing the buff
    -- but then the hunter must consume it
    if self:HunterPetNeedsBuff(spell.singleId) then
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
        if IsSpellKnown(spell.singleId) and not (self:HasItem(spell.lockIfHaveItem)) then
          tinsert(spell.NeedMember, playerMember)
        end
      elseif not (isPlayerBuff
              and self:TimeCheck(isPlayerBuff.expirationTime, isPlayerBuff.duration))
      then
        tinsert(spell.NeedMember, playerMember)
      end
    end

  elseif spell.type == "resurrection" then
    for i, member in ipairs(party) do
      if member.isDead
              and not member.hasResurrection
              and member.isConnected
              and member.class ~= "pet"
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
            and spellDefModule:IsSpellEnabled(BOM.SpellId.Druid.TrackHumanoids) then
      -- Do nothing - ignore herbs and minerals in catform if enabled track humanoids
    elseif not self:IsTrackingActive(spell)
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
      local blessing_name = spellDefModule:GetProfileSpell(constModule.BLESSING_ID)
      local blessingSpell = spellDefModule:GetProfileSpell(spell.ConfigID)

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
          found = self:TimeCheck(member_buff.expirationTime, member_buff.duration)
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
      ---@type BomSpellDef
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
              and (not BOM.SharedState.SameZone
              or (member.isSameZone
              or member.class == "pet" and member.owner.isSameZone)) then
        local found = false
        local member_buff = member.buffs[spell.ConfigID]

        if member.isDead then
          someoneIsDead = true
          spell.DeathGroup[member.group] = true

        elseif member_buff then
          found = self:TimeCheck(member_buff.expirationTime, member_buff.duration)
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
function taskScanModule:UpdateMacro(member, spellId, command)
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
    macro.icon = constModule.MACRO_ICON
  else
    if command then
      tinsert(macro.lines, command)
    end
    macro.icon = constModule.MACRO_ICON_DISABLED
  end

  macro:UpdateMacro()
end

function taskScanModule:GetGroupInRange(SpellName, party, groupNb, spell)
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
---@param party table<number, BomUnit>
---@param class string
---@param spell BomSpellDef
function taskScanModule:GetClassInRange(spellName, party, class, spell)
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
---@field Spell BomSpellDef
---@field Link string|nil
---@field Member string|nil
---@field SpellId number|nil
---@field manaCost number
local next_cast_spell = {}

---@type number
local bomCurrentPlayerMana

---@param link string Clickable spell link with icon
---@param inactiveText string Spell name as text
---@param member BomUnit
---@return boolean True if spell cast is prevented by PvP guard, false if spell can be casted
function taskScanModule:PreventPvpTagging(link, inactiveText, member)
  if BOM.SharedState.PreventPVPTag then
    -- TODO: Move Player PVP check and instance check outside
    local _in_instance, instance_type = IsInInstance()
    if instance_type == "none"
            and not UnitIsPVP("player")
            and UnitIsPVP(member.name) then
      -- Text: [Spell Name] Player is PvP
      tasklist:Add(link, inactiveText,
              _t("PreventPVPTagBlocked"), member, true)
      return true
    end
  end
  return false
end

---Stores a spell with cost/id/spell link to be casted in the `cast` global
---@param cost number Resource cost (mana cost)
---@param id number Spell id to capture
---@param link string Spell link for a picture
---@param member BomUnit player to benefit from the spell
---@param spell BomSpellDef the spell to be added
function taskScanModule:QueueSpell(cost, id, link, member, spell)
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
function taskScanModule:ClearNextCastSpell()
  next_cast_spell.manaCost = -1
  next_cast_spell.SpellId = nil
  next_cast_spell.Member = nil
  next_cast_spell.Spell = nil
  next_cast_spell.Link = nil
end

---Run checks to see if BOM should not be scanning buffs
---@return boolean, string {Active, WhyNotActive: string}
---@param playerUnit BomUnit
function taskScanModule:IsActive(playerUnit)
  local in_instance, instance_type = IsInInstance()

  -- Cancel buff tasks if in combat (ALWAYS FIRST CHECK)
  if InCombatLockdown() then
    return false, _t("InactiveReason_InCombat")
  end

  if UnitIsDeadOrGhost("player") then
    return false, _t("InactiveReason_PlayerDead")
  end

  if instance_type == "pvp" or instance_type == "arena" then
    if not BOM.SharedState.InPVP then
      return false, _t("InactiveReason_PvpZone")
    end

  elseif instance_type == "party"
          or instance_type == "raid"
          or instance_type == "scenario"
  then
    if not BOM.SharedState.InInstance then
      return false, _t("InactiveReason_Instance")
    end
  else
    if not BOM.SharedState.InWorld then
      return false, _t("InactiveReason_OpenWorld")
    end
  end

  -- Cancel buff tasks if is in a resting area, and option to scan is not set
  if not BOM.SharedState.ScanInRestArea and IsResting() then
    return false, _t("InactiveReason_RestArea")
  end

  -- Cancel buff task scan while mounted
  if not BOM.SharedState.ScanWhileMounted and IsMounted() then
    return false, _t("InactiveReason_Mounted")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  if not BOM.SharedState.ScanInStealth and IsStealthed() then
    return false, _t("InactiveReason_IsStealthed")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  -- and current mana is < 90%
  local spiritTapManaPercent = (BOM.SharedState.ActivateBomOnSpiritTap or 0) * 0.01
  local currentMana = bomCurrentPlayerMana or UnitPower("player", 0)
  if playerUnit.buffExists[BOM.SpellId.Priest.SpiritTap]
          and currentMana < UnitPowerMax("player", 0) * spiritTapManaPercent then
    return false, _t("InactiveReason_SpiritTap")
  end

  -- Having auto crusader aura enabled and Paladin class, and aura other than
  -- Crusader will block this check temporarily
  if self:IsFlying() and not self:IsMountedAndCrusaderAuraRequired() then
    -- prevent dismount in flight, OUCH!
    return false, _t("MsgFlying")

  elseif UnitOnTaxi("player") then
    return false, _t("MsgOnTaxi")
  end

  return true, nil
end

---Based on profile settings and current PVE or PVP instance choose the mode
---of operation
---@return string
function taskScanModule:ChooseProfile()
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
function taskScanModule:ActivateSelectedTracking()
  --reset tracking
  BOM.ForceTracking = nil

  ---@param spell BomSpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "tracking" then
      if spellDefModule:IsSpellEnabled(spell.ConfigID) then
        if spell.needForm ~= nil then
          if GetShapeshiftFormID() == spell.needForm
                  and BOM.ForceTracking ~= spell.trackingIconId then
            BOM.ForceTracking = spell.trackingIconId
            spellButtonsTabModule:UpdateSpellsTab("ForceUp1")
          end
        elseif self:IsTrackingActive(spell)
                and BOM.CharacterState.LastTracking ~= spell.trackingIconId then
          BOM.CharacterState.LastTracking = spell.trackingIconId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp2")
        end
      else
        if BOM.CharacterState.LastTracking == spell.trackingIconId
                and BOM.CharacterState.LastTracking ~= nil then
          BOM.CharacterState.LastTracking = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp3")
        end
      end -- if spell.enable
    end -- if tracking
  end -- for all spells

  if BOM.ForceTracking == nil then
    BOM.ForceTracking = BOM.CharacterState.LastTracking
  end
end

---@param player_member BomUnit
function taskScanModule:GetActiveAuraAndSeal(player_member)
  --find activ aura / seal
  BOM.ActivAura = nil
  BOM.ActivSeal = nil

  ---@param spell BomSpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    local player_buff = player_member.buffs[spell.ConfigID]

    if player_buff then
      if spell.type == "aura" then
        if (BOM.ActivAura == nil and BOM.LastAura == spell.ConfigID)
                or UnitIsUnit(player_buff.source, "player")
        then
          if self:TimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivAura = spell.ConfigID
          end
        end

      elseif spell.type == "seal" then
        if UnitIsUnit(player_buff.source, "player") then
          if self:TimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivSeal = spell.ConfigID
          end
        end
      end -- if is aura
    end -- if player.buffs[config.id]
  end -- for all spells
end

function taskScanModule:CheckChangesAndUpdateSpelltab()
  --reset aura/seal
  ---@param spell BomSpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "aura" then
      if spellDefModule:IsSpellEnabled(spell.ConfigID) then
        if BOM.ActivAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= spell.ConfigID then
          BOM.CurrentProfile.LastAura = spell.ConfigID
          spellButtonsTabModule:UpdateSpellsTab("ForceUp4")
        end
      else
        if BOM.CurrentProfile.LastAura == spell.ConfigID
                and BOM.CurrentProfile.LastAura ~= nil then
          BOM.CurrentProfile.LastAura = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp5")
        end
      end -- if currentprofile.spell.enable

    elseif spell.type == "seal" then
      if spellDefModule:IsSpellEnabled(spell.ConfigID) then
        if BOM.ActivSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= spell.ConfigID then
          BOM.CurrentProfile.LastSeal = spell.ConfigID
          spellButtonsTabModule:UpdateSpellsTab("ForceUp6")
        end
      else
        if BOM.CurrentProfile.LastSeal == spell.ConfigID
                and BOM.CurrentProfile.LastSeal ~= nil then
          BOM.CurrentProfile.LastSeal = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp7")
        end
      end -- if currentprofile.spell.enable
    end -- if is aura
  end
end

---@param party table<number, BomUnit> - the party
---@param player_member BomUnit - the player
function taskScanModule:ForceUpdate(party, player_member)
  self:ActivateSelectedTracking()

  -- Get the running aura and the running seal
  self:GetActiveAuraAndSeal(player_member)

  -- Check changes to auras and seals and update the spell tab
  self:CheckChangesAndUpdateSpelltab()

  -- who needs a buff!
  -- for each spell update spell potential targets
  local someoneIsDead = false -- the flag that buffing cannot continue while someone is dead

  -- For each selected spell check the targets
  ---@param spell BomSpellDef
  for i, spell in ipairs(BOM.SelectedSpells) do
    someoneIsDead = self:UpdateSpellTargets(party, spell, player_member, someoneIsDead)
  end

  taskScanModule.saveSomeoneIsDead = someoneIsDead
  return someoneIsDead
end

function taskScanModule:CancelBuffs(player_member)
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable
            and not spell.OnlyCombat
    then
      local player_buff = player_member.buffs[spell.ConfigID]

      if player_buff then
        BOM:Print(string.format(_t("MsgCancelBuff"),
                spell.singleLink or spell.singleText,
                UnitName(player_buff.source or "") or ""))
        self:CancelBuff(spell.singleFamily)
      end
    end
  end
end

---Whisper to the spell caster when the buff expired on yourself
function taskScanModule:WhisperExpired(spell)
  if spell.wasPlayerActiv and not spell.playerActiv then
    spell.wasPlayerActiv = false

    local name = UnitName(spell.buffSource or "")

    if name then
      local msg = string.format(_t("MsgSpellExpired"), spell.single)
      SendChatMessage(msg, "WHISPER", nil, name)

      BOM:Print(msg, "WHISPER", nil, name)
    end
  end
end

-- ---@param spell BomSpellDef
-- ---@param groupIndex number
-- ---@param classColorize boolean
-- ---@return string
--local function bomFormatGroupBuffText(groupIndex, spell, classColorize)
--  if classColorize then
--    return string.format(_t("FORMAT_BUFF_GROUP"),
--            "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r",
--            spell.groupLink or spell.group or "")
--  end
--
--  return string.format(_t("FORMAT_BUFF_GROUP"),
--          BOM.Tool.ClassName[groupIndex] or "?",
--          spell.groupLink or spell.group or "")
--end

-- ---@param prefix string Icon or some sort of string to prepend
-- ---@param member Member
-- ---@param spell SpellDef
-- ---@return string
--local function bomFormatSingleBuffText(prefix, member, spell)
--  return string.format(_t("FORMAT_BUFF_SINGLE"),
--          (prefix or "") .. member:GetText(),
--          (spell.singleLink or spell.single))
--end

---@param name string Consumable name to show
---@param count number How many of that consumable is available
function taskScanModule:FormatItemBuffInactiveText(name, count)
  if count == 0 then
    return string.format("%s (%s)", name, _t("OUT_OF_THAT_ITEM"))
  end

  return string.format("%s (x%d)", name, count)
end

---@return string
function taskScanModule:FormatItemBuffText(bag, slot, count)
  local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
  return string.format(" %s %s (x%d)",
          BOM.FormatTexture(texture),
          item_link,
          count)
end

---Add a paladin blessing
---@param spell BomSpellDef - spell to cast
---@param party table<number, BomUnit> - the party
---@param playerMember table - player
---@param inRange boolean - spell target is in range
function taskScanModule:AddBlessing(spell, party, playerMember, inRange)
  local ok, bag, slot, count
  if spell.reagentRequired then
    ok, bag, slot, count = self:HasItem(spell.reagentRequired, true)
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
        local classInRange = self:GetClassInRange(spell.groupText, spell.NeedMember, eachClassName, spell)

        if classInRange == nil then
          classInRange = self:GetClassInRange(spell.groupText, party, eachClassName, spell)
        end

        if classInRange ~= nil
                and (not spell.DeathGroup[eachClassName] or not BOM.SharedState.DeathBlock)
        then
          -- Group buff (Blessing)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  _t("TASK_BLESS_GROUP"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
                  "",
                  BOM.Class.GroupBuffTarget:new(eachClassName),
                  false)
          inRange = true

          self:QueueSpell(spell.groupMana, spell.groupId, spell.groupLink, classInRange, spell)
        else
          -- Group buff (Blessing) just info text
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  _t("TASK_BLESS_GROUP"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
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
      local blessing_name = spellDefModule:GetProfileSpell(constModule.BLESSING_ID)
      if blessing_name[member.name] ~= nil then
        add = string.format(constModule.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local test_in_range = IsSpellInRange(spell.singleText, member.unitId) == 1
              and not tContains(spell.SkipList, member.name)
      if self:PreventPvpTagging(spell.singleLink, spell.singleText, member) then
        -- Nothing, prevent poison function has already added the text
      elseif test_in_range then
        -- Single buff on group member
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
        inRange = true

        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        -- Single buff on group member (inactive just text)
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                true)
      end -- if in range
    end -- if not dead
  end -- for all NeedMember
end

---Add a generic buff of some sorts, or a group buff
---@param spell BomSpellDef - spell to cast
---@param party table<number, BomUnit> - the party
---@param playerMember BomUnit - player
---@param inRange boolean - spell target is in range
function taskScanModule:AddBuff(spell, party, playerMember, inRange)
  local ok, bag, slot, count

  if spell.reagentRequired then
    ok, bag, slot, count = self:HasItem(spell.reagentRequired, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  ------------------------
  -- Add GROUP BUFF
  ------------------------
  local minBuff = BOM.SharedState.MinBuff or 3

  if spell.groupMana ~= nil and not BOM.SharedState.NoGroupBuff then
    for groupIndex = 1, 8 do
      if spell.NeedGroup[groupIndex]
              and spell.NeedGroup[groupIndex] >= minBuff
      then
        BOM.RepeatUpdate = true
        local Group = self:GetGroupInRange(spell.groupText, spell.NeedMember, groupIndex, spell)

        if Group == nil then
          Group = self:GetGroupInRange(spell.groupText, party, groupIndex, spell)
        end

        if Group ~= nil
                and (not spell.DeathGroup[groupIndex] or not BOM.SharedState.DeathBlock)
        then
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  _t("BUFF_CLASS_GROUPBUFF"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
                  "",
                  BOM.Class.GroupBuffTarget:new(groupIndex),
                  false)
          inRange = true

          self:QueueSpell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)
        else
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  _t("BUFF_CLASS_GROUPBUFF"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
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
            or spell.NeedGroup[member.group] < minBuff)
    then
      if not member.isPlayer then
        BOM.RepeatUpdate = true
      end

      local add = ""
      local profile_spell = spellDefModule:GetProfileSpell(spell.ConfigID)

      if profile_spell.ForcedTarget[member.name] then
        add = string.format(constModule.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local is_in_range = (IsSpellInRange(spell.singleText, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if spell:HaveIgnoredBuffs(member) then
        tasklist:LowPrioComment(string.format(_t("tasklist.IgnoredBuffOn"), member.name, spell.singleText))
        -- Leave message that the target has a better or ignored buff
      elseif self:PreventPvpTagging(spell.singleLink, spell.singleText, member) then
        -- Nothing, prevent poison function has already added the text
      elseif is_in_range then
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("BUFF_CLASS_REGULAR"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
        inRange = true
        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      else
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("BUFF_CLASS_REGULAR"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false)
      end
    end
  end -- for all spell.needmember

  return inRange
end

---Adds a display text for a weapon buff
---@param spell BomSpellDef - the spell to cast
---@param player_member table - the player
---@param inRange boolean - value for range check
---@return table (bag_title string, bag_command string)
function taskScanModule:AddResurrection(spell, player_member, inRange)
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
      local targetIsInRange = (IsSpellInRange(spell.singleText, member.unitId) == 1)
              and not tContains(spell.SkipList, member.name)

      if targetIsInRange then
        inRange = true
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("TASK_CLASS_RESURRECT"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                false,
                BOM.TaskPriority.Resurrection)
      else
        -- Text: Range Target "SpellName"
        tasklist:AddWithPrefix(
                _t("TASK_CLASS_RESURRECT"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                BOM.Class.MemberBuffTarget:fromMember(member),
                true,
                BOM.TaskPriority.Resurrection)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if targetIsInRange or (BOM.SharedState.ResGhost and member.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
      end
    end
  end

  return inRange
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell BomSpellDef - the spell to cast
---@param playerMember BomUnit - the player
function taskScanModule:AddSelfbuff(spell, playerMember)
  if spell.requiresWarlockPet then
    if not UnitExists("pet") or UnitCreatureType("pet") ~= "Demon" then
      return -- No demon pet - buff can not be casted
    end
  end

  if (not spell.requiresOutdoors or IsOutdoors())
          and not tContains(spell.SkipList, playerMember.name) then
    -- Text: Target [Spell Name]
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("BUFF_CLASS_SELF_ONLY"),
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  else
    -- Text: Target "SpellName"
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("BUFF_CLASS_SELF_ONLY"),
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            true)
  end
end

---Adds a summon spell to the tasks
---@param spell BomSpellDef - the spell to cast
---@param playerMember BomUnit
function taskScanModule:AddSummonSpell(spell, playerMember)
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
            _t("TASK_SUMMON"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            nil,
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  end
end

---Adds a display text for a weapon buff
---@param spell BomSpellDef - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@param target string Insert this text into macro where [@player] target text would go
---@return string, string {cast_button_title, bag_macro_command}
function taskScanModule:AddConsumableSelfbuff(spell, playerMember, castButtonTitle, macroCommand, target)
  local haveItemOffCD, bag, slot, count = bomHasItem(spell.items, true)
  count = count or 0

  local taskText = _t("TASK_USE")
  if spell.tbcHunterPetBuff then
    taskText = _t("TASK_TBC_HUNTER_PET_BUFF")
  end

  if haveItemOffCD then
    if BOM.SharedState.DontUseConsumables
            and not IsModifierKeyDown() then
      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
              self:FormatItemBuffText(bag, slot, count),
              nil,
              _t("BUFF_CONSUMABLE_REMINDER"),
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      if target then
        macroCommand = string.format("/use [@%s] %d %d", target, bag, slot)
      else
        macroCommand = string.format("/use %d %d", bag, slot)
      end
      castButtonTitle = _t("TASK_USE") .. " " .. spell.singleText

      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
              self:FormatItemBuffText(bag, slot, count),
              nil,
              "",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              false)
    end

    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    -- Text: "ConsumableName" x Count
    if spell.singleText then
      -- safety, can crash on load
      tasklist:AddWithPrefix(
              _t("TASK_USE"),
              self:FormatItemBuffInactiveText(spell.singleText, count),
              nil,
              "",
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a consumable item
---@param spell BomSpellDef - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
function taskScanModule:AddConsumableWeaponBuff(spell, playerMember,
                                                castButtonTitle, macroCommand)
  -- count - reagent count remaining for the spell
  local have_item, bag, slot, count = self:HasItem(spell.items, true)
  count = count or 0

  if have_item then
    -- Have item, display the cast message and setup the cast button
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
    local profile_spell = spellDefModule:GetProfileSpell(spell.ConfigID)

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
                "(" .. _t("TooltipOffHand") .. ") " .. _t("BUFF_CONSUMABLE_REMINDER"),
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
                "(" .. _t("TooltipOffHand") .. ") ",
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
                "(" .. _t("TooltipMainHand") .. ") " .. _t("BUFF_CONSUMABLE_REMINDER"),
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        castButtonTitle = mainhand_message()
        macroCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. _t("TooltipMainHand") .. ") ",
                BOM.Class.MemberBuffTarget:fromSelf(playerMember),
                false)
      end
    end
    BOM.ScanModifier = BOM.SharedState.DontUseConsumables
  else
    -- Don't have item but display the intent
    -- Text: [Icon] [Consumable Name] x Count
    if spell.singleText then
      -- spell.single can be nil on addon load
      tasklist:Add(
              spell.singleText .. "x" .. count,
              nil,
              _t("TASK_CLASS_MISSING_CONSUM"),
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      BOM.SetForceUpdate("WeaponConsumableBuff display text") -- try rescan?
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a spell (shamans and paladins)
---@param spell BomSpellDef - the spell to cast
---@param playerMember BomUnit - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
function taskScanModule:AddWeaponEnchant(spell, playerMember,
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

  local profile_spell = spellDefModule:GetProfileSpell(spell.ConfigID)

  if profile_spell.MainHandEnable
          and playerMember.MainHandBuff == nil then
    -- Text: [Spell Name] (Main hand)
    tasklist:Add(
            spell.singleLink,
            spell.singleText,
            _t("TooltipMainHand"),
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)
    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  end

  if profile_spell.OffHandEnable
          and playerMember.OffHandBuff == nil then
    if block_offhand_enchant then
      -- Text: [Spell Name] (Off-hand) Blocked waiting
      tasklist:Add(
              spell.singleLink,
              spell.singleText,
              _t("TooltipOffHand") .. ": " .. _t("ShamanEnchantBlocked"),
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              true)
    else
      -- Text: [Spell Name] (Off-hand)
      tasklist:Add(
              spell.singleLink,
              spell.singleText,
              _t("TooltipOffHand"),
              BOM.Class.MemberBuffTarget:fromSelf(playerMember),
              false)
      self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
              playerMember, spell)
    end
  end

  return castButtonTitle, macroCommand
end

---Set text and enable the cast button (or disable)
---@param t string - text for the cast button
---@param enable boolean - whether to enable the button or not
function taskScanModule:CastButton(t, enable)
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
---@param playerMember BomUnit
function taskScanModule:CheckReputationItems(playerMember)
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
      tasklist:Comment(_t("TASK_UNEQUIP") .. " " .. _t("AD_REPUTATION_REMINDER"))
    end
  end

  if BOM.SharedState.Carrot then
    local hasCarrot = tContains(BOM.Carrot.itemIds, itemTrinket1) or
            tContains(BOM.Carrot.itemIds, itemTrinket2)
    if hasCarrot and not tContains(BOM.Carrot.zoneId, instanceID) then
      -- Text: Unequip [Carrot on a Stick]
      tasklist:Comment(_t("TASK_UNEQUIP") .. " " .. _t("RIDING_SPEED_REMINDER"))
    end
  end
end

---Check player weapons and report if they have the "Warn about missing enchants" option enabled
---@param player_member BomUnit
function taskScanModule:CheckMissingWeaponEnchantments(player_member)
  -- enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges
  , offHandEnchantId = GetWeaponEnchantInfo()

  if BOM.SharedState.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

    if link then
      -- Text: [Consumable Enchant Link]
      tasklist:Comment(_t("MSG_MAINHAND_ENCHANT_MISSING"))
    end
  end

  if BOM.SharedState.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))

    if link then
      tasklist:Comment(_t("MSG_OFFHAND_ENCHANT_MISSING"))
    end
  end
end

---@param playerMember BomUnit
---@param cast_button_title string
---@param macro_command string
---@return string, string {cast_button_title, macro_command}
function taskScanModule:CheckItemsAndContainers(playerMember, cast_button_title, macro_command)
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
        extra_msg = _t("BUFF_CONSUMABLE_REMINDER")
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
              "(" .. _t("MsgOpenContainer") .. ") " .. extra_msg,
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

---@param spell BomSpellDef
---@param playerMember BomUnit
---@param party table<number, BomUnit>
---@param inRange boolean
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
function taskScanModule:ScanOneSpell(spell, playerMember, party, inRange,
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
    self:AddSummonSpell(spell, playerMember)

  elseif spell.type == "weapon" then
    if #spell.NeedMember > 0 then
      if spell.isConsumable then
        castButtonTitle, macroCommand = self:AddConsumableWeaponBuff(
                spell, playerMember, castButtonTitle, macroCommand)
      else
        castButtonTitle, macroCommand = self:AddWeaponEnchant(spell, playerMember)
      end
    end

  elseif spell.isConsumable then
    if #spell.NeedMember > 0 then
      castButtonTitle, macroCommand = self:AddConsumableSelfbuff(
              spell, playerMember, castButtonTitle, macroCommand, spell.consumableTarget)
      inRange = true
    end

  elseif spell.isInfo then
    if #spell.NeedMember then
      for memberIndex, member in ipairs(spell.NeedMember) do
        -- Text: [Player Link] [Spell Link]
        tasklist:Add(
                spell.singleLink or spell.singleText,
                spell.singleText,
                "Info",
                BOM.Class.MemberBuffTarget:fromMember(member),
                true)
      end
    end

  elseif spell.type == "tracking" then
    -- TODO: Move this to its own periodic timer
    if #spell.NeedMember > 0 then
      if BOM.PlayerCasting == nil then
        self:SetTracking(spell, true)
      else
        -- Text: "Player" "Spell Name"
        tasklist:AddWithPrefix(
                _t("TASK_ACTIVATE"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                _t("BUFF_CLASS_TRACKING"),
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
      self:AddSelfbuff(spell, playerMember)
    end

  elseif spell.type == "resurrection" then
    inRange = self:AddResurrection(spell, playerMember, inRange)

  elseif spell.isBlessing then
    inRange = self:AddBlessing(spell, party, playerMember, inRange)

  else
    inRange = self:AddBuff(spell, party, playerMember, inRange)
  end

  return inRange, castButtonTitle, macroCommand
end

---@param playerMember BomUnit
---@param party table<number, BomUnit>
---@param inRange boolean
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
function taskScanModule:ScanSelectedSpells(playerMember, party, inRange, castButtonTitle, macroCommand)
  for _, spell in ipairs(BOM.SelectedSpells) do
    local profile_spell = spellDefModule:GetProfileSpell(spell.ConfigID)

    if spell.isInfo and profile_spell.Whisper then
      self:WhisperExpired(spell)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if spellDefModule:IsSpellEnabled(spell.ConfigID)
            and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then
      inRange, castButtonTitle, macroCommand = self:ScanOneSpell(
              spell, playerMember, party, inRange, castButtonTitle, macroCommand)
    end
  end

  return inRange, castButtonTitle, macroCommand
end

---When a paladin is mounted and AutoCrusaderAura enabled,
---offer player to cast Crusader Aura.
---@return boolean True if the scanning should be interrupted and only crusader aura prompt will be visible
function taskScanModule:MountedCrusaderAuraPrompt()
  local playerMember = BOM.GetMember("player")

  if self:IsMountedAndCrusaderAuraRequired() then
    local spell = BOM.CrusaderAuraSpell
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("BUFF_CLASS_SELF_ONLY"),
            BOM.Class.MemberBuffTarget:fromSelf(playerMember),
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)

    return true -- only show the aura and nothing else
  end

  return false -- continue scanning spells
end

function taskScanModule:UpdateScan_Scan()
  local party, playerMember = BOM.GetPartyMembers()

  -- Check whether BOM is disabled due to some option and a matching condition
  if not self:IsMountedAndCrusaderAuraRequired() then
    -- If mounted and crusader aura enabled, then do not do further checks, allow the crusader aura
    local isBomActive, reasonDisabled = self:IsActive(playerMember)
    if not isBomActive then
      BOM.ForceUpdate = false
      BOM.CheckForError = false
      BOM.AutoClose()
      BOM.Macro:Clear()
      self:CastButton(reasonDisabled, false)
      return
    end
  end

  local someoneIsDead = taskScanModule.saveSomeoneIsDead
  if BOM.ForceUpdate then
    someoneIsDead = self:ForceUpdate(party, playerMember)
  end

  -- cancel buffs
  self:CancelBuffs(playerMember)

  -- fill list and find cast
  bomCurrentPlayerMana = UnitPower("player", 0) or 0 --mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  self:ClearNextCastSpell()

  local macroCommand ---@type string
  local castButtonTitle ---@type string
  local inRange = false

  -- Cast crusader aura when mounted, without condition. Ignore all other buffs
  if self:MountedCrusaderAuraPrompt() then
    -- Do not scan other spells
    castButtonTitle = "Crusader"
    macroCommand = "/cast Crusader Aura"
  else
    -- Otherwise scan all enabled spells
    BOM.ScanModifier = false

    inRange, castButtonTitle, macroCommand = self:ScanSelectedSpells(
            playerMember, party, inRange,
            castButtonTitle, macroCommand)

    self:CheckReputationItems(playerMember)
    self:CheckMissingWeaponEnchantments(playerMember) -- if option to warn is enabled

    ---Check if someone has drink buff, print an info message
    if not BOM.SharedState.HideSomeoneIsDrinking then
      if BOM.drinkingPersonCount > 1 then
        tasklist:Comment(string.format(_t("InfoMultipleDrinking"), BOM.drinkingPersonCount))
      elseif BOM.drinkingPersonCount > 0 then
        tasklist:Comment(_t("InfoSomeoneIsDrinking"))
      end
    end

    castButtonTitle, macroCommand = self:CheckItemsAndContainers(
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
    self:CastButton(_t("MsgBusy"), false)
    self:UpdateMacro()

  elseif BOM.PlayerCasting == "channel" then
    --Print player is busy (casting channeled spell)
    self:CastButton(_t("MsgBusyChanneling"), false)
    self:UpdateMacro()

  elseif next_cast_spell.Member and next_cast_spell.SpellId then
    --Next cast is already defined - update the button text
    self:CastButton(next_cast_spell.Link, true)
    self:UpdateMacro(next_cast_spell.Member, next_cast_spell.SpellId)

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
      self:CastButton(_t("MsgNothingToDo"), true)

      for spellIndex, spell in ipairs(BOM.SelectedSpells) do
        if #spell.SkipList > 0 then
          wipe(spell.SkipList)
        end
      end

    else
      if someoneIsDead and BOM.SharedState.DeathBlock then
        self:CastButton(_t("InactiveReason_DeadMember"), false)
      else
        if inRange then
          -- Range is good but cast is not possible
          self:CastButton(ERR_OUT_OF_MANA, false)
        else
          self:CastButton(ERR_SPELL_OUT_OF_RANGE, false)
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
      self:CastButton(castButtonTitle, true)
    end

    self:UpdateMacro(nil, nil, macroCommand)
  end -- if not player casting
end -- end function bomUpdateScan_Scan()

function taskScanModule:UpdateScan_PreCheck(from)
  if BOM.SelectedSpells == nil then
    return
  end

  if BOM.InLoading then
    return
  end

  BOM.MinTimer = GetTime() + 36000 -- 10 hours
  tasklist:Clear()
  BOM.RepeatUpdate = false

  -- moved to next stage bomUpdateScan_Scan
  -- Check whether BOM is disabled due to some option and a matching condition
  --local isBomActive, reasonDisabled = self:IsActive()
  --if not isBomActive then
  --  BOM.ForceUpdate = false
  --  BOM.CheckForError = false
  --  BOM.AutoClose()
  --  BOM.Macro:Clear()
  --  bomCastButton(reasonDisabled, false)
  --  return
  --end

  --Choose Profile
  local auto_profile = self:ChooseProfile()

  if BOM.CurrentProfile ~= BOM.CharacterState[auto_profile] then
    BOM.CurrentProfile = BOM.CharacterState[auto_profile]
    spellButtonsTabModule:UpdateSpellsTab("UpdateScan1")
    BomC_MainWindow_Title:SetText(
            BOM.FormatTexture(constModule.BOM_BEAR_ICON_FULLPATH)
                    .. " " .. constModule.SHORT_TITLE .. " - "
                    .. L["profile_" .. auto_profile])
    BOM.SetForceUpdate("ProfileChanged")
  end

  -- All pre-checks passed
  self:UpdateScan_Scan()
end -- end function bomUpdateScan_PreCheck()

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
---@param from string Debug value to trace the caller of this function
function taskScanModule:UpdateScan(from)
  --BOM.Tool.Profile("UpdScan " .. from, function()
  self:UpdateScan_PreCheck(from)
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
            and taskScanModule:CancelBuff(spell.singleFamily)
    then
      BOM:Print(string.format(_t("MsgCancelBuff"), spell.singleLink or spell.singleText,
              UnitName(BOM.CancelBuffSource) or ""))
    end
  end
end
