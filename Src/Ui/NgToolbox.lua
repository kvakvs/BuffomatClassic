-- New Generation GUI Toolbox using WowAce (AceGUI-3.0)

---@class NgToolboxModule
local ngToolboxModule = BomModuleManager.ngToolboxModule
local _t = BomModuleManager.languagesModule

---@param control AceGUIWidget
---@param translationKey string The key to translation
function ngToolboxModule:TooltipWithTranslationKey(control, translationKey)
  control:SetCallback("OnEnter", function()
    GameTooltip:SetOwner(control.frame, "ANCHOR_RIGHT")
    GameTooltip:AddLine(_t(translationKey))
    GameTooltip:Show()
  end)
  control:SetCallback("OnLeave", function()
    GameTooltip:Hide()
  end)
end
