local BOM = BuffomatAddon ---@type BomAddon

---@shape BomActionUseModule
local actionUseModule = BomModuleManager.actionUseModule

local taskModule = BomModuleManager.taskModule
local _t = BomModuleManager.languagesModule

---@class BomTaskActionUse: BomTaskAction Uses an equipment slot or a bag item
---@field buffDef BomBuffDefinition|nil
---@field target string
---@field bag number|nil Nil bag means use equipment slot
---@field slot number
---@field extraText string|nil
local actionUseClass = {}
actionUseClass.__index = actionUseClass

---@param buffDef BomBuffDefinition|nil
---@param target string
---@param bag number
---@param slot number
---@return BomTaskActionUse
---@param extraText string|nil
function actionUseModule:New(buffDef, target, bag, slot, extraText)
  local a = --[[---@type BomTaskActionUse]] {}
  setmetatable(a, actionUseClass)
  a.buffDef = buffDef
  a.target = target
  a.bag = bag
  a.slot = slot
  a.extraText = extraText
  return a
end

function actionUseClass:CanCast()
  return taskModule.CAN_CAST_OK
end

---@param m BomMacro
function actionUseClass:UpdateMacro(m)
  if self.bag == nil then
    table.insert(m.lines, "/use " .. self.slot)
  end
  if self.target then
    table.insert(m.lines, string.format("/use [@%s] %d %d", self.target, self.bag, self.slot))
  else
    table.insert(m.lines, string.format("/use %d %d", self.bag, self.slot))
  end
end

function actionUseClass:GetButtonText()
  if self.buffDef == nil then
    return _t("task.UseOrOpen") .. " " .. (self.extraText or "")
  end
  return _t("TASK_USE") .. " " .. (--[[---@not nil]] self.buffDef).singleText
end