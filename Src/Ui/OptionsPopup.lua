local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomOptionsPopupModule
---@field behaviourSettings table<number, table> A list of {Key name, Default} for 'Profile' settings
local optionsPopupModule = BuffomatModule.DeclareModule("OptionsPopup") ---@type BomOptionsPopupModule

local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

optionsPopupModule.behaviourSettings = {
  { "AutoOpen", true },
  { "ScanInRestArea", false },
  { "ScanInStealth", false },
  { "ScanWhileMounted", true },
  { "InWorld", true },
  { "InPVP", true },
  { "InInstance", true },
  { "PreventPVPTag", true },

  { "DeathBlock", true },
  { "NoGroupBuff", false },
  { "SameZone", false },
  { "ResGhost", false },
  { "ReplaceSingle", true },
  { "ArgentumDawn", false },
  { "Carrot", false },
  { "MainHand", false },
  { "SecondaryHand", false },
  { "UseRank", true },
  { "AutoCrusaderAura", true },
  { "AutoDismount", true },
  { "AutoDismountFlying", false },
  { "AutoStand", true },
  { "AutoDisTravel", true },
  { "BuffTarget", false },
  { "OpenLootable", true },
  { "SelfFirst", false },
  { "DontUseConsumables", false },
  { "SlowerHardware", false },
  { "HideSomeoneIsDrinking", false },
}

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })

---Makes a tuple to pass to the menubuilder to display a settings checkbox in popup menu
---@param db table - BomSharedState reference to read settings from it
---@param var string Variable name from optionsPopupModule.BehaviourSettings
function optionsPopupModule:MakeSettingsRow(db, var)
  return L["options.short." .. var], false, db, var
end

local function bomOpenOptions()
  LibStub("AceConfigDialog-3.0"):Open(constModule.SHORT_TITLE)
end

---Populate the [⚙] popup menu
function optionsPopupModule:Setup(control, minimap)
  local name = (control:GetName() or "nil") .. (minimap and "Minimap" or "Normal")

  if not BOM.PopupDynamic:Wipe(name) then
    return
  end

  if minimap then
    BOM.PopupDynamic:AddItem(L.BtnOpen, false, BOM.ShowWindow)
    BOM.PopupDynamic:AddItem()
    BOM.PopupDynamic:AddItem(_t("options.short.ShowMinimapButton"), false, BOM.SharedState.Minimap, "visible")
    BOM.PopupDynamic:AddItem(_t("options.short.LockMinimapButton"), false, BOM.SharedState.Minimap, "lock")
    BOM.PopupDynamic:AddItem(_t("options.short.LockMinimapButtonDistance"), false, BOM.SharedState.Minimap, "lockDistance")
    BOM.PopupDynamic:AddItem()
  end

  -- --------------------------------------------
  -- Use Profiles checkbox and submenu
  -- --------------------------------------------
  BOM.PopupDynamic:AddItem(L["options.short.UseProfiles"], false, BOM.CharacterState, "UseProfiles")

  if BOM.CharacterState.UseProfiles then
    BOM.PopupDynamic:SubMenu(L["HeaderProfiles"], "subProfiles")
    BOM.PopupDynamic:AddItem(L["profile_auto"], false, BOM.ChooseProfile, "auto")

    for _i, profile in pairs(BOM.ALL_PROFILES) do
      BOM.PopupDynamic:AddItem(L["profile_" .. profile], false, BOM.ChooseProfile, profile)
    end

    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()

  -- --------------------------------------------
  -- Selected spells check on/off
  -- --------------------------------------------
  for i, spell in ipairs(BOM.SelectedSpells) do
    if not spell.isConsumable then
      BOM.PopupDynamic:AddItem(spell.singleLink or spell.singleText,
              "keep",
              spellDefModule:GetProfileSpell(spell.ConfigID),
              "Enable")
    end
  end

  local inBuffGroup -- unused? nil?
  if inBuffGroup then
    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()
  --BOM.PopupDynamic:SubMenu(L["popup.QuickSettings"], "subSettings")
  --
  --for i, set in ipairs(self.behaviourSettings) do
  --  BOM.PopupDynamic:AddItem(self:MakeSettingsRow(BOM.SharedState, set[1]))
  --end
  --
  ---- -------------------------------------------
  ---- Watch in Raid group -> 1 2 3 4 5 6 7 8
  ---- -------------------------------------------
  --BOM.PopupDynamic:AddItem()
  --BOM.PopupDynamic:SubMenu(L["HeaderWatchGroup"], "subGroup")
  --
  --for i = 1, 8 do
  --  BOM.PopupDynamic:AddItem(i, "keep", BomCharacterState.WatchGroup, i)
  --end
  --
  --BOM.PopupDynamic:SubMenu()
  BOM.PopupDynamic:AddItem(L.BtnSettings, false, bomOpenOptions, 1)

  BOM.PopupDynamic:Show(control or "cursor", 0, 0)
end
