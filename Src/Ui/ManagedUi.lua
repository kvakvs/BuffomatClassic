--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomManagedUiModule
---@field ICON_OFF string
---@field ICON_ON string

local managedUiModule = BomModuleManager.managedUiModule ---@type BomManagedUiModule

managedUiModule.ICON_ON = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0:0:0:0:64:64:4:60:4:60|t"
managedUiModule.ICON_OFF = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:0:0:0:0:64:64:4:60:4:60|t"

---Collection of UI elements which can be hidden together/shown in parts
---@class BomManagedUi
---@field uiElements table<string, BomGPIControl>
---@field parent BomGPIControl Use this parent to create all controls
local managedUiClass = {}
managedUiClass.__index = managedUiClass

---@return BomManagedUi
function managedUiModule:new(parent)
  local fields = --[[---@type BomManagedUi]] {
    uiElements = {},
  }
  setmetatable(fields, managedUiClass)
  return fields
end

---@param sel string Texture for selected
---@param unsel string|nil Texture for unselected
---@param selCoord table Texcoords for selected icon
---@param unselCoord table|nil Texcoords for unselected icon
function managedUiClass:NewButton(sel, unsel, selCoord, unselCoord)
  local newButton = CreateFrame("Button", nil, parent, "BomC_MyButtonSecure")
  managedUiModule:SetupButton(newButton, true)
  newButton:SetTextures(sel, unsel, nil, selCoord, unselCoord, nil)
  table.insert(self.uiElements, newButton)
  return newButton
end

---@param self WowControl
function managedUiModule.ButtonOnEnter(self)
  if self.bomToolTipLink or self.bomToolTipText then
    GameTooltip_SetDefaultAnchor(BomC_Tooltip, UIParent)
    BomC_Tooltip:SetOwner(BomC_MainWindow, "ANCHOR_PRESERVE")
    BomC_Tooltip:ClearLines()

    if self.bomToolTipLink then
      BomC_Tooltip:SetHyperlink(self.bomToolTipLink)
    else
      local add = ""
      if self.bomReadVariable then
        -- add a checkbox to the tooltip
        add = " " .. (self.bomReadVariable()
                and managedUiModule.ICON_ON
                or managedUiModule.ICON_OFF)
      end

      BomC_Tooltip:AddLine(self.bomToolTipText .. add)
    end

    BomC_Tooltip:Show()
  end
end

---@param self WowControl
function managedUiModule.ButtonOnLeave(self)

end

---@param button BomGPIControl
function managedUiModule:SetupButton(button, isSecure)
  button:SetScript("OnEnter", managedUiModule.ButtonOnEnter)
  button:SetScript("OnLeave", managedUiModule.ButtonOnLeave)
end
