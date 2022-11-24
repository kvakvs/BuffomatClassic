---@shape BomTaskModule
local taskModule = BomModuleManager.taskModule ---@type BomTaskModule

local buffomatModule = BomModuleManager.buffomatModule

-- TODO: Range check and power check and spellId can be stored here and postponed till we're ready to cast
---@class BomTask
--- @field target BomUnitBuffTarget|BomGroupBuffTarget|nil Unit name
--- @field distance number Distance to the target or nearest unit in the group target
--- @field prefixText string The message to show before the spell
--- @field actionText string The message to display if inactive: spell name
--- @field actionLink string The message to display if active: spell link with icon
--- @field extraText string The extra message to display after the spell
--- @field priority number Sorting for display purposes
--- @field isInfo boolean Reports something to the user but no target or action. Macro and cast button not updated.
--- @field macro string
--- @field inRange boolean|nil Boolean if range check was done
local taskClass = {}
taskClass.__index = taskClass

taskModule.TaskPriority = {
  Resurrection = 1,
  Default      = 10,
  SelfBuff     = 10,
  GroupBuff    = 100,
}

--Creates a new TaskListItem
---@param actionText string|nil
---@param actionLink string
---@return BomTask
function taskModule:Create(actionLink, actionText)
  local fields = --[[---@type BomTask]] {}
  setmetatable(fields, taskClass)

  fields.actionLink = actionLink or ""
  fields.actionText = actionText or actionLink
  fields.prefixText = ""
  fields.extraText = ""
  fields.target = nil
  fields.distance = 0
  fields.priority = taskModule.TaskPriority.Default
  fields.isInfo = false

  return fields
end

function taskClass:CanCast()
  -- TODO: Move mana check and reagents? check here
  return true
end

---@param target BomUnitBuffTarget|BomGroupBuffTarget
---@return BomTask
function taskClass:Target(target)
  self.distance = target:GetDistance()
  self.target = target
  return self
end

---@param inRange boolean
---@return BomTask
function taskClass:InRange(inRange)
  self.inRange = inRange
  return self
end

---@param prio number
---@return BomTask
function taskClass:Prio(prio)
  self.priority = prio
  return self
end

---@param macro string
---@return BomTask
function taskClass:Macro(macro)
  self.macro = macro
  return self
end

---Set the task to be a notification and not an action. Macro and cast button not updated.
---@return BomTask
function taskClass:IsInfo()
  self.isInfo = true
  return self
end

---@param t string
---@return BomTask
function taskClass:ExtraText(t)
  self.extraText = t
  return self
end

---@param t string
---@return BomTask
function taskClass:PrefixText(t)
  self.prefixText = t
  return self
end

-- TODO move to const module
local bomGray = "777777"
local bomRed = "cc4444"
local bomBleakRed = "bb5555"

function taskClass:Format()
  local targetText
  if self.target then
    targetText = (--[[---@not nil]] self.target):GetText() .. " "
  else
    targetText = ""
  end
  if self.isInfo then
    targetText = ""
  end
  return string.format("%s%s %s %s",
          targetText,
          buffomatModule:Color(bomGray, self.prefixText),
          self.actionLink,
          buffomatModule:Color(bomGray, self.extraText))
end

function taskClass:FormatDisabledRed(reason)
  local targetText
  if self.target then
    targetText = (--[[---@not nil]] self.target):GetText() .. " "
  else
    tate = ""
  end
  if self.isInfo then
    target = ""
  end
  return string.format("%s %s %s",
          buffomatModule:Color(bomRed, reason),
          target,
          buffomatModule:Color(bomBleakRed, self.actionText))
end
