local BOM = BuffomatAddon ---@type BomAddon

---@class BomTaskScanModule
local taskScanModule = BuffomatModule.New("TaskScan") ---@type BomTaskScanModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local buffChecksModule = BuffomatModule.Import("BuffChecks") ---@type BomBuffChecksModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule
local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local buffTargetModule = BuffomatModule.Import("UnitBuffTarget") ---@type BomUnitBuffTargetModule
local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local groupBuffTargetModule = BuffomatModule.Import("GroupBuffTarget") ---@type BomGroupBuffTargetModule
local profileModule = BuffomatModule.Import("Profile") ---@type BomProfileModule
local spellButtonsTabModule = BuffomatModule.Import("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
local spellIdsModule = BuffomatModule.Import("SpellIds") ---@type BomSpellIdsModule
local taskListModule = BuffomatModule.Import("TaskList") ---@type BomTaskListModule
local unitCacheModule = BuffomatModule.Import("UnitCache") ---@type BomUnitCacheModule

local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

taskScanModule.saveSomeoneIsDead = false

local tasklist ---@type BomTaskList

function taskScanModule:IsFlying()
  if BOM.IsTBC then
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
  if BOM.IsTBC then
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

---Check for party, spell and player, which targets that spell goes onto
---Update spell.NeedMember, spell.NeedGroup and spell.DeathGroup
---@param party table<number, BomUnit> - the party
---@param spell BomBuffDefinition the spell to update
---@param playerUnit BomUnit the player
---@return boolean someoneIsDead
function taskScanModule:UpdateSpellTargets(party, spell, playerUnit)
  local someoneIsDead = false
  --local thisBuffOnPlayer = playerUnit.knownBuffs[spell.buffId]
  spell:ResetBuffTargets()

  -- Save skipped unit and do nothing
  if spell:DoesUnitHaveBetterBuffs(playerUnit) then
    tinsert(spell.UnitsHaveBetterBuff, playerUnit)
  elseif not buffDefModule:IsSpellEnabled(spell.buffId) then
    --nothing, the spell is not enabled!
  elseif spellButtonsTabModule:CategoryIsHidden(spell.category) then
    --nothing, the category is not showing!
  elseif spell.type == "weapon" then
    buffChecksModule:PlayerNeedsWeaponBuff(spell, playerUnit, party, someoneIsDead)
    -- NOTE: This must go before spell.IsConsumable clause
    -- For TBC hunter pet buffs we check if the pet is missing the buff
    -- but then the hunter must consume it
  elseif spell.tbcHunterPetBuff then
    buffChecksModule:HunterPetNeedsBuff(spell, playerUnit, party, someoneIsDead)
  elseif spell.isConsumable then
    buffChecksModule:PlayerNeedsConsumable(spell, playerUnit, party, someoneIsDead)
  elseif spell.isInfo then
    buffChecksModule:PartyNeedsInfoBuff(spell, playerUnit, party, someoneIsDead)
  elseif spell.isOwn then
    buffChecksModule:PlayerNeedsSelfBuff(spell, playerUnit, party, someoneIsDead)
  elseif spell.type == "resurrection" then
    buffChecksModule:DeadNeedsResurrection(spell, playerUnit, party, someoneIsDead)
  elseif spell.type == "tracking" then
    buffChecksModule:PlayerNeedsTracking(spell, playerUnit, party, someoneIsDead)
  elseif spell.type == "aura" then
    buffChecksModule:PaladinNeedsAura(spell, playerUnit, party, someoneIsDead)
  elseif spell.type == "seal" then
    buffChecksModule:PaladinNeedsSeal(spell, playerUnit, party, someoneIsDead)
  elseif spell.isBlessing then
    someoneIsDead = buffChecksModule:PartyNeedsPaladinBlessing(spell, playerUnit, party, someoneIsDead)
  else
    buffChecksModule:PartyNeedsBuff(spell, playerUnit, party, someoneIsDead)
  end

  -- Check Spell CD
  if spell.hasCD and #spell.UnitsNeedBuff > 0 then
    local startTime, duration = GetSpellCooldown(spell.singleId)
    if duration ~= 0 then
      -- The buff spell is still not ready
      spell:ResetBuffTargets()
      startTime = startTime + duration

      -- Check next time when the cooldown is up, or sooner
      if BOM.MinTimer > startTime then
        BOM.MinTimer = startTime
      end

      someoneIsDead = false
    end
  end

  return someoneIsDead
end

--- Clears the Buffomat macro
---@param command string
function taskScanModule:WipeMacro(command)
  local macro = BOM.Macro
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
  local macro = BOM.Macro
  macro:Recreate()
  wipe(macro.lines)

  --Downgrade-Check
  local spell = BOM.ConfigToSpell[nextCast.spellId]
  local rank = ""

  if spell == nil then
    print("Update macro: NIL SPELL for spellid=", nextCast.spellId)
  end

  if buffomatModule.shared.UseRank
          or nextCast.targetUnit.unitId == "target"
          or nextCast.temporaryDownrank then
    local level = UnitLevel(nextCast.targetUnit.unitId)

    if spell and level ~= nil and level > 0 then
      local x

      if spell.singleFamily and tContains(spell.singleFamily, nextCast.spellId) then
        x = spell.singleFamily
      elseif spell.groupFamily and tContains(spell.groupFamily, nextCast.spellId) then
        x = spell.groupFamily
      end

      if x then
        local newSpellId

        for i, id in ipairs(x) do
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

  BOM.CastFailedSpellId = nextCast.spellId
  local name = GetSpellInfo(nextCast.spellId)
  if name == nil then
    BOM:Print("Update macro: Bad spell spellid=" .. nextCast.spellId)
  end

  if tContains(BOM.cancelForm, nextCast.spellId) then
    tinsert(macro.lines, "/cancelform [nocombat]")
  end
  tinsert(macro.lines, "/bom _checkforerror")
  tinsert(macro.lines, "/cast [@" .. nextCast.targetUnit.unitId .. ",nocombat]" .. name .. rank)
  macro.icon = constModule.MACRO_ICON

  macro:UpdateMacro()
end

---@param spellName string
---@param party table<number, BomUnit>
---@param groupIndex number
---@param spell BomBuffDefinition
function taskScanModule:GetGroupInRange(spellName, party, groupIndex, spell)
  local minDist
  local ret
  for i, member in ipairs(party) do
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

---Return list of members of class in spell range
---@param spellName string
---@param party table<number, BomUnit>
---@param class string
---@param spell BomBuffDefinition
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
---@field spell BomBuffDefinition
---@field spellLink string|nil
---@field targetUnit string|nil
---@field spellId number|nil
---@field manaCost number
---@field temporaryDownrank boolean Pick previous rank for certain spells, like Flametongue 10
local nextCastSpell = {} ---@type BomScan_NextCastSpell

---@type number
local bomCurrentPlayerMana = 0

---@param link string Clickable spell link with icon
---@param inactiveText string Spell name as text
---@param member BomUnit
---@return boolean True if spell cast is prevented by PvP guard, false if spell can be casted
function taskScanModule:PreventPvpTagging(link, inactiveText, member)
  if buffomatModule.shared.PreventPVPTag then
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
  elseif nextCastSpell.spell and buffDef.type ~= "tracking" then
    if nextCastSpell.spell.type == "tracking" then
      return
    elseif buffDef.type == "resurrection" then
      --------------------
      -- If resurrection
      --------------------
      if nextCastSpell.spell.type == "resurrection" then
        if (tContains(BOM.RESURRECT_CLASS, nextCastSpell.targetUnit.class) and not tContains(BOM.RESURRECT_CLASS, targetUnit.class))
                or (tContains(BOM.MANA_CLASSES, nextCastSpell.targetUnit.class) and not tContains(BOM.MANA_CLASSES, targetUnit.class))
                or (not nextCastSpell.targetUnit.isGhost and targetUnit.isGhost)
                or (nextCastSpell.targetUnit.distance < targetUnit.distance) then
          return
        end
      end
    else
      if (buffomatModule.shared.SelfFirst
              and nextCastSpell.targetUnit.isPlayer and not targetUnit.isPlayer)
              or (nextCastSpell.targetUnit.group ~= 9 and targetUnit.group == 9) then
        return
      elseif (not buffomatModule.shared.SelfFirst
              or (nextCastSpell.targetUnit.isPlayer == targetUnit.isPlayer))
              and ((nextCastSpell.targetUnit.group == 9) == (targetUnit.group == 9))
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
  nextCastSpell.spell = buffDef
end

---Cleares the spell from `cast` global
function taskScanModule:ClearNextCastSpell()
  nextCastSpell.manaCost = -1
  nextCastSpell.spellId = nil
  nextCastSpell.targetUnit = nil
  nextCastSpell.spell = nil
  nextCastSpell.spellLink = nil
  nextCastSpell.temporaryDownrank = false
end

---Run checks to see if BOM should not be scanning buffs
---@return boolean, string {Active, WhyNotActive: string}
---@param playerUnit BomUnit
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

  return true, nil
end

---Activate tracking spells
function taskScanModule:ActivateSelectedTracking()
  --reset tracking
  BOM.ForceTracking = nil

  ---@param spell BomBuffDefinition
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "tracking" then
      if buffDefModule:IsSpellEnabled(spell.buffId) then
        if spell.needForm ~= nil then
          if GetShapeshiftFormID() == spell.needForm
                  and BOM.ForceTracking ~= spell.trackingIconId then
            BOM.ForceTracking = spell.trackingIconId
            spellButtonsTabModule:UpdateSpellsTab("ForceUp1")
          end
        elseif buffChecksModule:IsTrackingActive(spell)
                and buffomatModule.character.LastTracking ~= spell.trackingIconId then
          buffomatModule.character.LastTracking = spell.trackingIconId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp2")
        end
      else
        if buffomatModule.character.LastTracking == spell.trackingIconId
                and buffomatModule.character.LastTracking ~= nil then
          buffomatModule.character.LastTracking = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp3")
        end
      end -- if spell.enable
    end -- if tracking
  end -- for all spells

  if BOM.ForceTracking == nil then
    BOM.ForceTracking = buffomatModule.character.LastTracking
  end
end

---@param playerUnit BomUnit
function taskScanModule:GetActiveAuraAndSeal(playerUnit)
  --find activ aura / seal
  BOM.ActivePaladinAura = nil
  BOM.ActivePaladinSeal = nil

  ---@param spell BomBuffDefinition
  for i, spell in ipairs(BOM.SelectedSpells) do
    local player_buff = playerUnit.knownBuffs[spell.buffId]

    if player_buff then
      if spell.type == "aura" then
        if (BOM.ActivePaladinAura == nil and BOM.LastAura == spell.buffId)
                or UnitIsUnit(player_buff.source, "player")
        then
          if buffChecksModule:TimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivePaladinAura = spell.buffId
          end
        end

      elseif spell.type == "seal" then
        if UnitIsUnit(player_buff.source, "player") then
          if buffChecksModule:TimeCheck(player_buff.expirationTime, player_buff.duration) then
            BOM.ActivePaladinSeal = spell.buffId
          end
        end
      end -- if is aura
    end -- if player.buffs[config.id]
  end -- for all spells
end

function taskScanModule:CheckChangesAndUpdateSpelltab()
  --reset aura/seal
  ---@param spell BomBuffDefinition
  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.type == "aura" then
      if buffDefModule:IsSpellEnabled(spell.buffId) then
        if BOM.ActivePaladinAura == spell.buffId
                and buffomatModule.currentProfile.LastAura ~= spell.buffId then
          buffomatModule.currentProfile.LastAura = spell.buffId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp4")
        end
      else
        if buffomatModule.currentProfile.LastAura == spell.buffId
                and buffomatModule.currentProfile.LastAura ~= nil then
          buffomatModule.currentProfile.LastAura = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp5")
        end
      end -- if currentprofile.spell.enable

    elseif spell.type == "seal" then
      if buffDefModule:IsSpellEnabled(spell.buffId) then
        if BOM.ActivePaladinSeal == spell.buffId
                and buffomatModule.currentProfile.LastSeal ~= spell.buffId then
          buffomatModule.currentProfile.LastSeal = spell.buffId
          spellButtonsTabModule:UpdateSpellsTab("ForceUp6")
        end
      else
        if buffomatModule.currentProfile.LastSeal == spell.buffId
                and buffomatModule.currentProfile.LastSeal ~= nil then
          buffomatModule.currentProfile.LastSeal = nil
          spellButtonsTabModule:UpdateSpellsTab("ForceUp7")
        end
      end -- if currentprofile.spell.enable
    end -- if is aura
  end
end

---@param party table<number, BomUnit> - the party
---@param playerUnit BomUnit - the player
function taskScanModule:ForceUpdate(party, playerUnit)
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
  for i, spell in ipairs(BOM.SelectedSpells) do
    someoneIsDead = self:UpdateSpellTargets(party, spell, playerUnit)
  end

  taskScanModule.saveSomeoneIsDead = someoneIsDead
  return someoneIsDead
end

---@param playerUnit BomUnit
function taskScanModule:CancelBuffs(playerUnit)
  for i, spell in ipairs(BOM.CancelBuffs) do
    if buffomatModule.currentProfile.CancelBuff[spell.buffId].Enable
            and not spell.OnlyCombat
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
---@param spell BomBuffDefinition - spell to cast
---@param party table<number, BomUnit> - the party
---@param playerMember table - player
---@param inRange boolean - spell target is in range
function taskScanModule:AddBlessing(spell, party, playerMember, inRange)
  local ok, bag, slot, count
  if spell.reagentRequired then
    ok, bag, slot, count = buffChecksModule:HasItem(spell.reagentRequired, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  if spell.groupMana ~= nil
          and not buffomatModule.shared.NoGroupBuff
  then
    -- For each class name WARRIOR, PALADIN, PRIEST, SHAMAN... etc
    for i, eachClassName in ipairs(BOM.Tool.Classes) do
      if spell.GroupsNeedBuff[eachClassName]
              and spell.GroupsNeedBuff[eachClassName] >= buffomatModule.shared.MinBlessing
      then
        BOM.RepeatUpdate = true
        local classInRange = self:GetClassInRange(spell.groupText, spell.UnitsNeedBuff, eachClassName, spell)

        if classInRange == nil then
          classInRange = self:GetClassInRange(spell.groupText, party, eachClassName, spell)
        end

        if classInRange ~= nil
                and (not spell.GroupsHaveDead[eachClassName]
                or not buffomatModule.shared.DeathBlock)
        then
          -- Group buff (Blessing)
          -- Text: Group 5 [Spell Name] x Reagents
          tasklist:AddWithPrefix(
                  _t("TASK_BLESS_GROUP"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
                  "",
                  groupBuffTargetModule:New(eachClassName),
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
                  groupBuffTargetModule:New(eachClassName),
                  true)
        end
      end -- if needgroup >= minblessing
    end -- for all classes
  end

  -- SINGLE BUFF (Ignored because better buff is found)
  for _k, unitHasBetter in ipairs(spell.UnitsHaveBetterBuff) do
    tasklist:LowPrioComment(string.format(_t("tasklist.IgnoredBuffOn"),
            unitHasBetter.name, spell.singleText))
    -- Leave message that the target has a better or ignored buff
  end

  -- SINGLE BUFF
  for _j, unitNeedsBuff in ipairs(spell.UnitsNeedBuff) do
    if not unitNeedsBuff.isDead
            and spell.singleMana ~= nil
            and (buffomatModule.shared.NoGroupBuff
            or spell.groupMana == nil
            or unitNeedsBuff.class == "pet"
            or spell.GroupsNeedBuff[unitNeedsBuff.class] == nil
            or spell.GroupsNeedBuff[unitNeedsBuff.class] < buffomatModule.shared.MinBlessing) then

      if not unitNeedsBuff.isPlayer then
        BOM.RepeatUpdate = true
      end

      local add = ""
      local blessing_name = buffDefModule:GetProfileBuff(constModule.BLESSING_ID)
      if blessing_name[unitNeedsBuff.name] ~= nil then
        add = string.format(constModule.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local test_in_range = IsSpellInRange(spell.singleText, unitNeedsBuff.unitId) == 1
              and not tContains(spell.SkipList, unitNeedsBuff.name)
      if self:PreventPvpTagging(spell.singleLink, spell.singleText, unitNeedsBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif test_in_range then
        -- Single buff on group member
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(unitNeedsBuff),
                false)
        inRange = true

        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, unitNeedsBuff, spell)
      else
        -- Single buff on group member (inactive just text)
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("TASK_BLESS"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(unitNeedsBuff),
                true)
      end -- if in range
    end -- if not dead
  end -- for all NeedMember
end

---Add a generic buff of some sorts, or a group buff
---@param spell BomBuffDefinition The spell to cast
---@param party table<number, BomUnit> The party
---@param playerUnit BomUnit The player; TODO: Remove passing this parameter
---@param inRange boolean Spell target is in range; TODO: Remove passing this parameter
function taskScanModule:AddBuff(spell, party, playerUnit, inRange)
  local ok, bag, slot, count
  if spell.reagentRequired then
    ok, bag, slot, count = buffChecksModule:HasItem(spell.reagentRequired, true)
  end

  if type(count) == "number" then
    count = " x" .. count .. " "
  else
    count = ""
  end

  ------------------------
  -- Add GROUP BUFF
  ------------------------
  local minBuff = buffomatModule.shared.MinBuff or 3

  if BOM.HaveWotLK then
    inRange = true -- cast on self to group buff, always in range
  end

  if spell.groupMana ~= nil and not buffomatModule.shared.NoGroupBuff then
    for groupIndex = 1, 8 do
      if spell.GroupsNeedBuff[groupIndex]
              and spell.GroupsNeedBuff[groupIndex] >= minBuff
      then
        BOM.RepeatUpdate = true
        local groupInRange = self:GetGroupInRange(spell.groupText, spell.UnitsNeedBuff, groupIndex, spell)

        if groupInRange == nil then
          groupInRange = self:GetGroupInRange(spell.groupText, party, groupIndex, spell)
        end

          --if groupInRange ~= nil and (not spell.GroupsHaveDead[groupIndex] or not buffomatModule.shared.DeathBlock) then
        if (not spell.GroupsHaveDead[groupIndex] or not buffomatModule.shared.DeathBlock) then
          -- Text: Group 5 [Spell Name]
          tasklist:AddWithPrefix(
                  _t("task.type.GroupBuff"),
                  spell.groupLink or spell.groupText,
                  spell.singleText,
                  "",
                  groupBuffTargetModule:New(groupIndex),
                  false)
          inRange = true

          self:QueueSpell(spell.groupMana, spell.groupId, spell.groupLink, groupInRange or playerUnit, spell)
        --else
        --  -- Group in range is nil, or someone is dead
        --  -- Text: Group 5 [Spell Name]
        --  tasklist:AddWithPrefix(
        --          _t("task.type.GroupBuff"),
        --          spell.groupLink or spell.groupText,
        --          spell.singleText,
        --          "",
        --          groupBuffTargetModule:New(groupIndex),
        --          false)
        end -- if group not nil
      end
    end -- for all 8 groups
  end -- if group buff spell costs mana

  ------------------------
  -- Add SINGLE BUFF
  ------------------------
  for _i, needBuff in ipairs(spell.UnitsNeedBuff) do
    if not needBuff.isDead
            and spell.singleMana ~= nil
            and (buffomatModule.shared.NoGroupBuff
            or spell.groupMana == nil
            or needBuff.group == 9
            or spell.GroupsNeedBuff[needBuff.group] == nil
            or spell.GroupsNeedBuff[needBuff.group] < minBuff)
    then
      if not needBuff.isPlayer then
        BOM.RepeatUpdate = true
      end

      local add = ""
      local profileBuff = buffDefModule:GetProfileBuff(spell.buffId)

      if profileBuff.ForcedTarget[needBuff.name] then
        add = string.format(constModule.PICTURE_FORMAT, BOM.ICON_TARGET_ON)
      end

      local unitIsInRange = (IsSpellInRange(spell.singleText, needBuff.unitId) == 1)
              and not tContains(spell.SkipList, needBuff.name)

      if self:PreventPvpTagging(spell.singleLink, spell.singleText, needBuff) then
        -- Nothing, prevent poison function has already added the text
      elseif unitIsInRange then
        -- Text: Target [Spell Name]
        tasklist:AddWithPrefix(
                _t("task.type.RegularBuff"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(needBuff),
                false)
        inRange = true
        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, needBuff, spell)
      else
        -- Text: Target "SpellName"
        tasklist:AddWithPrefix(
                _t("task.type.RegularBuff"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(needBuff),
                false)
      end
    end
  end -- for all spell.needmember

  return inRange
end

---Adds a display text for a weapon buff
---@param spell BomBuffDefinition the spell to cast
---@param playerUnit BomUnit the player
---@param inRange boolean value for range check
---@return table (bag_title string, bag_command string)
function taskScanModule:AddResurrection(spell, playerUnit, inRange)
  local clearskip = true

  for memberIndex, member in ipairs(spell.UnitsNeedBuff) do
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
  table.sort(spell.UnitsNeedBuff, function(a, b)
    local a_resser = tContains(BOM.RESURRECT_CLASS, a.class)
    local b_resser = tContains(BOM.RESURRECT_CLASS, b.class)
    if a_resser then
      return not b_resser
    end
    return false
  end)

  for _k, unitNeedsBuff in ipairs(spell.UnitsNeedBuff) do
    if not tContains(spell.SkipList, unitNeedsBuff.name) then
      BOM.RepeatUpdate = true

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
                BOM.TaskPriority.Resurrection)
      else
        -- Text: Range Target "SpellName"
        tasklist:AddWithPrefix(
                _t("task.type.Resurrect"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                "",
                buffTargetModule:FromUnit(unitNeedsBuff),
                true,
                BOM.TaskPriority.Resurrection)
      end

      -- If in range, we can res?
      -- Should we try and resurrect ghosts when their corpse is not targetable?
      if targetIsInRange or (buffomatModule.shared.ResGhost and unitNeedsBuff.isGhost) then
        -- Prevent resurrecting PvP players in the world?
        self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink, unitNeedsBuff, spell)
      end
    end
  end

  return inRange
end

---Adds a display text for a self buff or tracking or seal/weapon self-enchant
---@param spell BomBuffDefinition - the spell to cast
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
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(playerMember),
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  else
    -- Text: Target "SpellName"
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(playerMember),
            true)
  end
end

---Adds a summon spell to the tasks
---@param spell BomBuffDefinition - the spell to cast
---@param playerMember BomUnit
function taskScanModule:AddSummonSpell(spell, playerMember)
  if spell.sacrificeAuraIds then
    for i, id in ipairs(spell.sacrificeAuraIds) do
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
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)
  end
end

---Adds a display text for a weapon buff
---@param spell BomBuffDefinition - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@param target string Insert this text into macro where [@player] target text would go
---@return string, string {cast_button_title, bag_macro_command}
function taskScanModule:AddConsumableSelfbuff(spell, playerMember, castButtonTitle, macroCommand, target)
  local haveItemOffCD, bag, slot, count = buffChecksModule:HasItem(spell.items, true)
  count = count or 0

  local taskText = _t("TASK_USE")
  if spell.tbcHunterPetBuff then
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
              buffTargetModule:FromSelf(playerMember),
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
              buffTargetModule:FromSelf(playerMember),
              false)
    end

    BOM.ScanModifier = buffomatModule.shared.DontUseConsumables
  else
    -- Text: "ConsumableName" x Count
    if spell.singleText then
      -- safety, can crash on load
      tasklist:AddWithPrefix(
              _t("TASK_USE"),
              self:FormatItemBuffInactiveText(spell.singleText, count),
              nil,
              "",
              buffTargetModule:FromSelf(playerMember),
              true)
    end
  end

  return castButtonTitle, macroCommand
end

---Adds a display text for a weapon buff created by a consumable item
---@param spell BomBuffDefinition - the spell to cast
---@param playerMember table - the player
---@param castButtonTitle string - if not empty, is item name from the bag
---@param macroCommand string - console command to use item from the bag
---@return string, string cast button title and macro command
function taskScanModule:AddConsumableWeaponBuff(spell, playerMember,
                                                castButtonTitle, macroCommand)
  -- count - reagent count remaining for the spell
  local have_item, bag, slot, count = buffChecksModule:HasItem(spell.items, true)
  count = count or 0

  if have_item then
    -- Have item, display the cast message and setup the cast button
    local texture, _, _, _, _, _, item_link, _, _, _ = GetContainerItemInfo(bag, slot)
    local profile_spell = buffDefModule:GetProfileBuff(spell.buffId)

    if profile_spell.OffHandEnable
            and playerMember.OffHandBuff == nil then
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
                buffTargetModule:FromSelf(playerMember),
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
                buffTargetModule:FromSelf(playerMember),
                false)
      end
    end

    if profile_spell.MainHandEnable
            and playerMember.MainHandBuff == nil then
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
                buffTargetModule:FromSelf(playerMember),
                true)
      else
        -- Text: [Icon] [Consumable Name] x Count (Main hand)
        castButtonTitle = mainhand_message()
        macroCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
        tasklist:Add(
                castButtonTitle,
                nil,
                "(" .. _t("TooltipMainHand") .. ") ",
                buffTargetModule:FromSelf(playerMember),
                false)
      end
    end
    BOM.ScanModifier = buffomatModule.shared.DontUseConsumables
  else
    -- Don't have item but display the intent
    -- Text: [Icon] [Consumable Name] x Count
    if spell.singleText then
      -- spell.single can be nil on addon load
      tasklist:Add(
              spell.singleText .. "x" .. count,
              nil,
              _t("task.type.MissingConsumable"),
              buffTargetModule:FromSelf(playerMember),
              true)
    else
      BOM.SetForceUpdate("WeaponConsumableBuff display text") -- try rescan?
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
  if BOM.IsTBC and self_class == "SHAMAN" then
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

  local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId)

  -- OFFHAND FIRST
  -- Because offhand sets a temporaryDownrank flag in nextCastSpell and it somehow doesn't reset when offhand is queued second
  if profileBuff.OffHandEnable
          and playerUnit.OffHandBuff == nil then
    if blockOffhandEnchant then
      -- Text: [Spell Name] (Off-hand) Blocked waiting
      tasklist:Add(
              buffDef.singleLink,
              buffDef.singleText,
              _t("TooltipOffHand") .. ": " .. _t("ShamanEnchantBlocked"),
              buffTargetModule:FromSelf(playerUnit),
              true)
    else
      -- Text: [Spell Name] (Off-hand)
      -- or:   [Spell Name] (Off-hand) Downranked
      tasklist:Add(buffDef.singleLink, buffDef.singleText, _t("TooltipOffHand"), buffTargetModule:FromSelf(playerUnit), false)
      self:QueueSpell(buffDef.singleMana, buffDef.singleId, buffDef.singleLink,
              playerUnit, buffDef, downrank)
    end
  end

  -- MAINHAND AFTER OFFHAND
  -- Because offhand sets a temporaryDownrank flag in nextCastSpell and it somehow doesn't reset when offhand is queued second
  if profileBuff.MainHandEnable
          and playerUnit.MainHandBuff == nil then
    -- Special case is ruled by the option `ShamanFlametongueRanked`
    -- Flametongue enchant for spellhancement shamans only!
    local isDownrank = buffDef.buffId == 16342 and buffomatModule.shared.ShamanFlametongueRanked
    local taskText = ""
    if isDownrank then
      taskText = _t("TooltipMainHand") .. ": " .. _t("shaman.flametongueDownranked")
    else
      taskText = _t("TooltipMainHand")
    end

    -- Text: [Spell Name] (Main hand)
    tasklist:Add(buffDef.singleLink, buffDef.singleText, taskText, buffTargetModule:FromSelf(playerUnit), false)
    self:QueueSpell(buffDef.singleMana, buffDef.singleId, buffDef.singleLink, playerUnit, buffDef, isDownrank)
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
    local hasArgentumDawn = tContains(BOM.ArgentumDawn.itemIds, itemTrinket1) or
            tContains(BOM.ArgentumDawn.itemIds, itemTrinket2)
    if hasArgentumDawn and not tContains(BOM.ArgentumDawn.zoneId, instanceID) then
      -- Text: Unequip [Argent Dawn Commission]
      tasklist:Comment(_t("TASK_UNEQUIP") .. " " .. _t("AD_REPUTATION_REMINDER"))
    end
  end

  if buffomatModule.shared.Carrot then
    local hasCarrot = tContains(BOM.Carrot.itemIds, itemTrinket1) or
            tContains(BOM.Carrot.itemIds, itemTrinket2)
    if hasCarrot and not tContains(BOM.Carrot.zoneId, instanceID) then
      -- Text: Unequip [Carrot on a Stick]
      tasklist:Comment(_t("TASK_UNEQUIP") .. " " .. _t("RIDING_SPEED_REMINDER"))
    end
  end
end

---Check player weapons and report if they have the "Warn about missing enchants" option enabled
---@param playerUnit BomUnit
function taskScanModule:CheckMissingWeaponEnchantments(playerUnit)
  -- enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges
  , offHandEnchantId = GetWeaponEnchantInfo()

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
      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        extra_msg = _t("task.hint.HoldShiftConsumable")
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
              "(" .. _t("task.UseOrOpen") .. ") " .. extra_msg,
              buffTargetModule:FromSelf(playerMember),
              true)

      if buffomatModule.shared.DontUseConsumables and not IsModifierKeyDown() then
        macro_command = nil
        cast_button_title = nil
      end
      BOM.ScanModifier = buffomatModule.shared.DontUseConsumables
    end
  end

  return cast_button_title, macro_command
end

---@param spell BomBuffDefinition
---@param playerMember BomUnit
---@param party table<number, BomUnit>
---@param inRange boolean TODO: Remove passing this parameter
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {in_range, cast_button_title, macro_command}
function taskScanModule:ScanOneSpell(spell, playerMember, party, inRange,
                                     castButtonTitle, macroCommand)
  if #spell.UnitsNeedBuff > 0
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
    if #spell.UnitsNeedBuff > 0 then
      if spell.isConsumable then
        castButtonTitle, macroCommand = self:AddConsumableWeaponBuff(
                spell, playerMember, castButtonTitle, macroCommand)
      else
        castButtonTitle, macroCommand = self:AddWeaponEnchant(spell, playerMember)
      end
    end

  elseif spell.isConsumable then
    if #spell.UnitsNeedBuff > 0 then
      castButtonTitle, macroCommand = self:AddConsumableSelfbuff(
              spell, playerMember, castButtonTitle, macroCommand, spell.consumableTarget)
      inRange = true
    end

  elseif spell.isInfo then
    if #spell.UnitsNeedBuff then
      for _m, unitNeedsBuff in ipairs(spell.UnitsNeedBuff) do
        -- Text: [Player Link] [Spell Link]
        tasklist:Add(
                spell.singleLink or spell.singleText,
                spell.singleText,
                "Info",
                buffTargetModule:FromUnit(unitNeedsBuff),
                true)
      end
    end

  elseif spell.type == "tracking" then
    -- TODO: Move this to its own periodic timer
    if #spell.UnitsNeedBuff > 0 then
      if BOM.PlayerCasting == nil then
        self:SetTracking(spell, true)
      else
        -- Text: "Player" "Spell Name"
        tasklist:AddWithPrefix(
                _t("TASK_ACTIVATE"),
                spell.singleLink or spell.singleText,
                spell.singleText,
                _t("task.type.Tracking"),
                buffTargetModule:FromSelf(playerMember),
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
    elseif #spell.UnitsNeedBuff > 0 then
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
---@param inRange boolean TODO: Remove passing this parameter
---@param castButtonTitle string
---@param macroCommand string
---@return boolean, string, string {inRange, castButtonTitle, macroCommand}
function taskScanModule:ScanSelectedSpells(playerMember, party, inRange, castButtonTitle, macroCommand)
  for _, spell in ipairs(BOM.SelectedSpells) do
    local profile_spell = buffDefModule:GetProfileBuff(spell.buffId)

    if spell.isInfo and profile_spell.Whisper then
      self:WhisperExpired(spell)
    end

    -- if spell is enabled and we're in the correct shapeshift form
    if buffDefModule:IsSpellEnabled(spell.buffId)
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
  local playerMember = unitCacheModule:GetUnit("player")

  if self:IsMountedAndCrusaderAuraRequired() then
    local spell = BOM.CrusaderAuraSpell
    tasklist:AddWithPrefix(
            _t("TASK_CAST"),
            spell.singleLink or spell.singleText,
            spell.singleText,
            _t("task.target.SelfOnly"),
            buffTargetModule:FromSelf(playerMember),
            false)

    self:QueueSpell(spell.singleMana, spell.singleId, spell.singleLink,
            playerMember, spell)

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
  self:WipeMacro()
end

function taskScanModule:UpdateScan_Button_BusyChanneling()
  --Print player is busy (casting channeled spell)
  self:CastButton(_t("castButton.BusyChanneling"), false)
  self:WipeMacro()
end

function taskScanModule:UpdateScan_Button_TargetedSpell()
  --Next cast is already defined - update the button text
  self:CastButton(nextCastSpell.spellLink, true)
  self:UpdateMacro(nextCastSpell)

  local cdtest = GetSpellCooldown(nextCastSpell.spellId) or 0

  if cdtest ~= 0 then
    BOM.CheckCoolDown = nextCastSpell.spellId
    BomC_ListTab_Button:Disable()
  else
    BomC_ListTab_Button:Enable()
  end

  BOM.CastFailedSpell = nextCastSpell.spell
  BOM.CastFailedSpellTarget = nextCastSpell.targetUnit
end

function taskScanModule:UpdateScan_Button_Nothing()
  --If don't have any strings to display, and nothing to do -
  --Clear the cast button
  self:CastButton(_t("castButton.NothingToDo"), false)

  for _i, spell in ipairs(BOM.SelectedSpells) do
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
end

function taskScanModule:UpdateScan_Scan()
  local party, playerMember = unitCacheModule:GetPartyMembers()

  -- Check whether BOM is disabled due to some option and a matching condition
  if not self:IsMountedAndCrusaderAuraRequired() then
    -- If mounted and crusader aura enabled, then do not do further checks, allow the crusader aura
    local isBomActive, reasonDisabled = self:IsActive(playerMember)
    if not isBomActive then
      BOM.ForceUpdate = false
      BOM.CheckForError = false
      BOM.AutoClose()
      BOM.Macro:Clear()
      self:FadeBuffomatWindow()
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
  local inRange = false ---@type boolean

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
    self:SomeoneIsDrinking()

    castButtonTitle, macroCommand = self:CheckItemsAndContainers(
            playerMember, castButtonTitle, macroCommand)
  end

  -- Open Buffomat if any cast tasks were added to the task list
  if #tasklist.tasks > 0 or #tasklist.comments > 0 then
    BOM.AutoOpen()
  else
    self:FadeBuffomatWindow()
    BOM.AutoClose()
  end

  tasklist:Display() -- Show all tasks and comments

  BOM.ForceUpdate = false

  if BOM.PlayerCasting == "cast" then
    self:UpdateScan_Button_Busy()
  elseif BOM.PlayerCasting == "channel" then
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
  if BOM.SelectedSpells == nil then
    return
  end

  if BOM.InLoading then
    return
  end

  BOM.MinTimer = GetTime() + 36000 -- 10 hours
  tasklist:Clear()
  BOM.RepeatUpdate = false

  --Choose Profile
  local selectedProfileName = profileModule:ChooseProfile()

  if buffomatModule.currentProfileName ~= selectedProfileName then
    buffomatModule:UseProfile(selectedProfileName)
    spellButtonsTabModule:UpdateSpellsTab("UpdateScan1")
    BOM.SetForceUpdate("ProfileChanged")
  end

  -- All pre-checks passed
  self:UpdateScan_Scan()
end -- end function bomUpdateScan_PreCheck()

---Scan the available spells and group members to find who needs the rebuff/res
---and what would be their priority?
---@param from string Debug value to trace the caller of this function
function taskScanModule:UpdateScan(from)
  --if BOM.ForceUpdateSpellsTab then
  --spellButtonsTabModule:ClearRebuildSpellButtonsTab()
  --end

  buffomatModule:UseProfile(profileModule:ChooseProfile())
  self:UpdateScan_PreCheck(from)
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
  if BOM.SelectedSpells == nil or buffomatModule.currentProfile == nil then
    return
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    if buffomatModule.currentProfile.CancelBuff[spell.buffId].Enable
            and taskScanModule:CancelBuff(spell.singleFamily)
    then
      BOM:Print(string.format(_t("message.CancelBuff"), spell.singleLink or spell.singleText,
              UnitName(BOM.CancelBuffSource) or ""))
    end
  end
end
