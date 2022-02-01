local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

BOM.Class = BOM.Class or {}

---@class Macro
---@field name string Macro name, default Buff'o'mat
---@field icon string Texture path to macro icon
---@field lines table<number, string> Lines of the macro

---@type Macro
BOM.Class.Macro = {}
BOM.Class.Macro.__index = BOM.Class.Macro

local CLASS_TAG = "macro"

---Creates a new Macro
---@param name string
---@param lines table<number, string>|nil
---@return Macro
function BOM.Class.Macro:new(name, lines)
  local fields = {
    t     = CLASS_TAG,
    name  = name,
    lines = lines or {},
  }
  setmetatable(fields, BOM.Class.Macro)
  return fields
end

---@param self Macro
function BOM.Class.Macro.Clear(self)
  if InCombatLockdown() then
    return
  end

  self:Recreate()
  self.lines = {}
  self.icon = BOM.MACRO_ICON_DISABLED
  EditMacro(self.name, nil, self.icon, self:GetText())
end

---@param self Macro
---@return string
function BOM.Class.Macro.GetText(self)
  local t = "#showtooltip\n/bom update"
  for i, line in ipairs(self.lines) do
    t = t .. "\n" .. line
  end
  return t
end

---@param self Macro
function BOM.Class.Macro.UpdateMacro(self)
  EditMacro(BOM.MACRO_NAME, nil, self.icon, self:GetText())
  BOM.MinimapButton.SetTexture("Interface\\ICONS\\" .. self.icon)
end

---@param self Macro
function BOM.Class.Macro.Recreate(self)
  if (GetMacroInfo(BOM.MACRO_NAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar

    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      BOM.Print(L.MsgNeedOneMacroSlot)
      return
    end

    CreateMacro(self.name, BOM.MACRO_ICON, "", isChar)
  end
end
