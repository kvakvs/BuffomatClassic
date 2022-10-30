local BOM = BuffomatAddon ---@type BomAddon

---@class BomBuffChecksModule
local buffChecksModule = BuffomatModule.New("BuffChecks") ---@type BomBuffChecksModule

local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule
local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local spellIdsModule = BuffomatModule.Import("SpellIds") ---@type BomSpellIdsModule
local unitCacheModule = BuffomatModule.Import("UnitCache") ---@type BomUnitCacheModule

---Checks whether a tracking spell is now active
---@param spell BomBuffDefinition The tracking spell which might have tracking enabled
function buffChecksModule:IsTrackingActive(spell)
  if BOM.HaveTBC then
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

---@param expirationTime number Buff expiration time
---@param maxDuration number Max buff duration
function buffChecksModule:TimeCheck(expirationTime, maxDuration)
  if expirationTime == nil
          or maxDuration == nil
          or expirationTime == 0
          or maxDuration == 0 then
    return true
  end

  local remainingTimeTrigger

  if maxDuration <= 60 then
    remainingTimeTrigger = buffomatModule.shared.Time60 or 10
  elseif maxDuration <= 300 then
    remainingTimeTrigger = buffomatModule.shared.Time300 or 90
  elseif maxDuration <= 600 then
    remainingTimeTrigger = buffomatModule.shared.Time600 or 120
  elseif maxDuration <= 1800 then
    remainingTimeTrigger = buffomatModule.shared.Time1800 or 180
  else
    remainingTimeTrigger = buffomatModule.shared.Time3600 or 180
  end

  if remainingTimeTrigger + GetTime() < expirationTime then
    expirationTime = expirationTime - remainingTimeTrigger
    if expirationTime < BOM.nextCooldownDue then
      BOM.nextCooldownDue = expirationTime
    end
    return true
  end

  return false
end

---Check whether the player has item
-- TODO: Can move into Buffomat main operation class together with item cache?
---@param list table - the item?
---@param cd boolean - respect the cooldown?
---@return boolean, number|nil, number|nil, number {HasItem, Bag, Slot, Count}
function buffChecksModule:HasItem(list, cd)
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

---@param buff BomBuffDefinition the spell to update
---@param playerUnit BomUnit the player
function buffChecksModule:PlayerNeedsWeaponBuff(buff, playerUnit)
  local weaponSpell = buffDefModule:GetProfileBuff(buff.buffId)

  if (weaponSpell.MainHandEnable and playerUnit.MainHandBuff == nil)
          or (weaponSpell.OffHandEnable and playerUnit.OffHandBuff == nil)
  then
    tinsert(buff.UnitsNeedBuff, playerUnit)
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
function buffChecksModule:HunterPetNeedsBuff(buff, playerUnit, _party)
  if not BOM.HaveTBC then
    return -- pre-TBC this did not exist
  end

  local pet = unitCacheModule:GetUnit("pet")
  if not pet then
    return -- no pet - no problem
  end

  pet:ForceUpdateBuffs(playerUnit)
  if pet:HaveBuff(buff.singleId) then
    return -- have pet, have buff
  end

  tinsert(buff.UnitsNeedBuff, playerUnit) -- add player to buff list, because player must consume it
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
function buffChecksModule:PlayerNeedsConsumable(buff, playerUnit, _party)
  if not playerUnit.knownBuffs[buff.buffId] then
    tinsert(buff.UnitsNeedBuff, playerUnit)
  end

end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:PartyNeedsInfoBuff(buff, playerUnit, party)
  for _i, partyMember in ipairs(party) do
    local partyMemberBuff = partyMember.knownBuffs[buff.buffId]

    if partyMemberBuff then
      tinsert(buff.UnitsNeedBuff, partyMember)

      if partyMember.isPlayer then
        buff.buffSource = partyMemberBuff.source
      end

      if UnitIsUnit("player", partyMemberBuff.source or "") then
        BOM.ItemListTarget[buff.buffId] = partyMember.name
      end
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:PlayerNeedsSelfBuff(buff, playerUnit, party)
  if not playerUnit.isDead then
    local thisBuffOnPlayer = playerUnit.knownBuffs[buff.buffId]

    -- Check if the self-buff includes creating/conjuring an item
    if buff.lockIfHaveItem then
      if IsSpellKnown(buff.singleId) and not (self:HasItem(buff.lockIfHaveItem)) then
        tinsert(buff.UnitsNeedBuff, playerUnit)
      end

      -- Else check if the buff is on player and timer is not too short
    elseif not (thisBuffOnPlayer
            and self:TimeCheck(thisBuffOnPlayer.expirationTime, thisBuffOnPlayer.duration))
    then
      tinsert(buff.UnitsNeedBuff, playerUnit)
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:DeadNeedsResurrection(buff, playerUnit, party)
  for i, member in ipairs(party) do
    if member.isDead
            and not member.hasResurrection
            and member.isConnected
            and member.class ~= "pet"
            and (not buffomatModule.shared.SameZone or member.isSameZone) then
      tinsert(buff.UnitsNeedBuff, member)
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:PlayerNeedsTracking(buff, playerUnit, party)
  -- Special handling: Having find herbs and find ore will be ignored if
  -- in cat form and track humanoids is enabled
  if (buff.singleId == spellIdsModule.FindHerbs or
          buff.singleId == spellIdsModule.FindMinerals)
          and GetShapeshiftFormID() == CAT_FORM
          and buffDefModule:IsBuffEnabled(spellIdsModule.Druid_TrackHumanoids) then
    -- Do nothing - ignore herbs and minerals in catform if enabled track humanoids

  elseif not self:IsTrackingActive(buff)
          and (BOM.ForceTracking == nil
          or BOM.ForceTracking == buff.trackingIconId) then
    tinsert(buff.UnitsNeedBuff, playerUnit)
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:PaladinNeedsAura(buff, playerUnit, party)
  if BOM.ActivePaladinAura ~= buff.buffId
          and (buffomatModule.currentProfile.LastAura == nil
          or buffomatModule.currentProfile.LastAura == buff.buffId)
  then
    tinsert(buff.UnitsNeedBuff, playerUnit)
  end
end

---@param spell BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
function buffChecksModule:PaladinNeedsSeal(spell, playerUnit, party)
  if BOM.ActivePaladinSeal ~= spell.buffId
          and (buffomatModule.currentProfile.LastSeal == nil
          or buffomatModule.currentProfile.LastSeal == spell.buffId)
  then
    tinsert(spell.UnitsNeedBuff, playerUnit)
  end
end

---@param spell BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
---@param someoneIsDead boolean
---@return boolean someoneIsDead
function buffChecksModule:PartyNeedsPaladinBlessing(spell, playerUnit, party, someoneIsDead)
  for i, partyMember in ipairs(party) do
    local ok = false
    local notGroup = false
    local blessing_name = buffDefModule:GetProfileBuff(constModule.BLESSING_ID)
    local blessingSpell = buffDefModule:GetProfileBuff(spell.buffId)

    if blessing_name[partyMember.name] == spell.buffId
            or (partyMember.isTank
            and blessingSpell.Class["tank"]
            and not blessingSpell.SelfCast)
    then
      ok = true
      notGroup = true

    elseif blessing_name[partyMember.name] == nil then
      if blessingSpell.Class[partyMember.class]
              and (not IsInRaid() or buffomatModule.character.WatchGroup[partyMember.group])
              and not blessingSpell.SelfCast then
        ok = true
      end
      if blessingSpell.SelfCast
              and UnitIsUnit(partyMember.unitId, "player") then
        ok = true
      end
    end

    if blessingSpell.ForcedTarget[partyMember.name] then
      ok = true
    end
    if blessingSpell.ExcludedTarget[partyMember.name] then
      ok = false
    end

    if partyMember.NeedBuff
            and ok
            and partyMember.isConnected
            and (not buffomatModule.shared.SameZone or partyMember.isSameZone) then
      local found = false
      local partyMemberBuff = partyMember.knownBuffs[spell.buffId]

      if partyMember.isDead then
        if partyMember.group ~= 9 and partyMember.class ~= "pet" then
          someoneIsDead = true
          spell.GroupsHaveDead[partyMember.class] = true
        end

      elseif partyMemberBuff then
        found = self:TimeCheck(partyMemberBuff.expirationTime, partyMemberBuff.duration)
      end

      if not found then
        tinsert(spell.UnitsNeedBuff, partyMember)
        if not notGroup then
          spell:IncrementNeedGroupBuff(partyMember.class)
        end
      elseif not notGroup
              and buffomatModule.shared.ReplaceSingle
              and partyMemberBuff
              and partyMemberBuff.isSingle then
        spell:IncrementNeedGroupBuff(partyMember.class)
      end

    end
  end

  return someoneIsDead
end

---@param spell BomBuffDefinition
---@param playerUnit BomUnit
---@param party table<number, BomUnit>
---@param someoneIsDead boolean
function buffChecksModule:PartyNeedsBuff(spell, playerUnit, party, someoneIsDead)
  --spells
  for i, partyMember in ipairs(party) do
    local ok = false
    ---@type BomBuffDefinition
    local profileSpell = buffomatModule.currentProfile.Spell[spell.buffId]

    if profileSpell.Class[partyMember.class]
            and (not IsInRaid() or buffomatModule.character.WatchGroup[partyMember.group])
            and not profileSpell.SelfCast then
      ok = true
    end
    if profileSpell.SelfCast
            and UnitIsUnit(partyMember.unitId, "player") then
      ok = true
    end
    if partyMember.isTank and profileSpell.Class["tank"]
            and not profileSpell.SelfCast then
      ok = true
    end
    if profileSpell.ForcedTarget[partyMember.name] then
      ok = true
    end
    if profileSpell.ExcludedTarget[partyMember.name] then
      ok = false
    end

    if partyMember.NeedBuff
            and ok
            and partyMember.isConnected
            and (not buffomatModule.shared.SameZone
            or (partyMember.isSameZone
            or partyMember.class == "pet" and partyMember.owner.isSameZone)) then
      local found = false
      local partyMemberBuff = partyMember.knownBuffs[spell.buffId]

      if partyMember.isDead then
        someoneIsDead = true
        spell.GroupsHaveDead[partyMember.group] = true

      elseif partyMemberBuff then
        found = self:TimeCheck(partyMemberBuff.expirationTime, partyMemberBuff.duration)
      end

      if not found then
        tinsert(spell.UnitsNeedBuff, partyMember)
        spell.GroupsNeedBuff[partyMember.group] = (spell.GroupsNeedBuff[partyMember.group] or 0) + 1

      elseif buffomatModule.shared.ReplaceSingle
              and partyMemberBuff
              and partyMemberBuff.isSingle then
        spell.GroupsNeedBuff[partyMember.group] = (spell.GroupsNeedBuff[partyMember.group] or 0) + 1
      end
    end -- if needbuff and connected and samezone
  end -- for all in party
end