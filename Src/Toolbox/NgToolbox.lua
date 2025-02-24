-- New Generation GUI Toolbox using WowAce (AceGUI-3.0)

---@class NgToolboxModule

local ngToolboxModule = LibStub("Buffomat-NgToolbox") --[[@as NgToolboxModule]]
local _t = LibStub("Buffomat-Languages") --[[@as LanguagesModule]]
local libGUI = LibStub("AceGUI-3.0")

---@param widget AceGUIWidget
---@param text string The key to translation
function ngToolboxModule:SetTooltip(widget, text)
  widget:SetCallback("OnEnter", function()
    GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
    GameTooltip:AddLine(text)
    GameTooltip:Show()
  end)
  widget:SetCallback("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---@param widget AceGUIWidget
---@param translationKey string The key to translation
function ngToolboxModule:TooltipWithTranslationKey(widget, translationKey)
  widget:SetCallback("OnEnter", function()
    GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
    GameTooltip:AddLine(_t(translationKey))
    GameTooltip:Show()
  end)
  widget:SetCallback("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---Add onenter/onleave scripts to show the tooltip with spell
---@param widget AceGUIWidget
---@param link string The string in format "spell:<id>" or "item:<id>"
function ngToolboxModule:TooltipLink(widget, link)
  widget:SetCallback("OnEnter", function()
    local spellId = GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(link)
    GameTooltip:Show()
  end)
  widget:SetCallback("OnLeave", function()
    GameTooltip:Hide()
  end)
end


---@param frame Frame
function ngToolboxModule:SetButtonTextures(frame, normalTexture, selectedTexture, disabledTexture)
  frame:SetNormalTexture(normalTexture)
  local normalT = frame:GetNormalTexture()
  normalT:SetSize(20, 20)
  normalT:ClearAllPoints()
  normalT:SetPoint("CENTER")
  -- normalT:SetTexture(normalTexture)

  frame:SetPushedTexture(selectedTexture or normalTexture)
  local pushedT = frame:GetPushedTexture()
  pushedT:SetSize(20, 20)
  pushedT:ClearAllPoints()
  pushedT:SetPoint("CENTER")
  -- pushedT:SetTexture(selectedTexture or normalTexture)

  frame:SetDisabledTexture(disabledTexture or normalTexture)
  local disabledT = frame:GetDisabledTexture()
  disabledT:SetSize(20, 20)
  disabledT:ClearAllPoints()
  disabledT:SetPoint("CENTER")
  -- disabledT:SetTexture(disabledTexture or normalTexture)
end

---@param tooltip string
---@param textureOn string
---@param textureOff string
---@param getValue fun(): boolean
---@param setValue fun(value: boolean)
---@return AceGUIWidget
function ngToolboxModule:CreateToggle(tooltip, textureOn, textureOff, getValue, setValue)
  local button = libGUI:Create("Button")
  button:SetWidth(20)
  button:SetHeight(20)

  local valueOnCreation = getValue()
  local setTextureOn = function()
    ngToolboxModule:SetButtonTextures(button.frame, textureOn)
  end
  local setTextureOff = function()
    ngToolboxModule:SetButtonTextures(button.frame, textureOff)
  end
  if valueOnCreation then setTextureOn() else setTextureOff() end

  button:SetCallback("OnClick", function(_control, mouseButton)
    local newValue = not getValue()
    setValue(newValue)
    if newValue then setTextureOn() else setTextureOff() end
  end)

  self:SetTooltip(button, tooltip)
  return button
end
