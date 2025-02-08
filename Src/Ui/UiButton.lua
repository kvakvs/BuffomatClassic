---@class BomUiButtonModule
local uiButtonModule = BomModuleManager.uiButtonModule ---@type BomUiButtonModule
local texturesModule = BomModuleManager.texturesModule

---@param id string Button ID
---@param parent BomGPIControl parent UI frame for the button
---@param normalTexture string
function uiButtonModule:CreateSmallButton(id, parent, normalTexture)
  local b = CreateFrame("Button", id, parent)
  b:SetWidth(20);
  b:SetHeight(20);
  b:SetNormalTexture(normalTexture)
  b:SetDisabledTexture(texturesModule.ICON_DISABLED)
  --b:SetBackdrop(nil)

  return b
end