local BOM = BuffomatAddon ---@type BomAddon

---@shape BomTaskScanModule
---@field taskListSizeBeforeScan number Saved size before scan
local taskScanModule = BomModuleManager.taskScanModule ---@type BomTaskScanModule
taskScanModule.taskListSizeBeforeScan = 0

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffChecksModule = BomModuleManager.buffChecksModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local buffomatModule = BomModuleManager.buffomatModule
local buffTargetModule = BomModuleManager.unitBuffTargetModule
local constModule = BomModuleManager.constModule
local groupBuffTargetModule = BomModuleManager.groupBuffTargetModule
local itemListCacheModule = BomModuleManager.itemListCacheModule
local profileModule = BomModuleManager.profileModule
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule
local spellIdsModule = BomModuleManager.spellIdsModule
local taskListModule = BomModuleManager.taskListModule
local taskModule = BomModuleManager.taskModule
local texturesModule = BomModuleManager.texturesModule
local unitCacheModule = BomModuleManager.unitCacheModule

taskScanModule.saveSomeoneIsDead = false ---@type boolean

local tasklist ---@type BomTaskList

function taskScanModule:IsFlying()
  if BOM.isTBC then
    return IsFlying() and not buffomatModule.shared.AutoDismountFlying
  end
  return false
end

function taskScanModule:IsMountedAndCrusaderAuraRequired()
  return buffomatModule.shared.AutoCrusaderAura -- if setting enabled
          and IsSpellKnown(spellIdsModule.Paladin_CrusaderAura) -- and has the spell
          and (IsMounted() or self:IsFlying()) -- and flying
          and GetShapeshiftForm() ~= 7 -- and not crusader aura
end

function taskScanModule:SetupTasklist()
  tasklist = taskListModule:New()
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
  if BOM.isTBC then
    for i = 1, GetNumTrackingTypes() do
      local name, texture, active, _category, _nesting, spellId = GetTrackingInfo(i)
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

---Check for party, spell and player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param playerParty BomParty - the party
---@param buffDef BomBuffDefinition the spell to update
---@param playerUnit BomUnit the player
---@return boolean someoneIsDead
function taskScanModule:UpdateSpellTargets(playerParty, buffDef, playerUnit)
  local someoneIsDead = false
  --local thisBuffOnPlayer = playerUnit.knownBuffs[spell.buffId]
  buffDef:ResetBuffTargets()

  -- Save skipped unit and do nothing
  if buffDef:DoesUnitHaveBetterBuffs(playerUnit) then
    tinsert(buffDef.unitsHaveBetterBuff, playerUnit)
  elseif not buffDefModule:IsBuffEnabled(buffDef.buffId, nil) then
    --nothing, the spell is not enabled!
  elseif spellButtonsTabModule:CategoryIsHidden(buffDef.category) then
    --nothing, the category is not showing!
  elseif buffDef.type == "weapon" then
    buffChecksModule:PlayerNeedsWeaponBuff(buffDef, playerUnit)
    -- NOTE: This must go before spell.IsConsumable clause
    -- For TBC hunter pet buffs we check if the pet is missing the buff
    -- but then the hunter must consume it
  elseif buffDef.tbcHunterPetBuff then
    buffChecksModule:HunterPetNeedsBuff(buffDef, playerUnit)
  elseif buffDef.isConsumable then
    buffChecksModule:PlayerNeedsConsumable(buffDef, playerUnit)
  elseif buffDef.isInfo then
    buffChecksModule:PartyNeedsInfoBuff(buffDef, playerParty)
  elseif buffDef.isOwn then
    buffChecksModule:PlayerNeedsSelfBuff(buffDef, playerUnit)
  elseif buffDef.type == "resurrection" then
    buffChecksModule:DeadNeedsResurrection(buffDef, playerParty)
  elseif buffDef.type == "tracking" then
    buffChecksModule:PlayerNeedsTracking(buffDef, playerUnit)
  elseif buffDef.type == "aura" then
    buffChecksModule:PaladinNeedsAura(buffDef, playerUnit)
  elseif buffDef.type == "seal" then
    buffChecksModule:PaladinNeedsSeal(buffDef, playerUnit)
  elseif buffDef.isBlessing then
    someoneIsDead = buffChecksModule:PartyNeedsPaladinBlessing(buffDef, playerParty, someoneIsDead)
  else
    buffChecksModule:PartyNeedsBuff(buffDef, playerParty, someoneIsDead)
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

      someoneIsDead = false
    end
  end

  return someoneIsDead
end

--- Clears the Buffomat macro
---@param command string|nil
function taskScanModule:WipeMacro(command)
  local macro = BOM.theMacro
  macro:Recreate()
  wipe(macro.lines)

  if command then
    tinsert(macro.lines, command)
  end
  macro.icon = constModule.MACRO_ICON_DISABLED

  macro:UpdateMacro()
end

---Updates the BOM macro
-- -@param member table - next target to buff
-- -@param spellId number - spell to cast
-- -@param command string - bag command
-- -@param temporaryDownrank boolean Choose previous rank for some spells like Flametongue 10 on offhand
--function taskScanModule:UpdateMacro(member, spellId, command, temporaryDownrank)
---@param nextCast BomScan_NextCastSpell
function taskScanModule:UpdateMacro(nextCast)
  local macro = BOM.theMacro
  macro:Recreate()
  wipe(macro.lines)

  --Downgrade-Check
  local buffDef = BOM.buffFromSpellIdLookup[--[[---@not nil]] nextCast.spellId]
  local rank = ""

  if buffDef == nil then
    print("Update macro: NIL SPELL for spellid=", nextCast.spellId)
  end

  if buffomatModule.shared.UseRank
          or (nextCast.targetUnit and (--[[---@not nil]] nextCast.targetUnit).unitId == "target")
          or nextCast.temporaryDownrank then
    local level = UnitLevel((--[[---@not nil]] nextCast.targetUnit).unitId)

    if buffDef and level ~= nil and level > 0 then
      local spellChoices

      if buffDef.singleFamily and tContains(buffDef.singleFamily, nextCast.spellId) then
        spellChoices = buffDef.singleFamily
      elseif buffDef.groupFamily and tContains(buffDef.groupFamily, nextCast.spellId) then
        spellChoices = buffDef.groupFamily
      end

      if spellChoices then
        local newSpellId

        for i, id in ipairs(spellChoices) do
          if buffomatModule.shared.SpellGreaterEqualThan[id] == nil
                  or buffomatModule.shared.SpellGreaterEqualThan[id] < level then
            newSpellId = id
          else
            break
          end
          if id == nextCast.spellId then
            break
          end
        end
        nextCast.spellId = newSpellId or nextCast.spellId
      end
    end -- if spell and level

    rank = GetSpellSubtext(nextCast.spellId) or ""

    if rank ~= "" then
      rank = "(" .. rank .. ")"
    end
  end

  BOM.castFailedSpellId = nextCast.spellId
  local name = GetSpellInfo(nextCast.spellId)
  if name == nil then
    BOM:Print("Update macro: Bad spell spellid=" .. nextCast.spellId)
  end

  if tContains(BOM.cancelForm, nextCast.spellId) then
    tinsert(macro.lines, "/cancelform [nocombat]")
  end
  tinsert(macro.lines, "/bom _checkforerror")
  tinsert(macro.lines, "/cast [@" .. (--[[---@not nil]] nextCast.targetUnit).unitId .. ",nocombat]" .. name .. rank)
  macro.icon = constModule.MACRO_ICON

  macro:UpdateMacro()
end

---@param spellName string
---@param playerParty BomParty
---@param groupIndex number|nil
---@param spell BomBuffDefinition
function taskScanModule:GetGroupInRange(spellName, playerParty, groupIndex, spell)
  local minDist
  local ret
  for i, member in pairs(playerParty) do
    if member.group == groupIndex then
      if not (IsSpellInRange(spellName, member.unitId) == 1 or member.isDead) then
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
    --BOM:Debug(string.format("test %s %s %s", spellName, member.unitId, member.name))
    if IsSpellInRange(spellName, member.unitId) == 1
            and not member.isDead
            and (minDist == nil or member.distance < minDist)
            and not tContains(buffDef.SkipList, member.name) then
      minDist = member.distance
      ret = member
    end
    --if not (IsSpellInRange(spellName, member.unitId) == 1 or member.isDead) then
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
---@param playerParty BomParty
---@param class string
---@param spell BomBuffDefinition
function taskScanModule:GetClassInRange(spellName, playerParty, class, spell)
  local minDist
  local ret

  for i, member in pairs(playerParty) do
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

---@shape BomScan_NextCastSpell
---@field buffDef BomBuffDefinition|nil
---@field spellLink string|nil
---@field targetUnit BomUnit|nil
---@field spellId number|nil
---@field manaCost number
---@field temporaryDownrank boolean Pick previous rank for certain spells, like Flametongue 10
local nextCastSpell = {} ---@type BomScan_NextCastSpell

---@type number
local bomCurrentPlayerMana = 0

---@param link string Clickable spell link with icon
---@param inactiveText string Spell name as text
---@param targetUnit BomUnit
---@return boolean True if spell cast is prevented by PvP guard, false if spell can be casted
function taskScanModule:PreventPvpTagging(link, inactiveText, targetUnit)
  if buffomatModule.shared.PreventPVPTag then
    -- TODO: Move Player PVP check and instance check outside
    local _in_instance, instance_type = IsInInstance()
    if instance_type == "none"
            and not UnitIsPVP("player")
            and UnitIsPVP(targetUnit.name) then
      -- Text: [Spell Name] Player is PvP
      tasklist:Add(link, inactiveText,
              _t("PreventPVPTagBlocked"), buffTargetModule:FromUnit(targetUnit),
              true, nil)
      return true
    end
  end
  return false
end

---Stores a spell with cost/id/spell link to be casted in the `cast` global
---@param cost number Resource cost (mana cost)
---@param spellId number Spell id to capture
---@param link string Spell link for a picture
---@param targetUnit BomUnit player to benefit from the spell
---@param buffDef BomBuffDefinition the spell to be added
---@param temporaryDownrank boolean Pick previous rank for certain spells, like Flametongue 10
function taskScanModule:QueueSpell(cost, spellId, link, targetUnit, buffDef, temporaryDownrank)
  if cost > bomCurrentPlayerMana then
    return -- ouch
  end

  if not buffDef.type == "resurrection" and targetUnit.isDead then
    -- Cannot cast resurrections on deads
    return
  elseif nextCastSpell.buffDef and buffDef.type ~= "tracking" then
    if nextCastSpell.buffDef and (--[[---@not nil]] nextCastSpell.buffDef).type == "tracking" then
      return
    elseif buffDef.type == "resurrection" then
      --------------------
      -- If resurrection
      --------------------
      if nextCastSpell.buffDef
              and (--[[---@not nil]] nextCastSpell.buffDef).type == "resurrection"
      then
        local ncTargetUnit = --[[---@not nil]] nextCastSpell.targetUnit
        if (tContains(BOM.RESURRECT_CLASS, ncTargetUnit.class) and not tContains(BOM.RESURRECT_CLASS, ncTargetUnit.class))
                or (tContains(BOM.MANA_CLASSES, ncTargetUnit.class) and not tContains(BOM.MANA_CLASSES, ncTargetUnit.class))
                or (not ncTargetUnit.isGhost and ncTargetUnit.isGhost)
                or (ncTargetUnit.distance < ncTargetUnit.distance) then
          return
        end
      end
    else
      if (buffomatModule.shared.SelfFirst
              and (--[[---@not nil]] nextCastSpell.targetUnit).isPlayer and not targetUnit.isPlayer)
              or ((--[[---@not nil]] nextCastSpell.targetUnit).group ~= 9 and targetUnit.group == 9) then
        return
      elseif (not buffomatModule.shared.SelfFirst
              or ((--[[---@not nil]] nextCastSpell.targetUnit).isPlayer == targetUnit.isPlayer))
              and (((--[[---@not nil]] nextCastSpell.targetUnit).group == 9) == (targetUnit.group == 9))
              and nextCastSpell.manaCost > cost then
        return
      end
    end
  end

  nextCastSpell.temporaryDownrank = temporaryDownrank
  nextCastSpell.manaCost = cost
  nextCastSpell.spellId = spellId
  nextCastSpell.spellLink = link
  nextCastSpell.targetUnit = targetUnit
  nextCastSpell.buffDef = buffDef
end

---Cleares the spell from `cast` global
function taskScanModule:ClearNextCastSpell()
  nextCastSpell.manaCost = -1
  nextCastSpell.spellId = nil
  nextCastSpell.targetUnit = nil
  nextCastSpell.buffDef = nil
  nextCastSpell.spellLink = nil
  nextCastSpell.temporaryDownrank = false
end

---Run checks to see if BOM should not be scanning buffs
---@param playerUnit BomUnit
---@return boolean, string {Active, WhyNotActive: string}
function taskScanModule:IsActive(playerUnit)
  local in_instance, instance_type = IsInInstance()

  -- Cancel buff tasks if in combat (ALWAYS FIRST CHECK)
  if InCombatLockdown() then
    return false, _t("castButton.inactive.InCombat")
  end

  if UnitIsDeadOrGhost("player") then
    return false, _t("castButton.inactive.IsDead")
  end

  if instance_type == "pvp" or instance_type == "arena" then
    if not buffomatModule.shared.InPVP then
      return false, _t("castButton.inactive.PvpZone")
    end

  elseif instance_type == "party"
          or instance_type == "raid"
          or instance_type == "scenario"
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
  if not buffomatModule.shared.ScanWhileMounted and IsMounted() then
    return false, _t("castButton.inactive.Mounted")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  if not buffomatModule.shared.ScanInStealth and IsStealthed() then
    return false, _t("castButton.inactive.IsStealth")
  end

  -- Cancel buff tasks if is in stealth, and option to scan is not set
  -- and current mana is < 90%
  local spiritTapManaPercent = (buffomatModule.shared.ActivateBomOnSpiritTap or 0) * 0.01
  local currentMana = bomCurrentPlayerMana or UnitPower("player", 0)
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

  for i, buffDef in ipairs(BOM.selectedBuffs) do
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
  for i, buffDef in ipairs(BOM.selectedBuffs) do
    local player_buff = playerUnit.knownBuffs[buffDef.buffId]

    if player_buff then
      if buffDef.type == "aura" then
        if (BOM.activePaladinAura == nil and BOM.lastAura == buffDef.buffId)
                or UnitIsUnit(player_buff.source, "player")
        then
          if buffChecksModule:TimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.activePaladinAura = buffDef.buffId
          end
        end

      elseif buffDef.type == "seal" then
        if UnitIsUnit(player_buff.source, "player") then
          if buffChecksModule:TimeCheck(player_buff.expirationTime, player_buff.duration) then
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
  for i, buffDef in ipairs(BOM.selectedBuffs) do
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

---@param playerParty BomParty - the party
---@param playerUnit BomUnit - the player
function taskScanModule:ForceUpdate(playerParty, playerUnit)
  self:ActivateSelectedTracking()

  -- Get the running aura and the running seal
  self:GetActiveAuraAndSeal(playerUnit)

  -- Check changes to auras and seals and update the spell tab
  self:CheckChangesAndUpdateSpelltab()

  -- who needs a buff!
  -- for each spell update spell potential targets
  local someoneIsDead = false -- the flag that buffing cannot continue while someone is dead

  -- For each selected spell check the targets
  ---@param spell BomBuffDefinition
  for i, spell in ipairs(BOM.selectedBuffs) do
    someoneIsDead = self:UpdateSpellTargets(playerParty, spell, playerUnit)
  end

  taskScanModule.saveSomeoneIsDead = someoneIsDead
  return someoneIsDead
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

-- ---@param spell BomSpellDef
-- ---@param groupIndex number
-- ---@param classColorize boolean
-- ---@return string
--local function bomFormatGroupBuffText(groupIndex, spell, classColorize)
--  if classColorize then
--    return string.format(_t("FORMAT_BUFF_GROUP"),
--            "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. constModule.CLASS_NAMES[groupIndex] .. "|r",
--            spell.groupLink or spell.group or "")
--  end
--
--  return string.format(_t("FORMAT_BUFF_GROUP"),
--          constModule.CLASS_NAMES[groupIndex] or "?",
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
---@param buffDef BomBuffDefinition - spell to cast
---@param playerParty BomParty - the party
---@param playerUnit BomUnit
---@param inRange boolean - spell target is in range
---@return boolean in range
function taskScanModule:AddBlessing(buffDef, playerParty, playerUnit, inRange)
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
          classInRange = self:GetClassInRange(buffDef.groupText, playerParty, eachClassName, buffDef)
        end

        if classInRange ~= nil
                and (not buffDef.groupsHaveDead[eachClassName]
                or not buffomatModule.shared.DeathBlock)
        then
          -- Group buff (Blessing)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  _t("TASK_BLESS_GROUP"),
                  buffDef.groupLink or buffDef.groupText,
                  buffDef.singleText,
                  "",
                  groupBuffTargetModule:New(eachClassName),
                  false, nil)
          inRange = true

          self:QueueSpell(buffDef.groupMana, buffDef.highestRankGroupId, buffDef.groupLink, classInRange, buffDef, false)
        else
          -- Group buff (Blessing) just info text
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  _t("TASK_BLESS_GROUP"),
                  buffDef.groupLink or buffDef.groupText,
                  buffDef.singleText,
                  "",
                  groupBuffTargetModule:New(eachClassName),
                  true, nil)
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
              and not tContains(buffDef.SkipList, needsBuff.name)
      if self:PreventPvpTagging(buffDef.singleLink, buffDef.singleText, needsBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif test_in_range then
        -- Single buff on group member
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                "",
                buffTargetModule:FromUnit(needsBuff),
                false, nil)
        inRange = true

        self:QueueSpell(buffDef.singleMana,
                buffDef.highestRankSingleId, buffDef.singleLink,
                needsBuff, buffDef, false)
      else
        -- Single buff on group member (inactive just text)
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                "",
                buffTargetModule:FromUnit(needsBuff),
                true, nil)
      end -- if in range
    end -- if not dead
  end -- for all NeedMember

  return inRange
end

---Search for a 5man party in the current raid or party, which is in range and needs the group buff.
---This is pre-WotLK style buffing when group buff covered only 5-man parties in a raid.
---@param groupIndex number|nil
---@param buffDef BomBuffDefinition
---@param playerParty BomParty The party
---@param playerUnit BomUnit The player; TODO: Remove passing this parameter
---@param inRange boolean
---@return boolean inRange
function taskScanModule:FindTargetForGroupBuff(groupIndex, buffDef, playerParty, playerUnit, minBuff, inRange)
  if buffDef.groupsNeedBuff[groupIndex]
          and buffDef.groupsNeedBuff[groupIndex] >= minBuff
  then
    BOM.repeatUpdate = true
    local groupInRange = self:GetGroupInRange(
            buffDef.groupText, --[[---@type BomParty]] buffDef.unitsNeedBuff, groupIndex, buffDef)

    if groupInRange == nil then
      groupInRange = self:GetGroupInRange(buffDef.groupText, playerParty, groupIndex, buffDef)
    end

    --if groupInRange ~= nil and (not spell.GroupsHaveDead[groupIndex] or not buffomatModule.shared.DeathBlock) then
    if (groupIndex and not buffDef.groupsHaveDead[--[[---@not nil]] groupIndex])
            or not buffomatModule.shared.DeathBlock then
      -- Text: Group 5 [Spell Name]
      tasklist:AddWithPrefix(
              _t("task.type.GroupBuff"),
              buffDef.groupLink or buffDef.groupText,
              buffDef.singleText,
              "",
              groupBuffTargetModule:New(groupIndex),
              false, nil)
      inRange = true

      self:QueueSpell(buffDef.groupMana, buffDef.highestRankGroupId,
              buffDef.groupLink, groupInRange or playerUnit, buffDef, false)
    end -- if group not nil
  end

  return inRange
end

---Search for any party member in any size party, which is in range and needs the group buff.
---This is for WotLK style group buffing
---@param buffDef BomBuffDefinition
---@param playerParty BomParty The party
---@param playerUnit BomUnit The player; TODO: Remove passing this parameter
---@param inRange boolean
---@return boolean inRange
function taskScanModule:FindAnyPartyTargetForGroupBuff(buffDef, playerParty, playerUnit, minBuff, inRange)
  -- In WotLK group buffs do not allow range checking and are just generic 100+ yards line of sight spells
  -- Use single spell name instead for range check
  --local groupInRange = self:GetAnyPartyMemberInRange(buffDef.groupText, buffDef, playerParty, playerUnit)
  local groupInRange = self:GetAnyPartyMemberInRange(buffDef.singleText, buffDef, playerParty, playerUnit)

  --if (not buffDef.GroupsHaveDead[groupIndex] or not buffomatModule.shared.DeathBlock) then
  if groupInRange ~= nil then
    -- Text: Group 5 [Spell Name]
    tasklist:AddWithPrefix(
            _t("task.type.GroupBuff"),
            buffDef.groupLink or buffDef.groupText,
            buffDef.singleText,
            "",
            groupBuffTargetModule:New(0),
            false, nil)
    inRange = true

    self:QueueSpell(buffDef.groupMana, buffDef.highestRankGroupId, buffDef.groupLink,
            groupInRange or playerUnit, buffDef, false)
  end -- if group not nil

  return inRange
end

---@param buffDef BomBuffDefinition The spell to cast
---@param playerParty BomParty The party
---@param playerUnit BomUnit The player; TODO: Remove passing this parameter
---@param minBuff number Option for minimum players with missing buffs to choose group buff
---@param inRange boolean Spell target is in range; TODO: Remove passing this parameter
function taskScanModule:AddBuff_GroupBuff(buffDef, playerParty, playerUnit, minBuff, inRange)
  if BOM.haveWotLK then
    -- For WotLK: Scan entire party as one
    inRange = self:FindAnyPartyTargetForGroupBuff(buffDef, playerParty, playerUnit, minBuff, inRange)
  else
    -- For non-WotLK: Scan 5man groups in current party
    for groupIndex = 1, 8 do
      inRange = self:FindTargetForGroupBuff(groupIndex, buffDef, playerParty, playerUnit, minBuff, inRange)
    end -- for all 8 groups
  end

  return inRange
end

---@param buffDef BomBuffDefinition The spell to cast
---@param minBuff number Option for minimum players with missing buffs to choose group buff
---@param inRange boolean Spell target is in range; TODO: Remove passing this parameter
function taskScanModule:AddBuff_SingleBuff(buffDef, minBuff, inRange)
  for _i, needBuff in ipairs(buffDef.unitsNeedBuff) do
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
              and not tContains(buffDef.SkipList, needBuff.name)

      if self:PreventPvpTagging(buffDef.singleLink, buffDef.singleText, needBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif unitIsInRange then
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("task.type.RegularBuff"),
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                "",
                buffTargetModule:FromUnit(needBuff),
                false, nil)
        inRange = true
        self:QueueSpell(buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
                needBuff, buffDef, false)
      else
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("task.type.RegularBuff"),
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                "",
                buffTargetModule:FromUnit(needBuff),
                false, nil)
      end
    end
  end -- for all spell.needmember

  return inRange
end

---Add a generic buff of some sorts, or a group buff
---@param buffDef BomBuffDefinition The spell to cast
---@param playerParty BomParty The party
---@param playerUnit BomUnit The player; TODO: Remove passing this parameter
---@param inRange boolean Spell target is in range; TODO: Remove passing this parameter
function taskScanModule:AddBuff(buffDef, playerParty, playerUnit, inRange)
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
    inRange = self:AddBuff_GroupBuff(buffDef, playerParty, playerUnit, minBuff, inRange)
  else
    -- Add SINGLE BUFF
    inRange = self:AddBuff_SingleBuff(buffDef, minBuff, inRange)
  end

  return inRange
end

---Adds a display text for a weapon buff
---@param spell BomBuffDefinition the spell to cast
---@param playerUnit BomUnit the player
---@param inRange boolean value for range check
---@return boolean In range
function taskScanModule:AddResurrection(spell, playerUnit, inRange)
  local clearskip = true

  for memberIndex, member in ipairs(spell.unitsNeedBuff) do
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
  table.sort(spell.unitsNeedBuff, function(a, b)
    local aResser = tContains(BOM.RESURRECT_CLASS, a.class)
    local bResser = tContains(BOM.RESURRECT_CLASS, b.class)
    if aResser then
      return not bResser
    end
    return false
  end)

  for _k, unitNeedsBuff in ipairs(spell.unitsNeedBuff) do
    if not tContains(spell.SkipList, unitNeedsBuff.name) then
      BOM.repeatUpdate = true

      -- Is the body in range?
      local targetIsInRange = (IsSpellInRange(spell.singleText, unitNeedsBuff.unitId) == 1)
              and not tContains(spell.SkipList, unitNeedsBuff.name)

      if targetIsInRange then
        inRange = true
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("task.type.Resurrect"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(unitNeedsBuff),
                false,
                taskModule.TaskPriority.Resurrection)
      else
        -- Text: Range Target "SpellName"
        tasklist:AddWithPrefix(
                _t("task.type.Resurrect"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(unitNeedsBuff),
                true,
                taskModule.TaskPriority.Resurrection)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if targetIsInRange or (buffomatModule.shared.ResGhost and unitNeedsBuff.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        self:QueueSpell(spell.singleMana, spell.highestRankSingleId, spell.singleLink,
                unitNeedsBuff, spell, false)
      end
    end
  end

  return inRange
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

  if (not spell.requiresOutdoors or IsOutdoors())
          and not tContains(spell.SkipList, playerMember.name) then
    -- Text: Target [Spell Name]
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(playerMember),
            false, nil)

    self:QueueSpell(spell.singleMana, spell.highestRankSingleId, spell.singleLink,
            playerMember, spell, false)
  else
    -- Text: Target "SpellName"
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(playerMember),
            true, nil)
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
    tasklist:AddWithPrefix(
            _t("TASK_SUMMON"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            nil,
            buffTargetModule:FromSelf(playerMember),
            false, nil)

    self:QueueSpell(spell.singleMana, spell.highestRankSingleId, spell.singleLink,
            playerMember, spell, false)
  end
end

---Adds a display text for a weapon buff
---@param buffDef BomBuffDefinition - the spell to cast
---@param playerUnit BomUnit the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@param target string Insert this text into macro where [@player] target text would go
---@return string, string {cast_button_title, bag_macro_command}
function taskScanModule:AddConsumableSelfbuff(buffDef, playerUnit, castButtonTitle, macroCommand, target)
  local haveItemOffCD, bag, slot, count = buffChecksModule:HasItem(buffDef.items, true)
  count = count or 0

  local taskText = _t("TASK_USE")
  if buffDef.tbcHunterPetBuff then
    taskText = _t("TASK_TBC_HUNTER_PET_BUFF")
  end

  if haveItemOffCD then
    if buffomatModule.shared.DontUseConsumables
            and not IsModifierKeyDown() then
      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
              self:FormatItemBuffText(bag, slot, count),
              nil,
              _t("task.hint.HoldShiftConsumable"),
              buffTargetModule:FromSelf(playerUnit),
              true, nil)
    else
      if target then
        macroCommand = string.format("/use [@%s] %d %d", target, bag, slot)
      else
        macroCommand = string.format("/use %d %d", bag, slot)
      end
      castButtonTitle = _t("TASK_USE") .. " " .. buffDef.singleText

      -- Text: [Icon] [Consumable Name] x Count
      tasklist:AddWithPrefix(
              taskText,
              self:FormatItemBuffText(bag, slot, count),
              nil,
              "",
              buffTargetModule:FromSelf(playerUnit),
              false, nil)
    end

    BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
  else
    -- Text: "ConsumableName" x Count
    if buffDef.singleText then
      -- safety, can crash on load
      tasklist:AddWithPrefix(
              _t("TASK_USE"),
              self:FormatItemBuffInactiveText(buffDef.singleText, --[[---@not nil]] count),
              nil,
              nil,
              buffTargetModule:FromSelf(playerUnit),
              true, nil)
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a consumable item
---@param buffDef BomBuffDefinition the spell to cast
---@param playerUnit BomUnit the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
function taskScanModule:AddConsumableWeaponBuff(buffDef, playerUnit,
                                                castButtonTitle, macroCommand)
  -- count - reagent count remaining for the spell
  local haveItem, bag, slot, count = buffChecksModule:HasItem(buffDef.items, true)
  count = count or 0

  if haveItem then
    -- Have item, display the cast message and setup the cast button
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
    local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

    if profileBuff and (--[[---@not nil]] profileBuff).OffHandEnable
            and playerUnit.OffHandBuff == nil then
      local function offhand_message()
        return BOM.FormatTexture(texture) .. item_link .. "x" .. count
      end

      if buffomatModule.shared.DontUseConsumables
              and not IsModifierKeyDown() then
        -- Text: [Icon] [Consumable Name] x Count (Off-hand)
        tasklist:Add(
                offhand_message(),
                nil,
                "(" .. _t("TooltipOffHand") .. ") " .. _t("task.hint.HoldShiftConsumable"),
                buffTargetModule:FromSelf(playerUnit),
                true, nil)
      else
        -- Text: [Icon] [Consumable Name] x Count (Off-hand)
        castButtonTitle = offhand_message()
        macroCommand = "/use " .. bag .. " " .. slot
                .. "\n/use 17" -- offhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. _t("TooltipOffHand") .. ") ",
                buffTargetModule:FromSelf(playerUnit),
                false, nil)
      end
    end

    if profileBuff and (--[[---@not nil]] profileBuff).MainHandEnable
            and playerUnit.MainHandBuff == nil then
      local function mainhand_message()
        return BOM.FormatTexture(texture) .. item_link .. "x" .. count
      end

      if buffomatModule.shared.DontUseConsumables
              and not IsModifierKeyDown() then
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        tasklist:Add(
                mainhand_message(),
                nil,
                "(" .. _t("TooltipMainHand") .. ") " .. _t("task.hint.HoldShiftConsumable"),
                buffTargetModule:FromSelf(playerUnit),
                true, nil)
      else
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        castButtonTitle = mainhand_message()
        macroCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. _t("TooltipMainHand") .. ") ",
                buffTargetModule:FromSelf(playerUnit),
                false, nil)
      end
    end
    BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
  else
    -- Don't have item but display the intent
    -- Text: [Icon] [Consumable Name] x Count
    if buffDef.singleText then
      -- spell.single can be nil on addon load
      tasklist:Add(
              buffDef.singleText .. "x" .. count,
              nil,
              _t("task.type.MissingConsumable"),
              buffTargetModule:FromSelf(playerUnit),
              true, nil)
    else
      buffomatModule:SetForceUpdate("weaponConsumableBuff") -- try rescan?
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a spell (shamans and paladins)
---@param buffDef BomBuffDefinition - the spell to cast
---@param playerUnit BomUnit - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
function taskScanModule:AddWeaponEnchant(buffDef, playerUnit,
                                         castButtonTitle, macroCommand)
  local blockOffhandEnchant = false -- set to true to block temporarily

  local _, self_class, _ = UnitClass("player")
  if BOM.isTBC and self_class == "SHAMAN" then
    -- Special handling for TBC shamans, you cannot specify slot for enchants,
    -- and it goes into main then offhand
    local hasMainhand, _mh_expire, _mh_charges, _mh_enchantid, hasOffhand, _oh_expire, _oh_charges, _oh_enchantid = GetWeaponEnchantInfo()

    if not hasMainhand then
      -- shamans in TBC can't enchant offhand if MH enchant is missing
      blockOffhandEnchant = true
    end

    if hasOffhand then
      blockOffhandEnchant = true
    end
  end

  local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

  -- OFFHAND FIRST
  -- Because offhand sets a temporaryDownrank flag in nextCastSpell and it somehow doesn't reset when offhand is queued second
  if profileBuff and (--[[---@not nil]] profileBuff).OffHandEnable
          and playerUnit.OffHandBuff == nil then
    if blockOffhandEnchant then
      -- Text: [Spell Name] (Off-hand) Blocked waiting
      tasklist:Add(
              buffDef.singleLink,
              buffDef.singleText,
              _t("TooltipOffHand") .. ": " .. _t("ShamanEnchantBlocked"),
              buffTargetModule:FromSelf(playerUnit),
              true, nil)
    else
      -- Text: [Spell Name] (Off-hand)
      -- or:   [Spell Name] (Off-hand) Downranked
      tasklist:Add(buffDef.singleLink, buffDef.singleText, _t("TooltipOffHand"),
              buffTargetModule:FromSelf(playerUnit), false, nil)
      self:QueueSpell(buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
              playerUnit, buffDef, false)
    end
  end

  -- MAINHAND AFTER OFFHAND
  -- Because offhand sets a temporaryDownrank flag in nextCastSpell and it somehow doesn't reset when offhand is queued second
  if profileBuff and (--[[---@not nil]] profileBuff).MainHandEnable
          and playerUnit.MainHandBuff == nil then
    -- Special case is ruled by the option `ShamanFlametongueRanked`
    -- Flametongue enchant for spellhancement shamans only!
    local isDownrank = buffDef.buffId == spellIdsModule.Shaman_Flametongue6
            and buffomatModule.shared.ShamanFlametongueRanked
    local taskText = ""
    if isDownrank then
      taskText = _t("TooltipMainHand") .. ": " .. _t("shaman.flametongueDownranked")
    else
      taskText = _t("TooltipMainHand")
    end

    -- Text: [Spell Name] (Main hand)
    tasklist:Add(buffDef.singleLink, buffDef.singleText, taskText,
            buffTargetModule:FromSelf(playerUnit), false, nil)
    self:QueueSpell(buffDef.singleMana, buffDef.highestRankSingleId, buffDef.singleLink,
            playerUnit, buffDef, isDownrank)
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

  self:FadeBuffomatWindow()
end

---Check if player has rep items equipped where they should not have them
---@param playerMember BomUnit
function taskScanModule:CheckReputationItems(playerMember)
  local name, instanceType, difficultyID, difficultyName, maxPlayers
  , dynamicDifficulty, isDynamic, instanceID, instanceGroupSize
  , LfgDungeonID = GetInstanceInfo()

  local itemTrinket1, _ = GetInventoryItemID("player", 13)
  local itemTrinket2, _ = GetInventoryItemID("player", 14)

  if buffomatModule.shared.ArgentumDawn then
    -- settings to remind to remove AD trinket != instance compatible with AD Commission
    --if playerMember.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.zoneId, instanceID) then
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

---@param playerMember BomUnit
---@param castButtonTitle string
---@param macroCommand string
---@return string, string {cast_button_title, macro_command}
function taskScanModule:CheckItemsAndContainers(playerMember, castButtonTitle, macroCommand)
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

        if BOM.itemListSpellLookup[item.ID] then
          if BOM.itemListTarget[BOM.itemListSpellLookup[item.ID]] then
            target = BOM.itemListTarget[BOM.itemListSpellLookup[item.ID]]
          end
        end

      end
    elseif item.Lootable then
      ok = true
    end

    if ok then
      local extra_msg = "" -- tell user they need to hold Alt or something
      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        extra_msg = _t("task.hint.HoldShiftConsumable")
      end

      macroCommand = (target and ("/target " .. target .. "/n") or "")
              .. "/use " .. item.Bag .. " " .. item.Slot
      castButtonTitle = BOM.FormatTexture(item.Texture)
              .. item.Link
              .. (target and (" @" .. target) or "")
      -- Text: [Icon] [Item Link] @Target
      tasklist:Add(
              castButtonTitle,
              nil,
              "(" .. _t("task.UseOrOpen") .. ") " .. extra_msg,
              buffTargetModule:FromSelf(playerMember),
              true, nil)

      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        macroCommand = ""
        castButtonTitle = ""
      end
      BOM.scanModifierKeyDown = buffomatModule.shared.DontUseConsumables
    end
  end

  return castButtonTitle, macroCommand
end

---@param buffDef BomBuffDefinition
---@param playerUnit BomUnit
---@param playerParty BomParty
---@param inRange boolean TODO: Remove passing this parameter
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
function taskScanModule:ScanOneSpell(buffDef, playerParty, playerUnit, inRange,
                                     castButtonTitle, macroCommand)
  if #buffDef.unitsNeedBuff > 0
          and not buffDef.isInfo
          and not buffDef.isConsumable
  then
    if buffDef.singleMana < BOM.playerManaLimit
            and buffDef.singleMana > bomCurrentPlayerMana then
      BOM.playerManaLimit = buffDef.singleMana
    end

    if buffDef.groupMana
            and buffDef.groupMana < BOM.playerManaLimit
            and buffDef.groupMana > bomCurrentPlayerMana then
      BOM.playerManaLimit = buffDef.groupMana
    end
  end

  if buffDef.type == "summon" then
    self:AddSummonSpell(buffDef, playerUnit)

  elseif buffDef.type == "weapon" then
    if #buffDef.unitsNeedBuff > 0 then
      if buffDef.isConsumable then
        castButtonTitle, macroCommand = self:AddConsumableWeaponBuff(
                buffDef, playerUnit, castButtonTitle, macroCommand)
      else
        castButtonTitle, macroCommand = self:AddWeaponEnchant(buffDef, playerUnit, castButtonTitle, macroCommand)
      end
    end

  elseif buffDef.isConsumable then
    if #buffDef.unitsNeedBuff > 0 then
      castButtonTitle, macroCommand = self:AddConsumableSelfbuff(
              buffDef, playerUnit, castButtonTitle, macroCommand, buffDef.consumableTarget)
      inRange = true
    end

  elseif buffDef.isInfo then
    if #buffDef.unitsNeedBuff then
      for _m, unitNeedsBuff in ipairs(buffDef.unitsNeedBuff) do
        -- Text: [Player Link] [Spell Link]
        tasklist:Add(
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                "Info",
                buffTargetModule:FromUnit(unitNeedsBuff),
                true, nil)
      end
    end

  elseif buffDef.type == "tracking" then
    -- TODO: Move this to its own periodic timer
    if #buffDef.unitsNeedBuff > 0 then
      if BOM.isPlayerCasting == nil then
        self:SetTracking(buffDef, true)
      else
        -- Text: "Player" "Spell Name"
        tasklist:AddWithPrefix(
                _t("TASK_ACTIVATE"),
                buffDef.singleLink or buffDef.singleText,
                buffDef.singleText,
                _t("task.type.Tracking"),
                buffTargetModule:FromSelf(playerUnit),
                false, nil)
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
      self:AddSelfbuff(buffDef, playerUnit)
    end

  elseif buffDef.type == "resurrection" then
    inRange = self:AddResurrection(buffDef, playerUnit, inRange)

  elseif buffDef.isBlessing then
    inRange = self:AddBlessing(buffDef, playerParty, playerUnit, inRange)

  else
    inRange = self:AddBuff(buffDef, playerParty, playerUnit, inRange)
  end

  return inRange, castButtonTitle, macroCommand
end

---@param playerUnit BomUnit
---@param playerParty BomParty
---@param inRange boolean TODO: Remove passing this parameter
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {inRange, castButtonTitle, macroCommand}
function taskScanModule:ScanSelectedSpells(playerUnit, playerParty, inRange, castButtonTitle, macroCommand)
  for _, buffDef in ipairs(BOM.selectedBuffs) do
    local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

    if buffDef.isInfo and profileBuff
            and (--[[---@not nil]] profileBuff).AllowWhisper then
      self:WhisperExpired(buffDef)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if buffDefModule:IsBuffEnabled(buffDef.buffId, nil)
            and (buffDef.requiresForm == nil or GetShapeshiftFormID() == buffDef.requiresForm)
    then
      inRange, castButtonTitle, macroCommand = self:ScanOneSpell(
              buffDef, playerParty, playerUnit, inRange, castButtonTitle, macroCommand)
    end
  end

  return inRange, castButtonTitle, macroCommand
end

---When a paladin is mounted and AutoCrusaderAura enabled,
---offer player to cast Crusader Aura.
---@return boolean True if the scanning should be interrupted and only crusader aura prompt will be visible
function taskScanModule:MountedCrusaderAuraPrompt()
  local playerUnit = unitCacheModule:GetUnit("player", nil, nil, nil)

  if playerUnit and self:IsMountedAndCrusaderAuraRequired() then
    local spell = allBuffsModule.CrusaderAuraSpell
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(--[[---@not nil]] playerUnit),
            false, nil)

    self:QueueSpell(spell.singleMana, spell.highestRankSingleId, spell.singleLink,
            --[[---@not nil]] playerUnit, spell, false)

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

function taskScanModule:FadeBuffomatWindow()
  if BomC_ListTab_Button:IsEnabled() then
    BomC_MainWindow:SetAlpha(1.0)
  else
    local fade = buffomatModule.shared.FadeWhenNothingToDo
    if type(fade) ~= "number" then
      fade = 0.65
    end
    BomC_MainWindow:SetAlpha(fade) -- fade the window, default 65%
  end
end

function taskScanModule:UpdateScan_Button_Busy()
  --Print player is busy (casting normal spell)
  self:CastButton(_t("castButton.Busy"), false)
  self:WipeMacro(nil)
end

function taskScanModule:UpdateScan_Button_BusyChanneling()
  --Print player is busy (casting channeled spell)
  self:CastButton(_t("castButton.BusyChanneling"), false)
  self:WipeMacro(nil)
end

function taskScanModule:UpdateScan_Button_TargetedSpell()
  --Next cast is already defined - update the button text
  self:CastButton(--[[---@not nil]] nextCastSpell.spellLink, true)
  self:UpdateMacro(nextCastSpell)

  local cdtest = GetSpellCooldown(nextCastSpell.spellId) or 0

  if cdtest ~= 0 then
    BOM.checkCooldown = nextCastSpell.spellId
    BomC_ListTab_Button:Disable()
  else
    BomC_ListTab_Button:Enable()
  end

  BOM.castFailedBuff = nextCastSpell.buffDef
  BOM.castFailedBuffTarget = nextCastSpell.targetUnit
end

function taskScanModule:UpdateScan_Button_Nothing()
  --If don't have any strings to display, and nothing to do -
  --Clear the cast button
  self:CastButton(_t("castButton.NothingToDo"), false)

  for _i, spell in ipairs(BOM.selectedBuffs) do
    if #spell.SkipList > 0 then
      wipe(spell.SkipList)
    end
  end
end

function taskScanModule:UpdateScan_Button_SomeoneIsDead()
  self:CastButton(_t("InactiveReason_DeadMember"), false)
end

---@param inRange boolean
function taskScanModule:UpdateScan_Button_HaveTasks(inRange)
  if inRange then
    -- Range is good but cast is not possible
    --self:CastButton(ERR_OUT_OF_MANA, false)
    self:CastButton(_t("castButton.CantCastMaybeOOM"), false)
  else
    self:CastButton(ERR_SPELL_OUT_OF_RANGE, false)
    local skipreset = false

    for spellIndex, spell in ipairs(BOM.selectedBuffs) do
      if #spell.SkipList > 0 then
        skipreset = true
        wipe(spell.SkipList)
      end
    end

    if skipreset then
      buffomatModule:FastUpdateTimer()
      buffomatModule:SetForceUpdate("skipReset")
    end
  end -- if inrange
end

function taskScanModule:PlayTaskSound()
  local s = buffomatModule.shared.PlaySoundWhenTask
  if s ~= nil and s ~= "-" then
    PlaySoundFile("Interface\\AddOns\\BuffomatClassic\\Sounds\\" .. buffomatModule.shared.PlaySoundWhenTask)
  end
end

---@param playerParty BomParty
---@param playerUnit BomUnit
function taskScanModule:UpdateScan_Scan(playerParty, playerUnit)
  local someoneIsDead = taskScanModule.saveSomeoneIsDead
  if next(buffomatModule.forceUpdateRequestedBy) ~= nil then
    someoneIsDead = self:ForceUpdate(playerParty, playerUnit)
  end

  -- cancel buffs
  self:CancelBuffs(playerUnit)

  -- fill list and find cast
  bomCurrentPlayerMana = UnitPower("player", 0) or 0 --mana
  BOM.playerManaLimit = UnitPowerMax("player", 0) or 0

  self:ClearNextCastSpell()

  local macroCommand ---@type string
  local castButtonTitle ---@type string
  local inRange = false ---@type boolean

  -- Cast crusader aura when mounted, without condition. Ignore all other buffs
  if self:MountedCrusaderAuraPrompt() then
    -- Do not scan other spells
    castButtonTitle = "Crusader"
    macroCommand = "/cast Crusader Aura"
  else
    -- Otherwise scan all enabled spells
    BOM.scanModifierKeyDown = false

    inRange, castButtonTitle, macroCommand = self:ScanSelectedSpells(
            playerUnit, playerParty, inRange, castButtonTitle, macroCommand)

    self:CheckReputationItems(playerUnit)
    self:CheckMissingWeaponEnchantments(playerUnit) -- if option to warn is enabled

    ---Check if someone has drink buff, print an info message self:SomeoneIsDrinking()

    castButtonTitle, macroCommand = self:CheckItemsAndContainers(
            playerUnit, castButtonTitle, macroCommand)
  end

  -- Open Buffomat if any cast tasks were added to the task list
  if #tasklist.tasks > 0 or #tasklist.comments > 0 then
    buffomatModule:AutoOpen()
    -- to avoid repeating sound, check whether task list before we started had length of 0
    if self.taskListSizeBeforeScan == 0 then
      self:PlayTaskSound()
    end
  else
    self:FadeBuffomatWindow()
    buffomatModule:AutoClose()
  end

  tasklist:Display() -- Show all tasks and comments

  buffomatModule:ClearForceUpdate()

  if BOM.isPlayerCasting == "cast" then
    self:UpdateScan_Button_Busy()
  elseif BOM.isPlayerCasting == "channel" then
    self:UpdateScan_Button_BusyChanneling()
  elseif nextCastSpell.targetUnit and nextCastSpell.spellId then
    self:UpdateScan_Button_TargetedSpell()
  else
    if #tasklist.tasks == 0 then
      self:UpdateScan_Button_Nothing()
    else
      if someoneIsDead and buffomatModule.shared.DeathBlock then
        -- Have tasks and someone died and option is set to not buff
        self:UpdateScan_Button_SomeoneIsDead()
      else
        self:UpdateScan_Button_HaveTasks(inRange)
      end -- if somebodydeath and deathblock
    end -- if #display == 0

    if castButtonTitle then
      self:CastButton(castButtonTitle, true)
    end

    self:WipeMacro(macroCommand)
  end -- if not player casting
end -- end function bomUpdateScan_Scan()

function taskScanModule:UpdateScan_PreCheck(from)
  if BOM.selectedBuffs == nil then
    --BOM:Debug("UpdateScan_PreCheck: BOM.SelectedSpells is nil")
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
    buffomatModule:SetForceUpdate("profileChanged")
  end

  unitCacheModule:ClearCache()
  local playerParty, playerUnit = unitCacheModule:GetPartyMembers()

  -- Check whether BOM is disabled due to some option and a matching condition
  if not self:IsMountedAndCrusaderAuraRequired() then
    -- If mounted and crusader aura enabled, then do not do further checks, allow the crusader aura
    local isBomActive, reasonDisabled = self:IsActive(playerUnit)
    if not isBomActive then
      buffomatModule:ClearForceUpdate()
      BOM.checkForError = false
      buffomatModule:AutoClose()
      BOM.theMacro:Clear()
      self:FadeBuffomatWindow()
      self:CastButton(reasonDisabled, false)
      return
    end
  end

  -- All pre-checks passed
  self:UpdateScan_Scan(playerParty, playerUnit)
end -- end function bomUpdateScan_PreCheck()

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
---@param from string Debug value to trace the caller of this function
function taskScanModule:ScanNow(from)
  -- to avoid re-playing the same sound, only play when task list changes from 0 to some tasks
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

    if (castFailedBuffVal).SkipList
            and BOM.castFailedBuffTarget then
      tinsert(castFailedBuffVal.SkipList, castFailedTarget.name)
      buffomatModule:FastUpdateTimer()
      buffomatModule:SetForceUpdate("skipListMemberAdded")
    end
  end
end

function taskScanModule:ClearSkip()
  for spellIndex, spell in ipairs(BOM.selectedBuffs) do
    if spell.SkipList then
      wipe(spell.SkipList)
    end
  end
end

---On Combat Start go through cancel buffs list and cancel those bufs
function BOM.DoCancelBuffs()
  if BOM.selectedBuffs == nil or buffomatModule.currentProfile == nil then
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
