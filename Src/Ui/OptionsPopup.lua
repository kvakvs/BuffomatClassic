local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomBehaviourSetting
---@field name string
---@field value boolean

---@class BomOptionsPopupModule
---@field behaviourSettings BomBehaviourSetting[]
local optionsPopupModule = {}
BomModuleManager.optionsPopupModule = optionsPopupModule

local _t = BomModuleManager.languagesModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local profileModule = BomModuleManager.profileModule

---@deprecated See options.lua, and defaults in sharedState.lua and characterState.lua
optionsPopupModule.behaviourSettings = --[[---@type BomBehaviourSetting[] ]] {
  { name = "AutoOpen", value = true },
  { name = "ScanInRestArea", value = false },
  { name = "ScanInStealth", value = false },
  { name = "ScanWhileMounted", value = true },
  { name = "InWorld", value = true },
  { name = "InPVP", value = true },
  { name = "InInstance", value = true },
  { name = "PreventPVPTag", value = true },

  { name = "DeathBlock", value = true },
  { name = "NoGroupBuff", value = false },
  { name = "SameZone", value = false },
  { name = "ResGhost", value = false },
  { name = "ReplaceSingle", value = true },
  { name = "ArgentumDawn", value = false },
  { name = "Carrot", value = false },
  { name = "MainHand", value = false },
  { name = "SecondaryHand", value = false },
  { name = "UseRank", value = true },
  { name = "AutoCrusaderAura", value = true },
  { name = "AutoDismount", value = true },
  { name = "AutoDismountFlying", value = false },
  { name = "AutoStand", value = true },
  { name = "AutoDisTravel", value = true },
  { name = "BuffTarget", value = false },
  { name = "OpenLootable", value = true },
  { name = "SelfFirst", value = false },
  { name = "DontUseConsumables", value = false },
  { name = "SlowerHardware", value = false },
  { name = "SomeoneIsDrinking", value = false },
}

local L

---Makes a tuple to pass to the menubuilder to display a settings checkbox in popup menu
---@param db table - BuffomatShared reference to read settings from it
---@param var string Variable name from optionsPopupModule.BehaviourSettings
function optionsPopupModule:MakeSettingsRow(db, var)
  return _t("options.short." .. var), false, db, var
end

local function bomOpenOptions()
  LibStub("AceConfigDialog-3.0"):Open(constModule.SHORT_TITLE)
end

---Populate the [⚙] popup menu: Submenu "Quick Options"
---@deprecated
function optionsPopupModule:PopupQuickOptions()
  BOM.PopupDynamic:SubMenu(_t("popup.QuickSettings"), "subSettings")

  for i, setting in ipairs(self.behaviourSettings) do
    BOM.PopupDynamic:AddItem(self:MakeSettingsRow(buffomatModule.shared, setting.name))
  end

  -- -------------------------------------------
  -- Watch in Raid group -> 1 2 3 4 5 6 7 8
  -- -------------------------------------------
  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(_t("HeaderWatchGroup"), "subGroup")

  for i = 1, 8 do
    BOM.PopupDynamic:AddItem(i, "keep", buffomatModule.character.WatchGroup, i)
  end

  BOM.PopupDynamic:SubMenu()
end

---Populate the [⚙] popup menu
function optionsPopupModule:Setup(control, minimap)
  local name = (control:GetName() or "nil") .. (minimap and "Minimap" or "Normal")

  if not BOM.PopupDynamic:Wipe(name) then
    return
  end

  if minimap then
    BOM.PopupDynamic:AddItem(_t("BtnOpen"), false, BOM.ShowWindow)
    BOM.PopupDynamic:AddItem()
    BOM.PopupDynamic:AddItem(_t("options.short.ShowMinimapButton"), false,
            buffomatModule.shared.Minimap, "visible")
    BOM.PopupDynamic:AddItem(_t("options.short.LockMinimapButton"), false,
            buffomatModule.shared.Minimap, "lock")
    BOM.PopupDynamic:AddItem(_t("options.short.LockMinimapButtonDistance"), false,
            buffomatModule.shared.Minimap, "lockDistance")
    BOM.PopupDynamic:AddItem()
  end

  -- --------------------------------------------
  -- Use Profiles checkbox and submenu
  -- --------------------------------------------
  BOM.PopupDynamic:AddItem(_t("options.short.UseProfiles"), false,
          buffomatModule.character, "UseProfiles")

  if buffomatModule.character.UseProfiles then
    BOM.PopupDynamic:SubMenu(_t("HeaderProfiles"), "subProfiles")
    BOM.PopupDynamic:AddItem(_t("profile_auto"), false,
            buffomatModule.ChooseProfile, "auto")

    local currentProfileName = profileModule:ChooseProfile()
    for _i, eachProfileName in pairs(profileModule.ALL_PROFILES) do
      if currentProfileName == eachProfileName then
        local activeName = _t("profile.activeProfileMenuTag") .. " " .. _t("profile_" .. eachProfileName)
        BOM.PopupDynamic:AddItem(buffomatModule:Color("00ff00", activeName),
                false, buffomatModule.ChooseProfile, eachProfileName)
      else
        BOM.PopupDynamic:AddItem(_t("profile_" .. eachProfileName),
                false, buffomatModule.ChooseProfile, eachProfileName)
      end
    end

    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()

  -- --------------------------------------------
  -- Selected spells check on/off
  -- --------------------------------------------
  for i, buffDef in ipairs(BOM.selectedBuffs) do
    if not buffDef.isConsumable then
      BOM.PopupDynamic:AddItem(buffDef.singleLink or buffDef.singleText,
              "keep",
              buffDefModule:GetProfileBuff(buffDef.buffId, nil),
              "Enable")
    end
  end

  local inBuffGroup -- unused? nil?
  if inBuffGroup then
    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()
  --self:PopupQuickOptions()
  BOM.PopupDynamic:AddItem(_t("BtnSettings"), false, bomOpenOptions, 1)

  BOM.PopupDynamic:Show(control or "cursor", 0, 0)
end
