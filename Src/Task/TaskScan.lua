local BOM = BuffomatAddon ---@type BomAddon

---@shape BomTaskScanModule
---@field taskListSizeBeforeScan number Saved size before scan
---@field roundRobinGroup number Group number to refresh, rotates from 1 to 8 in raid, or stays always 1 otherwise
---@field saveSomeoneIsDead boolean
local taskScanModule = BomModuleManager.taskScanModule
taskScanModule.taskListSizeBeforeScan = 0
taskScanModule.roundRobinGroup = 0
taskScanModule.saveSomeoneIsDead = false

local _t = BomModuleManager.languagesModule
local actionCastModule = BomModuleManager.actionCastModule
local actionMacroModule = BomModuleManager.actionMacroModule
local actionUseModule = BomModuleManager.actionUseModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffChecksModule = BomModuleManager.buffChecksModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local buffTargetModule = BomModuleManager.unitBuffTargetModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local envModule = KvModuleManager.envModule
local groupBuffTargetModule = BomModuleManager.groupBuffTargetModule
local itemListCacheModule = BomModuleManager.itemListCacheModule
local partyModule = BomModuleManager.partyModule
local profileModule = BomModuleManager.profileModule
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule
local spellIdsModule = BomModuleManager.spellIdsModule
local taskListModule = BomModuleManager.taskListModule
local taskModule = BomModuleManager.taskModule
local texturesModule = BomModuleManager.texturesModule
local unitCacheModule = BomModuleManager.unitCacheModule

---@shape BomBuffScanContext
---@field someoneIsDead boolean
-- -@field inRange boolean Buff can reach the target
-- -@field macroCommand string The command to be placed in the macro
-- -@field castButtonTitle string The button in buffomat window

---@shape BomScan_NextCastSpell
---@field buffDef BomBuffDefinition|nil
---@field spellLink string|nil
---@field targetUnit BomUnit|nil
---@field spellId number|nil
---@field manaCost number
---@field temporaryDownrank boolean Pick previous rank for certain spells, like Flametongue 10
--local nextCastSpell = {}
local tasklist ---@type BomTaskList

function taskScanModule:IsFlying()
  if envModule.haveTBC then
    return IsFlying() and not buffomatModule.shared.AutoDismountFlying
  end
  return false
end

-- Global Cooldown Check
-- Call it with: if not GCDDone() then return; end
-- https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-general/wow-ui-macros-talent-specs/372421-lua-function-check-if-global-cooldown-done.html
function taskScanModule:IsInGlobalCooldown()
  local spellID = 61304
  local minValue = 0.05
  local maxValue = 0.3
  local kbsDown, kbsUp, lagHome, lagWorld = GetNetStats()
  local curPing = (lagHome + lagWorld) / 1000 + .025

  if curPing < minValue then
    curPing = minValue
  elseif curPing > maxValue then
    curPing = maxValue
  end

  local start, cdDuration = GetSpellCooldown(spellID)
  if cdDuration - curPing <= 0 then
    return false
  end
  return true
end

function taskScanModule:IsInVehicle()
  return type(UnitInVehicle) == "function" and UnitInVehicle("player")
end

---@return boolean
function taskScanModule:IsMountedAndCrusaderAuraRequired()
  if UnitOnTaxi("player") or self:IsInVehicle()
  then
    return false
  end
  return buffomatModule.shared.AutoCrusaderAura -- if setting enabled
          and IsSpellKnown(spellIdsModule.Paladin_CrusaderAura) -- and has the spell
          and (IsMounted() or self:IsFlying()) -- and flying
          and GetShapeshiftForm() ~= 7 -- and not crusader aura
end

function taskScanModule:CancelBuff(list)
  local ret = false
  if not InCombatLockdown() and list then
    for i = 1, 40 do
      --name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId,
      local _, _, _, _, _, _, source, _, _, spellId = UnitBuff("player", i, "CANCELABLE")
      if tContains(list, spellId) then
        ret = true
        BOM.cancelBuffSource = source or "player"
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

---If player just left the raid or party, reset watched frames to "watch all 8"
function taskScanModule:MaybeResetWatchGroups()
  if UnitPlayerOrPetInParty("player") == false then
    -- We have left the party - can clear monitored groups
    local need_to_report = false

    for i = 1, 8 do
      if not buffomatModule.character.WatchGroup[i] then
        buffomatModule.character.WatchGroup[i] = true
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

---Tries to activate tracking described by `spell`
---@param spell BomBuffDefinition The tracking spell to activate
---@param value boolean Whether tracking should be enabled
function taskScanModule:SetTracking(spell, value)
  -- From TBC onwards tracking is a setting and not a spell
  if envModule.haveTBC then
    for i = 1, GetNumTrackingTypes() do
      local _name, _texture, _active, _category, _nesting, spellId = GetTrackingInfo(i)
      if spellId == spell.highestRankSingleId then
        -- found, compare texture with spell icon
        --BOM:Print(_t("ActivateTracking") .. " " .. name)
        SetTracking(i, value)
        return
      end
    end
  else
    --BOM:Print(_t("ActivateTracking") .. " " .. spell.trackingSpellName)
    CastSpellByID(spell.highestRankSingleId)
  end
end

---Check per each enabled buff and each player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param party BomParty - the party
---@param buffDef BomBuffDefinition the spell to update
---@param buffCtx BomBuffScanContext
function taskScanModule:UpdateMissingBuffs_EachBuff(party, buffDef, buffCtx)
  buffCtx.someoneIsDead = false

  --local thisBuffOnPlayer = playerUnit.knownBuffs[spell.buffId]
  buffDef:ResetBuffTargets()

  -- Save skipped unit and do nothing
  if buffDef:DoesUnitHaveBetterBuffs(party.player) then
    table.insert(buffDef.unitsHaveBetterBuff, party.player)

  elseif not buffDefModule:IsBuffEnabled(buffDef.buffId, nil) then
    --nothing, the spell is not enabled!

  elseif spellButtonsTabModule:CategoryIsHidden(buffDef.category) then
    --nothing, the category is not showing!

  elseif buffDef.type == "weapon" then
    buffChecksModule:PlayerNeedsWeaponBuff(buffDef, party.player)
    -- NOTE: This must go before spell.IsConsumable clause
    -- For TBC hunter pet buffs we check if the pet is missing the buff
    -- but then the hunter must consume it

  elseif buffDef.tbcHunterPetBuff then
    buffChecksModule:HunterPetNeedsBuff(buffDef, party.player)

  elseif buffDef.isConsumable then
    buffChecksModule:PlayerNeedsConsumable(buffDef, party.player)

  elseif buffDef.isInfo then
    buffChecksModule:PartyNeedsInfoBuff(buffDef, party)

  elseif buffDef.isOwn then
    buffChecksModule:PlayerNeedsSelfBuff(buffDef, party.player)

  elseif buffDef.type == "resurrection" then
    buffChecksModule:DeadNeedsResurrection(buffDef, party)

  elseif buffDef.type == "tracking" then
    buffChecksModule:PlayerNeedsTracking(buffDef, party.player)

  elseif buffDef.type == "aura" then
    buffChecksModule:PaladinNeedsAura(buffDef, party.player)

  elseif buffDef.type == "seal" then
    buffChecksModule:PaladinNeedsSeal(buffDef, party.player)

  elseif buffDef.isBlessing then
    buffChecksModule:PartyNeedsPaladinBlessing(buffDef, party, buffCtx)

  else
    buffChecksModule:PartyNeedsBuff(buffDef, party, buffCtx)
  end

  -- Check Spell CD
  if buffDef.hasCD and #buffDef.unitsNeedBuff > 0 then
    local startTime, duration = GetSpellCooldown(buffDef.highestRankSingleId)
    if duration ~= 0 then
      -- The buff spell is still not ready
      buffDef:ResetBuffTargets()
      startTime = startTime + duration

      -- Check next time when the cooldown is up, or sooner
      if BOM.nextCooldownDue > startTime then
        BOM.nextCooldownDue = startTime
      end

      buffCtx.someoneIsDead = false
    end
  end
end

---@param spellName string
---@param units BomUnit[]
---@param groupIndex number|nil
---@param spell BomBuffDefinition
function taskScanModule:GetGroupInRange(spellName, units, groupIndex, spell)
  local minDist
  local ret
  for i, member in pairs(units) do
    if member.group == groupIndex then
      if not (IsSpellInRange(spellName, member.unitId) == 1 or member.isDead) then
        if member.distance > 2000 then
          return nil
        end
      elseif (minDist == nil or member.distance < minDist)
              and not tContains(spell.skipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end
  end

  return ret
end

---@param spellName string
---@param party BomParty
---@param buffDef BomBuffDefinition
---@param playerUnit BomUnit Default if no party
function taskScanModule:GetAnyPartyMemberInRange(spellName, buffDef, party, playerUnit)
  local minDist
  local ret

  if not UnitInParty("player") then
    return playerUnit
  end

  for i, member in ipairs(buffDef.unitsNeedBuff) do
    if IsSpellInRange(spellName, member.unitId) == 1
            and not member.isDead
            and (minDist == nil or member.distance < minDist)
            and not tContains(buffDef.skipList, member.name) then
      minDist = member.distance
      ret = member
    end
    --if not (IsSpellInRange(spellName, member.unitGUID) == 1 or member.isDead) then
    --  if member.distance > 2000 then
    --    return nil
    --  end
    --elseif (minDist == nil or member.distance < minDist)
    --        and not tContains(spell.SkipList, member.name) then
    --  minDist = member.distance
    --  ret = member
    --end
  end

  return ret
end

---Return list of members of class in spell range
---@param spellName string
---@param party BomParty
---@param class string
---@param spell BomBuffDefinition
function taskScanModule:GetClassInRange(spellName, party, class, spell)
  local minDist
  local ret

  ---@param member BomUnit
  for i, member in pairs(party.byUnitId) do
    if member.class == class then
      if member.isDead then
        return nil

      elseif not (IsSpellInRange(spellName, member.unitId) == 1) then
        if member.distance > 2000 then
          return nil
        end

      elseif (minDist == nil or member.distance < minDist)
              and not tContains(spell.skipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end -- if class
  end

  return ret
end

---@param link string Clickable spell link with icon
---@param inactiveText string Spell name as text
---@param targetUnit BomUnit
---@return boolean True if spell cast is prevented by PvP guard, false if spell can be casted
function taskScanModule:PreventPvpTagging(link, inactiveText, targetUnit)
  if buffomatModule.shared.PreventPVPTag then
    -- TODO: Move Player PVP check and instance check outside
    local _inInstance, instance_type = IsInInstance()
    if instance_type == "none"
            and not UnitIsPVP("player")
            and UnitIsPVP(targetUnit.name) then
      -- Text: [Spell Name] Player is PvP
      tasklist:Add(
              taskModule:Create(link, inactiveText)
                        :PrefixText(_t("PreventPVPTagBlocked"))
                        :Target(buffTargetModule:FromUnit(targetUnit))
                        :IsInfo())
      return true
    end
  end
  return false
end

---Run checks to see if BOM should not be scanning buffs
---@param playerUnit BomUnit
---@return boolean, string {Active, WhyNotActive: string}
function taskScanModule:IsActive(playerUnit)
  local inInstance, instanceType = IsInInstance()

  -- Cancel buff tasks if in combat (ALWAYS FIRST CHECK)
  if InCombatLockdown() then
    return false, _t("castButton.inactive.InCombat")
  end

  if UnitIsDeadOrGhost("player") then
    return false, _t("castButton.inactive.IsDead")
  end

  if instanceType == "pvp" or instanceType == "arena" then
    if not buffomatModule.shared.InPVP then
      return false, _t("castButton.inactive.PvpZone")
    end

  elseif instanceType == "party"
          or instanceType == "raid"
          or instanceType == "scenario"
  then
    if not buffomatModule.shared.InInstance then
      return false, _t("castButton.inactive.Instance")
    end
  else
    if not buffomatModule.shared.InWorld then
      return false, _t("castButton.inactive.OpenWorld")
    end
  end

  -- Cancel buff tasks if is in a resting area, and option to scan is not set
  if not buffomatModule.shared.ScanInRestArea and IsResting() then
    return false, _t("castButton.inactive.RestArea")
  end

  -- Cancel buff task scan while mounted or on taxi
  if UnitOnTaxi("player") then
    return false, _t("castButton.inactive.Taxi")
  end
  if self:IsInVehicle() then
    return false, _t("castButton.inactive.Vehicle")
  end
  if not buffomatModule.shared.ScanWhileMounted and (IsMounted()) then
    return false, _t("castButton.inactive.Mounted")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  if not buffomatModule.shared.ScanInStealth and IsStealthed() then
    return false, _t("castButton.inactive.IsStealth")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  -- and current mana is < 90%
  local spiritTapManaPercent = (buffomatModule.shared.ActivateBomOnSpiritTap or 0) * 0.01
  local currentMana = partyModule.playerMana or UnitPower("player", 0)
  if playerUnit.allBuffs[spellIdsModule.Priest_SpiritTap]
          and currentMana < UnitPowerMax("player", 0) * spiritTapManaPercent then
    return false, _t("castButton.inactive.PriestSpiritTap")
  end

  -- Having auto crusader aura enabled and Paladin class, and aura other than
  -- Crusader will block this check temporarily
  if self:IsFlying() and not self:IsMountedAndCrusaderAuraRequired() then
    -- prevent dismount in flight, OUCH!
    return false, _t("castButton.inactive.Flying")

  end

  return true, ""
end

---Activate tracking spells
function taskScanModule:ActivateSelectedTracking()
  --reset tracking
  BOM.forceTracking = nil

  for i, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    if buffDef.type == "tracking" then
      if buffDefModule:IsBuffEnabled(buffDef.buffId, nil) then
        if buffDef.requiresForm ~= nil then
          if GetShapeshiftFormID() == buffDef.requiresForm
                  and BOM.forceTracking ~= buffDef.trackingIconId then
            BOM.forceTracking = buffDef.trackingIconId
            spellButtonsTabModule:UpdateSpellsTab("ForceUp1")
          end
        elseif buffChecksModule:IsTrackingActive(buffDef)
                and buffomatModule.character.lastTrackingIconId ~= buffDef.trackingIconId then
          buffomatModule.character.lastTrackingIconId = buffDef.trackingIconId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp2")
        end
      else
        if buffomatModule.character.lastTrackingIconId == buffDef.trackingIconId
                and buffomatModule.character.lastTrackingIconId ~= nil then
          buffomatModule.character.lastTrackingIconId = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp3")
        end
      end -- if spell.enable
    end -- if tracking
  end -- for all spells

  if BOM.forceTracking == nil then
    BOM.forceTracking = buffomatModule.character.lastTrackingIconId
  end
end

---@param playerUnit BomUnit
function taskScanModule:GetActiveAuraAndSeal(playerUnit)
  --find activ aura / seal
  BOM.activePaladinAura = nil
  BOM.activePaladinSeal = nil

  ---@param buffDef BomBuffDefinition
  for i, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    local knownBuffOnPlayer = playerUnit.knownBuffs[buffDef.buffId]

    if knownBuffOnPlayer then
      if buffDef.type == "aura" then
        if (BOM.activePaladinAura == nil and BOM.lastAura == buffDef.buffId)
                or UnitIsUnit(knownBuffOnPlayer.source, "player")
        then
          if buffChecksModule:TimeCheck(knownBuffOnPlayer.expirationTime, knownBuffOnPlayer.duration) then
            BOM.activePaladinAura = buffDef.buffId
          end
        end

      elseif buffDef.type == "seal" then
        if UnitIsUnit(knownBuffOnPlayer.source, "player") then
          if buffChecksModule:TimeCheck(knownBuffOnPlayer.expirationTime, knownBuffOnPlayer.duration) then
            BOM.activePaladinSeal = buffDef.buffId
          end
        end
      end -- if is aura
    end -- if player.buffs[config.id]
  end -- for all spells
end

function taskScanModule:CheckChangesAndUpdateSpelltab()
  --reset aura/seal
  ---@param buffDef BomBuffDefinition
  for i, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    if buffDef.type == "aura" then
      if buffDefModule:IsBuffEnabled(buffDef.buffId, nil) then
        if BOM.activePaladinAura == buffDef.buffId
                and buffomatModule.currentProfile.LastAura ~= buffDef.buffId then
          buffomatModule.currentProfile.LastAura = buffDef.buffId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp4")
        end
      else
        if buffomatModule.currentProfile.LastAura == buffDef.buffId
                and buffomatModule.currentProfile.LastAura ~= nil then
          buffomatModule.currentProfile.LastAura = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp5")
        end
      end -- if currentprofile.spell.enable

    elseif buffDef.type == "seal" then
      if buffDefModule:IsBuffEnabled(buffDef.buffId, nil) then
        if BOM.activePaladinSeal == buffDef.buffId
                and buffomatModule.currentProfile.LastSeal ~= buffDef.buffId then
          buffomatModule.currentProfile.LastSeal = buffDef.buffId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp6")
        end
      else
        if buffomatModule.currentProfile.LastSeal == buffDef.buffId
                and buffomatModule.currentProfile.LastSeal ~= nil then
          buffomatModule.currentProfile.LastSeal = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp7")
        end
      end -- if currentprofile.spell.enable
    end -- if is aura
  end
end

-- TODO: Only scan missing buffs on current roundRobinGroup while in raid
---@param party BomParty - the party
---@param buffCtx BomBuffScanContext
function taskScanModule:UpdateMissingBuffs(party, buffCtx)
  -- Tracking is not a spell so it can be applied immediately
  self:ActivateSelectedTracking()

  -- Get the running aura and the running seal
  self:GetActiveAuraAndSeal(party.player)

  -- Check changes to auras and seals and update the spell tab
  self:CheckChangesAndUpdateSpelltab()

  -- =================
  -- who needs a buff?
  -- =================
  -- for each spell update spell potential targets
  buffCtx.someoneIsDead = false -- the flag that buffing cannot continue while someone is dead

  -- For each enabled buff check the targets
  for i, selectedBuff in ipairs(allBuffsModule.selectedBuffs) do
    self:UpdateMissingBuffs_EachBuff(party, selectedBuff, buffCtx)
  end

  taskScanModule.saveSomeoneIsDead = buffCtx.someoneIsDead
end

---@param playerUnit BomUnit
function taskScanModule:CancelBuffs(playerUnit)
  for i, spell in ipairs(BOM.cancelBuffs) do
    if buffomatModule.currentProfile.CancelBuff[spell.buffId].Enable
            and not spell.onlyCombat
    then
      local player_buff = playerUnit.knownBuffs[spell.buffId]

      if player_buff then
        BOM:Print(string.format(_t("message.CancelBuff"),
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
      local msg = string.format(_t("message.BuffExpired"), spell.single)
      SendChatMessage(msg, "WHISPER", nil, name)

      BOM:Print(string.format("Whisper to %s: %s", name, msg))
    end
  end
end

---@param name string Consumable name to show
---@param count number How many of that consumable is available
function taskScanModule:FormatItemBuffInactiveText(name, count)
  if count == 0 then
    return string.format("%s (%s)", name, _t("task.hint.DontHaveItem"))
  end

  return string.format("%s (x%d)", name, count)
end

---@return string
function taskScanModule:FormatItemBuffText(bag, slot, count)
  local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
  return string.format(" %s %s (x%d)",
          BOM.FormatTexture(--[[---@type string]] texture),
          item_link,
          count)
end

---Add a paladin blessing
---@param buffDef BomBuffDefinition - spell to cast
---@param party BomParty - the party
---@param buffCtx BomBuffScanContext
function taskScanModule:AddBlessing(buffDef, party, buffCtx)
  local ok, bag, slot, count
  if buffDef.reagentRequired then
    ok, bag, slot, count = buffChecksModule:HasItem(buffDef.reagentRequired, true)
  else
    ok, bag, slot, count = true, 0, 0, 0
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  if buffDef.groupMana ~= nil
          and not buffomatModule.shared.NoGroupBuff
  then
    -- For each class name WARRIOR, PALADIN, PRIEST, SHAMAN... etc
    for i, eachClassName in ipairs(constModule.CLASSES) do
      if buffDef.groupsNeedBuff[eachClassName]
              and buffDef.groupsNeedBuff[eachClassName] >= buffomatModule.shared.MinBlessing
      then
        BOM.repeatUpdate = true
        local classInRange = self:GetClassInRange(
                buffDef.groupText, --[[---@type BomParty]] buffDef.unitsNeedBuff, eachClassName, buffDef)

        if classInRange == nil then
          classInRange = self:GetClassInRange(buffDef.groupText, party, eachClassName, buffDef)
        end

        if classInRange ~= nil
                and (not buffDef.groupsHaveDead[eachClassName]
                or not buffomatModule.shared.DeathBlock)
        then
          -- Group buff (Blessing)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:Add(
                  taskModule:Create(buffDef.groupLink or buffDef.groupText, buffDef.singleText)
                            :PrefixText(_t("TASK_BLESS_GROUP"))
                            :Target(groupBuffTargetModule:New(eachClassName))
                            :InRange(true)
                            :Action(actionCastModule:New(
                          buffDef.groupMana, buffDef.highestRankGroupId, buffDef.groupLink,
                          classInRange, buffDef, false)))
        else
          -- Group buff (Blessing) just info text
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:Add(
                  taskModule:Create(buffDef.groupLink or buffDef.groupText, buffDef.singleText)
                            :PrefixText(_t("TASK_BLESS_GROUP"))
                            :Target(groupBuffTargetModule:New(eachClassName))
                            :IsInfo())
        end
      end -- if needgroup >= minblessing
    end -- for all classes
  end

  -- SINGLE BUFF (Ignored because better buff is found)
  for _k, unitHasBetter in ipairs(buffDef.unitsHaveBetterBuff) do
    tasklist:LowPrioComment(string.format(_t("tasklist.IgnoredBuffOn"),
            unitHasBetter.name, buffDef.singleText))
    -- Leave message that the target has a better or ignored buff
  end

  -- SINGLE BUFF
  for _j, needsBuff in ipairs(buffDef.unitsNeedBuff) do
    if not needsBuff.isDead
            and buffDef.singleMana ~= nil
            and (buffomatModule.shared.NoGroupBuff
            or buffDef.groupMana == nil
            or needsBuff.class == "pet"
            or buffDef.groupsNeedBuff[needsBuff.class] == nil
            or buffDef.groupsNeedBuff[needsBuff.class] < buffomatModule.shared.MinBlessing) then

      if not needsBuff.isPlayer then
        BOM.repeatUpdate = true
      end

      local add = ""
      local blessingState = buffDefModule:GetProfileBlessingState(nil)
      if blessingState[needsBuff.name] ~= nil then
        add = string.format(constModule.PICTURE_FORMAT, texturesModule.ICON_TARGET_ON)
      end

      local test_in_range = IsSpellInRange(buffDef.singleText, needsBuff.unitId) == 1
              and not tContains(buffDef.skipList, needsBuff.name)
      if self:PreventPvpTagging(buffDef.singleLink, buffDef.singleText, needsBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif test_in_range then
        -- Single buff on group member
        -- Text: Target [Spell Name]
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :PrefixText(_t("TASK_BLESS"))
                          :Target(buffTargetModule:FromUnit(needsBuff))
                          :InRange(true)
                          :Action(actionCastModule:New(
                        buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
                        needsBuff, buffDef, false)))
      else
        -- Single buff on group member (inactive just text)
        -- Text: Target "SpellName"
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :PrefixText(_t("TASK_BLESS"))
                          :Target(buffTargetModule:FromUnit(needsBuff))
                          :IsInfo())
      end -- if in range
    end -- if not dead
  end -- for all unitsNeedBuff
end

---Search for a 5man party in the current raid or party, which is in range and needs the group buff.
---This is pre-WotLK style buffing when group buff covered only 5-man parties in a raid.
---@param groupIndex number|nil
---@param buffDef BomBuffDefinition
---@param party BomParty The party
---@param minBuff number How many missing buffs mandate the group buff
---@param buffCtx BomBuffScanContext
function taskScanModule:FindTargetForGroupBuff(groupIndex, buffDef, party, minBuff, buffCtx)
  if buffDef.groupsNeedBuff[groupIndex]
          and buffDef.groupsNeedBuff[groupIndex] >= minBuff
  then
    BOM.repeatUpdate = true
    local groupInRange = self:GetGroupInRange(buffDef.groupText, buffDef.unitsNeedBuff, groupIndex, buffDef)

    --if groupInRange == nil then
    --  groupInRange = self:GetGroupInRange(buffDef.groupText, party, groupIndex, buffDef)
    --end

    --if groupInRange ~= nil and (not spell.GroupsHaveDead[groupIndex] or not buffomatModule.shared.DeathBlock) then
    if (groupIndex and not buffDef.groupsHaveDead[--[[---@not nil]] groupIndex])
            or not buffomatModule.shared.DeathBlock then
      -- Text: Group 5 [Spell Name]
      tasklist:Add(
              taskModule:Create(buffDef.groupLink or buffDef.groupText, buffDef.singleText)
                        :PrefixText(_t("task.type.GroupBuff"))
                        :Target(groupBuffTargetModule:New(groupIndex))
                        :InRange(true)
                        :Action(actionCastModule:New(
                      buffDef.groupMana, buffDef.highestRankGroupId, buffDef.groupLink,
                      groupInRange or party.player, buffDef, false)))
    end -- if group not nil
  end
end

---@param buffDef BomBuffDefinition The spell to cast
---@param party BomParty The party
---@param minBuff number Option for minimum players with missing buffs to choose group buff
---@param buffCtx BomBuffScanContext
function taskScanModule:AddBuff_GroupBuff(buffDef, party, minBuff, buffCtx)
  if envModule.haveWotLK then
    -- For WotLK: Scan entire party as one
    --inRange = self:FindAnyPartyTargetForGroupBuff(buffDef, party, minBuff, inRange)
    -- Text: Group 5 [Spell Name]
    tasklist:Add(
            taskModule:Create(buffDef.groupLink or buffDef.groupText, buffDef.singleText)
                      :PrefixText(_t("task.type.GroupBuff"))
                      :Target(groupBuffTargetModule:New(0))
                      :InRange(true)
            -- WotLK buff self for group buffs
                      :Action(actionCastModule:New(
                    buffDef.groupMana, buffDef.highestRankGroupId, buffDef.groupLink,
                    party.player, buffDef, false)))


  else
    -- For non-WotLK: Scan 5man groups in current party
    for groupIndex = 1, 8 do
      self:FindTargetForGroupBuff(groupIndex, buffDef, party, minBuff, buffCtx)
    end -- for all 8 groups
  end
end

---@param buffDef BomBuffDefinition The spell to cast
---@param minBuff number Option for minimum players with missing buffs to choose group buff
---@param buffCtx BomBuffScanContext
function taskScanModule:AddBuff_SingleBuff(buffDef, minBuff, buffCtx)
  for _i, needBuff in pairs(buffDef.unitsNeedBuff) do
    if not needBuff.isDead
            and buffDef.singleMana ~= nil
            and (buffomatModule.shared.NoGroupBuff
            or buffDef.groupMana == nil
            or needBuff.group == 9
            or buffDef.groupsNeedBuff[needBuff.group] == nil
            or buffDef.groupsNeedBuff[needBuff.group] < minBuff)
    then
      if not needBuff.isPlayer then
        BOM.repeatUpdate = true
      end

      local add = ""
      local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)
      if not profileBuff then
        BOM:Debug("No profile buff for " .. buffDef.buffId)
        return
      end

      if (--[[---@not nil]] profileBuff).ForcedTarget[needBuff.name] then
        add = string.format(constModule.PICTURE_FORMAT, texturesModule.ICON_TARGET_ON)
      end

      local unitIsInRange = (IsSpellInRange(buffDef.singleText, needBuff.unitId) == 1)
              and not tContains(buffDef.skipList, needBuff.name)

      if self:PreventPvpTagging(buffDef.singleLink, buffDef.singleText, needBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif unitIsInRange then
        -- Text: Target [Spell Name]
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :PrefixText(_t("task.type.RegularBuff"))
                          :Target(buffTargetModule:FromUnit(needBuff))
                          :InRange(true)
                          :Action(actionCastModule:New(
                        buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
                        needBuff, buffDef, false)))
      else
        -- Text: Target "SpellName"
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :PrefixText(buffomatModule:Color(constModule.TASKCOLOR_BLEAK_RED, _t("task.error.range"))
                        .. " " .. _t("task.type.RegularBuff"))
                          :Target(buffTargetModule:FromUnit(needBuff))
                          :IsInfo())
      end
    end
  end -- for all spell.needmember
end

---Add a generic buff of some sorts, or a group buff
---@param buffDef BomBuffDefinition The spell to cast
---@param party BomParty The party
---@param buffCtx BomBuffScanContext
function taskScanModule:AddBuff(buffDef, party, buffCtx)
  local ok, bag, slot, count
  if buffDef.reagentRequired then
    ok, bag, slot, count = buffChecksModule:HasItem(buffDef.reagentRequired, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  local minBuff = buffomatModule.shared.MinBuff or 3

  if buffDef.groupMana ~= nil
          and not buffomatModule.shared.NoGroupBuff
          and #buffDef.unitsNeedBuff >= minBuff then
    -- Add GROUP BUFF
    -- if group buff spell costs mana
    self:AddBuff_GroupBuff(buffDef, party, minBuff, buffCtx)
  else
    -- Add SINGLE BUFF
    self:AddBuff_SingleBuff(buffDef, minBuff, buffCtx)
  end
end

---Adds a display text for a weapon buff
---@param spell BomBuffDefinition the spell to cast
---@param playerUnit BomUnit the player
---@param buffCtx BomBuffScanContext
function taskScanModule:AddResurrection(spell, playerUnit, buffCtx)
  local clearskip = true

  for memberIndex, member in ipairs(spell.unitsNeedBuff) do
    if not tContains(spell.skipList, member.name) then
      clearskip = false
      break
    end
  end

  if clearskip then
    wipe(spell.skipList)
  end

  --Prefer resurrection classes first
  --TODO: This also modifies all subsequent operations on this table preferring those classes first
  table.sort(spell.unitsNeedBuff, function(a, b)
    local aResser = tContains(BOM.RESURRECT_CLASS, a.class)
    local bResser = tContains(BOM.RESURRECT_CLASS, b.class)
    if aResser then
      return not bResser
    end
    return false
  end)

  for _k, unitNeedsBuff in ipairs(spell.unitsNeedBuff) do
    if not tContains(spell.skipList, unitNeedsBuff.name) then
      BOM.repeatUpdate = true

      local prio = taskModule.PRIO_RESURRECTION
      if tContains(allBuffsModule.RESURRECT_CLASSES, unitNeedsBuff.class) then
        prio = taskModule.PRIO_RESURRECTION_FIRST
      end

      -- Is the body in range?
      local targetIsInRange = (IsSpellInRange(spell.singleText, unitNeedsBuff.unitId) == 1)
              and not tContains(spell.skipList, unitNeedsBuff.name)
      local task = taskModule:Create(spell.singleLink or spell.singleText, spell.singleText)
                             :PrefixText(_t("task.type.Resurrect"))
                             :Target(buffTargetModule:FromUnit(unitNeedsBuff))
                             :Prio(prio)
      if targetIsInRange then
        -- Text: Target [Spell Name]
        tasklist:Add(task:InRange(true))
      else
        -- Text: Range Target "SpellName"
        tasklist:Add(task:IsInfo())
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if targetIsInRange or (buffomatModule.shared.ResGhost and unitNeedsBuff.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        task:Action(actionCastModule:New(
                spell.singleMana, spell.highestRankSingleId, spell.singleLink,
                unitNeedsBuff, spell, false))
      end
    end
  end
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell BomBuffDefinition - the spell to cast
---@param playerMember BomUnit - the player
function taskScanModule:AddSelfbuff(spell, playerMember)
  if spell.requireWarlockPet then
    if not UnitExists("pet") or UnitCreatureType("pet") ~= "Demon" then
      return -- No demon pet - buff can not be casted
    end
  end

  local task = taskModule:Create(spell.singleLink or spell.singleText, spell.singleText)
                         :PrefixText(_t("TASK_CAST"))
                         :ExtraText(_t("task.target.SelfOnly"))
                         :Target(buffTargetModule:FromSelf(playerMember))

  if (not spell.requiresOutdoors or IsOutdoors())
          and not tContains(spell.skipList, playerMember.name) then
    -- Text: Target [Spell Name]
    tasklist:Add(
            task:Action(actionCastModule:New(
                    spell.singleMana, spell.highestRankSingleId, spell.singleLink,
                    playerMember, spell, false)))
  else
    -- Text: Target "SpellName"
    tasklist:Add(task:IsInfo())
  end
end

---Adds a summon spell to the tasks
---@param spell BomBuffDefinition - the spell to cast
---@param playerMember BomUnit
function taskScanModule:AddSummonSpell(spell, playerMember)
  if spell.sacrificeAuraIds then
    for i, id in ipairs(--[[---@not nil]] spell.sacrificeAuraIds) do
      if playerMember.allBuffs[id] then
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
    tasklist:Add(
            taskModule:Create(spell.singleLink or spell.singleText, spell.singleText)
                      :PrefixText(_t("TASK_SUMMON"))
                      :Target(buffTargetModule:FromSelf(playerMember))
                      :Action(actionCastModule:New(
                    spell.singleMana, spell.highestRankSingleId, spell.singleLink,
                    playerMember, spell, false)))
  end
end

---@param buffDef BomBuffDefinition - the spell to cast
---@param count number
---@param playerUnit BomUnit the player
function taskScanModule:AddConsumableSelfbuff_NoItem(buffDef, count, playerUnit)
  -- Text: "ConsumableName" x Count
  tasklist:Add(
          taskModule:Create(self:FormatItemBuffInactiveText(buffDef.singleText, --[[---@not nil]] count), nil)
                    :PrefixText(_t("task.type.Use"))
                    :Target(buffTargetModule:FromSelf(playerUnit))
                    :Prio(taskModule.PRIO_CONSUMABLE)
                    :IsInfo())
end

---@param buffDef BomBuffDefinition - the spell to cast
---@param bag number
---@param slot number
---@param count number
---@param playerUnit BomUnit the player
---@param target string
function taskScanModule:AddConsumableSelfbuff_HaveItemReady(buffDef, bag, slot, count, playerUnit, target)
  local taskText = _t("task.type.Use")
  if buffDef.tbcHunterPetBuff then
    taskText = _t("task.type.tbcHunterPetBuff")
  end

  local task = taskModule:Create(self:FormatItemBuffText(bag, slot, count or 0), nil)
                         :PrefixText(taskText)
                         :Target(buffTargetModule:FromSelf(playerUnit))

  if buffomatModule.shared.DontUseConsumables
          and not IsModifierKeyDown() then
    -- Text: [Icon] [Consumable Name] x Count
    tasklist:Add(task:ExtraText(_t("task.hint.HoldShiftConsumable"))
                     :IsInfo())
  else
    if bag ~= nil and slot ~= nil then
      local action = actionUseModule:New(buffDef, target, bag, slot, nil)

      -- Text: [Icon] [Consumable Name] x Count
      tasklist:Add(task
              :Action(action)
              :InRange(true))
    else
      BOM:Debug(string.format("Taskscan: bag %s slot %s", tostring(bag), tostring(slot)))
    end
  end

  BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
end

---Adds a display text for a weapon buff
---@param buffDef BomBuffDefinition - the spell to cast
---@param playerUnit BomUnit the player
---@param target string Insert this text into macro where [@player] target text would go
---@param buffCtx BomBuffScanContext
function taskScanModule:AddConsumableSelfbuff(buffDef, playerUnit, target, buffCtx)
  local haveItemOffCD, bag, slot, count = buffChecksModule:HasItem(buffDef.items or {}, true)

  if haveItemOffCD then
    self:AddConsumableSelfbuff_HaveItemReady(buffDef, bag, slot, count, playerUnit, target)
  else
    self:AddConsumableSelfbuff_NoItem(buffDef, count or 0, playerUnit)
  end
end

---@param buffDef BomBuffDefinition
---@param bag number
---@param slot number
---@param count number
---@param playerUnit BomUnit
---@param texture string
---@param itemLink string
function taskScanModule:AddConsumableWeaponBuff_HaveItem_Mainhand(buffDef, bag, slot, count, playerUnit, texture, itemLink)

  local mainhandMessage = BOM.FormatTexture(--[[---@type string]] texture) .. itemLink .. "x" .. count

  if buffomatModule.shared.DontUseConsumables
          and not IsModifierKeyDown() then
    -- Text: [Icon] [Consumable Name] x Count (Main hand)
    tasklist:Add(
            taskModule:Create(mainhandMessage, nil)
                      :ExtraText("(" .. _t("tooltip.mainhand") .. ") " .. _t("task.hint.HoldShiftConsumable"))
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :IsInfo())
  else
    -- Text: [Icon] [Consumable Name] x Count (Main hand)
    tasklist:Add(
            taskModule:Create(mainhandMessage, nil)
                      :ExtraText("(" .. _t("tooltip.mainhand") .. ")")
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :Prio(taskModule.PRIO_ENCHANTMENT)
                      :Action(actionMacroModule:New(
                    "/use " .. bag .. " " .. slot .. "\n/use 16",
                    buffDef.singleLink .. " " .. _t("tooltip.mainhand")))) -- mainhand
  end
end

---@param buffDef BomBuffDefinition
---@param bag number
---@param slot number
---@param count number
---@param playerUnit BomUnit
---@param texture string
---@param itemLink string
function taskScanModule:AddConsumableWeaponBuff_HaveItem_Offhand(buffDef, bag, slot, count, playerUnit, texture, itemLink)
  local offhandMessage = BOM.FormatTexture(--[[---@type string]] texture) .. itemLink .. "x" .. count

  if buffomatModule.shared.DontUseConsumables
          and not IsModifierKeyDown() then
    -- Text: [Icon] [Consumable Name] x Count (Off-hand)
    tasklist:Add(
            taskModule:Create(offhandMessage, nil)
                      :ExtraText("(" .. _t("tooltip.offhand") .. ") " .. _t("task.hint.HoldShiftConsumable"))
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :IsInfo())
  else
    -- Text: [Icon] [Consumable Name] x Count (Off-hand)
    tasklist:Add(
            taskModule:Create(offhandMessage, nil)
                      :ExtraText("(" .. _t("tooltip.offhand") .. ") ")
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :Prio(taskModule.PRIO_ENCHANTMENT)
                      :Action(actionMacroModule:New(
                    "/use " .. bag .. " " .. slot .. "\n/use 17",
                    buffDef.singleLink .. " " .. _t("tooltip.offhand")))) -- offhand
  end
end

---@param buffDef BomBuffDefinition
---@param bag number
---@param slot number
---@param count number
---@param playerUnit BomUnit
function taskScanModule:AddConsumableWeaponBuff_HaveItem(buffDef, bag, slot, count, playerUnit)
  -- Have item, display the cast message and setup the cast button
  local texture, _, _, _, _, _, itemLink, _, _, _ = GetContainerItemInfo(bag, slot)
  local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

  if profileBuff and (--[[---@not nil]] profileBuff).OffHandEnable
          and playerUnit.offhandEnchantment == nil
  then
    self:AddConsumableWeaponBuff_HaveItem_Offhand(buffDef, bag, slot, count, playerUnit, texture, itemLink)
  end

  if profileBuff and (--[[---@not nil]] profileBuff).MainHandEnable
          and playerUnit.mainhandEnchantment == nil
  then
    self:AddConsumableWeaponBuff_HaveItem_Mainhand(buffDef, bag, slot, count, playerUnit, texture, itemLink)
  end
  BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
end

---@param buffDef BomBuffDefinition
---@param count number
---@param playerUnit BomUnit
function taskScanModule:AddConsumableWeaponBuff_DontHaveItem(buffDef, count, playerUnit)
  -- Don't have item but display the intent
  -- Text: [Icon] [Consumable Name] x Count
  if buffDef.singleText then
    -- spell.single can be nil on addon load
    tasklist:Add(
            taskModule:Create(buffDef.singleText .. " x" .. count, nil)
                      :PrefixText(_t("task.type.Enchantment"))
                      :ExtraText(_t("task.type.MissingConsumable"))
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :IsInfo())
  else
    buffomatModule:RequestTaskRescan("weaponConsumableBuff") -- try rescan?
  end
end

---Adds a display text for a weapon buff created by a consumable item
---@param buffDef BomBuffDefinition the spell to cast
---@param playerUnit BomUnit the player
---@param buffCtx BomBuffScanContext
function taskScanModule:AddConsumableWeaponBuff(buffDef, playerUnit, buffCtx)
  -- count - reagent count remaining for the spell
  local haveItem, bag, slot, count = buffChecksModule:HasItem(buffDef.items or {}, true)
  count = count or 0

  if haveItem then
    self:AddConsumableWeaponBuff_HaveItem(buffDef,
            --[[---@not nil]] bag, --[[---@not nil]] slot, --[[---@not nil]] count,
            playerUnit)
  else
    self:AddConsumableWeaponBuff_DontHaveItem(buffDef, --[[---@not nil]] count, playerUnit)
  end
end

local function getMainhandEnchantTaskText(isDownrank)
  if isDownrank then
    return _t("tooltip.mainhand") .. ": " .. _t("shaman.flametongueDownranked")
  end
  return _t("tooltip.mainhand")
end

---Adds a display text for a weapon buff created by a spell (shamans and paladins)
---@param buffDef BomBuffDefinition - the spell to cast
---@param playerUnit BomUnit - the player
---@param buffCtx BomBuffScanContext
function taskScanModule:AddWeaponEnchant(buffDef, playerUnit, buffCtx)
  local _, selfClass, _ = UnitClass("player")
  if not envModule.haveTBC or selfClass ~= "SHAMAN" then
    return
  end

  -- Special handling for TBC shamans, you cannot specify slot for enchants,
  -- and it goes into main then offhand
  local hasMainhand, _mhExpire, _mhCharges, _mhEnchantid
  , hasOffhand, _ohExpire, _ohCharges, _ohEnchantid = GetWeaponEnchantInfo()

  local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

  -- OFFHAND FIRST
  if profileBuff
          and hasMainhand
          and (--[[---@not nil]] profileBuff).OffHandEnable
          and playerUnit.offhandEnchantment == nil then
    -- Text: [Spell Name] (Off-hand)
    tasklist:Add(
            taskModule:Create(buffDef.singleLink, buffDef.singleText)
                      :ExtraText(_t("tooltip.offhand"))
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :Prio(taskModule.PRIO_ENCHANTMENT)
                      :Action(actionCastModule:New(
                    buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
                    playerUnit, buffDef, false)))
    --end
  end

  -- MAINHAND AFTER OFFHAND
  if profileBuff
          and (--[[---@not nil]] profileBuff).MainHandEnable
          and playerUnit.mainhandEnchantment == nil then
    -- Special case is ruled by the option `ShamanFlametongueRanked`
    -- Flametongue enchant for spellhancement shamans only!
    local isDownrank = buffDef.buffId == spellIdsModule.Shaman_Flametongue6
            and buffomatModule.shared.ShamanFlametongueRanked

    local taskText = getMainhandEnchantTaskText(isDownrank)

    -- Text: [Spell Name] (Main hand)
    tasklist:Add(
            taskModule:Create(buffDef.singleLink, buffDef.singleText)
                      :ExtraText(taskText)
                      :Target(buffTargetModule:FromSelf(playerUnit))
                      :Prio(taskModule.PRIO_ENCHANTMENT)
                      :Action(actionCastModule:New(
                    buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
                    playerUnit, buffDef, isDownrank)))
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

  if buffomatModule.shared.ReputationTrinket then
    -- settings to remind to remove AD trinket != instance compatible with AD Commission
    --if playerMember.hasReputationTrinket ~= tContains(BOM.ReputationTrinket.zoneId, instanceID) then
    local hasReputationTrinket = tContains(BOM.reputationTrinketZones.itemIds, itemTrinket1) or
            tContains(BOM.reputationTrinketZones.itemIds, itemTrinket2)
    if hasReputationTrinket and not tContains(BOM.reputationTrinketZones.zoneId, instanceID) then
      -- Text: Unequip [Argent Dawn Commission]
      tasklist:Comment(_t("task.type.Unequip") .. " " .. _t("reminder.reputationTrinket"))
    end
  end

  if buffomatModule.shared.Carrot then
    local hasCarrot = tContains(BOM.ridingSpeedZones.itemIds, itemTrinket1) or
            tContains(BOM.ridingSpeedZones.itemIds, itemTrinket2)
    if hasCarrot and not tContains(BOM.ridingSpeedZones.zoneId, instanceID) then
      -- Text: Unequip [Carrot on a Stick]
      tasklist:Comment(_t("task.type.Unequip") .. " " .. _t("reminder.ridingSpeedTrinket"))
    end
  end
end

---Check player weapons and report if they have the "Warn about missing enchants" option enabled
---@param playerUnit BomUnit
function taskScanModule:CheckMissingWeaponEnchantments(playerUnit)
  -- enchantment on weapons
  ---@type boolean, number, number, number, boolean, number, number, number
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if buffomatModule.shared.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

    if link then
      -- Text: [Consumable Enchant Link]
      tasklist:Comment(_t("MSG_MAINHAND_ENCHANT_MISSING"))
    end
  end

  if buffomatModule.shared.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))

    if link then
      tasklist:Comment(_t("MSG_OFFHAND_ENCHANT_MISSING"))
    end
  end
end

---@param playerUnit BomUnit
---@param buffCtx BomBuffScanContext
function taskScanModule:CheckItemsAndContainers(playerUnit, buffCtx)
  --itemcheck
  local allPlayerItems = itemListCacheModule:GetItemList()

  for i, item in ipairs(allPlayerItems) do
    local ok = false
    local target

    if item.CD then
      if (item.CD[1] or 0) ~= 0 then
        local ti = item.CD[1] + item.CD[2] - GetTime() + 1
        if ti < BOM.nextCooldownDue then
          BOM.nextCooldownDue = ti
        end
      elseif item.Link then
        ok = true

        if allBuffsModule.itemListSpellLookup[item.ID] then
          if partyModule.itemListTarget[allBuffsModule.itemListSpellLookup[item.ID]] then
            target = partyModule.itemListTarget[allBuffsModule.itemListSpellLookup[item.ID]]
          end
        end

      end
    elseif item.Lootable then
      ok = true
    end

    if ok then
      local extraMsg = "" -- tell user they need to hold Alt or something
      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        extraMsg = _t("task.hint.HoldShiftConsumable")
      end

      local actionText = BOM.FormatTexture(item.Texture)
              .. item.Link
              .. (target and (" @" .. target) or "")
      -- Text: [Icon] [Item Link] @Target
      local task = taskModule:Create(actionText, nil)
                             :ExtraText("(" .. _t("task.UseOrOpen") .. ") " .. extraMsg)
                             :Prio(taskModule.PRIO_OPEN_CONTAINER)
                             :Target(buffTargetModule:FromSelf(playerUnit))

      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        -- Can't use or cast
        tasklist:Add(task:IsInfo())
      else
        -- Will use/cast
        tasklist:Add(task
                :Action(actionUseModule:New(nil, target, item.Bag, item.Slot, item.Link))
                :InRange(true))
      end
      BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
    end
  end
end

---@param buffDef BomBuffDefinition
---@param party BomParty
---@param buffCtx BomBuffScanContext
function taskScanModule:CreateOneBuffTask(buffDef, party, buffCtx)
  if #buffDef.unitsNeedBuff > 0
          and not buffDef.isInfo
          and not buffDef.isConsumable
  then
    if buffDef.singleMana < partyModule.playerManaLimit
            and buffDef.singleMana > partyModule.playerMana then
      partyModule.playerManaLimit = buffDef.singleMana
    end

    if buffDef.groupMana
            and buffDef.groupMana < partyModule.playerManaLimit
            and buffDef.groupMana > partyModule.playerMana then
      partyModule.playerManaLimit = buffDef.groupMana
    end
  end

  if buffDef.type == "summon" then
    self:AddSummonSpell(buffDef, party.player)

  elseif buffDef.type == "weapon" then
    if #buffDef.unitsNeedBuff > 0 then
      if buffDef.isConsumable then
        self:AddConsumableWeaponBuff(buffDef, party.player, buffCtx)
      else
        self:AddWeaponEnchant(buffDef, party.player, buffCtx)
      end
    end

  elseif buffDef.isConsumable then
    if #buffDef.unitsNeedBuff > 0 then
      self:AddConsumableSelfbuff(buffDef, party.player, buffDef.consumableTarget, buffCtx)
    end

  elseif buffDef.isInfo then
    if #buffDef.unitsNeedBuff then
      for _m, unitNeedsBuff in ipairs(buffDef.unitsNeedBuff) do
        -- Text: [Player Link] [Spell Link]
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :Target(buffTargetModule:FromUnit(unitNeedsBuff))
                          :IsInfo())
      end
    end

  elseif buffDef.type == "tracking" then
    -- TODO: Move this to its own periodic timer
    if #buffDef.unitsNeedBuff > 0 then
      if BOM.isPlayerCasting == nil then
        self:SetTracking(buffDef, true)
      else
        -- Text: "Player" "Spell Name"
        tasklist:Add(
                taskModule:Create(buffDef.singleLink or buffDef.singleText, buffDef.singleText)
                          :PrefixText(_t("TASK_ACTIVATE"))
                          :ExtraText(_t("task.type.Tracking"))
                          :Target(buffTargetModule:FromSelf(party.player)))
      end
    end

  elseif (buffDef.isOwn
          or buffDef.type == "tracking"
          or buffDef.type == "aura"
          or buffDef.type == "seal")
  then
    if buffDef.shapeshiftFormId and GetShapeshiftFormID() == buffDef.shapeshiftFormId then
      -- if spell is shapeshift, and is already active, skip it
    elseif #buffDef.unitsNeedBuff > 0 then
      -- self buffs are not pvp-guarded
      self:AddSelfbuff(buffDef, party.player)
    end

  elseif buffDef.type == "resurrection" then
    self:AddResurrection(buffDef, party.player, buffCtx)

  elseif buffDef.isBlessing then
    self:AddBlessing(buffDef, party, buffCtx)

  else
    self:AddBuff(buffDef, party, buffCtx)
  end
end

---@param party BomParty
---@param buffCtx BomBuffScanContext
function taskScanModule:CreateBuffTasks(party, buffCtx)
  -- Go through all available and selected player buffs
  for _, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

    if buffDef.isInfo and profileBuff
            and (--[[---@not nil]] profileBuff).AllowWhisper then
      self:WhisperExpired(buffDef)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if buffDefModule:IsBuffEnabled(buffDef.buffId, nil)
            and (buffDef.requiresForm == nil or GetShapeshiftFormID() == buffDef.requiresForm)
    then
      -- ================
      -- Scan entry point
      -- ================
      self:CreateOneBuffTask(buffDef, party, buffCtx)
    end
  end
end

---When a paladin is mounted and AutoCrusaderAura enabled,
---offer player to cast Crusader Aura.
---@return boolean True if the scanning should be interrupted and only crusader aura prompt will be visible
function taskScanModule:MountedCrusaderAuraPrompt()
  local playerUnit = unitCacheModule:GetUnit("player", nil, nil, nil)

  if playerUnit and self:IsMountedAndCrusaderAuraRequired() then
    local spell = allBuffsModule.CrusaderAuraSpell
    tasklist:Add(
            taskModule:Create(spell.singleLink or spell.singleText, spell.singleText)
                      :PrefixText(_t("TASK_CAST"))
                      :ExtraText(_t("task.target.SelfOnly"))
                      :Target(buffTargetModule:FromSelf(--[[---@not nil]] playerUnit))
                      :Action(actionCastModule:New(
                    spell.singleMana, spell.highestRankSingleId, spell.singleLink,
                    --[[---@not nil]] playerUnit, spell, false)))

    return true -- only show the aura and nothing else
  end

  return false -- continue scanning spells
end

function taskScanModule:SomeoneIsDrinking()
  if buffomatModule.shared.SomeoneIsDrinking ~= "hide" then
    local count = BOM.drinkingPersonCount

    if count > 1 then
      if buffomatModule.shared.SomeoneIsDrinking == "low-prio" then
        tasklist:LowPrioComment(string.format(_t("InfoMultipleDrinking"), count))
      else
        tasklist:Comment(string.format(_t("InfoMultipleDrinking"), count))
      end
    elseif count > 0 then
      if buffomatModule.shared.SomeoneIsDrinking == "low-prio" then
        tasklist:LowPrioComment(_t("InfoSomeoneIsDrinking"))
      else
        tasklist:Comment(_t("InfoSomeoneIsDrinking"))
      end
    end
  end
end

function taskScanModule:PlayTaskSound()
  local s = buffomatModule.shared.PlaySoundWhenTask
  if s ~= nil and s ~= "-" then
    PlaySoundFile("Interface\\AddOns\\BuffomatClassic\\Sounds\\" .. buffomatModule.shared.PlaySoundWhenTask)
  end
end

---@param party BomParty
function taskScanModule:UpdateScan_Scan(party)
  local buffCtx = --[[---@type BomBuffScanContext]] {
    macroCommand    = "",
    castButtonTitle = "",
    inRange         = false,
    someoneIsDead   = taskScanModule.saveSomeoneIsDead,
  }

  if next(buffomatModule.taskRescanRequestedBy) ~= nil then
    -- TODO: Only scan missing buffs on current roundRobinGroup while in raid
    self:UpdateMissingBuffs(party, buffCtx)
  end

  -- cancel buffs
  self:CancelBuffs(party.player)

  -- fill list and find cast
  partyModule.playerMana = UnitPower("player", 0) or 0 --mana
  partyModule.playerManaLimit = UnitPowerMax("player", 0) or 0

  --self:ClearNextCastSpell()

  -- Cast crusader aura when mounted, without condition. Ignore all other buffs
  if self:MountedCrusaderAuraPrompt() and not UnitOnTaxi("player") then
    tasklist:Add(
            taskModule:Create("Crusader", nil)
                      :Action(actionMacroModule:New("/cast Crusader Aura", "Crusader Aura"))
                      :InRange(true))
  else
    -- Otherwise scan all enabled spells
    BOM.scanModifierKeyDown = false

    -- ================
    -- Scan entry point
    -- ================
    self:CreateBuffTasks(party, buffCtx)

    self:CheckMissingWeaponEnchantments(party.player) -- if option to warn is enabled
    self:CheckReputationItems(party.player)

    ---Check if someone has drink buff, print an info message self:SomeoneIsDrinking()

    self:CheckItemsAndContainers(party.player, buffCtx)
  end
end

function taskScanModule:UpdateScan_Finalize()
  -- Open Buffomat if any cast tasks were added to the task list
  if #tasklist.tasks > 0 or #tasklist.comments > 0 then
    buffomatModule:AutoOpen()
    -- to avoid repeating sound, check whether task list before we started had length of 0
    if self.taskListSizeBeforeScan == 0 then
      self:PlayTaskSound()
    end
  else
    buffomatModule:FadeBuffomatWindow()
    buffomatModule:AutoClose()
  end

  tasklist:Sort()
  tasklist:Display() -- Show all tasks and comments

  buffomatModule:ClearForceUpdate()

  local firstToCast = tasklist:SelectTask()
  if firstToCast then
    tasklist:CastButton(--[[---@not nil]] firstToCast)
  else
    -- Nothing to do
    return tasklist:CastButton_Nothing() -- this is basically equal to if #tasklist.tasks == 0 below
  end
end

---For raid, invalidated group is rotated 1 to 8. For solo and party it does not rotate.
---Reloads party members and refreshes their buffs as necessary.
---@return BomParty
function taskScanModule:RotateInvalidatedGroup_GetGroup()
  if IsInRaid() then
    -- In raid we rotate groups 1 till 8 every refresh
    self.roundRobinGroup = self.roundRobinGroup + 1
    if self.roundRobinGroup > 8 then
      self.roundRobinGroup = 1
    end
  else
    self.roundRobinGroup = 1 -- always reload group 1 (also this is ignored in solo or 5man)
  end

  partyModule:InvalidatePartyGroup(self.roundRobinGroup)
  return partyModule:GetParty()
end

function taskScanModule:UpdateScan_PreCheck(from)
  if allBuffsModule.selectedBuffs == nil then
    return
  end

  if BOM.inLoadingScreen then
    return
  end

  BOM.nextCooldownDue = GetTime() + 36000 -- 10 hours
  tasklist:Clear()
  BOM.repeatUpdate = false

  --Choose Profile
  local selectedProfileName = profileModule:ChooseProfile()

  if buffomatModule.currentProfileName ~= selectedProfileName then
    buffomatModule:UseProfile(selectedProfileName)
    spellButtonsTabModule:UpdateSpellsTab("profileChanged")
    buffomatModule:RequestTaskRescan("profileChanged")
  end

  --unitCacheModule:ClearCache()
  local party = self:RotateInvalidatedGroup_GetGroup()

  -- Check whether BOM is disabled due to some option and a matching condition
  if not self:IsMountedAndCrusaderAuraRequired() then
    -- If mounted and crusader aura enabled, then do not do further checks, allow the crusader aura
    local isBomActive, reasonDisabled = self:IsActive(party.player)
    if not isBomActive then
      return self:ShowInactive(reasonDisabled)
    end
  end

  -- If in global cooldown
  --if self:IsInGlobalCooldown() then
  --  return self:ShowInactive(_t("castbutton.inactive.GCD"))
  --end

  -- If currently casting
  if BOM.isPlayerCasting == "cast" then
    return self:ShowInactive(_t("castButton.Busy"))
  else
    if BOM.isPlayerCasting == "channel" then
      return self:ShowInactive(_t("castButton.BusyChanneling"))
    end
  end

  -- All pre-checks passed
  self:UpdateScan_Scan(party)
  self:UpdateScan_Finalize()
end -- end function bomUpdateScan_PreCheck()

function taskScanModule:ShowInactive(reason)
  buffomatModule:ClearForceUpdate()
  BOM.checkForError = false
  buffomatModule:AutoClose()
  BOM.theMacro:Clear()
  buffomatModule:FadeBuffomatWindow()
  tasklist:CastButtonText(reason, false)
end

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
---@param from string Debug value to trace the caller of this function
function taskScanModule:ScanTasks(from)
  if InCombatLockdown() then
    return
  end

  -- to avoid re-playing the same sound, only play when task list changes from 0 to some tasks
  if not tasklist then
    tasklist = taskListModule:New()
  end
  self.taskListSizeBeforeScan = #tasklist.tasks

  buffomatModule:UseProfile(profileModule:ChooseProfile())

  self:UpdateScan_PreCheck(from)
end

---If a spell cast failed, the member is temporarily added to skip list, to
---continue casting buffs on other members
function BOM.AddMemberToSkipList()
  if BOM.castFailedBuff and BOM.castFailedBuffTarget then
    local castFailedBuffVal = --[[---@not nil]] BOM.castFailedBuff
    local castFailedTarget = --[[---@not nil]] BOM.castFailedBuffTarget

    if (castFailedBuffVal).skipList
            and BOM.castFailedBuffTarget then
      table.insert(castFailedBuffVal.skipList, castFailedTarget.name)
      buffomatModule:FastUpdateTimer()
      buffomatModule:RequestTaskRescan("skipListMemberAdded")
    end
  end
end

function taskScanModule:ClearSkip()
  for spellIndex, spell in ipairs(allBuffsModule.selectedBuffs) do
    if spell.skipList then
      wipe(spell.skipList)
    end
  end
end

---On Combat Start go through cancel buffs list and cancel those bufs
function BOM.DoCancelBuffs()
  if allBuffsModule.selectedBuffs == nil or buffomatModule.currentProfile == nil then
    return
  end

  for i, spell in ipairs(BOM.cancelBuffs) do
    if buffomatModule.currentProfile.CancelBuff[spell.buffId].Enable
            and taskScanModule:CancelBuff(spell.singleFamily)
    then
      BOM:Print(string.format(_t("message.CancelBuff"), spell.singleLink or spell.singleText,
              UnitName(BOM.cancelBuffSource) or ""))
    end
  end
end
