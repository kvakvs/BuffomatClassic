local BOM = BuffomatAddon

---@class BomActionMacroModule

local actionMacroModule = --[[@as BomActionMacroModule]] LibStub("Buffomat-ActionMacro")
local taskModule = --[[@as BomTaskModule]] LibStub("Buffomat-Task")
local constModule = --[[@as ConstModule]] LibStub("Buffomat-Const")

---@class BomTaskActionMacro: BomTaskAction Uses an equipment slot or a bag item
---@field macro string
---@field buttonText string
local actionMacroClass = {}
actionMacroClass.__index = actionMacroClass

---@param macro string
---@param buttonText string
---@return BomTaskActionMacro
function actionMacroModule:New(macro, buttonText)
  local a = --[[@as BomTaskActionMacro]] {}
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

--- Clears the Buffomat macro
---@param command string|nil
function actionMacroModule:WipeMacro(command)
  local macro = BOM.theMacro

  macro:EnsureExists()
  wipe(macro.lines)

  if command then
    table.insert(macro.lines, --[[---@not nil]] command)
  end

  macro.icon = constModule.MACRO_ICON_DISABLED
  macro:UpdateMacro()
end
