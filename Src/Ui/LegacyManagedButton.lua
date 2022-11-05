local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@alias BomManagedControlsTable {[string] = BomLegacyControl|BomControl}

---@shape BomUiMyButtonModule
---@field managed BomManagedControlsTable Contains all MyButtons with uniqueId
---@field managedWithoutUniqueId BomControl[] Contains all MyButtons without uniqueId
local managedUiModule = {
  managed                = {},
  managedWithoutUniqueId = {},
}
BomModuleManager.myButtonModule = managedUiModule

local ONIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0:0:0:0:64:64:4:60:4:60|t"
local OFFIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:0:0:0:0:64:64:4:60:4:60|t"

function BOM.MyButton_Update(self)
  if self._privat_disabled and self._IconDisabled then
    self._icon:SetTexture(self._IconDisabled, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconDisabledCoord))
    self._text:SetText("")

  elseif self._privat_state and self._IconSelected then
    self._icon:SetTexture(self._IconSelected, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconSelectedCoord))
    if self._privat_Text then
      self._text:SetText(self._privat_Text)
    end

  elseif self._IconUnSelected then
    self._icon:SetTexture(self._IconUnSelected, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconUnSelectedCoord))
    self._text:SetText("")
  end
end

---@param self BomGPIControl
function BOM.MyButton_SetOnClick(self, func)
  self._privat_OnClick = func
end

function BOM.MyButton_OnDisable(self)
  self._privat_disabled = true
  BOM.MyButton_Update(self)
end

function BOM.MyButton_OnEnable(self)
  self._privat_disabled = false
  BOM.MyButton_Update(self)
end

---@param self BomGPIControl
function BOM.MyButton_OnEnter(self)
  if self._privat_ToolTipLink or self._privat_ToolTipText then
    GameTooltip_SetDefaultAnchor(BomC_Tooltip, UIParent)
    BomC_Tooltip:SetOwner(BomC_MainWindow, "ANCHOR_PRESERVE")
    BomC_Tooltip:ClearLines()
    if self._privat_ToolTipLink then
      BomC_Tooltip:SetHyperlink(self._privat_ToolTipLink)
    else
      local add = ""
      if (self._privat_DB and self._privat_Var) then
        add = " " .. (self._privat_state and ONIcon or OFFIcon)
      end
      BomC_Tooltip:AddLine(self._privat_ToolTipText .. add)

    end
    BomC_Tooltip:Show()
  end
  if ((self._privat_DB and self._privat_Var) or self._privat_isSecure) and not self._privat_disabled then
    self._iconHighlight:SetTexture(self._icon:GetTexture())
    self._iconHighlight:SetTexCoord(self._icon:GetTexCoord())
    if (self._iconHighlight:SetDesaturated(true)) then
      self._iconHighlight:SetVertexColor(1, 0.75, 0.25, 0.75);
      self._iconHighlight:SetBlendMode("ADD")
    else
      self._iconHighlight:SetColorTexture(1, 1, 1, 0.2);
    end
  end
end

function BOM.MyButton_OnLeave(self)
  BomC_Tooltip:Hide()
  self._iconHighlight:SetColorTexture(1, 1, 1, 0)
  self._iconHighlight:SetVertexColor(1, 1, 1, 0);
end

---@param self BomGPIControl
function BOM.MyButton_OnMouseUp(self, button)
  if not self._privat_disabled then
    if self._privat_DB and self._privat_Var then
      if self._privat_Set == nil then
        self._privat_DB[self._privat_Var] = not self._privat_DB[self._privat_Var]
      else
        if self._privat_DB[self._privat_Var] ~= self._privat_Set then
          self._privat_DB[self._privat_Var] = self._privat_Set
        else
          self._privat_DB[self._privat_Var] = nil
        end
      end
      self:SetState()
      BOM.MyButton_OnEnter(self)
      if self._privat_OnClick then
        self._privat_OnClick(self, button)
      end
    end
  end
end

function BOM.MyButton_SetText(self, text)
  self._privat_Text = text
  BOM.MyButton_Update(self)
end

---@param self BomGPIControl
function BOM.MyButton_OnLoad(self, isSecure)
  self._privat_state = true
  self._privat_disabled = false
  self.SetState = BOM.MyButton_SetState
  self.SetTextures = BOM.MyButton_SetTextures
  self.SetTooltipLink = BOM.MyButton_SetTooltipLink
  self.SetTooltip = BOM.MyButton_SetTooltip
  self.SetVariable = BOM.MyButton_SetVariable
  self.SetText = BOM.MyButton_SetText

  if not isSecure then
    self:SetScript("OnMouseUp", BOM.MyButton_OnMouseUp)
    self.SetOnClick = BOM.MyButton_SetOnClick
    self.Disable = BOM.MyButton_OnDisable
    self.Enable = BOM.MyButton_OnEnable
  else
    self:SetScript("OnDisable", BOM.MyButton_OnDisable)
    self:SetScript("OnEnable", BOM.MyButton_OnEnable)
    self.SetSpell = BOM.MyButton_SetSpell
    self._privat_isSecure = true
  end
  self:SetScript("OnEnter", BOM.MyButton_OnEnter)
  self:SetScript("OnLeave", BOM.MyButton_OnLeave)
end

---@param self BomGPIControl
function BOM.MyButton_SetState(self, state)
  if state == nil then
    if self._privat_DB and self._privat_Var then
      if self._privat_Set == nil then
        self._privat_state = self._privat_DB[self._privat_Var]
      else
        self._privat_state = (self._privat_DB[self._privat_Var] == self._privat_Set)
      end
    end
  else
    self._privat_state = state
  end
  BOM.MyButton_Update(self)
end

local defaultcoord = { 0, 1, 0, 1 }

function BOM.MyButton_SetTextures(self, sel, unsel, dis, selCoord, unselCoord, disCoord)
  self._IconSelected = sel
  self._IconUnSelected = unsel
  self._IconDisabled = dis
  self._IconSelectedCoord = selCoord or defaultcoord
  self._IconUnSelectedCoord = unselCoord or defaultcoord
  self._IconDisabledCoord = disCoord or defaultcoord
  BOM.MyButton_Update(self)
end

---@param self BomGPIControl
---@param db table A storage table where clicking the button will modify something
---@param var string Key in the table to be modified
---@param set any Value to be written to the table if the button is clicked
function BOM.MyButton_SetVariable(self, db, var, set)
  self._privat_DB = db
  self._privat_Var = var
  self._privat_Set = set
  self:SetState(nil)
end

function BOM.MyButton_SetTooltipLink(self, link)
  self._privat_ToolTipLink = link
  self._privat_ToolTipText = nil
end

function BOM.MyButton_SetTooltip(self, text)
  self._privat_ToolTipLink = nil
  self._privat_ToolTipText = text
end

function BOM.MyButton_SetSpell(self, spell)
  self:SetAttribute("type", "spell")
  self:SetAttribute("spell", spell)
  self:SetAttribute("unit", "player")
end

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
  BOM.MyButton_OnLoad(newButtonFrame, false)
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
  BOM.MyButton_OnLoad(newButton, true)
  newButton:SetTextures(sel, unsel, dis, selCoord, unselCoord, disCoord)
  self:ManageControl(uniqueId, newButton)
  return newButton
end

function managedUiModule:UpdateAll()
  for uniq, control in pairs(self.managed) do
    if control.SetState then
      control:SetState()
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
