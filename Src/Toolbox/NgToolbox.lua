-- New Generation GUI Toolbox using WowAce (AceGUI-3.0)

---@class NgToolboxModule

local ngToolboxModule = --[[---@type NgToolboxModule]] LibStub("Buffomat-NgToolbox")
local _t = --[[---@type BomLanguagesModule]] LibStub("Buffomat-Languages")

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
