local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomRowBuilderModule
local rowBuilderModule = BomModuleManager.rowBuilderModule ---@type BomRowBuilderModule

---@class BomRowBuilder
---@field prevControl BomControl|nil Previous control in the row
---@field rowStartControl BomControl|nil First control in the row, to align next row
---@field categories table<string, boolean> True if category label was created already
local rowBuilderClass = {}
rowBuilderClass.__index = rowBuilderClass

---Creates a new RowBuilder
---@field prev_control table Stores last created control, for lining up the following one
---@return BomRowBuilder
function rowBuilderModule:new()
  local fields = --[[---@type BomRowBuilder]] {
    categories = {},
    dx         = 0,
    dy         = 0,
  }
  setmetatable(fields, rowBuilderClass)

  return fields
end

---@param control BomControl
---@param betweenLinesOffset number|nil If defined, will step down extra before new line except the first line
---@param afterOffset number|nil
function rowBuilderClass:PositionAtNewRow(control, betweenLinesOffset, afterOffset)
  if self.rowStartControl ~= nil then
    if betweenLinesOffset then
      self.dy = self.dy + betweenLinesOffset
    end

    control:SetPoint("TOPLEFT", --[[---@not nil]] self.rowStartControl, "BOTTOMLEFT", 0, -self.dy)
  else
    control:SetPoint("TOPLEFT", 0, -self.dy)
  end

  self.dy = 0
  self.dx = afterOffset or 0
  self.prevControl = control
  self.rowStartControl = control
end

---@param anchor BomControl|nil
---@param control BomControl
---@param spaceAfter number|nil
function rowBuilderClass:ChainToTheRight(anchor, control, spaceAfter)
  if anchor == nil then
    anchor = self.prevControl
  end

  control:SetPoint("TOPLEFT", --[[---@not nil]] anchor, "TOPRIGHT", self.dx, 0)

  self.dx = spaceAfter or 0
  self.prevControl = control
end

function rowBuilderClass:SpaceToTheRight(control, dx)
  self.prevControl = control
  self.dx = dx
end
