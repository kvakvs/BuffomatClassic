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
BUFFOMAT_ADDON = BOM

BOM.BehaviourSettings = {
  { "AutoOpen", true },
  { "InWorld", true },
  { "InPVP", true },
  { "InInstance", true },
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
}

--BOM.TOC_VERSION = GetAddOnMetadata(TOCNAME, "Version") --unused?
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

BOM.CHAT_MSG_PREFIX = "Buffomat: "

---Print a text with "Buffomat: " prefix in the game chat window
---@param t string
function BOM.Print(t)
  DEFAULT_CHAT_FRAME:AddMessage(BOM.CHAT_MSG_PREFIX .. t)
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
---@param var string - variable name
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

    for _i, profile in pairs(BOM.ProfileNames) do
      BOM.PopupDynamic:AddItem(L["profile_" .. profile], false, BOM.ChooseProfile, profile)
    end

    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()

  for i, spell in ipairs(BOM.SelectedSpells) do
    if not spell.isBuff then
      BOM.PopupDynamic:AddItem(spell.singleLink or spell.single,
              "keep",
              BOM.CurrentProfile.Spell[spell.ConfigID],
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

-- Something changed (buff gained possibly?) update all spells and spell tabs
function BOM.OptionsUpdate()
  BOM.ForceUpdate = true
  BOM.UpdateScan()
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

function BOM.OptionsInit()
  BOM.Options.Init(
          function()
            -- doOk
            BOM.Options.DoOk()
            BOM.OptionsUpdate()
          end,
          function()
            -- doCancel
            BOM.Options.DoCancel()
            BOM.OptionsUpdate()
          end,
          function()
            --doDefault
            BOM.Options.DoDefault()
            BOM.SharedState.Minimap.position = 50
            BOM.ResetWindow()
            BOM.OptionsUpdate()
          end
  )

  -- Main
  BOM.Options.AddPanel(BOM.TOC_TITLE, false, true)
  --BOM.Options.AddVersion('|cff00c0ff' .. BOM.TOC_VERSION .. "|r")

  BOM.Options.AddCheckBox(BOM.SharedState.Minimap, "visible", true, L["Cboxshowminimapbutton"])
  BOM.Options.AddCheckBox(BOM.SharedState.Minimap, "lock", false, L["CboxLockMinimapButton"])
  BOM.Options.AddCheckBox(BOM.SharedState.Minimap, "lockDistance", false, L["CboxLockMinimapButtonDistance"])
  BOM.Options.AddSpace()
  BOM.Options.AddCheckBox(BOM.CharacterState, "UseProfiles", false, L["CboxUseProfiles"])
  BOM.Options.AddSpace()

  for i, set in ipairs(BOM.BehaviourSettings) do
    bom_add_checkbox(set[1], set[2])
  end

  BOM.Options.AddSpace()
  bom_add_editbox("MinBuff", 3, 350)
  bom_add_editbox("MinBlessing", 3, 350)
  BOM.Options.AddSpace()
  BOM.Options.AddCategory(L.HeaderRenew)
  BOM.Options.Indent(20)
  bom_add_editbox("Time60", 10)--60s
  bom_add_editbox("Time300", 60)--5m
  bom_add_editbox("Time600", 120)--10m
  bom_add_editbox("Time1800", 300)--30m
  bom_add_editbox("Time3600", 300)--60m
  BOM.Options.Indent(-20)
  BOM.Options.AddSpace()
  BOM.Options.AddButton(L.BtnSettingsSpells, BOM.ShowSpellSettings)

  -- localization

  BOM.Options.AddPanel(L["HeaderCustomLocales"], false, true)
  BOM.Options.SetScale(0.85)
  BOM.Options.AddText(L["MsgLocalRestart"])
  BOM.Options.AddSpace()

  local locales = BOM.locales.enEN
  local t = {}

  for key, value in pairs(locales) do
    table.insert(t, key)
  end

  table.sort(t)

  for i, key in ipairs(t) do
    local col = L[key] ~= locales[key] and "|cffffffff" or "|cffff4040"
    local txt = L[key .. "_org"] ~= "[" .. key .. "_org]" and L[key .. "_org"] or L[key]

    BOM.Options.AddEditBox(BOM.SharedState.CustomLocales, key, "", col .. "[" .. key .. "]", 450, 200, false, locales[key], txt)
  end

  BOM.Options.SetScale(1)

  -- About
  local panel = BOM.Options.AddPanel(L.PanelAbout, false, true)
  panel:SetHyperlinksEnabled(true);
  panel:SetScript("OnHyperlinkEnter", BOM.EnterHyperlink)
  panel:SetScript("OnHyperlinkLeave", BOM.LeaveHyperlink)

  local function bom_add_text(txt)
    BOM.Options.AddText(txt)
  end

  BOM.Options.AddCategory("|cFFFF1C1C" .. GetAddOnMetadata(TOCNAME, "Title") .. " " .. GetAddOnMetadata(TOCNAME, "Version") .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
  BOM.Options.Indent(10)
  BOM.Options.AddText(GetAddOnMetadata(TOCNAME, "Notes"))
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L["HeaderInfo"])
  BOM.Options.Indent(10)
  BOM.Options.AddText(L["AboutInfo"], -20)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L["HeaderUsage"])
  BOM.Options.Indent(10)
  BOM.Options.AddText(L["AboutUsage"], -20)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L["HeaderSlashCommand"])
  BOM.Options.Indent(10)
  BOM.Options.AddText(L["AboutSlashCommand"], -20)
  BOM.Tool.PrintSlashCommand(nil, nil, bom_add_text)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L["HeaderCredits"])
  BOM.Options.Indent(10)
  BOM.Options.AddText(L["AboutCredits"], -20)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L.HeaderSupportedSpells)
  BOM.Options.Indent(20)

  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    if type(spell) == "table" then
      spell.optionText = BOM.Options.AddText("<placeholder>")
    else
      BOM.Options.Indent(-10)
      if LOCALIZED_CLASS_NAMES_MALE[spell] then
        BOM.Options.AddCategory(LOCALIZED_CLASS_NAMES_MALE[spell])
      else
        BOM.Options.AddCategory(L["Header_" .. spell])
      end
      BOM.Options.Indent(10)
    end
  end

  BOM.Options.Indent(-10)
  BOM.Options.AddCategory(L["Header_CANCELBUFF"])
  BOM.Options.Indent(10)

  for i, spell in ipairs(BOM.CancelBuffs) do
    spell.optionText = BOM.Options.AddText("<placeholder>")
  end

  BOM.Options.Indent(-10)
  BOM.Options.AddCategory(" ")
end

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
  BOM.ForceUpdate = true
  BOM.UpdateScan()
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
    BOM.Print("Unknown profile")
  end

  BOM.ClearSkip()
  BOM.PopupDynamic:Wipe()
  BOM.ForceUpdate = true
  BOM.UpdateScan()
end

---When BomCharacterState.WatchGroup has changed, update the buff tab text to show what's
---being buffed. Example: "Buff All", "Buff G3,5-7"...
function bom_update_buff_tab_text()
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

---Called from event handler on Addon Loaded event
---Execution start here
function BOM.Init()
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

  if not BomCharacterState[BOM.ProfileNames[1]] then
    BomCharacterState[BOM.ProfileNames[1]] = {
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

  for i, profil in ipairs(BOM.ProfileNames) do
    if not BomCharacterState[profil] then
      BomCharacterState[profil] = {}
    end
  end

  BOM.SharedState = BomSharedState
  BOM.CharacterState = BomCharacterState
  BOM.CurrentProfile = BomCharacterState[BOM.ProfileNames[1]]

  BOM.LocalizationInit()

  local x, y, w, h = BOM.SharedState.X, BOM.SharedState.Y, BOM.SharedState.Width, BOM.SharedState.Height

  if not x or not y or not w or not h then
    BOM.SaveWindowPosition()
  else
    BomC_MainWindow:ClearAllPoints()
    BomC_MainWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    BomC_MainWindow:SetWidth(w)
    BomC_MainWindow:SetHeight(h)
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
        BOM.ForceUpdate = true
        BOM.UpdateScan()
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

  -- Which groups are watched by the buff scanner - save in character state
  if not BomCharacterState.WatchGroup then
    BomCharacterState.WatchGroup = {}
    for i = 1, 8 do
      BomCharacterState.WatchGroup[i] = true
    end
  end
  bom_update_buff_tab_text()

  _G["BINDING_NAME_MACRO Buff'o'mat"] = L["BtnPerformeBuff"]
  _G["BINDING_HEADER_BUFFOMATHEADER"] = "Buffomat Classic"

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

local function Event_UNIT_POWER_UPDATE(arg1, arg2)
  --UNIT_POWER_UPDATE: "unitTarget", "powerType"
  if arg2 == "MANA" and UnitIsUnit(arg1, "player") then
    if (BOM.PlayerManaMax or 0) <= (UnitPower("player", 0) or 0) then
      BOM.ForceUpdate = true
    end
  end
end

local function Event_GenericUpdate()
  BOM.ForceUpdate = true
end

local function Event_Bag()
  BOM.ForceUpdate = true
  BOM.WipeCachedItems = true

  if BOM.CachedHasItems then
    wipe(BOM.CachedHasItems)
  end
end

local function Event_SpellsChanged()
  BOM.GetSpells()
  BOM.ForceUpdate = true
  BOM.SpellTabsCreatedFlag = false
  BOM.OptionsInsertSpells()
end

local bom_in_party = IsInRaid() or IsInGroup()

local function Event_PartyChanged()
  BOM.PartyUpdateNeeded = true
  BOM.ForceUpdate = true

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
    BOM.ForceUpdate = true
  end
end

local function Event_UNIT_SPELLCAST_START(unit)
  if UnitIsUnit(unit, "player") then
    BOM.PlayerCasting = true
    BOM.ForceUpdate = true
  end
end

local function Event_UNIT_SPELLCAST_STOP(unit)
  if UnitIsUnit(unit, "player") then
    BOM.PlayerCasting = false
    BOM.ForceUpdate = true
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
  BOM.ForceUpdate = true
  BOM.DeclineHasResurrection = true
  BOM.AutoClose()
  if not InCombatLockdown() then
    BomC_ListTab_Button:Disable()
  end
  BOM.BattleCancelBuffs()
end

local function Event_CombatStop()
  BOM.ClearSkip()
  BOM.ForceUpdate = true
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
  BOM.ForceUpdate = true
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
    BOM.ForceUpdate = true
    BOM.UpdateScan()
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
        BOM.ADDSKIP()
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

local bom_last_update_timestamp = 0
local bom_last_modifier
local bom_fps_check = 0
local bom_update_timer_limit = 1.500 --bumped from 0.1 which potentially causes Naxxramas lag?
local bom_slow_count = 0

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
    BOM.ForceUpdate = true
  end

  if BOM.CheckCoolDown then
    local cdtest = GetSpellCooldown(BOM.CheckCoolDown)
    if cdtest == 0 then
      BOM.CheckCoolDown = nil
      BOM.ForceUpdate = true
    end
  end

  if BOM.ScanModifier and bom_last_modifier ~= IsModifierKeyDown() then
    bom_last_modifier = IsModifierKeyDown()
    BOM.ForceUpdate = true
  end

  bom_fps_check = bom_fps_check + 1

  if (BOM.ForceUpdate or BOM.RepeatUpdate)
          and GetTime() - (bom_last_update_timestamp or 0) > bom_update_timer_limit
          and InCombatLockdown() == false
  then
    bom_last_update_timestamp = GetTime()
    bom_fps_check = debugprofilestop()

    BOM.UpdateScan()

    if (debugprofilestop() - bom_fps_check) > 6 and BOM.RepeatUpdate then
      bom_slow_count = bom_slow_count + 1
      if bom_slow_count >= 6 and bom_update_timer_limit < 1 then
        bom_update_timer_limit = 1
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

function BOM.UnitAura(unitId, buffIndex, filter)
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura(unitId, buffIndex, filter)

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
      BOM.ForceUpdate = true

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
  BOM.Tool.RegisterEvent("TAXIMAP_OPENED", Event_TAXIMAP_OPENED)
  BOM.Tool.RegisterEvent("ADDON_LOADED", Event_ADDON_LOADED)
  BOM.Tool.RegisterEvent("UNIT_POWER_UPDATE", Event_UNIT_POWER_UPDATE)
  BOM.Tool.RegisterEvent("PLAYER_STARTED_MOVING", Event_PLAYER_STARTED_MOVING)
  BOM.Tool.RegisterEvent("PLAYER_STOPPED_MOVING", Event_PLAYER_STOPPED_MOVING)
  BOM.Tool.RegisterEvent("PLAYER_TARGET_CHANGED", Event_PLAYER_TARGET_CHANGED)
  BOM.Tool.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Event_COMBAT_LOG_EVENT_UNFILTERED)
  BOM.Tool.RegisterEvent("UI_ERROR_MESSAGE", Event_UI_ERROR_MESSAGE)

  BOM.Tool.RegisterEvent("UNIT_SPELLCAST_START", Event_UNIT_SPELLCAST_START)
  BOM.Tool.RegisterEvent("UNIT_SPELLCAST_STOP", Event_UNIT_SPELLCAST_STOP)
  BOM.Tool.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Event_UNIT_SPELLCAST_errors)
  BOM.Tool.RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", Event_UNIT_SPELLCAST_errors)
  BOM.Tool.RegisterEvent("UNIT_SPELLCAST_FAILED", Event_UNIT_SPELLCAST_errors)

  for i, event in ipairs(EVT_COMBAT_START) do
    BOM.Tool.RegisterEvent(event, Event_CombatStart)
  end
  for i, event in ipairs(EVT_COMBAT_STOP) do
    BOM.Tool.RegisterEvent(event, Event_CombatStop)
  end
  for i, event in ipairs(EVT_LOADING_SCREEN_START) do
    BOM.Tool.RegisterEvent(event, Event_LoadingStart)
  end
  for i, event in ipairs(EVT_LOADING_SCREEN_END) do
    BOM.Tool.RegisterEvent(event, Event_LoadingStop)
  end

  for i, event in ipairs(EVT_SPELLBOOK_CHANGED) do
    BOM.Tool.RegisterEvent(event, Event_SpellsChanged)
  end
  for i, event in ipairs(EVT_PARTY_CHANGED) do
    BOM.Tool.RegisterEvent(event, Event_PartyChanged)
  end
  for i, event in ipairs(EVT_UPDATE) do
    BOM.Tool.RegisterEvent(event, Event_GenericUpdate)
  end
  for i, event in ipairs(EVT_BAG_CHANGED) do
    BOM.Tool.RegisterEvent(event, Event_Bag)
  end
end

local autoHelper = "open"
function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      autoHelper = "KeepClose"
      BOM.ForceUpdate = true
      BOM.UpdateScan()
    end
  end
end

function BOM.ShowWindow(tab)
  if not InCombatLockdown() then
    if not BOM.WindowVisible() then
      BomC_MainWindow:Show()
      autoHelper = "KeepOpen"
    end
    BOM.Tool.SelectTab(BomC_MainWindow, tab or 1)
  end

end

function BOM.WindowVisible()
  return BomC_MainWindow:IsVisible()
end

function BOM.ToggleWindow()
  if BomC_MainWindow:IsVisible() then
    BOM.HideWindow()
  else
    BOM.ForceUpdate = true
    BOM.UpdateScan()
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

function BOM.DoBlessin4gOnClick(self)
  local saved = self._privat_DB[self._privat_Var]

  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.isBlessing then
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
