local BOM = BuffomatAddon

---@class BomActionMacroModule
local actionMacroModule = BomModuleManager.actionMacroModule

local taskModule = BomModuleManager.taskModule
local constModule = BomModuleManager.constModule

---@class BomTaskActionMacro: BomTaskAction Uses an equipment slot or a bag item
---@field macro string
---@field buttonText string
local actionMacroClass = {}
actionMacroClass.__index = actionMacroClass

---@param macro string
---@param buttonText string
---@return BomTaskActionMacro
function actionMacroModule:New(macro, buttonText)
  local a = --[[---@type BomTaskActionMacro]] {}
  setmetatable(a, actionMacroClass)
  a.macro = macro
  a.buttonText = buttonText
  return a
end

function actionMacroClass:CanCast()
  return taskModule.CAN_CAST_OK
end

---@param task BomTask
function actionMacroClass:GetButtonText(task)
  return self.buttonText .. " " .. task.extraText
end

---@param m BomMacro
function actionMacroClass:UpdateMacro(m)
  table.insert(m.lines, self.macro)

  m.icon = constModule.MACRO_ICON
  m:UpdateMacro()
end