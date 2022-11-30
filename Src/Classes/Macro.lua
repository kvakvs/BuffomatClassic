--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomMacroModule
local macroModule = BomModuleManager.macroModule

local constModule = BomModuleManager.constModule
local _t = BomModuleManager.languagesModule

---@shape BomMacro
---@field name string Macro name, default Buff'o'mat
---@field icon string Texture path to macro icon
---@field lines string[] Lines of the macro
local macroClass = {}
macroClass.__index = macroClass

---Creates a new Macro
---@param name string
---@param lines string[]|nil
---@return BomMacro
function macroModule:NewMacro(name, lines)
  local fields = --[[---@type BomMacro]] {}
  fields.name  = name
  fields.lines = lines or {}

  setmetatable(fields, macroClass)
  return fields
end

function macroClass:Clear()
  if InCombatLockdown() then
    return
  end

  self:EnsureExists()
  self.lines = {}
  self.icon = constModule.MACRO_ICON_DISABLED
  EditMacro(self.name, nil, self.icon, self:GetText())
end

---@return string
function macroClass:GetText()
  local t = "#showtooltip\n/bom update"
  for i, line in ipairs(self.lines) do
    t = t .. "\n" .. line
  end
  return t
end

function macroClass:UpdateMacro()
  local icon = self.icon or constModule.MACRO_ICON
  EditMacro(constModule.MACRO_NAME, nil, icon, self:GetText())
  BOM.minimapButton:SetTexture("Interface\\ICONS\\" .. icon)
end

function macroClass:EnsureExists()
  if (GetMacroInfo(constModule.MACRO_NAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar

    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      BOM:Print(_t("castButton.NoMacroSlots"))
      return
    end

    CreateMacro(self.name, constModule.MACRO_ICON, "", isChar)
  end
end
