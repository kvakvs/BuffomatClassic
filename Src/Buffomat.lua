local TOCNAME, _ = ...

---@class BomBuffomatModule
local buffomatModule = BuffomatModule.DeclareModule("Buffomat") ---@type BomBuffomatModule

local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local eventsModule = BuffomatModule.Import("Events") ---@type BomEventsModule
local languagesModule = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local optionsModule = BuffomatModule.Import("Options") ---@type BomOptionsModule
local optionsPopupModule = BuffomatModule.Import("OptionsPopup") ---@type BomOptionsPopupModule
local taskScanModule = BuffomatModule.Import("TaskScan") ---@type BomTaskScanModule
local toolboxModule = BuffomatModule.Import("Toolbox") ---@type BomToolboxModule
local spellButtonsTabModule = BuffomatModule.Import("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule

---global, visible from XML files and from script console and chat commands
---@class BuffomatAddon
---@field ALL_PROFILES table<string> Lists all buffomat profile names (group, solo... etc)
---@field RESURRECT_CLASS table<string> Classes who can resurrect others
---@field MANA_CLASSES table<string> Classes with mana resource
---@field CLASSIC_ERA string Constant for era classification of a consumable
---@field TBC_ERA string Constant for era classification of a consumable
---@field locales BuffomatTranslations (same as BOM.L)
---@field L BuffomatTranslations (same as BOM.locales)
---@field AllBuffomatSpells table<number, BomSpellDef> All spells known to Buffomat
---@field EnchantList table<number, table<number>> Spell ids mapping to enchant ids
---@field CancelBuffs table<number, BomSpellDef> All spells to be canceled on detection
---@field ItemCache table<number, BomItemCacheElement> Precreated precached items
---@field ActivAura nil|number Spell id of aura if an unique aura was casted (only one can be active)
---@field ActivSeal nil|number Spell id of weapon seal, if an seal-type temporary enchant was used (only one can be active)
---
---@field ForceProfile string|nil Nil will choose profile name automatically, otherwise this profile will be used
---@field ArgentumDawn table Equipped AD trinket: Spell to and zone ids to check
---@field BuffExchangeId table<number, table<number>> Combines spell ids of spellrank flavours into main spell id
---@field BuffIgnoreAll table<number> Having this buff on target excludes the target (phaseshifted imp for example)
---@field CachedHasItems table<string, CachedItem> Items in player's bag
---@field CancelBuffSource string Unit who casted the buff to be auto-canceled
---@field Carrot table Equipped Riding trinket: Spell to and zone ids to check
---@field CheckForError boolean Used by error suppression code
---@field CurrentProfile State Current profile from CharacterState.Profiles
---@field CharacterState CharacterState Copy of state only for the current character, with separate states per profile
---@field SharedState State Copy of state shared with all accounts
---@field DeclineHasResurrection boolean Set to true on combat start, stop, holding Alt, cleared on party update
---@field EnchantToSpell table<number, number> Reverse-maps enchant ids back to spells
---@field ForceTracking number|nil Defines icon id for enforced tracking
---@field ForceUpdate boolean Requests immediate spells/buffs refresh
---@field RepeatUpdate boolean Requests some sort of spells update similar to ForceUpdate
---@field IsMoving boolean Indicated that the player is moving (updated in event handlers)
---@field ItemList table<table<number>> Group different ranks of item together
---@field ItemListSpell table<number, number> Map itemid to spell?
---@field ItemListTarget table<number, string> Remember who casted item buff on you?
---@field lastTarget string|nil Last player's target
---@field ManaLimit number Player max mana
---@field PartyUpdateNeeded boolean Requests player party update
---@field PlayerCasting string|nil Indicates that the player is currently casting (updated in event handlers)
---@field SelectedSpells table<number, BomSpellDef>
---@field cancelForm table<number, number> Spell ids which cancel shapeshift form
---@field SpellIdIsSingle table<number, boolean> Whether spell ids are single buffs
---@field SpellIdtoConfig table<number, number> Maps spell ids to the key id of spell in the AllSpells
---@field SpellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field SpellToSpell table<number, number> Maps spells ids to other spell ids
---@field TBC boolean Whether we are running TBC classic
---@field IsClassic boolean Whether we are running Classic Era or Season of Mastery
---@field WipeCachedItems boolean Command to reset cached items
---@field MinimapButton GPIMinimapButton Minimap button control
---@field legacyOptions BomLegacyUiOptions
---
---@field ICON_PET string
---@field ICON_OPT_ENABLED string
---@field ICON_OPT_DISABLED string
---@field ICON_SELF_CAST_ON string
---@field ICON_SELF_CAST_OFF string
---@field CLASS_ICONS_ATLAS string
---@field CLASS_ICONS_ATLAS_TEX_COORD string
---@field ICON_EMPTY string
---@field ICON_SETTING_ON string
---@field ICON_SETTING_OFF string
---@field ICON_WHISPER_ON string
---@field ICON_WHISPER_OFF string
---@field ICON_BUFF_ON string
---@field ICON_BUFF_OFF string
---@field ICON_DISABLED string
---@field ICON_TARGET_ON string
---@field ICON_TARGET_OFF string
---@field ICON_TARGET_EXCLUDE string
---@field ICON_CHECKED string
---@field ICON_CHECKED_OFF string
---@field ICON_GROUP string
---@field ICON_GROUP_ITEM string
---@field ICON_GROUP_NONE string
---@field ICON_GEAR string
---@field ICON_GEAR string
---@field IconAutoOpenOn string
---@field IconAutoOpenOnCoord table<number>
---@field IconAutoOpenOff string
---@field IconAutoOpenOffCoord table<number>
---@field IconDeathBlockOn string
---@field IconDeathBlockOff string
---@field IconDeathBlockOffCoord table<number>
---@field IconNoGroupBuffOn string
---@field IconNoGroupBuffOnCoord table<number>
---@field IconNoGroupBuffOff string
---@field IconNoGroupBuffOffCoord table<number>
---@field IconSameZoneOn string
---@field IconSameZoneOnCoord table<number>
---@field IconSameZoneOff string
---@field IconSameZoneOffCoord table<number>
---@field IconResGhostOn string
---@field IconResGhostOnCoord table<number>
---@field IconResGhostOff string
---@field IconResGhostOffCoord table<number>
---@field IconReplaceSingleOff string
---@field IconReplaceSingleOffCoord table<number>
---@field IconReplaceSingleOn string
---@field IconReplaceSingleOnCoord table<number>
---@field IconArgentumDawnOff string
---@field IconArgentumDawnOn string
---@field IconArgentumDawnOnCoord table<number>
---@field IconCarrotOff string
---@field IconCarrotOn string
---@field IconCarrotOnCoord table<number>
---@field IconMainHandOff string
---@field IconMainHandOn string
---@field IconMainHandOnCoord table<number>
---@field IconSecondaryHandOff string
---@field IconSecondaryHandOn string
---@field IconSecondaryHandOnCoord table<number>
---@field ICON_TANK string
---@field ICON_TANK_COORD table<number>
---@field ICON_PET string
---@field ICON_PET_COORD table<number>
---@field IconInPVPOff string
---@field IconInPVPOn string
---@field IconInPVPOnCoord table<number>
---@field IconInWorldOff string
---@field IconInWorldOn string
---@field IconInWorldOnCoord table<number>
---@field IconInInstanceOff string
---@field IconInInstanceOn string
---@field IconInInstanceOnCoord table<number>
---@field IconUseRankOff string
---@field IconUseRankOn string
---
---@field QuickSingleBuff BomLegacyControl Button for single/group buff toggling next to cast button
---
---@field SpellId table<string, table<string, number>> Map of spell name to id
---@field ItemId table<string, table<string, number>> Map of item name to id
---@field PopupDynamic BomPopupDynamic

BuffomatAddon = LibStub("AceAddon-3.0"):NewAddon(
        "Buffomat", "AceConsole-3.0", "AceEvent-3.0") ---@type BuffomatAddon
local BOM = BuffomatAddon

--- Addon is running on Classic TBC client
---@type boolean
BOM.TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

--- Addon is running on Classic "Vanilla" client: Means Classic Era and its seasons like SoM
---@type boolean
BOM.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

---Print a text with "BomDebug: " prefix in the game chat window
---@param t string
function BOM.Dbg(t)
  DEFAULT_CHAT_FRAME:AddMessage(tostring(GetTime()) .. " " .. BOM.Color("883030", "BOM") .. t)
end

function BOM.Color(hex, text)
  return "|cff" .. hex .. text .. "|r"
end

---Creates a string which will display a picture in a FontString
---@param texture string - path to UI texture file (for example can come from
---  GetContainerItemInfo(bag, slot) or spell info etc
function BOM.FormatTexture(texture)
  return string.format(constModule.ICON_FORMAT, texture)
end

function BOM.BtnClose()
  BOM.HideWindow()
end

function BOM.BtnSettings(self)
  optionsPopupModule:Setup(self)
end

function BOM.BtnMacro()
  PickupMacro(constModule.MACRO_NAME)
end

function BOM.ScrollMessage(self, delta)
  self:SetScrollOffset(self:GetScrollOffset() + delta * 5);
  self:ResetAllFadeTimes()
end

function BOM.SetForceUpdate(reason)
  --if reason ~= nil then
  --  BOM.Dbg("Set force update: " .. reason)
  --end
  BOM.ForceUpdate = true
end

-- Something changed (buff gained possibly?) update all spells and spell tabs
function buffomatModule:OptionsUpdate()
  BOM.SetForceUpdate("OptionsUpdate")
  BOM.UpdateScan("OptionsUpdate")
  spellButtonsTabModule:UpdateSpellsTab("OptionsUpdate")
  BOM.MyButtonUpdateAll()
  BOM.MinimapButton.UpdatePosition()
  --BOM.legacyOptions.DoCancel()
end

--local function bom_add_checkbox(Var, Init)
--  BOM.legacyOptions.AddCheckBox(BOM.SharedState, Var, Init, L["options.short." .. Var])
--end

--local function bom_add_editbox(Var, Init, width)
--  --Options:AddEditBox(DB,Var,Init,TXTLeft,width,widthLeft,onlynumbers,tooltip,suggestion)
--  BOM.legacyOptions.AddEditBox(BOM.SharedState, Var, Init, L["Ebox" .. Var], 50, width or 150, true)
--end

--local function bom_add_editbox_str(Var, Init, width)
--  --Options:AddEditBox(DB,Var,Init,TXTLeft,width,widthLeft,onlynumbers,tooltip,suggestion)
--  BOM.legacyOptions.AddEditBox(BOM.SharedState, Var, Init, L["Ebox" .. Var], 50, width or 150, false)
--end

--local function bom_options_add_main_panel()
--  local opt = BOM.legacyOptions
--  opt.AddPanel(constModule.TOC_TITLE, false, true)
--  opt.AddVersion('Version |cff00c0ff' .. constModule.TOC_VERSION .. "|r")
--
--  opt.AddCheckBox(BOM.SharedState.Minimap, "visible", true, L["options.short.ShowMinimapButton"])
--  opt.AddCheckBox(BOM.SharedState.Minimap, "lock", false, L["options.short.LockMinimapButton"])
--  opt.AddCheckBox(BOM.SharedState.Minimap, "lockDistance", false, L["options.short.LockMinimapButtonDistance"])
--  opt.AddSpace()
--  opt.AddCheckBox(BOM.CharacterState, "UseProfiles", false, L["options.short.UseProfiles"])
--  opt.AddSpace()
--
--  for i, set in ipairs(optionsPopupModule.BehaviourSettings) do
--    bom_add_checkbox(set[1], set[2])
--  end
--
--  opt.AddSpace()
--  bom_add_editbox_str("UIWindowScale", 1, 350)
--  bom_add_editbox("MinBuff", 3, 350)
--  bom_add_editbox("MinBlessing", 3, 350)
--  opt.AddSpace()
--  opt.AddCategory(L.HeaderRenew)
--  opt.Indent(20)
--  bom_add_editbox("Time60", 10)--60 s rebuff in 10 s
--  bom_add_editbox("Time300", 60)--5 m rebuff in 1 min
--  bom_add_editbox("Time600", 120)--10 m rebuff in 2 min
--  bom_add_editbox("Time1800", 300)--30 m rebuff in 5 min
--  bom_add_editbox("Time3600", 300)--60 m rebuff in 5 min
--  opt.Indent(-20)
--  opt.AddSpace()
--  opt.AddButton(L.BtnSettingsSpells, BOM.ShowSpellSettings)
--end

--local function bom_options_add_localization_panel()
--  local opt = BOM.legacyOptions
--
--  opt.AddPanel(L["HeaderCustomLocales"], false, true)
--  opt.SetScale(0.85)
--  opt.AddText(L["MsgLocalRestart"])
--  opt.AddSpace()
--
--  local locales = BOM.locales.enEN
--  local t = {}
--
--  for key, value in pairs(locales) do
--    table.insert(t, key)
--  end
--
--  table.sort(t)
--
--  for i, key in ipairs(t) do
--    local col = L[key] ~= locales[key] and "|cffffffff" or "|cffff4040"
--    local txt = L[key .. "_org"] ~= "[" .. key .. "_org]" and L[key .. "_org"] or L[key]
--
--    opt.AddEditBox(
--            BOM.SharedState.CustomLocales,
--            key,
--            "",
--            col .. "[" .. key .. "]",
--            450, 200,
--            false,
--            locales[key],
--            txt)
--  end
--
--  opt.SetScale(1)
--end

--local function bom_options_add_about_panel()
--  local opt = BOM.legacyOptions
--
--  local panel = opt.AddPanel(L.PanelAbout, false, true)
--  panel:SetHyperlinksEnabled(true);
--  panel:SetScript("OnHyperlinkEnter", BOM.EnterHyperlink)
--  panel:SetScript("OnHyperlinkLeave", BOM.LeaveHyperlink)
--
--  local function bom_add_text(txt)
--    opt.AddText(txt)
--  end
--
--  opt.AddCategory("|cFFFF1C1C" .. GetAddOnMetadata(TOCNAME, "Title")
--          .. " " .. GetAddOnMetadata(TOCNAME, "Version")
--          .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
--  opt.Indent(10)
--  opt.AddText(GetAddOnMetadata(TOCNAME, "Notes"))
--  opt.Indent(-10)
--
--  opt.AddCategory(L["HeaderInfo"])
--  opt.Indent(10)
--  opt.AddText(L["AboutInfo"], -20)
--  opt.Indent(-10)
--
--  opt.AddCategory(L["HeaderUsage"])
--  opt.Indent(10)
--  opt.AddText(L["AboutUsage"], -20)
--  opt.Indent(-10)
--
--  opt.AddCategory(L["HeaderSlashCommand"])
--  opt.Indent(10)
--  opt.AddText(L["AboutSlashCommand"], -20)
--  BOM.Tool.PrintSlashCommand(nil, nil, bom_add_text)
--  opt.Indent(-10)
--
--  opt.AddCategory(L["HeaderCredits"])
--  opt.Indent(10)
--  opt.AddText(L["AboutCredits"], -20)
--  opt.Indent(-10)
--
--  opt.AddCategory(L.HeaderSupportedSpells)
--  opt.Indent(20)
--
--  for i, spell in ipairs(BOM.AllBuffomatSpells) do
--    if type(spell) == "table" then
--      spell.optionText = opt.AddText("<placeholder>")
--    else
--      opt.Indent(-10)
--      if LOCALIZED_CLASS_NAMES_MALE[spell] then
--        opt.AddCategory(LOCALIZED_CLASS_NAMES_MALE[spell])
--      else
--        opt.AddCategory(L["Header_" .. spell])
--      end
--      opt.Indent(10)
--    end
--  end
--
--  opt.Indent(-10)
--  opt.AddCategory(L["Header_CANCELBUFF"])
--  opt.Indent(10)
--
--  for i, spell in ipairs(BOM.CancelBuffs) do
--    spell.optionText = opt.AddText("<placeholder>")
--  end
--
--  opt.Indent(-10)
--  opt.AddCategory(" ")
--end

function buffomatModule:OptionsInit()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(
          constModule.SHORT_TITLE, optionsModule:CreateOptionsTable(), { })

  self.optionsFrames = {
    general = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
            constModule.SHORT_TITLE, _t("options.OptionsTitle"), nil)
  }
  self.optionsFrames.general.default = function()
    optionsModule:ResetDefaultOptions()
  end

  --local newDoOk = function()
  --  BOM.legacyOptions.DoOk()
  --  BOM.OptionsUpdate()
  --end
  --local newDoCancel = function()
  --  BOM.legacyOptions.DoCancel()
  --  BOM.OptionsUpdate()
  --end
  --local newDoDefault = function()
  --  BOM.legacyOptions.DoDefault()
  --  BOM.SharedState.Minimap.position = 50
  --  BOM.ResetWindow()
  --  BOM.OptionsUpdate()
  --end
  --
  --BOM.legacyOptions.Init(newDoOk, newDoCancel, newDoDefault)

  --bom_options_add_main_panel()
  --bom_options_add_localization_panel()
  --bom_options_add_about_panel()
end

-----Update spell list in options, called from Event_SpellsChanged
--function BOM.OptionsInsertSpells()
--  for i, spell in ipairs(BOM.AllBuffomatSpells) do
--    if type(spell) == "table" and spell.optionText then
--      if spell.groupId then
--        BOM.legacyOptions.EditText(spell.optionText,
--                (spell.singleLink or spell.single) .. " / " .. (spell.groupLink or spell.group))
--      else
--        BOM.legacyOptions.EditText(spell.optionText,
--                (spell.singleLink or spell.single or spell.ConfigID))
--      end
--    end
--  end
--
--  for i, spell in ipairs(BOM.CancelBuffs) do
--    if spell.optionText then
--      BOM.legacyOptions.EditText(spell.optionText,
--              (spell.singleLink or spell.single or spell.ConfigID))
--    end
--  end
----end

---ChooseProfile
---BOM profile selection, using 'auto' by default
---@param profile table
function BOM.ChooseProfile (profile)
  if profile == nil or profil == "" or profile == "auto" then
    BOM.ForceProfile = nil
    BOM:Print("Set profile to auto")

  elseif BOM.CharacterState[profile] then
    BOM.ForceProfile = profile
    BOM:Print("Set profile to " .. profile)

  else
    BOM:Print("Unknown profile: " .. profile)
  end

  BOM.ClearSkip()
  BOM.PopupDynamic:Wipe()
  BOM.SetForceUpdate("ChooseProfile")
  BOM.UpdateScan("ChooseProfile")
end

---When BomCharacterState.WatchGroup has changed, update the buff tab text to show what's
---being buffed. Example: "Buff All", "Buff G3,5-7"...
function buffomatModule:UpdateBuffTabText()
  local selectedGroups = 0
  local t = BomC_MainWindow.Tabs[1]

  for i = 1, 8 do
    if BomCharacterState.WatchGroup[i] then
      selectedGroups = selectedGroups + 1
    end
  end

  if selectedGroups == 8 then
    t:SetText(_t("TabBuff"))
    PanelTemplates_TabResize(t, 0)
    return
  end

  if selectedGroups == 0 then
    t:SetText(_t("TabBuffOnlySelf"))
    PanelTemplates_TabResize(t, 0)
    return
  end

  local function endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
  end

  -- Build comma-separated group list to buff: "G1,2,3,5"...
  local groups = ""
  for i = 1, 8 do
    if BomCharacterState.WatchGroup[i] then
      --If we are adding number i, and previous (i-1) is in the string
      local prev = tostring(i - 1)
      local prev_range = "-" .. tostring(i - 1)

      if endsWith(groups, prev_range) then
        --"1-2" + "3" should become "1-3"
        groups = groups:gsub(prev_range, "") .. "-" .. tostring(i)
      else
        if endsWith(groups, prev) then
          --"1" + "2" should become "1-2"
          groups = groups .. "-" .. tostring(i)
        else
          --Otherwise: append comma (if not empty) and the number
          if #groups > 0 then
            groups = groups .. ","
          end
          groups = groups .. tostring(i)
        end
      end
    end
  end

  -- Set tab name to display groups too: "Buff G1-5" for example
  t:SetText(_t("TabBuff") .. " G" .. groups)
  PanelTemplates_TabResize(t, 0)
end

---Creates small mybutton which toggles group buff setting, next to CAST button
function BOM.CreateSingleBuffButton(parent_frame)
  if BOM.QuickSingleBuff == nil then
    BOM.QuickSingleBuff = BOM.CreateManagedButton(
            parent_frame,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF,
            nil, nil, nil, nil,
            true)
    BOM.QuickSingleBuff:SetPoint("BOTTOMLEFT", parent_frame, "BOTTOMRIGHT", -18, 0);
    BOM.QuickSingleBuff:SetPoint("BOTTOMRIGHT", parent_frame, "BOTTOMRIGHT", -2, 12);
    BOM.QuickSingleBuff:SetVariable(BOM.SharedState, "NoGroupBuff")
    BOM.QuickSingleBuff:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.TooltipText(
            BOM.QuickSingleBuff,
            BOM.FormatTexture(BOM.ICON_SELF_CAST_ON) .. " - " .. _t("options.long.NoGroupBuff")
                    .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_SELF_CAST_OFF) .. " - " .. _t("options.long.GroupBuff"))

    BOM.QuickSingleBuff:Show()
  end
end

function buffomatModule:InitUI()
  BomC_ListTab_MessageFrame:SetFading(false);
  BomC_ListTab_MessageFrame:SetFontObject(GameFontNormalSmall);
  BomC_ListTab_MessageFrame:SetJustifyH("LEFT");
  BomC_ListTab_MessageFrame:SetHyperlinksEnabled(true);
  BomC_ListTab_MessageFrame:Clear()
  BomC_ListTab_MessageFrame:SetMaxLines(100)

  BomC_ListTab_Button:SetAttribute("type", "macro")
  BomC_ListTab_Button:SetAttribute("macro", constModule.MACRO_NAME)

  toolboxModule:OnUpdate(self.UpdateTimer)

  BOM.PopupDynamic = toolboxModule:CreatePopup(buffomatModule.OptionsUpdate)

  BOM.MinimapButton.Init(
          BOM.SharedState.Minimap,
          constModule.BOM_BEAR_ICON_FULLPATH,
          function(self, button)
            if button == "LeftButton" then
              buffomatModule:ToggleWindow()
            else
              optionsPopupModule:Setup(self.button, true)
            end
          end,
          constModule.SHORT_TITLE)

  BomC_MainWindow_Title:SetText(
          BOM.FormatTexture(constModule.BOM_BEAR_ICON_FULLPATH)
                  .. " "
                  .. _t("Buffomat")
                  .. " - "
                  .. _t("profile_solo"))
  --BomC_ListTab_Button:SetText(L["BtnGetMacro"])

  buffomatModule:OptionsInit()
  BOM.PartyUpdateNeeded = true
  BOM.RepeatUpdate = false

  -- Make main frame draggable
  BOM.Tool.EnableMoving(BomC_MainWindow, BOM.SaveWindowPosition)
  BomC_MainWindow:SetMinResize(180, 90)

  toolboxModule:AddTab(BomC_MainWindow, _t("TabBuff"), BomC_ListTab, true)
  toolboxModule:AddTab(BomC_MainWindow, _t("TabSpells"), BomC_SpellTab, true)
  toolboxModule:SelectTab(BomC_MainWindow, 1)
end

---Called from event handler on Addon Loaded event
---Execution start here
function BuffomatAddon:Init()
  languagesModule:SetupTranslations()
  allSpellsModule:SetupSpells()
  allSpellsModule:SetupCancelBuffs()
  --BOM.SetupItemCache()
  taskScanModule:SetupTasklist()

  BOM.Macro = BOM.Class.Macro:new(constModule.MACRO_NAME)

  --function SetDefault(db, var, init)
  --  if db[var] == nil then
  --    db[var] = init
  --  end
  --end

  ---@type table - returns value if not nil, otherwise returns empty table
  local init_val = function(v)
    if not v then
      return {}
    else
      return v
    end
  end

  BomSharedState = init_val(BomSharedState)
  BomSharedState.Minimap = init_val(BomSharedState.Minimap)
  BomSharedState.SpellGreatherEqualThan = init_val(BomSharedState.SpellGreatherEqualThan)
  BomSharedState.CustomLocales = init_val(BomSharedState.CustomLocales)
  BomSharedState.CustomSpells = init_val(BomSharedState.CustomSpells)
  BomSharedState.CustomCancelBuff = init_val(BomSharedState.CustomCancelBuff)
  BomCharacterState = init_val(BomCharacterState)

  if BomCharacterState.Duration then
    BomSharedState.Duration = BomCharacterState.Duration
    BomCharacterState.Duration = nil
  elseif not BomSharedState.Duration then
    BomSharedState.Duration = {}
  end

  if not BomCharacterState[BOM.ALL_PROFILES[1]] then
    BomCharacterState[BOM.ALL_PROFILES[1]] = {
      ["CancelBuff"] = BomCharacterState.CancelBuff,
      ["Spell"]      = BomCharacterState.Spell,
      ["LastAura"]   = BomCharacterState.LastAura,
      ["LastSeal"]   = BomCharacterState.LastSeal,
    }
    BomCharacterState.CancelBuff = nil
    BomCharacterState.Spell = nil
    BomCharacterState.LastAura = nil
    BomCharacterState.LastSeal = nil
  end

  for i, each_profile in ipairs(BOM.ALL_PROFILES) do
    if not BomCharacterState[each_profile] then
      BomCharacterState[each_profile] = {}
    end
  end

  BOM.SharedState = BomSharedState
  BOM.CharacterState = BomCharacterState
  BOM.CurrentProfile = BomCharacterState[BOM.ALL_PROFILES[1]]

  languagesModule:LocalizationInit()

  do
    -- addon window position
    local x, y = BOM.SharedState.X, BOM.SharedState.Y
    local w, h = BOM.SharedState.Width, BOM.SharedState.Height

    if not x or not y or not w or not h then
      BOM.SaveWindowPosition()
    else
      BomC_MainWindow:ClearAllPoints()
      BomC_MainWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
      BomC_MainWindow:SetWidth(w)
      BomC_MainWindow:SetHeight(h)
    end
  end

  BOM.Tool.EnableSize(BomC_MainWindow, 8, nil, function()
    BOM.SaveWindowPosition()
  end)

  -- slash command
  -- Unused?
  local function slash_command_db_set(DB, var, value)
    if value == nil then
      DB[var] = not DB[var]

    elseif tContains({ "true", "1", "enable" }, value) then
      DB[var] = true

    elseif tContains({ "false", "0", "disable" }, value) then
      DB[var] = false
    end

    BOM:Print("Set " .. var .. " to " .. tostring(DB[var]))
    buffomatModule:OptionsUpdate()
  end

  BOM.Tool.SlashCommand({ "/bom", "/buffomat" }, {
    { "debug", "", {
      { "buff", "", BOM.DebugBuffList },
      { "target", "", BOM.DebugBuffs, "target" },
    },
    },
    { "profile", "", {
      { "%", _t("SlashProfile"), BOM.ChooseProfile }
    },
    },
    { "spellbook", _t("SlashSpellBook"), BOM.SetupAvailableSpells },
    { "update", _t("SlashUpdate"),
      function()
        BOM.SetForceUpdate()
        BOM.UpdateScan("Macro /bom update")
      end },
    { "updatespellstab", "", spellButtonsTabModule.UpdateSpellsTab },
    { "close", _t("SlashClose"), BOM.HideWindow },
    { "reset", _t("SlashReset"), BOM.ResetWindow },
    { "_checkforerror", "",
      function()
        if not InCombatLockdown() then
          BOM.CheckForError = true
        end
      end },
    { "", _t("SlashOpen"), BOM.ShowWindow },
  })

  buffomatModule:InitUI()

  -- Which groups are watched by the buff scanner - save in character state
  if not BomCharacterState.WatchGroup then
    BomCharacterState.WatchGroup = {}
    for i = 1, 8 do
      BomCharacterState.WatchGroup[i] = true
    end
  end

  buffomatModule:UpdateBuffTabText()

  -- Key Binding section header and key translations (see Bindings.XML)
  _G["BINDING_HEADER_BUFFOMATHEADER"] = "Buffomat Classic"
  _G["BINDING_NAME_MACRO Buffomat Classic"] = _t("ButtonCastBuff")
  _G["BINDING_NAME_BUFFOMAT_WINDOW"] = _t("ButtonBuffomatWindow")
end

---AceAddon handler
function BuffomatAddon:OnInitialize()
  -- do init tasks here, like loading the Saved Variables,
  -- or setting up slash commands.
end

---AceAddon handler
function BuffomatAddon:OnEnable()
  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize
  self:Init()
  eventsModule:InitEvents()
  self.Tool.AddDataBroker(
          constModule.BOM_BEAR_ICON_FULLPATH,
          function(self, button)
            if button == "LeftButton" then
              buffomatModule:ToggleWindow()
            else
              optionsPopupModule:Setup(self, true)
            end
          end)
end

---AceAddon handler
function BuffomatAddon:OnDisable()
end

local function bomDownGrade()
  if BOM.CastFailedSpell
          and BOM.CastFailedSpell.SkipList
          and BOM.CastFailedSpellTarget then
    local level = UnitLevel(BOM.CastFailedSpellTarget.unitId)

    if level ~= nil and level > -1 then
      if BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] == nil
              or BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] < level
      then
        BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] = level
        BOM.FastUpdateTimer()
        BOM.SetForceUpdate("Downgrade")
        BOM:Print(string.format(_t("MsgDownGrade"),
                BOM.CastFailedSpell.singleText,
                BOM.CastFailedSpellTarget.name))

      elseif BOM.SharedState.SpellGreatherEqualThan[BOM.CastFailedSpellId] >= level then
        BOM.AddMemberToSkipList()
      end
    else
      BOM.AddMemberToSkipList()
    end
  end
end

-- Update timers for Buffomat checking spells and buffs
-- See option: BOM.SharedState.SlowerHardware
buffomatModule.lastUpdateTimestamp = 0
buffomatModule.lastModifierKeyState = false
buffomatModule.fpsCheck = 0
buffomatModule.slowCount = 0

---bumped from 0.1 which potentially causes Naxxramas lag?
---Checking BOM.SharedState.SlowerHardware will use bom_slowerhardware_update_timer_limit
buffomatModule.updateTimerLimit = 0.500
buffomatModule.slowerhardwareUpdateTimerLimit = 1.500
-- This is written to updateTimerLimit if overload is detected in a large raid or slow hardware
buffomatModule.BOM_THROTTLE_TIMER_LIMIT = 1.000
buffomatModule.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT = 2.000

function buffomatModule.UpdateTimer()
  if BOM.InLoading and BOM.LoadingScreenTimeOut then
    if BOM.LoadingScreenTimeOut > GetTime() then
      return
    else
      BOM.InLoading = false
      eventsModule:OnCombatStop()
    end
  end

  if BOM.MinTimer and BOM.MinTimer < GetTime() then
    BOM.SetForceUpdate("MinTimer")
  end

  if BOM.CheckCoolDown then
    local cdtest = GetSpellCooldown(BOM.CheckCoolDown)
    if cdtest == 0 then
      BOM.CheckCoolDown = nil
      BOM.SetForceUpdate("CheckCooldown")
    end
  end

  if BOM.ScanModifier and buffomatModule.lastModifierKeyState ~= IsModifierKeyDown() then
    buffomatModule.lastModifierKeyState = IsModifierKeyDown()
    BOM.SetForceUpdate("ModifierKeyDown")
  end

  --
  -- Update timers, slow hardware and auto-throttling
  --
  buffomatModule.fpsCheck = buffomatModule.fpsCheck + 1

  local updateTimerLimit = buffomatModule.updateTimerLimit
  if BOM.SharedState.SlowerHardware then
    updateTimerLimit = buffomatModule.slowerhardwareUpdateTimerLimit
  end

  if (BOM.ForceUpdate or BOM.RepeatUpdate)
          and GetTime() - (buffomatModule.lastUpdateTimestamp or 0) > updateTimerLimit
          and InCombatLockdown() == false
  then
    buffomatModule.lastUpdateTimestamp = GetTime()
    buffomatModule.fpsCheck = debugprofilestop()

    BOM.UpdateScan("Timer")

    -- If updatescan call above took longer than 6 ms, and repeated update, then
    -- bump the slow alarm counter, once it reaches 6 we consider throttling
    if (debugprofilestop() - buffomatModule.fpsCheck) > 6 and BOM.RepeatUpdate then
      buffomatModule.slowCount = buffomatModule.slowCount + 1

      if buffomatModule.slowCount >= 20 and updateTimerLimit < 1 then
        buffomatModule.updateTimerLimit = buffomatModule.BOM_THROTTLE_TIMER_LIMIT
        buffomatModule.slowerhardwareUpdateTimerLimit = buffomatModule.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT
        BOM:Print("Overwhelmed - entering slow mode!")
      end
    else
      buffomatModule.slowCount = 0
    end
  end
end

function BOM.FastUpdateTimer()
  buffomatModule.lastUpdateTimestamp = 0
end

BOM.PlayerBuffs = {}

---Handles UnitAura WOW API call.
---For spells that are tracked by Buffomat the data is also stored in BOM.PlayerBuffs
---@param unitId string
---@param buffIndex number Index of buff/debuff slot starts 1 max 40?
---@param filter string Filter string like "HELPFUL", "PLAYER", "RAID"... etc
function BOM.UnitAura(unitId, buffIndex, filter)
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable
  , nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer
  , nameplateShowAll, timeMod = UnitAura(unitId, buffIndex, filter)

  if spellId and BOM.AllSpellIds and tContains(BOM.AllSpellIds, spellId) then

    if source ~= nil and source ~= "" and UnitIsUnit(source, "player") then
      if UnitIsUnit(unitId, "player") and duration ~= nil and duration > 0 then
        BOM.SharedState.Duration[name] = duration
      end

      if duration == nil or duration == 0 then
        duration = BOM.SharedState.Duration[name] or 0
      end

      if duration > 0 and (expirationTime == nil or expirationTime == 0) then
        local destName = (UnitFullName(unitId))

        if BOM.PlayerBuffs[destName] and BOM.PlayerBuffs[destName][name] then
          expirationTime = BOM.PlayerBuffs[destName][name] + duration

          if expirationTime <= GetTime() then
            BOM.PlayerBuffs[destName][name] = GetTime()
            expirationTime = GetTime() + duration
          end
        end
      end

      if expirationTime == 0 then
        duration = 0
      end
    end

  end

  return name, icon, count, debuffType, duration, expirationTime, source, isStealable,
  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
end

buffomatModule.autoHelper = "open"

function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      buffomatModule.autoHelper = "KeepClose"
      BOM.SetForceUpdate("HideWindow")
      BOM.UpdateScan("HideWindow")
    end
  end
end

function BOM.ShowWindow(tab)
  if not InCombatLockdown() then
    if not BOM.WindowVisible() then
      BomC_MainWindow:Show()
      BomC_MainWindow:SetScale(tonumber(BOM.SharedState.UIWindowScale) or 1.0)
      buffomatModule.autoHelper = "KeepOpen"
    else
      BOM.BtnClose()
    end
    toolboxModule:SelectTab(BomC_MainWindow, tab or 1)
  else
    BOM:Print(_t("ActionInCombatError"))
  end
end

function BOM.WindowVisible()
  return BomC_MainWindow:IsVisible()
end

function buffomatModule:ToggleWindow()
  if BomC_MainWindow:IsVisible() then
    BOM.HideWindow()
  else
    BOM.SetForceUpdate("ToggleWindow")
    BOM.UpdateScan("ToggleWindow")
    BOM.ShowWindow()
  end
end

function BOM.AutoOpen()
  if not InCombatLockdown() and BOM.SharedState.AutoOpen then
    if not BOM.WindowVisible() and buffomatModule.autoHelper == "open" then
      buffomatModule.autoHelper = "close"
      BomC_MainWindow:Show()
      BomC_MainWindow:SetScale(tonumber(BOM.SharedState.UIWindowScale) or 1.0)
      toolboxModule:SelectTab(BomC_MainWindow, 1)
    end
  end
end

function BOM.AutoClose(x)
  if not InCombatLockdown() and BOM.SharedState.AutoOpen then
    if BOM.WindowVisible() then
      if buffomatModule.autoHelper == "close" then
        BomC_MainWindow:Hide()
        buffomatModule.autoHelper = "open"
      end
    elseif buffomatModule.autoHelper == "KeepClose" then
      buffomatModule.autoHelper = "open"
    end
  end
end

function BOM.AllowAutOpen()
  if not InCombatLockdown() and BOM.SharedState.AutoOpen then
    if buffomatModule.autoHelper == "KeepClose" then
      buffomatModule.autoHelper = "open"
    end
  end
end

function BOM.SaveWindowPosition()
  BOM.SharedState.X = BomC_MainWindow:GetLeft()
  BOM.SharedState.Y = BomC_MainWindow:GetTop()
  BOM.SharedState.Width = BomC_MainWindow:GetWidth()
  BOM.SharedState.Height = BomC_MainWindow:GetHeight()
end

function BOM.ResetWindow()
  BomC_MainWindow:ClearAllPoints()
  BomC_MainWindow:SetPoint("Center", UIParent, "Center", 0, 0)
  BomC_MainWindow:SetWidth(200)
  BomC_MainWindow:SetHeight(200)
  BOM.SaveWindowPosition()
  BOM.ShowWindow(1)
  BOM:Print("Window position is reset.")
end

local function perform_who_request(name)
  DEFAULT_CHAT_FRAME.editBox:SetText("/who " .. name)
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox)
end

local function perform_whisper_request(name)
  ChatFrame_OpenChat("/w " .. name .. " ")
end

function BOM.EnterHyperlink(self, link, text)
  --print(link,text)
  local part = BOM.Tool.Split(link, ":")
  if part[1] == "spell" or part[1] == "unit" or part[1] == "item" then
    GameTooltip_SetDefaultAnchor(BomC_Tooltip, UIParent)
    BomC_Tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
    BomC_Tooltip:ClearLines()
    BomC_Tooltip:SetHyperlink(link)
    BomC_Tooltip:Show()
  end
end

function BOM.LeaveHyperlink(self)
  BomC_Tooltip:Hide()
end

function BOM.ClickHyperlink(self, link)
  local part = BOM.Tool.Split(link, ":")
  if part[1] == "unit" then
    if IsShiftKeyDown() then
      perform_who_request(part[3])
      --SendWho( req.name )
    else
      perform_whisper_request(part[3])
    end
  end
end

function BOM.DebugBuffs(dest)
  dest = dest or "player"

  print("LastTracking:", BOM.CharacterState.LastTracking, " ")
  print("ForceTracking:", BOM.ForceTracking, " ")
  print("ActivAura:", BOM.ActivAura, " ")
  print("LastAura:", BOM.CurrentProfile.LastAura, " ")
  print("ActivSeal:", BOM.ActivSeal, " ")
  print("LastSeal:", BOM.CurrentProfile.LastSeal, " ")
  print("Shapeshift:", GetShapeshiftFormID(), " ")
  print("Weaponenchantment:", GetWeaponEnchantInfo())

  --local name, icon, count, debuffType, duration, expirationTime, source,
  --isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff,
  --castByPlayer, nameplateShowAll, timeMod
  for buffIndex = 1, 40 do
    local name, icon, count, debuffType, duration, expirationTime, source,
    isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff,
    castByPlayer, nameplateShowAll, timeMod = BOM.UnitAura(dest, buffIndex, "HELPFUL")

    if name or icon or count or debuffType then
      print("Help:", name, spellId, duration, expirationTime, source, (expirationTime or 0) - GetTime())
    end
  end -- for 40 buffs
end

function BOM.DebugBuffList()
  print("PlayerBuffs stored ", #BOM.PlayerBuffs)

  for name, spellist in pairs(BOM.PlayerBuffs) do
    print(name)

    for spellname, ti in pairs(spellist) do
      print(name, spellname, ti, GetTime() - ti)
    end
  end
end

function BOM.ShowSpellSettings()
  InterfaceOptionsFrame:Hide()
  GameMenuFrame:Hide()
  BOM.ShowWindow(2)
end

function BOM.MyButtonOnClick(self)
  buffomatModule:OptionsUpdate()
end
