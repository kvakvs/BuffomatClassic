--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomControlModule
local controlModule = BomModuleManager.controlModule ---@type BomControlModule

---@class GPIMinimapButtonConfigData
---@field position number|nil
---@field distance number|nil
---@field visible boolean|nil
---@field lock boolean|nil
---@field lockDistance boolean|nil
controlModule.GPIMinimapButtonConfigData = {}
controlModule.GPIMinimapButtonConfigData.__index = controlModule.GPIMinimapButtonConfigData

---@class WowTexture
---@field GetTexCoord fun(self: WowTexture): BomTexCoord
---@field GetTexture fun(self: WowTexture): string
---@field SetAllPoints function
---@field SetBlendMode fun(self: WowTexture, blendMode: string)
---@field SetColorTexture fun(self: WowTexture, r: number, g: number, b: number, a: number)
---@field SetDesaturated fun(self: WowTexture, desaturated: boolean)
---@field SetRotation fun(self: WowTexture, rotation: number, a: number|nil, b: number|nil)
---@field SetTexCoord fun(self: WowTexture, coord: BomTexCoord)
---@field SetTexture fun(self: WowTexture, texturePath: string|nil, a: nil, filterQuality: nil)
---@field SetPoint fun(self: WowTexture, point: string, x: number, y: number)
---@field SetSize fun(self: WowTexture, width: number, height: number)
---@field SetVertexColor fun(self: WowTexture, r: number, g: number, b: number, a: number)

---@class WowControl A blizzard UI frame but may contain private fields used by internal library by Buffomat
---@field bomReadVariable function Returns value which the button can modify, boolean for toggle buttons
---@field bomToolTipLink string Mouseover will show the link
---@field bomToolTipText string Mouseover will show the text
---@field ClearAllPoints fun(self: WowControl)
---@field CreateFontString fun(self: WowControl, name: string|nil, layer: string|nil, inherits: string): WowControl
---@field CreateTexture fun(self: WowControl): WowTexture
---@field Disable fun(self: WowControl)
---@field Enable fun(self: WowControl)
---@field GetHeight fun(self: WowControl): number
---@field GetLeft fun(self: WowControl): number
---@field GetParent fun(self: WowControl): WowControl
---@field GetTop fun(self: WowControl): number
---@field GetWidth fun(self: WowControl): number
---@field Hide fun(self: WowControl)
---@field IsEnabled fun(self: WowControl): boolean
---@field IsVisible fun(self: WowControl): boolean
---@field SetAlpha fun(self: WowControl, a: number)
---@field SetAttribute function
---@field SetFrameStrata fun(self: WowControl, strata: string)
---@field SetHeight fun(self: WowControl, height: number)
---@field SetMinResize function
---@field SetOwner fun(self: WowControl, owner: WowControl, anchor: string)
---@field SetParent fun(self: WowControl, parent: WowControl|nil)
---@field SetPoint fun(self: WowControl, point: string, relativeTo: WowControl|nil, relativePoint: string, xOfs: number, yOfs: number)|fun(self: WowControl, point: string, x: number, y: number)
---@field SetScale function
---@field SetScript fun(self: WowControl, script: string, handler: function)
---@field SetState fun(self: BomGPIControl, state: any) GPI control handler but is here for simpler code where controls are mixed in same container
---@field SetText fun(self: WowControl, text: string)
---@field SetTextures fun(self: WowControl, sel: string|nil, unsel: string|nil, dis: string|nil, selCoord: number[]|nil, unselCoord: number[]|nil, disCoord: number[]|nil)
---@field SetWidth fun(self: WowControl, width: number)
---@field Show fun(self: WowControl)
---@field StartSizing fun(self: WowControl, sizingType: string)
---@field StopMovingOrSizing fun(self: WowControl)

---@class WowUIErrorsFrame: WowControl
---@field Clear function

---@class WowChatFrame: WowControl
---@field editBox WowControl
---@field AddMessage function
---@field Clear function
---@field SetFading function
---@field SetFontObject function
---@field SetJustifyH function
---@field SetHyperlinksEnabled function
---@field SetMaxLines function
---
---@class WowGameTooltip: WowControl
---@field AddLine fun(m: string)
---@field SetHyperlink fun(m: string)

---@class BomTooltipControl: WowControl
---@field AddFontStrings fun(self: WowControl, text: WowControl, subText: WowControl)
---@field ClearLines fun(self: WowControl)
---@field GetRegions fun(self: WowControl): table[]
-- -@field [string] function

---@alias BomMenuItemDefList BomMenuItemDef[]

---@class BomGPIControl: WowControl A blizzard UI frame but may contain private fields used by internal library by GPI
---@field gpiCombatLock boolean
---@field Texture WowTexture
---@field _icon WowTexture
---@field _text WowControl
---@field _iconHighlight WowTexture
---@field gpiDict table Stores dictionary which will be updated when button is clicked
---@field gpiVariableName string Variable name in the gpiDict, which will be updated on click
---@field gpiValueOnClick any Value to be set/reset to nil when the button is clicked, use nil to toggle a boolean
---@field _privat_OnClick function
---@field _privat_state boolean
---@field _privat_disabled boolean
---@field _privat_Text string
---@field _privat_ToolTipLink string Mouseover will show the link
---@field _privat_ToolTipText string Mouseover will show the text
---@field _GPIPRIVAT_events table<string, function> Events
---@field _GPIPRIVAT_updates table<function> private field
---@field _GPIPRIVAT_MovingStopCallback any private field
---@field bomPopupMenuCallback function
---@field bomMenuItems BomMenuItemDefList Popup menu items
---@field _GPIPRIVAT_MovingStopCallback function
---@field gpiCursor any
---@field gpiRotation number Rotation in degrees
---@field GPI_SIZETYPE string
---@field gpiMinimapButton BomMinimapButtonPlaceholder Stores extra values for minimap button control
---@field SetSpell fun(self: BomGPIControl, spell: BomSpellId)
---@field SetOnClick fun(self: BomGPIControl, func: function)
---@field GPI_DoStop fun(control: WowControl) Note: no self
---@field GPI_DoStart fun(control: WowControl) Note: no self
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
      if (self.gpiDict and self.gpiVariableName) then
        add = " " .. (self._privat_state and ONIcon or OFFIcon)
      end
      BomC_Tooltip:AddLine(self._privat_ToolTipText .. add)

    end
    BomC_Tooltip:Show()
  end
  if ((self.gpiDict and self.gpiVariableName) or self._privat_isSecure) and not self._privat_disabled then
    self._iconHighlight:SetTexture(self._icon:GetTexture(), nil, nil)
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
    if self.gpiDict and self.gpiVariableName then
      if self.gpiValueOnClick == nil then
        self._privat_state = self.gpiDict[self.gpiVariableName]
      else
        self._privat_state = (self.gpiDict[self.gpiVariableName] == self.gpiValueOnClick)
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
    if self.gpiDict and self.gpiVariableName then
      if self.gpiValueOnClick == nil then
        self.gpiDict[self.gpiVariableName] = not self.gpiDict[self.gpiVariableName]
      else
        if self.gpiDict[self.gpiVariableName] ~= self.gpiValueOnClick then
          self.gpiDict[self.gpiVariableName] = self.gpiValueOnClick
        else
          self.gpiDict[self.gpiVariableName] = nil
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
---@param dictionary table A storage table where clicking the button will modify something
---@param variableName string Key in the table to be modified
---@param valueOnClick any Value to be written to the table if the button is clicked
function controlModule.MyButton_SetVariable(self, dictionary, variableName, valueOnClick)
  self.gpiDict = dictionary
  self.gpiVariableName = variableName
  self.gpiValueOnClick = valueOnClick
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
