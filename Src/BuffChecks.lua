local BOM = BuffomatAddon ---@type BomAddon

---@shape BomBuffChecksModule
local buffChecksModule = BomModuleManager.buffChecksModule ---@type BomBuffChecksModule

local buffDefModule = BomModuleManager.buffDefinitionModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local spellIdsModule = BomModuleManager.spellIdsModule
local unitCacheModule = BomModuleManager.unitCacheModule

---Checks whether a tracking spell is now active
---@param spell BomBuffDefinition The tracking spell which might have tracking enabled
function buffChecksModule:IsTrackingActive(spell)
  if BOM.haveTBC then
    for i = 1, GetNumTrackingTypes() do
      local _name, _texture, active, _category, _nesting, spellId = GetTrackingInfo(i)
      if tContains(spell.singleFamily, spellId)  then
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

---@param itemToCheck BomItemId
---@param cd boolean respect the cooldown?
---@return boolean, number|nil, number|nil, number|nil {HasItem, Bag, Slot, Count}
function buffChecksModule:HasOneItem(itemToCheck, cd)
  if itemToCheck == nil then
    return true, nil, nil, 1 -- spell.items is nil, no items required
  end

  local key = itemToCheck .. (cd and "CD" or "")
  local cachedItem = BOM.cachedPlayerBag[key]

  if not cachedItem then
    BOM.cachedPlayerBag[key] = --[[---@type BomCachedBagItem]]{}
    cachedItem = BOM.cachedPlayerBag[key]
    cachedItem.a = false
    cachedItem.d = 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink
        , isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        if itemToCheck == itemID then
          if cd then
            cachedItem.a, cachedItem.b, cachedItem.c = true, bag, slot
            cachedItem.d = cachedItem.d + itemCount

          else
            cachedItem.a = true
            return true, nil, nil, nil
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

  return cachedItem.a, cachedItem.b, cachedItem.c, cachedItem.d
end

---Check whether the player has item
-- TODO: Can move into Buffomat main operation class together with item cache?
---@param itemsToCheck BomItemId[]
---@param cd boolean respect the cooldown?
---@return boolean, number|nil, number|nil, number|nil {HasItem, Bag, Slot, Count}
function buffChecksModule:HasItem(itemsToCheck, cd)
  for i, itemId in pairs(itemsToCheck) do
    local okEach, bagEach, slotEach, countEach = self:HasOneItem(itemId, cd)
    if okEach then -- save last successful result
      return okEach, bagEach, slotEach, countEach
    end
  end
  return false, nil, nil, nil
end

---@param buff BomBuffDefinition the spell to update
---@param playerUnit BomUnit the player
function buffChecksModule:PlayerNeedsWeaponBuff(buff, playerUnit)
  local weaponBuff = buffDefModule:GetProfileBuff(buff.buffId, nil)

  if weaponBuff
          and ((--[[---@not nil]] weaponBuff).MainHandEnable and playerUnit.MainHandBuff == nil)
          or ((--[[---@not nil]] weaponBuff).OffHandEnable and playerUnit.OffHandBuff == nil)
  then
    tinsert(buff.unitsNeedBuff, playerUnit)
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
function buffChecksModule:HunterPetNeedsBuff(buff, playerUnit)
  if not BOM.haveTBC then
    return -- pre-TBC this did not exist
  end

  local pet = unitCacheModule:GetUnit("pet", nil, nil, false)
  if not pet then
    return -- no pet - no problem
  end

  (--[[---@not nil]] pet):ForceUpdateBuffs(playerUnit)
  if (--[[---@not nil]] pet):HaveBuff(buff.highestRankSingleId) then
    return -- have pet, have buff
  end

  tinsert(buff.unitsNeedBuff, playerUnit) -- add player to buff list, because player must consume it
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
function buffChecksModule:PlayerNeedsConsumable(buff, playerUnit)
  if not playerUnit.knownBuffs[buff.buffId] then
    tinsert(buff.unitsNeedBuff, playerUnit)
  end

end

---@param buff BomBuffDefinition
---@param playerParty BomParty
function buffChecksModule:PartyNeedsInfoBuff(buff, playerParty)
  for _i, partyMember in pairs(playerParty) do
    local partyMemberBuff = partyMember.knownBuffs[buff.buffId]

    if partyMemberBuff then
      tinsert(buff.unitsNeedBuff, partyMember)

      if partyMember.isPlayer then
        buff.buffSource = partyMemberBuff.source
      end

      if UnitIsUnit("player", partyMemberBuff.source or "") then
        BOM.itemListTarget[buff.buffId] = partyMember.name
      end
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party BomParty
function buffChecksModule:PlayerNeedsSelfBuff(buff, playerUnit)
  if not playerUnit.isDead then
    local thisBuffOnPlayer = playerUnit.knownBuffs[buff.buffId]

    -- Check if the self-buff includes creating/conjuring an item
    if buff.lockIfHaveItem then
      if IsSpellKnown(buff.highestRankSingleId) and not (self:HasItem(buff.lockIfHaveItem, buff.hasCD)) then
        tinsert(buff.unitsNeedBuff, playerUnit)
      end

      -- Else check if the buff is on player and timer is not too short
    elseif not (thisBuffOnPlayer
            and self:TimeCheck(thisBuffOnPlayer.expirationTime, thisBuffOnPlayer.duration))
    then
      tinsert(buff.unitsNeedBuff, playerUnit)
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param playerParty BomParty
function buffChecksModule:DeadNeedsResurrection(buff, playerParty)
  for i, member in pairs(playerParty) do
    if member.isDead
            and not member.hasResurrection
            and member.isConnected
            and member.class ~= "pet"
            and (not buffomatModule.shared.SameZone or member.isSameZone) then
      tinsert(buff.unitsNeedBuff, member)
    end
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party BomParty
function buffChecksModule:PlayerNeedsTracking(buff, playerUnit)
  -- Special handling: Having find herbs and find ore will be ignored if
  -- in cat form and track humanoids is enabled
  if (buff.highestRankSingleId == spellIdsModule.FindHerbs or
          buff.highestRankSingleId == spellIdsModule.FindMinerals)
          and GetShapeshiftFormID() == CAT_FORM
          and buffDefModule:IsBuffEnabled(spellIdsModule.Druid_TrackHumanoids, nil) then
    -- Do nothing - ignore herbs and minerals in catform if enabled track humanoids

  elseif not self:IsTrackingActive(buff)
          and (BOM.forceTracking == nil
          or BOM.forceTracking == buff.trackingIconId) then
    tinsert(buff.unitsNeedBuff, playerUnit)
  end
end

---@param buff BomBuffDefinition
---@param playerUnit BomUnit
---@param party BomParty
function buffChecksModule:PaladinNeedsAura(buff, playerUnit)
  if BOM.activePaladinAura ~= buff.buffId
          and (buffomatModule.currentProfile.LastAura == nil
          or buffomatModule.currentProfile.LastAura == buff.buffId)
  then
    tinsert(buff.unitsNeedBuff, playerUnit)
  end
end

---@param spell BomBuffDefinition
---@param playerUnit BomUnit
---@param party BomParty
function buffChecksModule:PaladinNeedsSeal(spell, playerUnit)
  if BOM.activePaladinSeal ~= spell.buffId
          and (buffomatModule.currentProfile.LastSeal == nil
          or buffomatModule.currentProfile.LastSeal == spell.buffId)
  then
    tinsert(spell.unitsNeedBuff, playerUnit)
  end
end

---@param buffDef BomBuffDefinition
---@param playerParty BomParty
---@param someoneIsDead boolean
---@return boolean someoneIsDead
function buffChecksModule:PartyNeedsPaladinBlessing(buffDef, playerParty, someoneIsDead)
  -- Blessing user settings (regardless of the current buff)
  local currentBlessing = buffDefModule:GetProfileBlessingState( nil)
  -- Current user settings for the selected buff
  local profileBuff = --[[---@not nil]] buffDefModule:GetProfileBuff(buffDef.buffId, nil)

  ---@param partyMember BomUnit
  for i, partyMember in ipairs(playerParty) do
    local ok = false
    local notGroup = false

    if currentBlessing[partyMember.name] == buffDef.buffId
            or (partyMember.isTank and profileBuff.Class["tank"] and not profileBuff.SelfCast)
    then
      ok = true
      notGroup = true

    elseif currentBlessing[partyMember.name] == nil then
      if profileBuff.Class[partyMember.class]
              and (not IsInRaid() or buffomatModule.character.WatchGroup[partyMember.group])
              and not profileBuff.SelfCast then
        ok = true
      end
      if profileBuff.SelfCast
              and UnitIsUnit(partyMember.unitId, "player") then
        ok = true
      end
    end

    if profileBuff.ForcedTarget[partyMember.name] then
      ok = true
    end
    if profileBuff.ExcludedTarget[partyMember.name] then
      ok = false
    end

    if partyMember.NeedBuff
            and ok
            and partyMember.isConnected
            and (not buffomatModule.shared.SameZone or partyMember.isSameZone) then
      local found = false
      local partyMemberBuff = partyMember.knownBuffs[buffDef.buffId]

      if partyMember.isDead then
        if partyMember.group ~= 9 and partyMember.class ~= "pet" then
          someoneIsDead = true
          buffDef.groupsHaveDead[partyMember.class] = true
        end

      elseif partyMemberBuff then
        found = self:TimeCheck(partyMemberBuff.expirationTime, partyMemberBuff.duration)
      end

      if not found then
        tinsert(buffDef.unitsNeedBuff, partyMember)
        if not notGroup then
          buffDef:IncrementNeedGroupBuff(partyMember.class)
        end
      elseif not notGroup
              and buffomatModule.shared.ReplaceSingle
              and partyMemberBuff
              and partyMemberBuff.isSingle then
        buffDef:IncrementNeedGroupBuff(partyMember.class)
      end

    end
  end

  return someoneIsDead
end

---@param buffDef BomBuffDefinition
---@param party BomParty
---@param someoneIsDead boolean
function buffChecksModule:PartyNeedsBuff(buffDef, party, someoneIsDead)
  --spells
  for i, partyMember in pairs(party) do
    local ok = false
    local profileBuff = buffomatModule.currentProfile.Spell[buffDef.buffId]

    if profileBuff.Class[partyMember.class]
            and (not IsInRaid() or buffomatModule.character.WatchGroup[partyMember.group])
            and not profileBuff.SelfCast then
      ok = true
    end
    if profileBuff.SelfCast
            and UnitIsUnit(partyMember.unitId, "player") then
      ok = true
    end
    if partyMember.isTank and profileBuff.Class["tank"]
            and not profileBuff.SelfCast then
      ok = true
    end
    if profileBuff.ForcedTarget[partyMember.name] then
      ok = true
    end
    if profileBuff.ExcludedTarget[partyMember.name] then
      ok = false
    end

    if partyMember.NeedBuff
            and ok
            and partyMember.isConnected
            and (not buffomatModule.shared.SameZone
            or (partyMember.isSameZone
            or partyMember.class == "pet" and (--[[---@not nil]] partyMember.owner).isSameZone))
    then
      local found = false
      local partyMemberBuff = partyMember.knownBuffs[buffDef.buffId]

      if partyMember.isDead then
        someoneIsDead = true
        buffDef.groupsHaveDead[partyMember.group] = true

      elseif partyMemberBuff then
        found = self:TimeCheck(partyMemberBuff.expirationTime, partyMemberBuff.duration)
      end

      if not found then
        tinsert(buffDef.unitsNeedBuff, partyMember)
        buffDef.groupsNeedBuff[partyMember.group] = (buffDef.groupsNeedBuff[partyMember.group] or 0) + 1

      elseif buffomatModule.shared.ReplaceSingle
              and partyMemberBuff
              and partyMemberBuff.isSingle then
        buffDef.groupsNeedBuff[partyMember.group] = (buffDef.groupsNeedBuff[partyMember.group] or 0) + 1
      end
    end -- if needbuff and connected and samezone
  end -- for all in party
end