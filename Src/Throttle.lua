local BuffomatAddon = BuffomatAddon

---@class ThrottleModule

local throttleModule = LibStub("Buffomat-Throttle") --[[@as ThrottleModule]]
local buffomatModule = LibStub("Buffomat-Buffomat") --[[@as BuffomatModule]]
local eventsModule = LibStub("Buffomat-Events") --[[@as EventsModule]]
local taskScanModule = LibStub("Buffomat-TaskScan") --[[@as TaskScanModule]]
local profileModule = LibStub("Buffomat-Profile") --[[@as ProfileModule]]
local taskListPanelModule = LibStub("Buffomat-TaskListPanel") --[[@as TaskListPanelModule]]

---@class BomThrottleState
---@field lastUpdateTimestamp number
---@field lastModifierKeyState boolean
---@field fpsCheck number
---@field slowCount number
---@field SPELLS_TAB_UPDATE_DELAY number
---bumped from 0.1 which potentially causes Naxxramas lag?
---Checking BOM.SharedState.SlowerHardware will use bom_slowerhardware_update_timer_limit
---@field updateTimerLimit number
---@field slowerHardwareUpdateTimerLimit number
-- This is written to updateTimerLimit if overload is detected in a large raid or slow hardware
---@field BOM_THROTTLE_TIMER_LIMIT number
---@field BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT number
---@field lastSpellsTabUpdate number

---@type BomThrottleState
local throttleState = {
  lastUpdateTimestamp = 0,
  lastModifierKeyState = false,
  fpsCheck = 0,
  slowCount = 0,
  SPELLS_TAB_UPDATE_DELAY = 2.0,
  updateTimerLimit = 0.500,
  slowerHardwareUpdateTimerLimit = 1.500,
  BOM_THROTTLE_TIMER_LIMIT = 1.000,
  BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT = 2.000,
  lastSpellsTabUpdate = 0,
}

function throttleModule:FastUpdateTimer()
  throttleState.lastUpdateTimestamp = 0
end

---This runs every frame, do not do any excessive work here
function throttleModule:UpdateTimer(elapsed)
  local inCombat = InCombatLockdown()

  if inCombat then
    return
  end

  local now = GetTime()

  if BuffomatAddon.inLoadingScreen and BuffomatAddon.loadingScreenTimeOut then
    if BuffomatAddon.loadingScreenTimeOut > now then
      return
    else
      BuffomatAddon.inLoadingScreen = false
      eventsModule:OnCombatStop()
    end
  end

  if now - throttleState.lastSpellsTabUpdate > throttleState.SPELLS_TAB_UPDATE_DELAY then
    -- if spellButtonsTabModule:UpdateSpellsTab_Throttled() then
    -- throttleState.lastSpellsTabUpdate = now
    -- end
    buffomatModule:UseProfile(profileModule:ChooseProfile())
    throttleState.lastSpellsTabUpdate = now
  end

  if BuffomatAddon.nextCooldownDue and BuffomatAddon.nextCooldownDue <= now then
    buffomatModule:RequestTaskRescan("cdDue")
  end

  if BuffomatAddon.checkCooldown then
    local cdtest = GetSpellCooldown(BuffomatAddon.checkCooldown)
    if cdtest == 0 then
      BuffomatAddon.checkCooldown = nil
      buffomatModule:RequestTaskRescan("checkCd")
    end
  end

  if BuffomatAddon.scanModifierKeyDown and throttleState.lastModifierKeyState ~= IsModifierKeyDown() then
    throttleState.lastModifierKeyState = IsModifierKeyDown()
    buffomatModule:RequestTaskRescan("ModifierKeyDown")
  end

  taskListPanelModule:WindowCommand()

  --
  -- Update timers, slow hardware and auto-throttling
  -- This will trigger update on timer, regardless of other conditions
  --
  --throttleState.fpsCheck = throttleState.fpsCheck + 1

  local updateTimerLimit = throttleState.updateTimerLimit
  if BuffomatShared.SlowerHardware then
    updateTimerLimit = throttleState.slowerHardwareUpdateTimerLimit
  end

  local needForceUpdate = next(buffomatModule.taskRescanRequestedBy) ~= nil

  if (needForceUpdate or BuffomatAddon.repeatUpdate)
      and now - (throttleState.lastUpdateTimestamp or 0) > updateTimerLimit
      and not inCombat
  then
    throttleState.lastUpdateTimestamp = now
    throttleState.fpsCheck = debugprofilestop()

    -- Debug: Print the callers as reasons to force update
    -- buffomatModule:PrintCallers("Update: ", buffomatModule.forceUpdateRequestedBy)
    buffomatModule:ClearForceUpdate(nil)
    taskScanModule:ScanTasks("timer")

    -- If updatescan call above took longer than 32 ms, and repeated update, then
    -- bump the slow alarm counter, once it reaches 32 we consider throttling.
    -- 1000 ms / 32 ms = 31.25 fps
    if (debugprofilestop() - throttleState.fpsCheck) > 32 and BuffomatAddon.repeatUpdate then
      throttleState.slowCount = throttleState.slowCount + 1

      if throttleState.slowCount >= 20 and updateTimerLimit < 1 then
        throttleState.updateTimerLimit = throttleState.BOM_THROTTLE_TIMER_LIMIT
        throttleState.slowerHardwareUpdateTimerLimit = throttleState.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT
        BuffomatAddon:Print("Overwhelmed - slowing down the scans!")
      end
    else
      throttleState.slowCount = 0
    end
  end
end