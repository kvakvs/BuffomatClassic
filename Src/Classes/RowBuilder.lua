local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomRowBuilderModule
local rowBuilderModule = BuffomatModule.DeclareModule("RowBuilder") ---@type BomRowBuilderModule

---@class RowBuilder
---@field prevControl BomControl|nil Previous control in the row
---@field rowStartControl BomControl|nil First control in the row, to align next row
---@field categories table<string, boolean> True if category label was created already

local rowBuilderClass = {} ---@type RowBuilder
rowBuilderClass.__index = rowBuilderClass

---Creates a new RowBuilder
---@field prev_control table Stores last created control, for lining up the following one
---@return RowBuilder
function rowBuilderModule:new()
  local fields = {} ---@type RowBuilder
  setmetatable(fields, rowBuilderClass)

  fields.categories = {}
  fields.dx = 0
  fields.dy = 0

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

    control:SetPoint("TOPLEFT", self.rowStartControl, "BOTTOMLEFT", 0, -self.dy)
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
---@param spaceAfter number
function rowBuilderClass:ChainToTheRight(anchor, control, spaceAfter)
  if anchor == nil then
    anchor = self.prevControl
  end

  control:SetPoint("TOPLEFT", anchor, "TOPRIGHT", self.dx, 0)

  self.dx = spaceAfter or 0
  self.prevControl = control
end

function rowBuilderClass:SpaceToTheRight(control, dx)
  self.prevControl = control
  self.dx = dx
end
