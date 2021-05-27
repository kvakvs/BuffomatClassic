---@type BuffomatAddon
local TOCNAME, BOM = ...
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

-- global, visible from XML files and from script console and chat commands
---@type BuffomatAddon
BUFFOMAT_ADDON = BOM

BOM.BehaviourSettings = {
  { "AutoOpen", true },
  { "ScanInRestArea", false },
  { "ScanInStealth", false },
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
  { "AutoDismount", true },
  { "AutoStand", true },
  { "AutoDisTravel", true },
  { "BuffTarget", false },
  { "OpenLootable", true },
  { "SelfFirst", false },
  { "DontUseConsumables", false },
  { "SlowerHardware", false },
  --{ "ShowClassicConsumables", true},
  --{ "ShowTBCConsumables", true},
}

BOM.TOC_VERSION = GetAddOnMetadata(TOCNAME, "Version") --used for display in options
BOM.TOC_TITLE = GetAddOnMetadata(TOCNAME, "Title")

BOM.MACRO_ICON = "Ability_Druid_ChallangingRoar"
BOM.MACRO_ICON_DISABLED = "Ability_Druid_DemoralizingRoar"
BOM.MACRO_ICON_FULLPATH = "Interface\\ICONS\\Ability_Druid_ChallangingRoar"

BOM.ICON_FORMAT = "|T%s:0:0:0:0:64:64:4:60:4:60|t"
BOM.PICTURE_FORMAT = "|T%s:0|t"

BOM.MACRO_NAME = "Buff'o'mat"
BOM.MAX_AURAS = 40
BOM.BLESSING_ID = "blessing"
BOM.LOADING_SCREEN_TIMEOUT = 2

local function bom_is_tbc()
  local function get_version()
    return select(4, GetBuildInfo())
  end

  local ui_ver = get_version()
  return ui_ver >= 20000 and ui_ver <= 29999
end

BOM.TBC = bom_is_tbc()

---Print a text with "Buffomat: " prefix in the game chat window
---@param t string
function BOM.Print(t)
  DEFAULT_CHAT_FRAME:AddMessage(BOM.Color("808080", L.CHAT_MSG_PREFIX) .. t)
end

---Print a text with "BomDebug: " prefix in the game chat window
---@param t string
function BOM.Dbg(t)
  DEFAULT_CHAT_FRAME:AddMessage(tostring(GetTime()) .. " " .. BOM.Color("883030", L.CHAT_MSG_PREFIX) .. t)
end

function BOM.Color(hex, text)
  return "|cff" .. hex .. text .. "|r"
end

---Creates a string which will display a picture in a FontString
---@param texture string - path to UI texture file (for example can come from
---  GetContainerItemInfo(bag, slot) or spell info etc
function BOM.FormatTexture(texture)
  return string.format(BOM.ICON_FORMAT, texture)
end

--"UNIT_POWER_UPDATE","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","PLAYER_STARTED_MOVING","PLAYER_STOPPED_MOVING"
local EVT_COMBAT_STOP = { "PLAYER_REGEN_ENABLED" }
local EVT_COMBAT_START = { "PLAYER_REGEN_DISABLED" }
local EVT_LOADING_SCREEN_START = { "LOADING_SCREEN_ENABLED", "PLAYER_LEAVING_WORLD" }
local EVT_LOADING_SCREEN_END = { "PLAYER_ENTERING_WORLD", "LOADING_SCREEN_DISABLED" }

local EVT_UPDATE = {
  "UPDATE_SHAPESHIFT_FORM", "UNIT_AURA", "READY_CHECK",
  "PLAYER_ALIVE", "PLAYER_UNGHOST", "INCOMING_RESURRECT_CHANGED",
  "UNIT_INVENTORY_CHANGED" }

local EVT_BAG_CHANGED = { "BAG_UPDATE_DELAYED", "TRADE_CLOSED" }

local EVT_PARTY_CHANGED = { "GROUP_JOINED", "GROUP_ROSTER_UPDATE",
                            "RAID_ROSTER_UPDATE", "GROUP_LEFT" }

local EVT_SPELLBOOK_CHANGED = { "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB" }

--- Error messages which will make player stand if sitting.
local ERR_NOT_STANDING = {
  ERR_CANTATTACK_NOTSTANDING, SPELL_FAILED_NOT_STANDING,
  ERR_LOOT_NOTSTANDING, ERR_TAXINOTSTANDING }

--- Error messages which will make player dismount if mounted.
local ERR_IS_MOUNTED = {
  ERR_NOT_WHILE_MOUNTED, ERR_ATTACK_MOUNTED,
  ERR_TAXIPLAYERALREADYMOUNTED, SPELL_FAILED_NOT_MOUNTED }

--- Error messages which will make player cancel shapeshift.
local ERR_IS_SHAPESHIFT = {
  ERR_EMBLEMERROR_NOTABARDGEOSET, ERR_CANT_INTERACT_SHAPESHIFTED,
  ERR_MOUNT_SHAPESHIFTED, ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
  ERR_NOT_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,
  SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
  SPELL_FAILED_NOT_SHAPESHIFT, SPELL_NOT_SHAPESHIFTED,
  SPELL_NOT_SHAPESHIFTED_NOSPACE }

---Makes a tuple to pass to the menubuilder to display a settings checkbox in popup menu
---@param db table - BomSharedState reference to read settings from it
---@param var string Variable name from BOM.BehaviourSettings
local function bom_make_popup_menu_settings_row(db, var)
  return L["Cbox" .. var], false, db, var
end

function BOM.Popup(self, minimap)
  local name = (self:GetName() or "nil") .. (minimap and "Minimap" or "Normal")

  if not BOM.PopupDynamic:Wipe(name) then
    return
  end

  if minimap then
    BOM.PopupDynamic:AddItem(L.BtnOpen, false, BOM.ShowWindow)
    BOM.PopupDynamic:AddItem()
    BOM.PopupDynamic:AddItem(L["Cboxshowminimapbutton"], false, BOM.SharedState.Minimap, "visible")
    BOM.PopupDynamic:AddItem(L["CboxLockMinimapButton"], false, BOM.SharedState.Minimap, "lock")
    BOM.PopupDynamic:AddItem(L["CboxLockMinimapButtonDistance"], false, BOM.SharedState.Minimap, "lockDistance")
    BOM.PopupDynamic:AddItem()
  end

  BOM.PopupDynamic:AddItem(L["CboxUseProfiles"], false, BOM.CharacterState, "UseProfiles")

  if BOM.CharacterState.UseProfiles then
    BOM.PopupDynamic:SubMenu(L["HeaderProfiles"], "subProfiles")
    BOM.PopupDynamic:AddItem(L["profile_auto"], false, BOM.ChooseProfile, "auto")

    for _i, profile in pairs(BOM.ALL_PROFILES) do
      BOM.PopupDynamic:AddItem(L["profile_" .. profile], false, BOM.ChooseProfile, profile)
    end

    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()

  for i, spell in ipairs(BOM.SelectedSpells) do
    if not spell.isConsumable then
      BOM.PopupDynamic:AddItem(spell.singleLink or spell.single,
              "keep",
              BOM.GetProfileSpell(spell.ConfigID),
              "Enable")
    end
  end

  if inBuffGroup then
    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(L.BtnQuickSettings, "subSettings")

  for i, set in ipairs(BOM.BehaviourSettings) do
    BOM.PopupDynamic:AddItem(bom_make_popup_menu_settings_row(BOM.SharedState, set[1]))
  end

  -----------------------
  -- Watch in Raid group -> 1 2 3 4 5 6 7 8
  -----------------------
  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(L["HeaderWatchGroup"], "subGroup")

  for i = 1, 8 do
    BOM.PopupDynamic:AddItem(i, "keep", BomCharacterState.WatchGroup, i)
  end

  BOM.PopupDynamic:SubMenu()

  BOM.PopupDynamic:AddItem(L.BtnSettings, false, BOM.Options.Open, 1)
  BOM.PopupDynamic:AddItem(L["BtnCancel"], false)

  BOM.PopupDynamic:Show(self or "cursor", 0, 0)
end

function BOM.BtnClose()
  BOM.HideWindow()
end

function BOM.BtnSettings(self)
  BOM.Popup(self)
end

function BOM.BtnMacro()
  PickupMacro(BOM.MACRO_NAME)
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
function BOM.OptionsUpdate()
  BOM.SetForceUpdate("OptionsUpdate")
  BOM.UpdateScan("OptionsUpdate")
  BOM.UpdateSpellsTab()
  BOM.MyButtonUpdateAll()
  BOM.MinimapButton.UpdatePosition()
  BOM.Options.DoCancel()
end

local function bom_add_checkbox(Var, Init)
  BOM.Options.AddCheckBox(BOM.SharedState, Var, Init, L["Cbox" .. Var])
end

local function bom_add_editbox(Var, Init, width)
  --Options:AddEditBox(DB,Var,Init,TXTLeft,width,widthLeft,onlynumbers,tooltip,suggestion)
  BOM.Options.AddEditBox(BOM.SharedState, Var, Init, L["Ebox" .. Var], 50, width or 150, true)
end

local function bom_options_add_main_panel()
  local opt = BOM.Options
  opt.AddPanel(BOM.TOC_TITLE, false, true)
  opt.AddVersion('Version |cff00c0ff' .. BOM.TOC_VERSION .. "|r")

  opt.AddCheckBox(BOM.SharedState.Minimap, "visible", true, L["Cboxshowminimapbutton"])
  opt.AddCheckBox(BOM.SharedState.Minimap, "lock", false, L["CboxLockMinimapButton"])
  opt.AddCheckBox(BOM.SharedState.Minimap, "lockDistance", false, L["CboxLockMinimapButtonDistance"])
  opt.AddSpace()
  opt.AddCheckBox(BOM.CharacterState, "UseProfiles", false, L["CboxUseProfiles"])
  opt.AddSpace()

  for i, set in ipairs(BOM.BehaviourSettings) do
    bom_add_checkbox(set[1], set[2])
  end

  opt.AddSpace()
  bom_add_editbox("MinBuff", 3, 350)
  bom_add_editbox("MinBlessing", 3, 350)
  opt.AddSpace()
  opt.AddCategory(L.HeaderRenew)
  opt.Indent(20)
  bom_add_editbox("Time60", 10)--60 s rebuff in 10 s
  bom_add_editbox("Time300", 60)--5 m rebuff in 1 min
  bom_add_editbox("Time600", 120)--10 m rebuff in 2 min
  bom_add_editbox("Time1800", 300)--30 m rebuff in 5 min
  bom_add_editbox("Time3600", 300)--60 m rebuff in 5 min
  opt.Indent(-20)
  opt.AddSpace()
  opt.AddButton(L.BtnSettingsSpells, BOM.ShowSpellSettings)
end

local function bom_options_add_localization_panel()
  local opt = BOM.Options

  opt.AddPanel(L["HeaderCustomLocales"], false, true)
  opt.SetScale(0.85)
  opt.AddText(L["MsgLocalRestart"])
  opt.AddSpace()

  local locales = BOM.locales.enEN
  local t = {}

  for key, value in pairs(locales) do
    table.insert(t, key)
  end

  table.sort(t)

  for i, key in ipairs(t) do
    local col = L[key] ~= locales[key] and "|cffffffff" or "|cffff4040"
    local txt = L[key .. "_org"] ~= "[" .. key .. "_org]" and L[key .. "_org"] or L[key]

    opt.AddEditBox(
            BOM.SharedState.CustomLocales,
            key,
            "",
            col .. "[" .. key .. "]",
            450, 200,
            false,
            locales[key],
            txt)
  end

  opt.SetScale(1)
end

local function bom_options_add_about_panel()
  local opt = BOM.Options

  local panel = opt.AddPanel(L.PanelAbout, false, true)
  panel:SetHyperlinksEnabled(true);
  panel:SetScript("OnHyperlinkEnter", BOM.EnterHyperlink)
  panel:SetScript("OnHyperlinkLeave", BOM.LeaveHyperlink)

  local function bom_add_text(txt)
    opt.AddText(txt)
  end

  opt.AddCategory("|cFFFF1C1C" .. GetAddOnMetadata(TOCNAME, "Title")
          .. " " .. GetAddOnMetadata(TOCNAME, "Version")
          .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
  opt.Indent(10)
  opt.AddText(GetAddOnMetadata(TOCNAME, "Notes"))
  opt.Indent(-10)

  opt.AddCategory(L["HeaderInfo"])
  opt.Indent(10)
  opt.AddText(L["AboutInfo"], -20)
  opt.Indent(-10)

  opt.AddCategory(L["HeaderUsage"])
  opt.Indent(10)
  opt.AddText(L["AboutUsage"], -20)
  opt.Indent(-10)

  opt.AddCategory(L["HeaderSlashCommand"])
  opt.Indent(10)
  opt.AddText(L["AboutSlashCommand"], -20)
  BOM.Tool.PrintSlashCommand(nil, nil, bom_add_text)
  opt.Indent(-10)

  opt.AddCategory(L["HeaderCredits"])
  opt.Indent(10)
  opt.AddText(L["AboutCredits"], -20)
  opt.Indent(-10)

  opt.AddCategory(L.HeaderSupportedSpells)
  opt.Indent(20)

  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    if type(spell) == "table" then
      spell.optionText = opt.AddText("<placeholder>")
    else
      opt.Indent(-10)
      if LOCALIZED_CLASS_NAMES_MALE[spell] then
        opt.AddCategory(LOCALIZED_CLASS_NAMES_MALE[spell])
      else
        opt.AddCategory(L["Header_" .. spell])
      end
      opt.Indent(10)
    end
  end

  opt.Indent(-10)
  opt.AddCategory(L["Header_CANCELBUFF"])
  opt.Indent(10)

  for i, spell in ipairs(BOM.CancelBuffs) do
    spell.optionText = opt.AddText("<placeholder>")
  end

  opt.Indent(-10)
  opt.AddCategory(" ")
end

function BOM.OptionsInit()
  local newDoOk = function()
    BOM.Options.DoOk()
    BOM.OptionsUpdate()
  end
  local newDoCancel = function()
    BOM.Options.DoCancel()
    BOM.OptionsUpdate()
  end
  local newDoDefault = function()
    BOM.Options.DoDefault()
    BOM.SharedState.Minimap.position = 50
    BOM.ResetWindow()
    BOM.OptionsUpdate()
  end

  BOM.Options.Init(newDoOk, newDoCancel, newDoDefault)

  bom_options_add_main_panel()
  bom_options_add_localization_panel()
  bom_options_add_about_panel()
end

---Update spell list in options, called from Event_SpellsChanged
function BOM.OptionsInsertSpells()
  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    if type(spell) == "table" and spell.optionText then
      if spell.groupId then
        BOM.Options.EditText(spell.optionText,
                (spell.singleLink or spell.single) .. " / " .. (spell.groupLink or spell.group))
      else
        BOM.Options.EditText(spell.optionText,
                (spell.singleLink or spell.single or spell.ConfigID))
      end
    end
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    if spell.optionText then
      BOM.Options.EditText(spell.optionText,
              (spell.singleLink or spell.single or spell.ConfigID))
    end
  end

  BOM.UpdateSpellsTab()
  BOM.SetForceUpdate("OptionsInsertSpells")
  BOM.UpdateScan("OptionsInsertSpells")
end

---ChooseProfile
---BOM profile selection, using 'auto' by default
---@param profile table
function BOM.ChooseProfile (profile)
  if profile == nil or profil == "" or profile == "auto" then
    BOM.ForceProfile = nil
    BOM.Print("Set profile to auto")

  elseif BOM.CharacterState[profile] then
    BOM.ForceProfile = profile
    BOM.Print("Set profile to " .. profile)

  else
    BOM.Print("Unknown profile: " .. profile)
  end

  BOM.ClearSkip()
  BOM.PopupDynamic:Wipe()
  BOM.SetForceUpdate("ChooseProfile")
  BOM.UpdateScan("ChooseProfile")
end

---When BomCharacterState.WatchGroup has changed, update the buff tab text to show what's
---being buffed. Example: "Buff All", "Buff G3,5-7"...
local function bom_update_buff_tab_text()
  local selected_groups = 0
  local t = BomC_MainWindow.Tabs[1]

  for i = 1, 8 do
    if BomCharacterState.WatchGroup[i] then
      selected_groups = selected_groups + 1
    end
  end

  if selected_groups == 8 then
    t:SetText(L.TabBuff)
    PanelTemplates_TabResize(t, 0)
    return
  end

  if selected_groups == 0 then
    t:SetText(L.TabBuffOnlySelf)
    PanelTemplates_TabResize(t, 0)
    return
  end

  local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
  end

  -- Build comma-separated group list to buff: "G1,2,3,5"...
  local groups = ""
  for i = 1, 8 do
    if BomCharacterState.WatchGroup[i] then
      --If we are adding number i, and previous (i-1) is in the string
      local prev = tostring(i - 1)
      local prev_range = "-" .. tostring(i - 1)

      if ends_with(groups, prev_range) then
        --"1-2" + "3" should become "1-3"
        groups = groups:gsub(prev_range, "") .. "-" .. tostring(i)
      else
        if ends_with(groups, prev) then
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

  t:SetText(L.TabBuff .. " G" .. groups)
  PanelTemplates_TabResize(t, 0)
end

BOM.UpdateBuffTabText = bom_update_buff_tab_text

---Creates small mybutton which toggles group buff setting, next to CAST button
function BOM.CreateSingleBuffButton(parent_frame)
  if BOM.QuickSingleBuff == nil then
    BOM.QuickSingleBuff = BOM.CreateMyButton(
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
            BOM.FormatTexture(BOM.ICON_SELF_CAST_ON) .. " - " .. L.CboxNoGroupBuff
                    .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_SELF_CAST_OFF) .. " - " .. L.CboxGroupBuff)

    BOM.QuickSingleBuff:Show()
  end
end

local function bom_init_ui()
  BomC_ListTab_MessageFrame:SetFading(false);
  BomC_ListTab_MessageFrame:SetFontObject(GameFontNormalSmall);
  BomC_ListTab_MessageFrame:SetJustifyH("LEFT");
  BomC_ListTab_MessageFrame:SetHyperlinksEnabled(true);
  BomC_ListTab_MessageFrame:Clear()
  BomC_ListTab_MessageFrame:SetMaxLines(100)

  BomC_ListTab_Button:SetAttribute("type", "macro")
  BomC_ListTab_Button:SetAttribute("macro", BOM.MACRO_NAME)

  BOM.Tool.OnUpdate(BOM.UpdateTimer)

  BOM.PopupDynamic = BOM.Tool.CreatePopup(BOM.OptionsUpdate)

  BOM.MinimapButton.Init(
          BOM.SharedState.Minimap,
          BOM.MACRO_ICON_FULLPATH,
          function(self, button)
            if button == "LeftButton" then
              BOM.ToggleWindow()
            else
              BOM.Popup(self.button, true)
            end
          end,
          BOM.TOC_TITLE)

  BomC_MainWindow_Title:SetText(
          BOM.FormatTexture(BOM.MACRO_ICON_FULLPATH)
                  .. " "
                  .. L.Buffomat
                  .. " - "
                  .. L.profile_solo)
  --BomC_ListTab_Button:SetText(L["BtnGetMacro"])

  BOM.OptionsInit()
  BOM.PartyUpdateNeeded = true
  BOM.RepeatUpdate = false

  -- Make main frame draggable
  BOM.Tool.EnableMoving(BomC_MainWindow, BOM.SaveWindowPosition)
  BomC_MainWindow:SetMinResize(180, 90)

  BOM.Tool.AddTab(BomC_MainWindow, L.TabBuff, BomC_ListTab, true)
  BOM.Tool.AddTab(BomC_MainWindow, L.TabSpells, BomC_SpellTab, true)
  BOM.Tool.SelectTab(BomC_MainWindow, 1)
end

---Called from event handler on Addon Loaded event
---Execution start here
function BOM.Init()
  BOM.SetupSpells()
  BOM.SetupCancelBuffs()
  BOM.SetupItemCache()

  function SetDefault(db, var, init)
    if db[var] == nil then
      db[var] = init
    end
  end

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

  BOM.LocalizationInit()

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

    BOM.Print("Set " .. var .. " to " .. tostring(DB[var]))
    BOM.OptionsUpdate()
  end

  BOM.Tool.SlashCommand({ "/bom", "/buffomat" }, {
    { "debug", "", {
      { "buff", "", BOM.DebugBuffList },
      { "target", "", BOM.DebugBuffs, "target" },
    },
    },
    { "profile", "", {
      { "%", L["SlashProfile"], BOM.ChooseProfile }
    },
    },
    { "spellbook", L["SlashSpellBook"], BOM.GetSpells },
    { "update", L["SlashUpdate"],
      function()
        BOM.SetForceUpdate()
        BOM.UpdateScan("Macro /bom update")
      end },
    { "updatespellstab", "", BOM.UpdateSpellsTab },
    { "close", L["SlashClose"], BOM.HideWindow },
    { "reset", L["SlashReset"], BOM.ResetWindow },
    { "_checkforerror", "",
      function()
        if not InCombatLockdown() then
          BOM.CheckForError = true
        end
      end },
    { "", L["SlashOpen"], BOM.ShowWindow },
  })

  bom_init_ui()

  -- Which groups are watched by the buff scanner - save in character state
  if not BomCharacterState.WatchGroup then
    BomCharacterState.WatchGroup = {}
    for i = 1, 8 do
      BomCharacterState.WatchGroup[i] = true
    end
  end

  bom_update_buff_tab_text()

  -- Key Binding section header and key translations (see Bindings.XML)
  _G["BINDING_HEADER_BUFFOMATHEADER"] = "Buffomat Classic"
  _G["BINDING_NAME_MACRO Buffomat Classic"] = L["ButtonCastBuff"]
  _G["BINDING_NAME_BUFFOMAT_WINDOW"] = L["ButtonBuffomatWindow"]

  ----Create small toggle button to the right of [Cast <spell>] button
  --BOM.CreateSingleBuffButton(BomC_ListTab) --maybe not created yet?

  print("|cFFFF1C1C Loaded: " .. GetAddOnMetadata(TOCNAME, "Title") .. " "
          .. GetAddOnMetadata(TOCNAME, "Version")
          .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
end

local function Event_ADDON_LOADED(arg1)
  if arg1 == TOCNAME then
    BOM.Init()
  end

  BOM.Tool.AddDataBrocker(
          BOM.MACRO_ICON_FULLPATH,
          function(self, button)
            if button == "LeftButton" then
              BOM.ToggleWindow()
            else
              BOM.Popup(self, true)
            end
          end)
end

local function Event_UNIT_POWER_UPDATE(unitTarget, powerType)
  --UNIT_POWER_UPDATE: "unitTarget", "powerType"
  if powerType == "MANA" and UnitIsUnit(unitTarget, "player") then
    local max_mana = BOM.PlayerManaMax or 0
    local actual_mana = UnitPower("player", 0) or 0

    if max_mana <= actual_mana then
      BOM.SetForceUpdate(nil)
    end
  end
end

local function Event_GenericUpdate()
  BOM.SetForceUpdate()
end

local function Event_Bag()
  BOM.SetForceUpdate()
  BOM.WipeCachedItems = true

  if BOM.CachedHasItems then
    wipe(BOM.CachedHasItems)
  end
end

local function Event_SpellsChanged()
  BOM.GetSpells()
  BOM.SetForceUpdate("Evt Spells Changed")
  BOM.SpellTabsCreatedFlag = false
  BOM.OptionsInsertSpells()
end

local bom_in_party = IsInRaid() or IsInGroup()

local function Event_PartyChanged()
  BOM.PartyUpdateNeeded = true
  BOM.SetForceUpdate("Evt Party Changed")

  -- if in_party changed from true to false, clear the watch groups
  local in_party = IsInRaid() or IsInGroup()
  if bom_in_party ~= in_party then
    if not in_party then
      BOM.MaybeResetWatchGroups()
    end
    bom_in_party = in_party
  end
end

local function Event_UNIT_SPELLCAST_errors(unit)
  if UnitIsUnit(unit, "player") then
    BOM.CheckForError = false
    BOM.SetForceUpdate()
  end
end

local function Event_UNIT_SPELLCAST_START(unit)
  if UnitIsUnit(unit, "player") and not BOM.PlayerCasting then
    BOM.PlayerCasting = "cast"
    BOM.SetForceUpdate()
  end
end

local function Event_UNIT_SPELLCAST_STOP(unit)
  if UnitIsUnit(unit, "player") and BOM.PlayerCasting then
    BOM.PlayerCasting = nil
    BOM.SetForceUpdate()
    BOM.CheckForError = false
  end
end

local function Event_UNIT_SPELLCHANNEL_START(unit)
  if UnitIsUnit(unit, "player") and not BOM.PlayerCasting then
    BOM.PlayerCasting = "channel"
    BOM.SetForceUpdate()
  end
end

local function Event_UNIT_SPELLCHANNEL_STOP(unit)
  if UnitIsUnit(unit, "player") and BOM.PlayerCasting then
    BOM.PlayerCasting = nil
    BOM.SetForceUpdate()
    BOM.CheckForError = false
  end
end

local function Event_PLAYER_STARTED_MOVING()
  BOM.IsMoving = true
end

local function Event_PLAYER_STOPPED_MOVING()
  BOM.IsMoving = false
end

---On combat start will close the UI window and disable the UI. Will cancel the cancelable buffs.
local function Event_CombatStart()
  BOM.SetForceUpdate("Evt Combat Start")
  BOM.DeclineHasResurrection = true
  BOM.AutoClose()
  if not InCombatLockdown() then
    BomC_ListTab_Button:Disable()
  end

  BOM.DoCancelBuffs()
end

local function Event_CombatStop()
  BOM.ClearSkip()
  BOM.SetForceUpdate("Evt Combat Stop")
  BOM.DeclineHasResurrection = true
  BOM.AllowAutOpen()
end

local function Event_LoadingStart()
  BOM.InLoading = true
  BOM.LoadingScreenTimeOut = nil
  Event_CombatStart()
  --print("loading start")
end

local function Event_LoadingStop()
  BOM.LoadingScreenTimeOut = GetTime() + BOM.LOADING_SCREEN_TIMEOUT
  BOM.SetForceUpdate("Evt Loading Stop")
end

---Event_PLAYER_TARGET_CHANGED
---Handle player target change, spells possibly might have changed too.
local function Event_PLAYER_TARGET_CHANGED()
  if not InCombatLockdown() then
    if UnitInParty("target") or UnitInRaid("target") or UnitIsUnit("target", "player") then
      BOM.lastTarget = (UnitFullName("target"))
      BOM.UpdateSpellsTab()

    elseif BOM.lastTarget then
      BOM.lastTarget = nil
      BOM.UpdateSpellsTab()
    end
  else
    BOM.lastTarget = nil
  end

  if not BOM.SharedState.BuffTarget then
    return
  end

  local newName
  if UnitExists("target")
          and UnitCanCooperate("player", "target")
          and UnitIsPlayer("target")
          and not UnitPlayerOrPetInParty("target")
          and not UnitPlayerOrPetInRaid("target")
  then
    newName = UnitName("target")
  end

  if newName ~= BOM.SaveTargetName then
    BOM.SaveTargetName = newName
    BOM.SetForceUpdate("PlayerTargetChanged")
    BOM.UpdateScan("PlayerTargetChanged")
  end

end

---Event_UI_ERROR_MESSAGE
---Will stand if sitting, will dismount if mounted, will cancel shapeshift, if
---shapeshifted while trying to cast a spell and that produces an error message.
---@param errorType table
---@param message table
local function Event_UI_ERROR_MESSAGE(errorType, message)
  if tContains(ERR_NOT_STANDING, message) then
    if BOM.SharedState.AutoStand then
      UIErrorsFrame:Clear()
      DoEmote("STAND")
    end

  elseif tContains(ERR_IS_MOUNTED, message) then
    if BOM.SharedState.AutoDismount then
      UIErrorsFrame:Clear()
      Dismount()
    end

  elseif BOM.SharedState.AutoDisTravel and tContains(ERR_IS_SHAPESHIFT, message) and BOM.CancelShapeShift() then
    UIErrorsFrame:Clear()

  elseif not InCombatLockdown() then
    if BOM.CheckForError then
      if message == SPELL_FAILED_LOWLEVEL then
        BOM.DownGrade()
      else
        BOM.AddMemberToSkipList()
      end
    end
  end

  BOM.CheckForError = false
end

---Event_TAXIMAP_OPENED
---Will dismount player if mounted when opening taxi tab. Will stand and cancel
---shapeshift to be able to talk to the taxi NPC.
local function Event_TAXIMAP_OPENED()
  if IsMounted() then
    Dismount()
  else
    DoEmote("STAND")
    BOM.CancelShapeShift()
  end
end

---PLAYER_LEVEL_UP Event
local function Event_PLAYER_LEVEL_UP(level)
  -- TODO: Rebuild the UI buttons for new spells which appeared due to level up
  --BOM.SetupSpells()
  --BOM.ForceUpdate = true
  --BOM.UpdateScan()
end

-- Update timers for Buffomat checking spells and buffs
-- See option: BOM.SharedState.SlowerHardware
local bom_last_update_timestamp = 0
local bom_last_modifier
local bom_fps_check = 0
local bom_slow_count = 0

---bumped from 0.1 which potentially causes Naxxramas lag?
---Checking BOM.SharedState.SlowerHardware will use bom_slowerhardware_update_timer_limit
local bom_update_timer_limit = 0.500
local bom_slowerhardware_update_timer_limit = 1.500
-- This is written to bom_update_timer_limit if overload is detected in a large raid or slow hardware
local BOM_THROTTLE_TIMER_LIMIT = 1.000
local BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT = 2.000

function BOM.UpdateTimer()
  if BOM.InLoading and BOM.LoadingScreenTimeOut then
    if BOM.LoadingScreenTimeOut > GetTime() then
      --print("prevent buffomat!")
      return
    else
      --print("loading done")
      BOM.InLoading = false
      Event_CombatStop()
    end
  end

  if BOM.MinTimer and BOM.MinTimer < GetTime() then
    --print("MINTIMER!")
    BOM.SetForceUpdate("MinTimer")
  end

  if BOM.CheckCoolDown then
    local cdtest = GetSpellCooldown(BOM.CheckCoolDown)
    if cdtest == 0 then
      BOM.CheckCoolDown = nil
      BOM.SetForceUpdate("CheckCooldown")
    end
  end

  if BOM.ScanModifier and bom_last_modifier ~= IsModifierKeyDown() then
    bom_last_modifier = IsModifierKeyDown()
    BOM.SetForceUpdate("ModifierKeyDown")
  end

  --
  -- Update timers, slow hardware and auto-throttling
  --
  bom_fps_check = bom_fps_check + 1

  local update_timer_limit = bom_update_timer_limit
  if BOM.SharedState.SlowerHardware then
    update_timer_limit = bom_slowerhardware_update_timer_limit
  end

  if (BOM.ForceUpdate or BOM.RepeatUpdate)
          and GetTime() - (bom_last_update_timestamp or 0) > update_timer_limit
          and InCombatLockdown() == false
  then
    bom_last_update_timestamp = GetTime()
    bom_fps_check = debugprofilestop()

    BOM.UpdateScan("Timer")

    -- If updatescan call above took longer than 6 ms, and repeated update, then
    -- bump the slow alarm counter, once it reaches 6 we consider throttling
    if (debugprofilestop() - bom_fps_check) > 6 and BOM.RepeatUpdate then
      bom_slow_count = bom_slow_count + 1

      if bom_slow_count >= 6 and update_timer_limit < 1 then
        bom_update_timer_limit = BOM_THROTTLE_TIMER_LIMIT
        bom_slowerhardware_update_timer_limit = BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT
        BOM.Print("Overwhelmed - entering slow mode!")
      end
    else
      bom_slow_count = 0
    end
  end
end

function BOM.FastUpdateTimer()
  bom_last_update_timestamp = 0
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

local partyCheckMask = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
--  BOM.PlayerBuffs cleanup in scan bom_get_party_members

local function Event_COMBAT_LOG_EVENT_UNFILTERED()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
  spellId, spellName, spellSchool,
  auraType, amount = CombatLogGetCurrentEventInfo()

  if bit.band(destFlags, partyCheckMask) > 0 and destName ~= nil and destName ~= "" then
    --print(event,spellName,bit.band(destFlags,partyCheckMask)>0,bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_MINE)>0)
    if event == "UNIT_DIED" then
      --BOM.PlayerBuffs[destName]=nil -- problem with hunters and fake-deaths!
      --additional check in bom_get_party_members
      --print("dead",destName)
      BOM.SetForceUpdate("Evt UNIT_DIED")

    elseif BOM.SharedState.Duration[spellName] then
      if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
        if event == "SPELL_CAST_SUCCESS" then

        elseif event == "SPELL_AURA_REFRESH" then
          BOM.PlayerBuffs[destName] = BOM.PlayerBuffs[destName] or {}
          BOM.PlayerBuffs[destName][spellName] = GetTime()

        elseif event == "SPELL_AURA_APPLIED" then
          BOM.PlayerBuffs[destName] = BOM.PlayerBuffs[destName] or {}
          if BOM.PlayerBuffs[destName][spellName] == nil then
            BOM.PlayerBuffs[destName][spellName] = GetTime()
          end

        elseif event == "SPELL_AURA_REMOVED" then
          if BOM.PlayerBuffs[destName] and BOM.PlayerBuffs[destName][spellName] then
            BOM.PlayerBuffs[destName][spellName] = nil
          end
        end

      elseif event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED" and event == "SPELL_AURA_REMOVED" then
        if BOM.PlayerBuffs[destName] and BOM.PlayerBuffs[destName][spellName] then
          BOM.PlayerBuffs[destName][spellName] = nil
        end
      end
    end

  end
end

---OnLoad is called when XML frame for the main window is loaded into existence
---BOM.Init() will also be called when the addon is loaded (earlier than this)
function BOM.OnLoad()
  BOM.RegisterEvent("PLAYER_LEVEL_UP", Event_PLAYER_LEVEL_UP)

  BOM.RegisterEvent("TAXIMAP_OPENED", Event_TAXIMAP_OPENED)
  BOM.RegisterEvent("ADDON_LOADED", Event_ADDON_LOADED)
  BOM.RegisterEvent("UNIT_POWER_UPDATE", Event_UNIT_POWER_UPDATE)
  BOM.RegisterEvent("PLAYER_STARTED_MOVING", Event_PLAYER_STARTED_MOVING)
  BOM.RegisterEvent("PLAYER_STOPPED_MOVING", Event_PLAYER_STOPPED_MOVING)
  BOM.RegisterEvent("PLAYER_TARGET_CHANGED", Event_PLAYER_TARGET_CHANGED)
  BOM.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Event_COMBAT_LOG_EVENT_UNFILTERED)
  BOM.RegisterEvent("UI_ERROR_MESSAGE", Event_UI_ERROR_MESSAGE)

  BOM.RegisterEvent("UNIT_SPELLCAST_START", Event_UNIT_SPELLCAST_START)
  BOM.RegisterEvent("UNIT_SPELLCAST_STOP", Event_UNIT_SPELLCAST_STOP)
  BOM.RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Event_UNIT_SPELLCHANNEL_START)
  BOM.RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Event_UNIT_SPELLCHANNEL_STOP)

  BOM.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Event_UNIT_SPELLCAST_errors)
  BOM.RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", Event_UNIT_SPELLCAST_errors)
  BOM.RegisterEvent("UNIT_SPELLCAST_FAILED", Event_UNIT_SPELLCAST_errors)

  -- TODO for TBC: PLAYER_REGEN_DISABLED / ENABLED is sent before/after the combat and protected frames lock up

  for i, event in ipairs(EVT_COMBAT_START) do
    BOM.RegisterEvent(event, Event_CombatStart)
  end
  for i, event in ipairs(EVT_COMBAT_STOP) do
    BOM.RegisterEvent(event, Event_CombatStop)
  end
  for i, event in ipairs(EVT_LOADING_SCREEN_START) do
    BOM.RegisterEvent(event, Event_LoadingStart)
  end
  for i, event in ipairs(EVT_LOADING_SCREEN_END) do
    BOM.RegisterEvent(event, Event_LoadingStop)
  end

  for i, event in ipairs(EVT_SPELLBOOK_CHANGED) do
    BOM.RegisterEvent(event, Event_SpellsChanged)
  end
  for i, event in ipairs(EVT_PARTY_CHANGED) do
    BOM.RegisterEvent(event, Event_PartyChanged)
  end
  for i, event in ipairs(EVT_UPDATE) do
    BOM.RegisterEvent(event, Event_GenericUpdate)
  end
  for i, event in ipairs(EVT_BAG_CHANGED) do
    BOM.RegisterEvent(event, Event_Bag)
  end
end

local autoHelper = "open"
function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      autoHelper = "KeepClose"
      BOM.SetForceUpdate("HideWindow")
      BOM.UpdateScan("HideWindow")
    end
  end
end

function BOM.ShowWindow(tab)
  if not InCombatLockdown() then
    if not BOM.WindowVisible() then
      BomC_MainWindow:Show()
      autoHelper = "KeepOpen"
    else
      BOM.BtnClose()
    end
    BOM.Tool.SelectTab(BomC_MainWindow, tab or 1)
  else
    BOM.Print(L.MsgShowWindowInCombat)
  end
end

function BOM.WindowVisible()
  return BomC_MainWindow:IsVisible()
end

function BOM.ToggleWindow()
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
    if not BOM.WindowVisible() and autoHelper == "open" then
      autoHelper = "close"
      BomC_MainWindow:Show()
      BOM.Tool.SelectTab(BomC_MainWindow, 1)
    end
  end
end

function BOM.AutoClose(x)
  if not InCombatLockdown() and BOM.SharedState.AutoOpen then
    if BOM.WindowVisible() then
      if autoHelper == "close" then
        BomC_MainWindow:Hide()
        autoHelper = "open"
      end
    elseif autoHelper == "KeepClose" then
      autoHelper = "open"
    end
  end
end

function BOM.AllowAutOpen()
  if not InCombatLockdown() and BOM.SharedState.AutoOpen then
    if autoHelper == "KeepClose" then
      autoHelper = "open"
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

function BOM.DoBlessingOnClick(self)
  local saved = self._privat_DB[self._privat_Var]

  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.isBlessing then
      -- TODO: use spell instead of BOM.CurrentProfile.Spell[]
      BOM.CurrentProfile.Spell[spell.ConfigID].Class[self._privat_Var] = false
    end
  end
  self._privat_DB[self._privat_Var] = saved

  BOM.MyButtonUpdateAll()
  BOM.OptionsUpdate()
end

function BOM.MyButtonOnClick(self)
  BOM.OptionsUpdate()
end

-- Convert a lua table into a lua syntactically correct string
--local function table_to_string(tbl)
--  if type(tbl) ~= "table" then
--    return tostring(tbl)
--  end
--
--  local result = "{"
--  for k, v in pairs(tbl) do
--    -- Check the key type (ignore any numerical keys - assume its an array)
--    if type(k) == "string" then
--      result = result .. "[\"" .. k .. "\"]" .. "="
--    end
--
--    -- Check the value type
--    if type(v) == "table" then
--      result = result .. table_to_string(v)
--      --elseif type(v) == "boolean" then
--      --  result = result..tostring(v)
--      --else
--      --  result = result.."\""..v.."\""
--    else
--      result = result .. tostring(v)
--    end
--    result = result .. ", "
--  end
--  -- Remove leading commas from the result
--  if result ~= "" then
--    result = result:sub(1, result:len() - 1)
--  end
--  return result .. "}"
--end
--BOM.DbgTableToString = table_to_string
