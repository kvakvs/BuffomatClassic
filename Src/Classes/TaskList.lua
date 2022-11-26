--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomTaskListModule
local taskListModule = BomModuleManager.taskListModule ---@type BomTaskListModule

local constModule = BomModuleManager.constModule
local taskModule = BomModuleManager.taskModule
local buffomatModule = BomModuleManager.buffomatModule
local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule

---@shape BomTaskList
---@field tasks BomTask[]
---@field comments string[]
---@field lowPrioComments string[]
local taskListClass = {}
taskListClass.__index = taskListClass

---@return BomTask|nil
function taskListClass:SelectTask()
  for _, t in ipairs(self.tasks) do
    if t:CanCast() then
      return t
    end
  end
  return nil
end

---@return BomTaskList
function taskListModule:New()
  local fields = --[[---@type BomTaskList]] {
    tasks           = {},
    comments        = {},
    lowPrioComments = {},
  }
  setmetatable(fields, taskListClass)
  return fields
end

-- ---Adds a text line to display in the message frame. The line is stored in DisplayCache
-- ---@param actionText string|nil Text to display (target of the action) with icon and color
-- ---@param actionLink string Text to display if inactive (just text)
-- ---@param extraText string Text to display (extra comment)
-- ---@param target BomUnitBuffTarget|BomGroupBuffTarget Distance to the party member, or group (if string)
-- ---@param isInfo boolean Whether the text is info text or a cast
-- ---@param prio number|nil Priority, a constant from taskModule.TaskPriority
-- ---@deprecated
--function taskListClass:Add_0(actionLink, actionText, extraText,
--                             target, isInfo, prio)
--  local newTask = taskModule:Create(
--          "", actionLink, actionText, extraText, target, isInfo, prio)
--  table.insert(self.tasks, newTask)
--end

---@param t BomTask
function taskListClass:Add(t)
  table.insert(self.tasks, t)
  self.firstToCast = t -- always first to cast is most recent; TODO: Respect prio
end

-- ---Adds a text line to display in the message frame. The line is stored in DisplayCache
-- ---@param actionLink string Text to display (target of the action) with icon and color
-- ---@param actionText string|nil Text to display if inactive (just text). Nil to use action_link
-- ---@param prefixText string Text to display before spell (a verb?)
-- ---@param extraText string|nil Text to display (extra comment)
-- ---@param target BomUnitBuffTarget|BomGroupBuffTarget Distance to the party member, or group (if string)
-- ---@param isInfo boolean Whether the text is info text or a cast
-- ---@param prio number|nil Priority, a constant from taskModule.TaskPriority
--function taskListClass:AddWithPrefix_0(prefixText,
--                                       actionLink, actionText, extraText,
--                                       target, isInfo, prio)
--  local newTask = taskModule:Create(
--          prefixText, actionLink, actionText, extraText, target, isInfo, prio)
--  table.insert(self.tasks, newTask)
--end

---Add a comment text which WILL auto open buffomat window when it is displayed
---@param text string
function taskListClass:Comment(text)
  table.insert(self.comments, text)
end

---Add a comment text which WILL NOT auto open buffomat window and will display in grey
---@param text string
function taskListClass:LowPrioComment(text)
  table.insert(self.lowPrioComments, text)
end

---Clear the cached text, and clear the message frame
function taskListClass:Clear()
  BomC_ListTab_MessageFrame:Clear()
  self.firstToCast = nil
  wipe(self.tasks)
  wipe(self.comments)
  wipe(self.lowPrioComments)
end

---@param a BomTask
---@param b BomTask
local function bomOrderTasksByDistance(a, b)
  if not b then
    return false
  end
  if not a then
    return true
  end
  return a.distance < b.distance -- or
  --a.priority < b.priority or
  --a.action_text < b.action_text
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
function taskListClass:Display()
  local taskFrame = BomC_ListTab_MessageFrame
  taskFrame:Clear()

  --table.sort(bom_cast_messages, function(a, b)
  --  return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  --end)

  -- update distances if the players have moved
  for i, task in ipairs(self.tasks) do
    -- Refresh the copy of distance value
    --if task.t == "memberBuffTarget" or task.t == "groupBuffTarget" then
    if not task.target then
      task.distance = 0
    else
      task.distance = (--[[---@not nil]] task.target):GetDistance()
    end
    --end
  end

  table.sort(self.tasks, bomOrderTasksByDistance)

  for i, text in ipairs(self.lowPrioComments) do
    taskFrame:AddMessage(buffomatModule:Color("aaaaaa", text))
  end

  for i, text in ipairs(self.comments) do
    taskFrame:AddMessage(text)
  end

  for i, task in ipairs(self.tasks) do
    if task.distance > 43 * 43 then
      taskFrame:AddMessage(task:FormatDisabledRed(_t("task.error.range")))
    end
  end

  for i, task in ipairs(self.tasks) do
    if task.distance <= 43 * 43 then
      taskFrame:AddMessage(task:Format())
    end
  end
end

function taskListClass:CastButton_Nothing()
  --If don't have any strings to display, and nothing to do -
  --Clear the cast button
  self:CastButton(_t("castButton.NothingToDo"), false)

  for _i, spell in ipairs(allBuffsModule.selectedBuffs) do
    if #spell.skipList > 0 then
      wipe(spell.skipList)
    end
  end
end

---@param task BomTask
---@param buffCtx BomBuffScanContext
function taskListClass:SetupButton(task, buffCtx)
  -- TOO FAR
  if task.inRange == false then
    return self:CastButton_OutOfRange()
  end
  -- CASTING something else
  if BOM.isPlayerCasting == "cast" then
    return self:CastButton_Busy()
  end
  -- CHANNELING something else
  if BOM.isPlayerCasting == "channel" then
    return self:CastButton_BusyChanneling()
  end
  -- No buffing if someone is dead
  if buffCtx.someoneIsDead and buffomatModule.shared.DeathBlock then
    -- Have tasks and someone died and option is set to not buff
    return self:CastButton_SomeoneIsDead()
  end

  -- ============================
  -- OK to cast 1 spell on target
  -- ============================
  if task:CanCast() == false then
    return self:CastButton_CantCast()
  end

  if task.action then
    if (--[[---@not nil]] task.action).target
            and (--[[---@not nil]] task.action).spellId then
      return self:CastButton_TargetedSpell(task)
    end

    return self:CastButton(task.actionText, true)

  end
end

---Set text and enable the cast button (or disable)
---@param t string - text for the cast button
---@param enable boolean - whether to enable the button or not
function taskListClass:CastButton(t, enable)
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

  buffomatModule:FadeBuffomatWindow()
end

function taskListClass:CastButton_Busy()
  --Print player is busy (casting normal spell)
  self:CastButton(_t("castButton.Busy"), false)
  taskListModule:WipeMacro(nil)
end

function taskListClass:CastButton_BusyChanneling()
  --Print player is busy (casting channeled spell)
  self:CastButton(_t("castButton.BusyChanneling"), false)
  taskListModule:WipeMacro(nil)
end

---@param task BomTask
function taskListClass:CastButton_TargetedSpell(task)
  --Next cast is already defined - update the button text
  self:CastButton((--[[---@not nil]] task.action).spellLink or "?", true)
  taskListModule:UpdateMacro(--[[---@not nil]] task.action)

  local cdtest = GetSpellCooldown((--[[---@not nil]] task.action).spellId) or 0

  if cdtest ~= 0 then
    BOM.checkCooldown = (--[[---@not nil]] task.action).spellId
    BomC_ListTab_Button:Disable()
  else
    BomC_ListTab_Button:Enable()
  end

  BOM.castFailedBuff = (--[[---@not nil]] task.action).buffDef
  BOM.castFailedBuffTarget = (--[[---@not nil]] task.action).target
end

function taskListClass:CastButton_SomeoneIsDead()
  self:CastButton(_t("InactiveReason_DeadMember"), false)
end

function taskListClass:CastButton_CantCast()
  -- Range is good but cast is not possible
  --self:CastButton(ERR_OUT_OF_MANA, false)
  self:CastButton(_t("castButton.CantCastMaybeOOM"), false)
end

function taskListClass:CastButton_OutOfRange()
  self:CastButton(ERR_SPELL_OUT_OF_RANGE, false)
  local skipreset = false

  for spellIndex, spell in ipairs(allBuffsModule.selectedBuffs) do
    if #spell.skipList > 0 then
      skipreset = true
      wipe(spell.skipList)
    end
  end

  if skipreset then
    buffomatModule:FastUpdateTimer()
    buffomatModule:RequestTaskRescan("skipReset")
  end
end -- if inrange
--- Clears the Buffomat macro
---@param command string|nil
function taskListModule:WipeMacro(command)
  local macro = BOM.theMacro
  macro:Recreate()
  wipe(macro.lines)

  if command then
    table.insert(macro.lines, --[[---@not nil]] command)
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
---@param action BomTaskAction
function taskListModule:UpdateMacro(action)
  local macro = BOM.theMacro
  macro:Recreate()
  wipe(macro.lines)

  --Downgrade-Check
  local buffDef = allBuffsModule.buffFromSpellIdLookup[--[[---@not nil]] action.spellId]
  local rank = ""

  if buffDef == nil then
    print("Update macro: NIL SPELL for spellid=", action.spellId)
  end

  if buffomatModule.shared.UseRank
          or (action.target and (--[[---@not nil]] action.target).unitId == "target")
          or action.temporaryDownrank then
    local level = UnitLevel((--[[---@not nil]] action.target).unitId)

    if buffDef and level ~= nil and level > 0 then
      local spellChoices

      if buffDef.singleFamily
              and tContains(buffDef.singleFamily, action.spellId) then
        spellChoices = buffDef.singleFamily
      elseif buffDef.groupFamily
              and tContains(--[[---@not nil]] buffDef.groupFamily, action.spellId) then
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
          if id == action.spellId then
            break
          end
        end
        action.spellId = newSpellId or action.spellId
      end
    end -- if spell and level

    rank = GetSpellSubtext(--[[---@not nil]] action.spellId) or ""

    if rank ~= "" then
      rank = "(" .. rank .. ")"
    end
  end

  BOM.castFailedSpellId = action.spellId
  local name = GetSpellInfo(--[[---@not nil]] action.spellId)
  if name == nil then
    BOM:Print("Update macro: Bad spell spellid=" .. action.spellId)
  end

  if tContains(allBuffsModule.cancelForm, action.spellId) then
    table.insert(macro.lines, "/cancelform [nocombat]")
  end
  table.insert(macro.lines, "/bom _checkforerror")
  table.insert(macro.lines, "/cast [@"
          .. (--[[---@not nil]] action.target).unitId
          .. ",nocombat]" .. name .. rank)
  macro.icon = constModule.MACRO_ICON

  macro:UpdateMacro()
end
