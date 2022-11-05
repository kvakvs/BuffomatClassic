--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon

---@class BomControlModule
local controlModule = {}
BomModuleManager.controlModule = controlModule

---@class GPIMenuItem
---@field text string
---@field disabled boolean
---@field value any
---@field arg1 any
---@field arg2 any
---@field MenuDepth number
controlModule.GPIMenuItem = {}
controlModule.GPIMenuItem.__index = controlModule.GPIMenuItem


---@class GPIMinimapButtonConfigData
---@field position number|nil
---@field distance number|nil
---@field visible boolean|nil
---@field lock boolean|nil
---@field lockDistance boolean|nil
controlModule.GPIMinimapButtonConfigData = {}
controlModule.GPIMinimapButtonConfigData.__index = controlModule.GPIMinimapButtonConfigData


---@class BomGPIMinimapButton: BomGPIControl
---@field icon table
---@field isMouseDown boolean
---@field isDraggingButton boolean
---@field db GPIMinimapButtonConfigData Config database which will persist between addon reloads
---@field tooltip string
---@field isMinimapButton boolean
---@field button BomGPIControl
---@field Init function
---@field OnClick function
---@field UpdatePosition function
---@field SetTexture fun(texturePath: string)
controlModule.GPIMinimapButton = {
  --UpdatePosition = minimapButtonClass:UpdatePosition ???
}
controlModule.GPIMinimapButton.__index = controlModule.GPIMinimapButton


---@class WowTexture
---@field SetTexture fun(self: WowTexture, texturePath: string)
---@field SetTexCoord fun(self: WowTexture, coord: BomTexCoord)
---@field GetTexture fun(self: WowTexture): string
---@field GetTexCoord fun(self: WowTexture): BomTexCoord
---@field SetDesaturated fun(self: WowTexture, desaturated: boolean)
---@field SetBlendMode fun(self: WowTexture, blendMode: string)
---@field SetVertexColor fun(self: WowTexture, r: number, g: number, b: number, a: number)
---@field SetColorTexture fun(self: WowTexture, r: number, g: number, b: number, a: number)

---@class BomControl A blizzard UI frame but may contain private fields used by internal library by Buffomat
---@field bomToolTipLink string Mouseover will show the link
---@field bomToolTipText string Mouseover will show the text
---@field bomReadVariable function Returns value which the button can modify, boolean for toggle buttons
---@field SetPoint fun(self: BomControl, point: string, relativeTo: BomControl, relativePoint: string, xOfs: number, yOfs: number)
---@field Hide fun(self: BomControl)
---@field ClearAllPoints fun(self: BomControl)
---@field SetParent fun(self: BomControl, parent: BomControl|nil)
---@field SetScript fun(self: BomControl, script: string, handler: function)
---@field Hide fun(self: BomControl)
---@field Show fun(self: BomControl)
---@field SetTextures fun(self: BomControl, sel: string|nil, unsel: string|nil, dis: string|nil, selCoord: number[]|nil, unselCoord: number[]|nil, disCoord: number[]|nil)
---@field SetText fun(self: BomControl, text: string)
---@field SetWidth fun(self: BomControl, width: number)
---@field SetHeight fun(self: BomControl, height: number)
---@field SetState fun(self: BomGPIControl, state: any) GPI control handler but is here for simpler code where controls are mixed in same container

---@class BomGPIControl: BomControl A blizzard UI frame but may contain private fields used by internal library by GPI
---@field _icon WowTexture
---@field _text BomControl
---@field _iconHighlight WowTexture
---@field _privat_DB table Stores value when button is clicked
---@field _privat_Var string Variable name in the _privat_DB
---@field _privat_Set any Value to be set/reset to nil when the button is clicked, use nil to toggle a boolean
---@field _privat_OnClick function
---@field _privat_state boolean
---@field _privat_disabled boolean
---@field _privat_Text string
---@field _privat_ToolTipLink string Mouseover will show the link
---@field _privat_ToolTipText string Mouseover will show the text
---@field _GPIPRIVAT_events table<string, function> Events
---@field _GPIPRIVAT_updates table<function> private field
---@field _GPIPRIVAT_MovingStopCallback any private field
---@field _GPIPRIVAT_TableCallback function
---@field _GPIPRIVAT_Items table<GPIMenuItem> Popup item list?
---@field _GPIPRIVAT_MovingStopCallback function
---@field GPI_Cursor any
---@field GPI_Rotation number Rotation in degrees
---@field GPI_DoStart boolean
---@field GPI_DoStop boolean
---@field GPI_SIZETYPE string
---@field Lib_GPI_MinimapButton BomGPIMinimapButton Stores extra values for minimap button control
---@field SetSpell fun(self: BomGPIControl, spell: BomSpellId)
---@field SetOnClick fun(self: BomGPIControl, func: function)
local gpiControlClass = {}
gpiControlClass.__index = gpiControlClass
controlModule.gpiControlClass = gpiControlClass

---@param self BomGPIControl
function controlModule.MyButton_OnLoad(self, isSecure)
  self._privat_state = true
  self._privat_disabled = false
  self.SetState = controlModule.MyButton_SetState
  self.SetTextures = controlModule.MyButton_SetTextures
  self.SetTooltipLink = controlModule.MyButton_SetTooltipLink
  self.SetTooltip = controlModule.MyButton_SetTooltip
  self.SetVariable = controlModule.MyButton_SetVariable
  self.SetText = controlModule.MyButton_SetText

  if not isSecure then
    self:SetScript("OnMouseUp", controlModule.MyButton_OnMouseUp)
    self.SetOnClick = controlModule.MyButton_SetOnClick
    self.Disable = controlModule.MyButton_OnDisable
    self.Enable = controlModule.MyButton_OnEnable
  else
    self:SetScript("OnDisable", controlModule.MyButton_OnDisable)
    self:SetScript("OnEnable", controlModule.MyButton_OnEnable)
    self.SetSpell = controlModule.MyButton_SetSpell
    self._privat_isSecure = true
  end
  self:SetScript("OnEnter", controlModule.MyButton_OnEnter)
  self:SetScript("OnLeave", controlModule.MyButton_OnLeave)
end

---@param self BomGPIControl
function controlModule.MyButton_OnEnter(self)
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

---@param self BomGPIControl
function controlModule.MyButton_OnLeave(self)
  BomC_Tooltip:Hide()
  self._iconHighlight:SetColorTexture(1, 1, 1, 0)
  self._iconHighlight:SetVertexColor(1, 1, 1, 0);
end

---@param self BomGPIControl
function controlModule.MyButton_SetState(self, state)
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
  controlModule.MyButton_Update(self)
end

local defaultcoord = { 0, 1, 0, 1 }

---@param self BomGPIControl
function controlModule.MyButton_SetTextures(self, sel, unsel, dis, selCoord, unselCoord, disCoord)
  self._IconSelected = sel
  self._IconUnSelected = unsel
  self._IconDisabled = dis
  self._IconSelectedCoord = selCoord or defaultcoord
  self._IconUnSelectedCoord = unselCoord or defaultcoord
  self._IconDisabledCoord = disCoord or defaultcoord
  controlModule.MyButton_Update(self)
end

---@param self BomGPIControl
function controlModule.MyButton_Update(self)
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
function controlModule.MyButton_SetOnClick(self, func)
  self._privat_OnClick = func
end

---@param self BomGPIControl
function controlModule.MyButton_OnDisable(self)
  self._privat_disabled = true
  controlModule.MyButton_Update(self)
end

---@param self BomGPIControl
function controlModule.MyButton_OnEnable(self)
  self._privat_disabled = false
  controlModule.MyButton_Update(self)
end

---@param self BomGPIControl
---@param button string Key or mouse button?
function controlModule.MyButton_OnMouseUp(self, button)
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
      self:SetState(nil)
      controlModule.MyButton_OnEnter(self)
      if self._privat_OnClick then
        self._privat_OnClick(self, button)
      end
    end
  end
end

---@param self BomGPIControl
---@param text string
function controlModule.MyButton_SetText(self, text)
  self._privat_Text = text
  controlModule.MyButton_Update(self)
end

---@param self BomGPIControl
---@param db table A storage table where clicking the button will modify something
---@param var string Key in the table to be modified
---@param set any Value to be written to the table if the button is clicked
function controlModule.MyButton_SetVariable(self, db, var, set)
  self._privat_DB = db
  self._privat_Var = var
  self._privat_Set = set
  self:SetState(nil)
end

function controlModule.MyButton_SetTooltipLink(self, link)
  self._privat_ToolTipLink = link
  self._privat_ToolTipText = nil
end

function controlModule.MyButton_SetTooltip(self, text)
  self._privat_ToolTipLink = nil
  self._privat_ToolTipText = text
end

function controlModule.MyButton_SetSpell(self, spell)
  self:SetAttribute("type", "spell")
  self:SetAttribute("spell", spell)
  self:SetAttribute("unit", "player")
end
