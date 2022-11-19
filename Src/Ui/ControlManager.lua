---@alias BomManagedControlsTable {[string]: BomGPIControl|BomControl}

---@shape BomUiMyButtonModule
---@field managed BomManagedControlsTable Contains all MyButtons with uniqueId
---@field managedWithoutUniqueId BomControl[] Contains all MyButtons without uniqueId
local managedUiModule = BomModuleManager.myButtonModule ---@type BomUiMyButtonModule
managedUiModule.managed = --[[---@type BomManagedControlsTable]] {}
managedUiModule.managedWithoutUniqueId = {}

local controlModule = BomModuleManager.controlModule

---Creates small clickable button in the spell tab
---@param parent table - UI parent frame
---@param sel string - texture for checked / selected
---@param unsel string|nil - texture for unchecked / unselected
---@param dis string|nil - texture for disabled
---@param selCoord number[]|nil - texcoord for selected
---@param unselCoord number[]|nil - texcoord for unselected
---@param disCoord number[]|nil - texcoord for disabled
---@param uniqueId string|nil - set to nil to not add button to bom_managed_mybuttons, or pass unique id
---@return BomGPIControl
function managedUiModule:CreateManagedButton(parent, sel, unsel, dis, selCoord, unselCoord, disCoord, uniqueId)
  local newButtonFrame = CreateFrame("frame", nil, parent, "BomC_MyButton")
  controlModule.MyButton_OnLoad(newButtonFrame, false)
  newButtonFrame:SetTextures(sel, unsel, dis, selCoord, unselCoord, disCoord)

  self:ManageControl(uniqueId, newButtonFrame)
  return newButtonFrame
end

---@param uniqueId string|nil Pass a nil to not add button to bom_managed_mybuttons, or provide an unique id
---@param control BomControl
function managedUiModule:ManageControl(uniqueId, control)
  if uniqueId ~= nil then
    self.managed[--[[---@not nil]]uniqueId] = control
  else
    table.insert(self.managedWithoutUniqueId, control)
  end
end

---@return BomGPIControl
---@param uniqueId string|nil Uniqueid for ManageControl call or nil to keep unmanaged
function managedUiModule:CreateMyButtonSecure(parent, sel, unsel, dis, selCoord, unselCoord, disCoord, uniqueId)
  local newButton = CreateFrame("Button", nil, parent, "BomC_MyButtonSecure")
  controlModule.MyButton_OnLoad(newButton, true)
  newButton:SetTextures(sel, unsel, dis, selCoord, unselCoord, disCoord)
  self:ManageControl(uniqueId, newButton)
  return newButton
end

function managedUiModule:UpdateAll()
  for uniq, control in pairs(self.managed) do
    if control.SetState then
      control:SetState(nil)
    end
  end
  for i, control in ipairs(self.managedWithoutUniqueId) do
    if control.SetState then
      control:SetState(nil)
    end
  end
end

-- Hides all icons and clickable buttons in the spells tab
function managedUiModule:HideAllManagedButtons()
  for uniq, control in pairs(self.managed) do
    control:Hide()
  end
  for i, control in ipairs(self.managedWithoutUniqueId) do
    control:Hide()
  end
end
