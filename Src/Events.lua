--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomEventsModule
local eventsModule = BomModuleManager.eventsModule

local taskListModule = BomModuleManager.taskListModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local partyModule = BomModuleManager.partyModule
local profileModule = BomModuleManager.profileModule
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule
local spellSetupModule = BomModuleManager.spellSetupModule
local taskScanModule = BomModuleManager.taskScanModule
local envModule = KvModuleManager.envModule

--"UNIT_POWER_UPDATE","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","PLAYER_STARTED_MOVING","PLAYER_STOPPED_MOVING"
eventsModule.EVT_COMBAT_STOP = { "PLAYER_REGEN_ENABLED" }
eventsModule.EVT_COMBAT_START = { "PLAYER_REGEN_DISABLED" }
eventsModule.EVT_LOADING_SCREEN_START = { "LOADING_SCREEN_ENABLED", "PLAYER_LEAVING_WORLD" }
eventsModule.EVT_LOADING_SCREEN_END = { "PLAYER_ENTERING_WORLD", "LOADING_SCREEN_DISABLED" }

eventsModule.GENERIC_UPDATE_EVENTS = {
  "UPDATE_SHAPESHIFT_FORM", "UNIT_AURA", "READY_CHECK",
  "PLAYER_ALIVE", "PLAYER_UNGHOST", "INCOMING_RESURRECT_CHANGED",
  "UNIT_INVENTORY_CHANGED" }

eventsModule.EVT_BAG_CHANGED = { "BAG_UPDATE_DELAYED", "TRADE_CLOSED" }

eventsModule.EVT_PARTY_CHANGED = { "GROUP_JOINED", "GROUP_ROSTER_UPDATE",
                                   "RAID_ROSTER_UPDATE", "GROUP_LEFT" }

eventsModule.EVT_SPELLBOOK_CHANGED = { "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB" }

--- Error messages which will make player stand if sitting.
eventsModule.ERR_NOT_STANDING = {
  ERR_CANTATTACK_NOTSTANDING, SPELL_FAILED_NOT_STANDING,
  ERR_LOOT_NOTSTANDING, ERR_TAXINOTSTANDING }

--- Error messages which will make player dismount if mounted.
eventsModule.ERR_IS_MOUNTED = {
  ERR_NOT_WHILE_MOUNTED, ERR_ATTACK_MOUNTED,
  ERR_TAXIPLAYERALREADYMOUNTED, SPELL_FAILED_NOT_MOUNTED }

--- Error messages which will make player cancel shapeshift.
eventsModule.ERR_IS_SHAPESHIFT = {
  ERR_EMBLEMERROR_NOTABARDGEOSET, ERR_CANT_INTERACT_SHAPESHIFTED,
  ERR_MOUNT_SHAPESHIFTED, ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
  ERR_NOT_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,
  SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
  SPELL_FAILED_NOT_SHAPESHIFT, SPELL_NOT_SHAPESHIFTED,
  SPELL_NOT_SHAPESHIFTED_NOSPACE }

---Event_TAXIMAP_OPENED
---Will dismount player if mounted when opening taxi tab. Will stand and cancel
---shapeshift to be able to talk to the taxi NPC.
local function Event_TAXIMAP_OPENED()
  if IsMounted() then
    Dismount()
  else
    DoEmote("STAND")
    BOM.CancelShapeShift()
  end
end

local function Event_UNIT_POWER_UPDATE(unitTarget, powerType)
  --UNIT_POWER_UPDATE: "unitTarget", "powerType"
  if powerType == "MANA" and UnitIsUnit(unitTarget, "player") then
    local maxMana = partyModule.playerManaLimit or 0
    local actualMana = UnitPower("player", 0) or 0

    if maxMana <= actualMana then
      buffomatModule:RequestTaskRescan("powerUpdate")
    end
  end
end

local function Event_PLAYER_STARTED_MOVING()
  BOM.isPlayerMoving = true
end

local function Event_PLAYER_STOPPED_MOVING()
  BOM.isPlayerMoving = false
end

---On combat start will close the UI window and disable the UI. Will cancel the cancelable buffs.
local function Event_CombatStart()
  buffomatModule:RequestTaskRescan("combatStart")
  BOM.declineHasResurrection = true
  buffomatModule:AutoClose()
  if not InCombatLockdown() then
    BomC_ListTab_Button:Disable()
  end

  BOM.DoCancelBuffs()
end

local function Event_CombatStop()
  taskScanModule:ClearSkip()
  buffomatModule:RequestTaskRescan("combatStop")
  BOM.declineHasResurrection = true
  BOM.AllowAutOpen()
end

function eventsModule:OnCombatStop()
  return Event_CombatStop()
end

local function Event_LoadingStart()
  BOM.inLoadingScreen = true
  BOM.loadingScreenTimeOut = nil
  Event_CombatStart()
  --print("loading start")
end

local oneTimeLoadItemsAndSpells = false

local function Event_LoadingStop()
  if not oneTimeLoadItemsAndSpells then
    oneTimeLoadItemsAndSpells = true
    allBuffsModule:LoadItemsAndSpells()
  end

  BOM.loadingScreenTimeOut = GetTime() + constModule.LOADING_SCREEN_TIMEOUT
  buffomatModule:RequestTaskRescan("loadingStop")
end

---Event_PLAYER_TARGET_CHANGED
---Handle player target change, spells possibly might have changed too.
local function Event_PLAYER_TARGET_CHANGED()
  if not InCombatLockdown() then
    if UnitInParty("target") or UnitInRaid("target") or UnitIsUnit("target", "player") then
      BOM.lastTarget = UnitFullName("target")
      spellButtonsTabModule:UpdateSpellsTab("PL_TAR_CHANGED1")

    elseif BOM.lastTarget then
      BOM.lastTarget = nil
      spellButtonsTabModule:UpdateSpellsTab("PL_TAR_CHANGED2")
    end
  else
    BOM.lastTarget = nil
  end

  if not buffomatModule.shared.BuffTarget then
    return
  end

  local newName
  if UnitExists("target")
          and UnitCanCooperate("player", "target")
          and UnitIsPlayer("target")
          and not UnitPlayerOrPetInParty("target")
          and not UnitPlayerOrPetInRaid("target")
  then
    newName = UnitName("target")
  end

  if newName ~= BOM.SaveTargetName then
    BOM.SaveTargetName = newName
    buffomatModule:RequestTaskRescan("targetChanged")
    taskScanModule:ScanTasks("PlayerTargetChanged")
  end
end

local partyCheckMask = COMBATLOG_OBJECT_AFFILIATION_RAID
        + COMBATLOG_OBJECT_AFFILIATION_PARTY
        + COMBATLOG_OBJECT_AFFILIATION_MINE
--  partyModule.buffs cleanup in scan bom_get_party_members

local function Event_COMBAT_LOG_EVENT_UNFILTERED()
  ---@type number, any, boolean, string, string, any, any, string, string, any, any, number, string, number, number, number
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags
  , destGUID, unitName, destFlags, destRaidFlags, spellId, spellName, spellSchool
  , auraType, amount = CombatLogGetCurrentEventInfo()

  if bit.band(destFlags, partyCheckMask) > 0 and unitName ~= nil and unitName ~= "" then
    --print(event,spellName,bit.band(destFlags,partyCheckMask)>0,bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_MINE)>0)
    if event == "UNIT_DIED" then
      --partyModule.buffs[destName]=nil -- problem with hunters and fake-deaths!
      --additional check in bom_get_party_members
      --print("dead",destName)
      buffomatModule:RequestTaskRescan("unitDied")

    elseif allBuffsModule.selectedBuffsSpellIds
            and allBuffsModule.selectedBuffsSpellIds[spellId] ~= nil then
      -- a known buff
      --if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
      if event == "SPELL_CAST_SUCCESS" then
        -- nothing

      elseif event == "SPELL_AURA_REFRESH" then
        partyModule:OnBuffsChangedEvent(unitName, spellId, "refreshed")

      elseif event == "SPELL_AURA_APPLIED" then
        partyModule:OnBuffsChangedEvent(unitName, spellId, "applied")

      elseif event == "SPELL_AURA_REMOVED" then
        partyModule:OnBuffsChangedEvent(unitName, spellId, "removed")
      end
      --end
    end
  end
end

---Event_UI_ERROR_MESSAGE
---Will stand if sitting, will dismount if mounted, will cancel shapeshift, if
---shapeshifted while trying to cast a spell and that produces an error message.
---@param errorType table
---@param message table
local function Event_UI_ERROR_MESSAGE(errorType, message)
  if tContains(eventsModule.ERR_NOT_STANDING, message) then
    if buffomatModule.shared.AutoStand then
      UIErrorsFrame:Clear()
      DoEmote("STAND")
    end

  elseif tContains(eventsModule.ERR_IS_MOUNTED, message) then
    local flying = false -- prevent dismount in flight, OUCH!
    if envModule.haveTBC then
      flying = IsFlying() and not buffomatModule.shared.AutoDismountFlying
    end
    if not flying then
      if buffomatModule.shared.AutoDismount then
        UIErrorsFrame:Clear()
        Dismount()
      end
    end

  elseif buffomatModule.shared.AutoDisTravel
          and tContains(eventsModule.ERR_IS_SHAPESHIFT, message)
          and BOM.CancelShapeShift() then
    UIErrorsFrame:Clear()

  elseif not InCombatLockdown() then
    if BOM.checkForError then
      if message == SPELL_FAILED_LOWLEVEL then
        buffomatModule:DownGrade()
      else
        BOM.AddMemberToSkipList()
      end
    end
  end

  BOM.checkForError = false
end

-----PLAYER_LEVEL_UP Event
--- Should also fire spellbook change event and we handle there
--local function Event_PLAYER_LEVEL_UP(level)
--  -- TODO: Rebuild the UI buttons for new spells which appeared due to level up
--end

eventsModule.isPlayerInParty = IsInRaid() or IsInGroup()

local function Event_PartyChanged()
  partyModule:InvalidatePartyCache()
  partyModule.theParty = nil -- Reset saved party

  buffomatModule:RequestTaskRescan("partyChanged")

  -- if in_party changed from true to false, clear the watch groups
  local inParty = IsInRaid() or IsInGroup()
  if eventsModule.isPlayerInParty ~= inParty then
    if not inParty then
      taskScanModule:MaybeResetWatchGroups()
    end
    eventsModule.isPlayerInParty = inParty
  end
end

local function Event_TALENT_GROUP_CHANGED(newGroup, oldGroup)
  buffomatModule:UseProfile(profileModule:ChooseProfile())
end

local function Event_UNIT_SPELLCAST_errors(unit)
  if UnitIsUnit(unit, "player") then
    BOM.checkForError = false
    buffomatModule:RequestTaskRescan("spellcastError")
  end
end

function eventsModule:SafeWipeMacro()
  if not InCombatLockdown() then
    -- To prevent same macro being recast when player quickly mashes the shortcut key
    taskListModule:WipeMacro(nil)
  end
end

local function Event_UNIT_SPELLCAST_START(eventType, unit)
  if UnitIsUnit(unit, "player") then
    buffomatModule:SetPlayerCasting("cast")
    eventsModule:SafeWipeMacro() -- not sure if this has any effect
    buffomatModule:RequestTaskRescan("castStart")
  end
end

local function Event_UNIT_SPELLCAST_STOP(eventType, unit)
  if UnitIsUnit(unit, "player") then
    buffomatModule:SetPlayerCasting(nil)
    buffomatModule:RequestTaskRescan("castStop")
    BOM.checkForError = false
  end
end

local function Event_UNIT_SPELLCHANNEL_START(eventType, unit)
  if UnitIsUnit(unit, "player") then
    buffomatModule:SetPlayerCasting("channel")
    eventsModule:SafeWipeMacro() -- not sure if this has any effect
    buffomatModule:RequestTaskRescan("channelStart")
  end
end

local function Event_UNIT_SPELLCHANNEL_STOP(eventType, unit)
  if UnitIsUnit(unit, "player") then
    buffomatModule:SetPlayerCasting(nil)
    buffomatModule:RequestTaskRescan("channelStop")
    BOM.checkForError = false
  end
end

function eventsModule.Event_SpellsChanged()
  spellSetupModule:SetupAvailableSpells()
  buffomatModule:RequestTaskRescan("spellsChanged")
  spellButtonsTabModule:UpdateSpellsTab("spellsChanged")
end

local function Event_Bag()
  buffomatModule:RequestTaskRescan("bagUpdate")
  BOM.wipeCachedItems = true

  if BOM.cachedPlayerBag then
    wipe(BOM.cachedPlayerBag)
  end
end

function eventsModule:InitEvents()
  -- Should also fire spellbook change event and we handle there
  --BuffomatAddon:RegisterEvent("PLAYER_LEVEL_UP", Event_PLAYER_LEVEL_UP)

  -- Events which might change active state of Buffomat
  BuffomatAddon:RegisterEvent("ZONE_CHANGED", function()
    buffomatModule:RequestTaskRescan("zoneChanged")
  end)
  BuffomatAddon:RegisterEvent("PLAYER_UPDATE_RESTING", function()
    buffomatModule:RequestTaskRescan("restingChanged")
  end)

  BuffomatAddon:RegisterEvent("TAXIMAP_OPENED", Event_TAXIMAP_OPENED)
  --BuffomatAddon:RegisterEvent("ADDON_LOADED", Event_ADDON_LOADED)
  BuffomatAddon:RegisterEvent("UNIT_POWER_UPDATE", Event_UNIT_POWER_UPDATE)
  BuffomatAddon:RegisterEvent("PLAYER_STARTED_MOVING", Event_PLAYER_STARTED_MOVING)
  BuffomatAddon:RegisterEvent("PLAYER_STOPPED_MOVING", Event_PLAYER_STOPPED_MOVING)
  BuffomatAddon:RegisterEvent("PLAYER_TARGET_CHANGED", Event_PLAYER_TARGET_CHANGED)
  BuffomatAddon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Event_COMBAT_LOG_EVENT_UNFILTERED)
  BuffomatAddon:RegisterEvent("UI_ERROR_MESSAGE", Event_UI_ERROR_MESSAGE)

  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_START", Event_UNIT_SPELLCAST_START)
  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_STOP", Event_UNIT_SPELLCAST_STOP)
  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Event_UNIT_SPELLCHANNEL_START)
  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Event_UNIT_SPELLCHANNEL_STOP)

  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Event_UNIT_SPELLCAST_errors)
  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", Event_UNIT_SPELLCAST_errors)
  BuffomatAddon:RegisterEvent("UNIT_SPELLCAST_FAILED", Event_UNIT_SPELLCAST_errors)

  -- Dualspec talent switch
  if envModule.haveWotLK then
    BuffomatAddon:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Event_TALENT_GROUP_CHANGED)
  end

  -- TODO for TBC: PLAYER_REGEN_DISABLED / ENABLED is sent before/after the combat and protected frames lock up

  for i, event in ipairs(eventsModule.EVT_COMBAT_START) do
    BuffomatAddon:RegisterEvent(event, Event_CombatStart)
  end
  for i, event in ipairs(eventsModule.EVT_COMBAT_STOP) do
    BuffomatAddon:RegisterEvent(event, Event_CombatStop)
  end
  for i, event in ipairs(eventsModule.EVT_LOADING_SCREEN_START) do
    BuffomatAddon:RegisterEvent(event, Event_LoadingStart)
  end
  for i, event in ipairs(eventsModule.EVT_LOADING_SCREEN_END) do
    BuffomatAddon:RegisterEvent(event, Event_LoadingStop)
  end

  for i, event in ipairs(eventsModule.EVT_SPELLBOOK_CHANGED) do
    BuffomatAddon:RegisterEvent(event, eventsModule.Event_SpellsChanged)
  end
  for i, event in ipairs(eventsModule.EVT_PARTY_CHANGED) do
    BuffomatAddon:RegisterEvent(event, Event_PartyChanged)
  end
  for i, event in ipairs(eventsModule.GENERIC_UPDATE_EVENTS) do
    local e = event .. ""
    BuffomatAddon:RegisterEvent(event, function()
      buffomatModule:RequestTaskRescan(e)
    end)
  end
  for i, event in ipairs(eventsModule.EVT_BAG_CHANGED) do
    BuffomatAddon:RegisterEvent(event, Event_Bag)
  end
end
