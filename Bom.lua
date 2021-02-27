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

--BOM.IsDebug=true

BOM.Version = GetAddOnMetadata(TOCNAME, "Version")
BOM.Title = GetAddOnMetadata(TOCNAME, "Title")

BOM.Icon = "Ability_Druid_ChallangingRoar"
BOM.IconOff = "Ability_Druid_DemoralizingRoar"
BOM.FullIcon = "Interface\\ICONS\\Ability_Druid_ChallangingRoar"
BOM.TxtEscapeIcon = "|T%s:0:0:0:0:64:64:4:60:4:60|t"
BOM.TxtEscapePicture = "|T%s:0|t"
BOM.MSGPREFIX = "BOM: "
BOM.MACRONAME = "Buff'o'mat"
BOM.MAXAURAS = 40
BOM.BLESSINGID = "blessing"
BOM.LOADINGSCREENTIMEOUT = 2


--"UNIT_POWER_UPDATE","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","PLAYER_STARTED_MOVING","PLAYER_STOPPED_MOVING"
local CombatEventStop = { "PLAYER_REGEN_ENABLED" }
local CombatEventStart = { "PLAYER_REGEN_DISABLED" }
local LoadingScreenStartEvent = { "LOADING_SCREEN_ENABLED", "PLAYER_LEAVING_WORLD" }
local LoadingScreenStopEvent = { "PLAYER_ENTERING_WORLD", "LOADING_SCREEN_DISABLED" }
local UpdateOnEvent = { "UPDATE_SHAPESHIFT_FORM", "UNIT_AURA", "READY_CHECK",
                        "PLAYER_ALIVE", "PLAYER_UNGHOST", "INCOMING_RESURRECT_CHANGED",
                        "UNIT_INVENTORY_CHANGED" }
local BagOnEvent = { "BAG_UPDATE_DELAYED", "TRADE_CLOSED" }
local PartyChangeEvent = { "GROUP_JOINED", "GROUP_ROSTER_UPDATE",
                           "RAID_ROSTER_UPDATE", "GROUP_LEFT" }
local SpellChangedEvent = { "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB" }

--- Error messages which will make player stand if sitting.
local ErrStand = { ERR_CANTATTACK_NOTSTANDING, SPELL_FAILED_NOT_STANDING,
                   ERR_LOOT_NOTSTANDING, ERR_TAXINOTSTANDING }

--- Error messages which will make player dismount if mounted.
local ErrMounted = { ERR_NOT_WHILE_MOUNTED, ERR_ATTACK_MOUNTED,
                     ERR_TAXIPLAYERALREADYMOUNTED, SPELL_FAILED_NOT_MOUNTED }

--- Error messages which will make player cancel shapeshift.
local ErrShapeShift = { ERR_EMBLEMERROR_NOTABARDGEOSET, ERR_CANT_INTERACT_SHAPESHIFTED,
                        ERR_MOUNT_SHAPESHIFTED, ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
                        ERR_NOT_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,
                        SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
                        SPELL_FAILED_NOT_SHAPESHIFT, SPELL_NOT_SHAPESHIFTED,
                        SPELL_NOT_SHAPESHIFTED_NOSPACE }

local function get_popup_db(db, var)
  return L["Cbox" .. var], false, db, var
end

function BOM.Popup(self, minimap)
  if not BOM.PopupDynamic:Wipe((self:GetName() or "nil") .. (minimap and "Minimap" or "Normal")) then
    return
  end

  if minimap then
    BOM.PopupDynamic:AddItem(L.BtnOpen, false, BOM.ShowWindow)
    BOM.PopupDynamic:AddItem()
    BOM.PopupDynamic:AddItem(L["Cboxshowminimapbutton"], false, BOM.DB.Minimap, "visible")
    BOM.PopupDynamic:AddItem(L["CboxLockMinimapButton"], false, BOM.DB.Minimap, "lock")
    BOM.PopupDynamic:AddItem(L["CboxLockMinimapButtonDistance"], false, BOM.DB.Minimap, "lockDistance")
    BOM.PopupDynamic:AddItem()
  end

  BOM.PopupDynamic:AddItem(L["CboxUseProfiles"], false, BOM.DBChar, "UseProfiles")

  if BOM.DBChar.UseProfiles then
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
    BOM.PopupDynamic:AddItem(get_popup_db(BOM.DB, set[1]))
  end

  -----------------------
  -- Watch in Raid group -> 1 2 3 4 5 6 7 8
  -----------------------
  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(L["HeaderWatchGroup"], "subGroup")

  for i = 1, 8 do
    BOM.PopupDynamic:AddItem(i, "keep", BOM.WatchGroup, i)
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
  PickupMacro(BOM.MACRONAME)
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
  BOM.Options.AddCheckBox(BOM.DB, Var, Init, L["Cbox" .. Var])
end

local function bom_add_editbox(Var, Init, width)
  --Options:AddEditBox(DB,Var,Init,TXTLeft,width,widthLeft,onlynumbers,tooltip,suggestion)
  BOM.Options.AddEditBox(BOM.DB, Var, Init, L["Ebox" .. Var], 50, width or 150, true)
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
            BOM.DB.Minimap.position = 50
            BOM.ResetWindow()
            BOM.OptionsUpdate()
          end
  )

  -- Main
  BOM.Options.AddPanel(BOM.Title, false, true)
  --BOM.Options.AddVersion('|cff00c0ff' .. BOM.Version .. "|r")

  BOM.Options.AddCheckBox(BOM.DB.Minimap, "visible", true, L["Cboxshowminimapbutton"])
  BOM.Options.AddCheckBox(BOM.DB.Minimap, "lock", false, L["CboxLockMinimapButton"])
  BOM.Options.AddCheckBox(BOM.DB.Minimap, "lockDistance", false, L["CboxLockMinimapButtonDistance"])
  BOM.Options.AddSpace()
  BOM.Options.AddCheckBox(BOM.DBChar, "UseProfiles", false, L["CboxUseProfiles"])
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

    BOM.Options.AddEditBox(BOM.DB.CustomLocales, key, "", col .. "[" .. key .. "]", 450, 200, false, locales[key], txt)
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
    DEFAULT_CHAT_FRAME:AddMessage(BOM.MSGPREFIX .. "Set profile to auto")

  elseif BOM.DBChar[profile] then
    BOM.ForceProfile = profile
    DEFAULT_CHAT_FRAME:AddMessage(BOM.MSGPREFIX .. "Set profile to " .. profile)

  else
    DEFAULT_CHAT_FRAME:AddMessage(BOM.MSGPREFIX .. "Unknown profile")
  end

  BOM.ClearSkip()
  BOM.PopupDynamic:Wipe()
  BOM.ForceUpdate = true
  BOM.UpdateScan()
end

---Start from here
function BOM.Init()
  function SetDefault(db, var, init)
    if db[var] == nil then
      db[var] = init
    end
  end

  if not BomSharedState then
    BomSharedState = {}
  end
  if not BomSharedState.Minimap then
    BomSharedState.Minimap = {}
  end
  if not BomSharedState.SpellGreatherEqualThan then
    BomSharedState.SpellGreatherEqualThan = {}
  end
  if not BomSharedState.CustomLocales then
    BomSharedState.CustomLocales = {}
  end
  if not BomSharedState.CustomSpells then
    BomSharedState.CustomSpells = {}
  end
  if not BomSharedState.CustomCancelBuff then
    BomSharedState.CustomCancelBuff = {}
  end

  if not BomCharacterState then
    BomCharacterState = {}
  end
  --if not BomCharacterState.Duration then BomCharacterState.Duration={} end
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

  BOM.DB = BomSharedState
  BOM.DBChar = BomCharacterState
  BOM.CurrentProfile = BomCharacterState[BOM.ProfileNames[1]]

  BOM.LocalizationInit()

  local x, y, w, h = BOM.DB.X, BOM.DB.Y, BOM.DB.Width, BOM.DB.Height

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

    DEFAULT_CHAT_FRAME:AddMessage(BOM.MSGPREFIX .. "Set " .. var .. " to " .. tostring(DB[var]))

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
  BomC_ListTab_Button:SetAttribute("macro", BOM.MACRONAME)

  BOM.Tool.OnUpdate(BOM.UpdateTimer)

  BOM.PopupDynamic = BOM.Tool.CreatePopup(BOM.OptionsUpdate)

  BOM.MinimapButton.Init(
          BOM.DB.Minimap,
          BOM.FullIcon,
          function(self, button)
            if button == "LeftButton" then
              BOM.ToggleWindow()
            else
              BOM.Popup(self.button, true)
            end
          end,
          BOM.Title)

  BomC_MainWindow_Title:SetText(
          string.format(BOM.TxtEscapeIcon, BOM.FullIcon) .. " Buffomat - " .. L.profile_solo)
  --BomC_ListTab_Button:SetText(L["BtnGetMacro"])

  BOM.OptionsInit()
  BOM.PartyUpdateNeeded = true
  BOM.RepeatUpdate = false

  BOM.Tool.EnableMoving(BomC_MainWindow, BOM.SaveWindowPosition)

  BomC_MainWindow:SetMinResize(290, 75)

  BOM.Tool.AddTab(BomC_MainWindow, L.TabBuff, BomC_ListTab, true)
  BOM.Tool.AddTab(BomC_MainWindow, L.TabSpells, BomC_SpellTab, true)
  --BOM.Tool.AddTab(BomC_MainWindow, L.TabItems, BomC_ItemTab, true)
  --BOM.Tool.AddTab(BomC_MainWindow, L.TabBehaviour, BomC_BehaviourTab, true)
  BOM.Tool.SelectTab(BomC_MainWindow, 1)

  BOM.WatchGroup = {}
  for i = 1, 8 do
    BOM.WatchGroup[i] = true
  end

  _G["BINDING_NAME_MACRO Buff'o'mat"] = L["BtnPerformeBuff"]
  _G["BINDING_HEADER_BUFFOMATHEADER"] = "Buffomat"

  print("|cFFFF1C1C Loaded: " .. GetAddOnMetadata(TOCNAME, "Title") .. " "
          .. GetAddOnMetadata(TOCNAME, "Version")
          .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))

end

local function Event_ADDON_LOADED(arg1)
  if arg1 == TOCNAME then
    BOM.Init()
  end

  BOM.Tool.AddDataBrocker(
          BOM.FullIcon,
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

local function Event_PartyChanged()
  BOM.PartyUpdateNeeded = true
  BOM.ForceUpdate = true
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
  BOM.LoadingScreenTimeOut = GetTime() + BOM.LOADINGSCREENTIMEOUT
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

  if not BOM.DB.BuffTarget then
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
  if tContains(ErrStand, message) then
    if BOM.DB.AutoStand then
      UIErrorsFrame:Clear()
      DoEmote("STAND")
    end

  elseif tContains(ErrMounted, message) then
    if BOM.DB.AutoDismount then
      UIErrorsFrame:Clear()
      Dismount()
    end

  elseif BOM.DB.AutoDisTravel and tContains(ErrShapeShift, message) and BOM.CancelShapeShift() then
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

local LastUpdateTimer = 0
local lastModifier
local fpsCheck = 0
local UpdateTimerLimit = 0.100
local SlowCount = 0

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

  if BOM.ScanModifier and LastModifier ~= IsModifierKeyDown() then
    LastModifier = IsModifierKeyDown()
    BOM.ForceUpdate = true
  end

  fpsCheck = fpsCheck + 1

  if (BOM.ForceUpdate or BOM.RepeatUpdate) and GetTime() - (LastUpdateTimer or 0) > UpdateTimerLimit then

    --print( GetTime()-LastUpdateTimer)
    LastUpdateTimer = GetTime()
    fpsCheck = debugprofilestop()
    BOM.UpdateScan()
    --BomC_MainWindow_Title:SetText((debugprofilestop()-fpsCheck).."-".. (BOM.ForceUpdate and "true" or "false"))
    if (debugprofilestop() - fpsCheck) > 6 and BOM.RepeatUpdate then
      SlowCount = SlowCount + 1
      if SlowCount >= 6 and UpdateTimerLimit < 1 then
        UpdateTimerLimit = 1
        print(BOM.MSGPREFIX .. "Enter slow mode!")
      end

    else
      SlowCount = 0
      --print(debugprofilestop()-fpsCheck)
    end
  end
end
function BOM.FastUpdateTimer()
  LastUpdateTimer = 0
end

BOM.PlayerBuffs = {}

function BOM.UnitAura(unitId, buffIndex, filter)
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura(unitId, buffIndex, filter)

  if spellId and BOM.AllSpellIds and tContains(BOM.AllSpellIds, spellId) then

    if source ~= nil and source ~= "" and UnitIsUnit(source, "player") then
      if UnitIsUnit(unitId, "player") and duration ~= nil and duration > 0 then
        BOM.DB.Duration[name] = duration
      end

      if duration == nil or duration == 0 then
        duration = BOM.DB.Duration[name] or 0
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
--  BOM.PlayerBuffs cleanup in scan BOM.GetPartyMembers()

local function Event_COMBAT_LOG_EVENT_UNFILTERED()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
  spellId, spellName, spellSchool,
  auraType, amount = CombatLogGetCurrentEventInfo()

  if bit.band(destFlags, partyCheckMask) > 0 and destName ~= nil and destName ~= "" then
    --print(event,spellName,bit.band(destFlags,partyCheckMask)>0,bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_MINE)>0)
    if event == "UNIT_DIED" then
      --BOM.PlayerBuffs[destName]=nil -- problem with hunters and fake-deaths!
      --additional check in BOM.GetPartyMembers()
      --print("dead",destName)
      BOM.ForceUpdate = true

    elseif BOM.DB.Duration[spellName] then
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

function BOM.OnLoad()
  --print("internal load")

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

  for i, event in ipairs(CombatEventStart) do
    BOM.Tool.RegisterEvent(event, Event_CombatStart)
  end
  for i, event in ipairs(CombatEventStop) do
    BOM.Tool.RegisterEvent(event, Event_CombatStop)
  end
  for i, event in ipairs(LoadingScreenStartEvent) do
    BOM.Tool.RegisterEvent(event, Event_LoadingStart)
  end
  for i, event in ipairs(LoadingScreenStopEvent) do
    BOM.Tool.RegisterEvent(event, Event_LoadingStop)
  end

  for i, event in ipairs(SpellChangedEvent) do
    BOM.Tool.RegisterEvent(event, Event_SpellsChanged)
  end
  for i, event in ipairs(PartyChangeEvent) do
    BOM.Tool.RegisterEvent(event, Event_PartyChanged)
  end
  for i, event in ipairs(UpdateOnEvent) do
    BOM.Tool.RegisterEvent(event, Event_GenericUpdate)
  end
  for i, event in ipairs(BagOnEvent) do
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
  if not InCombatLockdown() and BOM.DB.AutoOpen then
    if not BOM.WindowVisible() and autoHelper == "open" then
      autoHelper = "close"
      BomC_MainWindow:Show()
      BOM.Tool.SelectTab(BomC_MainWindow, 1)
    end
  end
end

function BOM.AutoClose(x)
  if not InCombatLockdown() and BOM.DB.AutoOpen then
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
  if not InCombatLockdown() and BOM.DB.AutoOpen then
    if autoHelper == "KeepClose" then
      autoHelper = "open"
    end
  end
end

function BOM.SaveWindowPosition()
  BOM.DB.X = BomC_MainWindow:GetLeft()
  BOM.DB.Y = BomC_MainWindow:GetTop()
  BOM.DB.Width = BomC_MainWindow:GetWidth()
  BOM.DB.Height = BomC_MainWindow:GetHeight()
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

  print("LastTracking:", BOM.DBChar.LastTracking, " ")
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

BOM.IconOptionEnabled = "Interface\\Buttons\\UI-CheckBox-Check"
BOM.IconOptionDisabled = "Interface\\Buttons\\UI-CheckBox-Up"

BOM.IconSelfCastOn = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon"
BOM.IconSelfCastOff = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon"

BOM.IconClasses = BOM.Tool.IconClassTextureWithoutBorder
BOM.IconClassesCoord = BOM.Tool.IconClassTextureCoord
BOM.IconEmpty = "Interface\\Buttons\\UI-MultiCheck-Disabled"

BOM.IconSettingOn = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
BOM.IconSettingOff = BOM.IconEmpty

BOM.IconWhisperOn = "Interface\\Buttons\\UI-GuildButton-MOTD-Up"
BOM.IconWhisperOff = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled"

BOM.IconBuffOff = BOM.IconEmpty
BOM.IconBuffOn = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"

--"Interface\\Buttons\\UI-CheckBox-Up"
BOM.IconDisabled = "Interface\\FriendsFrame\\StatusIcon-DnD"
--"Interface\\COMMON\\VOICECHAT-MUTED"
BOM.IconTargetOn = "Interface\\CURSOR\\Crosshairs"
BOM.IconTargetOff = BOM.IconEmpty
BOM.IconChecked = "Interface\\Buttons\\UI-CheckBox-Check"
BOM.IconUnChecked = BOM.IconEmpty
BOM.IconGroup = "Interface\\ICONS\\Achievement_GuildPerk_EverybodysFriend"
BOM.IconGroupItem = "Interface\\Buttons\\UI-PageButton-Background"
BOM.IconGroupNone = BOM.IconEmpty
BOM.IconGear = "Interface\\ICONS\\INV_Misc_Gear_01"

BOM.IconAutoOpenOn = "Interface\\LFGFRAME\\BattlenetWorking1"
BOM.IconAutoOpenOnCoord = { 0.2, 0.8, 0.2, 0.8 }
BOM.IconAutoOpenOff = "Interface\\LFGFRAME\\BattlenetWorking4"
BOM.IconAutoOpenOffCoord = { 0.2, 0.8, 0.2, 0.8 }
BOM.IconDeathBlockOn = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8"
BOM.IconDeathBlockOff = "Interface\\ICONS\\Spell_Holy_ArcaneIntellect"--INV_Enchant_DustVision"
BOM.IconDeathBlockOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconNoGroupBuffOn = BOM.IconSelfCastOn
BOM.IconNoGroupBuffOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconNoGroupBuffOff = BOM.IconSelfCastOff
BOM.IconNoGroupBuffOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconSameZoneOn = "Interface\\ICONS\\INV_Misc_Map_01"
BOM.IconSameZoneOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconSameZoneOff = "Interface\\ICONS\\INV_Scroll_03"
BOM.IconSameZoneOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconResGhostOn = "Interface\\RAIDFRAME\\Raid-Icon-Rez"
BOM.IconResGhostOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconResGhostOff = "Interface\\ICONS\\Ability_Vanish"
BOM.IconResGhostOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconReplaceSingleOff = "Interface\\ICONS\\Spell_Holy_DivineSpirit"
BOM.IconReplaceSingleOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconReplaceSingleOn = "Interface\\ICONS\\Spell_Holy_PrayerofSpirit"
BOM.IconReplaceSingleOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconArgentumDawnOff = BOM.IconEmpty
BOM.IconArgentumDawnOn = "Interface\\ICONS\\INV_Jewelry_Talisman_07"
BOM.IconArgentumDawnOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconCarrotOff = BOM.IconEmpty
BOM.IconCarrotOn = "Interface\\ICONS\\INV_Misc_Food_54"
BOM.IconCarrotOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconMainHandOff = BOM.IconEmpty
BOM.IconMainHandOn = "Interface\\ICONS\\INV_Weapon_ShortBlade_03"
BOM.IconMainHandOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconSecondaryHandOff = BOM.IconEmpty
BOM.IconSecondaryHandOn = "Interface\\ICONS\\INV_Weapon_Halberd_12"
BOM.IconSecondaryHandOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconTank = "Interface\\RAIDFRAME\\UI-RAIDFRAME-MAINTANK"
BOM.IconTankCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconPet = "Interface\\ICONS\\Ability_Mount_JungleTiger"
BOM.IconPetCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInPVPOff = BOM.IconEmpty
BOM.IconInPVPOn = "Interface\\ICONS\\Ability_DualWield"
BOM.IconInPVPOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInWorldOff = BOM.IconEmpty
BOM.IconInWorldOn = "Interface\\ICONS\\INV_Misc_Orb_01"
BOM.IconInWorldOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInInstanceOff = BOM.IconEmpty
BOM.IconInInstanceOn = "Interface\\ICONS\\INV_Misc_Head_Dragon_01"
BOM.IconInInstanceOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconUseRankOff = BOM.IconEmpty
BOM.IconUseRankOn = "Interface\\Buttons\\JumpUpArrow"

function BOM.DoBlessingOnClick(self)
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
