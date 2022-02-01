local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

BOM.UI = {}

---@param id string Button ID
---@param parent Control parent UI frame for the button
---@param normalTexture string
function BOM.UI.CreateSmallButton(id, parent, normalTexture)
  local b = CreateFrame("Button", id, parent)
  b:SetWidth(20);
  b:SetHeight(20);
  b:SetNormalTexture(normalTexture)
  b:SetDisabledTexture(BOM.ICON_DISABLED)
  --b:SetBackdrop(nil)

  return b
end
