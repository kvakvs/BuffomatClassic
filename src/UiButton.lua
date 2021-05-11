---@type BuffomatAddon
local TOCNAME, BOM = ...

BOM.UI = {}

---@param id string Button ID
---@param parent Control parent UI frame for the button
function BOM.UI.CreateButton20(id, parent)
  local b = CreateFrame("Button", id, parent, "UIPanelButtonTemplate")
  b:SetWidth(20);
  b:SetHeight(20);

  return b
end
