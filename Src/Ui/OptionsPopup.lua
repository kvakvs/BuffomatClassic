local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomBehaviourSetting
---@field name string
---@field value boolean

---@shape BomOptionsPopupModule
-- -@field behaviourSettings BomBehaviourSetting[]
local optionsPopupModule = BomModuleManager.optionsPopupModule ---@type BomOptionsPopupModule

local _t = BomModuleManager.languagesModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local profileModule = BomModuleManager.profileModule
local popupModule = BomModuleManager.popupModule

-----@deprecated See options.lua, and defaults in sharedState.lua and characterState.lua
--optionsPopupModule.behaviourSettings = --[[---@type BomBehaviourSetting[] ]] {
--  { name = "AutoOpen", value = true },
--  { name = "ScanInRestArea", value = false },
--  { name = "ScanInStealth", value = false },
--  { name = "ScanWhileMounted", value = true },
--  { name = "InWorld", value = true },
--  { name = "InPVP", value = true },
--  { name = "InInstance", value = true },
--  { name = "PreventPVPTag", value = true },
--
--  { name = "DeathBlock", value = true },
--  { name = "NoGroupBuff", value = false },
--  { name = "SameZone", value = false },
--  { name = "ResGhost", value = false },
--  { name = "ReplaceSingle", value = true },
--  { name = "ArgentumDawn", value = false },
--  { name = "Carrot", value = false },
--  { name = "MainHand", value = false },
--  { name = "SecondaryHand", value = false },
--  { name = "UseRank", value = true },
--  { name = "AutoCrusaderAura", value = true },
--  { name = "AutoDismount", value = true },
--  { name = "AutoDismountFlying", value = false },
--  { name = "AutoStand", value = true },
--  { name = "AutoDisTravel", value = true },
--  { name = "BuffTarget", value = false },
--  { name = "OpenLootable", value = true },
--  { name = "SelfFirst", value = false },
--  { name = "DontUseConsumables", value = false },
--  { name = "SlowerHardware", value = false },
--  { name = "SomeoneIsDrinking", value = false },
--}

---Makes a tuple to pass to the menubuilder to display a settings checkbox in popup menu
---@param db table - BuffomatShared reference to read settings from it
---@param var string Variable name from optionsPopupModule.BehaviourSettings
function optionsPopupModule:MakeSettingsRow(db, var)
  return _t("options.short." .. var), false, db, var
end

function optionsPopupModule.OpenOptions()
  LibStub("AceConfigDialog-3.0"):Open(constModule.SHORT_TITLE)
end

-----Populate the [⚙] popup menu: Submenu "Quick Options"
-----@deprecated
--function optionsPopupModule:PopupQuickOptions()
--  BOM.popupMenuDynamic:SubMenu(_t("popup.QuickSettings"), "subSettings")
--
--  for i, setting in ipairs(self.behaviourSettings) do
--    BOM.popupMenuDynamic:AddItem(self:MakeSettingsRow(buffomatModule.shared, setting.name), nil, nil, nil, nil)
--  end
--
--  -- -------------------------------------------
--  -- Watch in Raid group -> 1 2 3 4 5 6 7 8
--  -- -------------------------------------------
--  BOM.popupMenuDynamic:AddItem(nil, nil, nil, nil, nil)
--  BOM.popupMenuDynamic:SubMenu(_t("HeaderWatchGroup"), "subGroup", nil)
--
--  for i = 1, 8 do
--    BOM.popupMenuDynamic:AddItem(i, "keep", buffomatModule.character.WatchGroup, i, nil)
--  end
--
--  BOM.popupMenuDynamic:SubMenu(nil, nil)
--end

---Populate the [⚙] popup menu
---@param minimap boolean
function optionsPopupModule:Setup(control, minimap)
  local name = (control:GetName() or "nil") .. (minimap and "Minimap" or "Normal")
  local dyn = BOM.popupMenuDynamic
  local menuItems = --[[---@type BomMenuItemDef[] ]] {}

  if not dyn:Wipe(name) then
    return
  end

  if minimap then
    table.insert(menuItems, popupModule:Clickable(_t("popup.OpenBuffomat"), BOM.ShowWindow, nil, nil))
    table.insert(menuItems, popupModule:Separator())
    table.insert(menuItems, popupModule:Boolean(_t("options.short.ShowMinimapButton"),
            buffomatModule.shared.Minimap, "visible"))
    table.insert(menuItems, popupModule:Boolean(_t("options.short.LockMinimapButton"),
            buffomatModule.shared.Minimap, "lock"))
    table.insert(menuItems, popupModule:Boolean(_t("options.short.LockMinimapButtonDistance"),
            buffomatModule.shared.Minimap, "lockDistance"))
    table.insert(menuItems, popupModule:Separator())
  end

  -- --------------------------------------------
  -- Use Profiles checkbox and submenu
  -- --------------------------------------------
  table.insert(menuItems, popupModule:Boolean(_t("options.short.UseProfiles"),
          buffomatModule.character, "UseProfiles"))

  if buffomatModule.character.UseProfiles then
    local subprofilesMenu = --[[---@type BomMenuItemDef[] ]] {}
    table.insert(subprofilesMenu, popupModule:Clickable(_t("profile_auto"),
            buffomatModule.ChooseProfile, "auto", nil))

    local currentProfileName = profileModule:ChooseProfile()

    for _i, eachProfileName in pairs(profileModule.ALL_PROFILES) do
      if currentProfileName == eachProfileName then
        local activeName = _t("profile.activeProfileMenuTag") .. " " .. _t("profile_" .. eachProfileName)
        table.insert(subprofilesMenu, popupModule:Clickable(buffomatModule:Color("00ff00", activeName),
                buffomatModule.ChooseProfile, eachProfileName, nil))
      else
        table.insert(subprofilesMenu, popupModule:Clickable(_t("profile_" .. eachProfileName),
                buffomatModule.ChooseProfile, eachProfileName, nil))
      end
    end

    table.insert(menuItems, popupModule:SubMenu(_t("header.Profiles"), 1, subprofilesMenu))
  end

  table.insert(menuItems, popupModule:Separator())


  -- --------------------------------------------
  -- Selected spells check on/off
  -- --------------------------------------------
  if true then
    for i, buffDef in ipairs(BOM.selectedBuffs) do
      if not buffDef.isConsumable then
        table.insert(menuItems, popupModule:Boolean(
                buffDef.singleLink or buffDef.singleText,
                buffDefModule:GetProfileBuff(buffDef.buffId, nil),
                "Enable"))
      end
    end
  end

  --local inBuffGroup -- unused? nil?
  --if inBuffGroup then
  --  dyn:SubMenu(nil, nil)
  --end

  table.insert(menuItems, popupModule:Separator())

  --self:PopupQuickOptions()

  table.insert(menuItems, popupModule:Clickable(_t("optionsMenu.Settings"),
          optionsPopupModule.OpenOptions, 1, nil))

  dyn:SetMenuItems(menuItems)
  dyn:Show(control or "cursor", 0, 0)
end
