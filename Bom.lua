local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })
BUFFOMAT_ADDON = BOM

local settings = {
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
local UpdateOnEvent = { "UPDATE_SHAPESHIFT_FORM", "UNIT_AURA", "READY_CHECK", "PLAYER_ALIVE", "PLAYER_UNGHOST", "INCOMING_RESURRECT_CHANGED", "UNIT_INVENTORY_CHANGED" }
local BagOnEvent = { "BAG_UPDATE_DELAYED", "TRADE_CLOSED" }
local PartyChangeEvent = { "GROUP_JOINED", "GROUP_ROSTER_UPDATE", "RAID_ROSTER_UPDATE", "GROUP_LEFT" }
local SpellChangedEvent = { "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB" }

local ErrStand = { ERR_CANTATTACK_NOTSTANDING, SPELL_FAILED_NOT_STANDING, ERR_LOOT_NOTSTANDING, ERR_TAXINOTSTANDING }
local ErrMounted = { ERR_NOT_WHILE_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED, SPELL_FAILED_NOT_MOUNTED }
local ErrShapeShift = { ERR_EMBLEMERROR_NOTABARDGEOSET, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_MOUNT_SHAPESHIFTED, ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_FAILED_NOT_SHAPESHIFT, SPELL_NOT_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED_NOSPACE }

local function PopupDB(db, var)
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
    for i, profile in pairs(BOM.ProfileNames) do
      BOM.PopupDynamic:AddItem(L["profile_" .. profile], false, BOM.ChooseProfile, profile)
    end
    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()

  for i, spell in ipairs(BOM.Spells) do
    if not spell.isBuff then
      BOM.PopupDynamic:AddItem(spell.singleLink or spell.single, "keep", BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")
    end
  end
  if inBuffGroup then
    BOM.PopupDynamic:SubMenu()
  end

  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(L.BtnSettings, "subSettings")
  for i, set in ipairs(settings) do
    BOM.PopupDynamic:AddItem(PopupDB(BOM.DB, set[1]))
  end
  BOM.PopupDynamic:SubMenu()

  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:SubMenu(L["HeaderWatchGroup"], "subGroup")

  for i = 1, 8 do
    BOM.PopupDynamic:AddItem(i, "keep", BOM.WatchGroup, i)
  end
  BOM.PopupDynamic:SubMenu()

  BOM.PopupDynamic:AddItem()
  BOM.PopupDynamic:AddItem(L.BtnSettings, false, BOM.Options.Open, 1)
  BOM.PopupDynamic:AddItem(L.BtnSettingsSpells, false, BOM.ShowWindow, 2)
  BOM.PopupDynamic:AddItem()
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

function BOM.OptionsUpdate()
  BOM.ForceUpdate = true
  BOM.UpdateScan()
  BOM.UpdateSpellsTab()
  BOM.MyButtonUpdateAll()
  BOM.MinimapButton.UpdatePosition()
  BOM.Options.DoCancel()
end

local function BOM_CheckBox(Var, Init)
  BOM.Options.AddCheckBox(BOM.DB, Var, Init, L["Cbox" .. Var])
end
local function BOM_EditBox(Var, Init, width)
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
  for i, set in ipairs(settings) do
    BOM_CheckBox(set[1], set[2])
  end

  BOM.Options.AddSpace()
  BOM_EditBox("MinBuff", 3, 350)
  BOM_EditBox("MinBlessing", 3, 350)
  BOM.Options.AddSpace()
  BOM.Options.AddCategory(L.HeaderRenew)
  BOM.Options.Indent(20)
  BOM_EditBox("Time60", 10)--60s
  BOM_EditBox("Time300", 60)--5m
  BOM_EditBox("Time600", 120)--10m
  BOM_EditBox("Time1800", 300)--30m
  BOM_EditBox("Time3600", 300)--60m
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
  local function SlashText(txt)
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
  BOM.Tool.PrintSlashCommand(nil, nil, SlashText)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L["HeaderCredits"])
  BOM.Options.Indent(10)
  BOM.Options.AddText(L["AboutCredits"], -20)
  BOM.Options.Indent(-10)

  BOM.Options.AddCategory(L.HeaderSupportedSpells)
  BOM.Options.Indent(20)
  for i, spell in ipairs(BOM.SpellList) do
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

  for i, spell in ipairs(BOM.SpellList) do
    if type(spell) == "table" and spell.optionText then
      if spell.groupId then
        BOM.Options.EditText(spell.optionText, (spell.singleLink or spell.single) .. " / " .. (spell.groupLink or spell.group))
      else
        BOM.Options.EditText(spell.optionText, (spell.singleLink or spell.single or spell.ConfigID))
      end
    end
  end
  for i, spell in ipairs(BOM.CancelBuffs) do
    if spell.optionText then
      BOM.Options.EditText(spell.optionText, (spell.singleLink or spell.single or spell.ConfigID))
    end
  end

  --BOM.DB.DEBUGTXT=txt
  BOM.UpdateSpellsTab()
  BOM.ForceUpdate = true
  BOM.UpdateScan()
end

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
      ["Spell"] = BomCharacterState.Spell,
      ["LastAura"] = BomCharacterState.LastAura,
      ["LastSeal"] = BomCharacterState.LastSeal,
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
    BuffOmat_MainWindow:ClearAllPoints()
    BuffOmat_MainWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    BuffOmat_MainWindow:SetWidth(w)
    BuffOmat_MainWindow:SetHeight(h)
  end

  BOM.Tool.EnableSize(BuffOmat_MainWindow, 8, nil, function()
    BOM.SaveWindowPosition()
  end)

  -- slash command
  local function doDBSet(DB, var, value)
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
    { "update", L["SlashUpdate"], function()
      BOM.ForceUpdate = true
      BOM.UpdateScan()
    end },
    { "updatespellstab", "", BOM.UpdateSpellsTab },
    { "close", L["SlashClose"], BOM.HideWindow },
    { "reset", L["SlashReset"], BOM.ResetWindow },
    { "_checkforerror", "", function()
      if not InCombatLockdown() then
        BOM.CheckForError = true
      end
    end },
    { "", L["SlashOpen"], BOM.ShowWindow },
  })

  BuffOmat_ListTab_MessageFrame:SetFading(false);
  BuffOmat_ListTab_MessageFrame:SetFontObject(GameFontNormalSmall);
  BuffOmat_ListTab_MessageFrame:SetJustifyH("LEFT");
  BuffOmat_ListTab_MessageFrame:SetHyperlinksEnabled(true);
  BuffOmat_ListTab_MessageFrame:Clear()
  BuffOmat_ListTab_MessageFrame:SetMaxLines(100)

  BuffOmat_ListTab_Button:SetAttribute("type", "macro")
  BuffOmat_ListTab_Button:SetAttribute("macro", BOM.MACRONAME)

  BOM.Tool.OnUpdate(BOM.UpdateTimer)

  BOM.PopupDynamic = BOM.Tool.CreatePopup(BOM.OptionsUpdate)

  BOM.MinimapButton.Init(BOM.DB.Minimap, BOM.FullIcon,
          function(self, button)
            if button == "LeftButton" then
              BOM.ToggleWindow()
            else
              BOM.Popup(self.button, true)
            end
          end
  , BOM.Title)

  BuffOmat_MainWindow_Title:SetText(string.format(BOM.TxtEscapeIcon, BOM.FullIcon) .. " " .. BOM.Title .. " - " .. L.profile_solo)
  --BuffOmat_ListTab_Button:SetText(L["BtnGetMacro"])

  BOM.OptionsInit()
  BOM.PartyUpdateNeeded = true
  BOM.RepeatUpdate = false

  BOM.Tool.EnableMoving(BuffOmat_MainWindow, BOM.SaveWindowPosition)

  BuffOmat_MainWindow:SetMinResize(290, 75)

  BOM.Tool.AddTab(BuffOmat_MainWindow, L.TabBuff, BuffOmat_ListTab, true)
  BOM.Tool.AddTab(BuffOmat_MainWindow, L.TabSpells, BuffOmat_SpellTab, true)
  BOM.Tool.SelectTab(BuffOmat_MainWindow, 1)

  BOM.WatchGroup = {}
  for i = 1, 8 do
    BOM.WatchGroup[i] = true
  end

  _G["BINDING_NAME_MACRO Buff'o'mat"] = L["BtnPerformeBuff"]
  _G["BINDING_HEADER_BUFFOMATHEADER"] = "Buffomat Classic"

  print("|cFFFF1C1C Loaded: " .. GetAddOnMetadata(TOCNAME, "Title") .. " " .. GetAddOnMetadata(TOCNAME, "Version") .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))

end

local function Event_ADDON_LOADED(arg1)
  if arg1 == TOCNAME then
    BOM.Init()
  end
  BOM.Tool.AddDataBrocker(BOM.FullIcon,
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
    if (BOM.ManaLimit or 0) <= (UnitPower("player", 0) or 0) then
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
  BOM.CreateSpellTab = false
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
    --print("casting")
    BOM.PlayerCasting = true
    BOM.ForceUpdate = true
  end
end

local function Event_UNIT_SPELLCAST_STOP(unit)
  if UnitIsUnit(unit, "player") then
    --print("endcasting")
    BOM.PlayerCasting = false
    BOM.ForceUpdate = true
    BOM.CheckForError = false
  end
end

local function Event_PLAYER_STARTED_MOVING()
  --BOM.ForceUpdate=BOM.RepeatUpdate
  BOM.IsMoving = true
end

local function Event_PLAYER_STOPPED_MOVING()
  --BOM.ForceUpdate=BOM.RepeatUpdate
  BOM.IsMoving = false
end

local function Event_CombatStart()
  BOM.ForceUpdate = true
  BOM.DeclineHasResurrection = true
  BOM.AutoClose()
  BuffOmat_ListTab_Button:Disable()
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
  if UnitExists("target") and UnitCanCooperate("player", "target") and UnitIsPlayer("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target") then
    newName = UnitName("target")
  end

  if newName ~= BOM.SaveTargetName then
    BOM.SaveTargetName = newName
    BOM.ForceUpdate = true
    BOM.UpdateScan()
  end

end

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
    --BuffOmat_MainWindow_Title:SetText((debugprofilestop()-fpsCheck).."-".. (BOM.ForceUpdate and "true" or "false"))
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
      BuffOmat_MainWindow:Hide()
      autoHelper = "KeepClose"
      BOM.ForceUpdate = true
      BOM.UpdateScan()
    end
  end
end

function BOM.ShowWindow(tab)
  if not InCombatLockdown() then
    if not BOM.WindowVisible() then
      BuffOmat_MainWindow:Show()
      autoHelper = "KeepOpen"
    end
    BOM.Tool.SelectTab(BuffOmat_MainWindow, tab or 1)
  end

end

function BOM.WindowVisible()
  return BuffOmat_MainWindow:IsVisible()
end

function BOM.ToggleWindow()
  if BuffOmat_MainWindow:IsVisible() then
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
      BuffOmat_MainWindow:Show()
      BOM.Tool.SelectTab(BuffOmat_MainWindow, 1)
    end
  end
end
function BOM.AutoClose(x)
  if not InCombatLockdown() and BOM.DB.AutoOpen then
    if BOM.WindowVisible() then
      if autoHelper == "close" then
        BuffOmat_MainWindow:Hide()
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
  BOM.DB.X = BuffOmat_MainWindow:GetLeft()
  BOM.DB.Y = BuffOmat_MainWindow:GetTop()
  BOM.DB.Width = BuffOmat_MainWindow:GetWidth()
  BOM.DB.Height = BuffOmat_MainWindow:GetHeight()
end

function BOM.ResetWindow()
  BuffOmat_MainWindow:ClearAllPoints()
  BuffOmat_MainWindow:SetPoint("Center", UIParent, "Center", 0, 0)
  BuffOmat_MainWindow:SetWidth(200)
  BuffOmat_MainWindow:SetHeight(200)
  BOM.SaveWindowPosition()
  BOM.ShowWindow(1)
end

local function WhoRequest(name)
  DEFAULT_CHAT_FRAME.editBox:SetText("/who " .. name)
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox)
end

local function WhisperRequest(name)
  ChatFrame_OpenChat("/w " .. name .. " ")
end

function BOM.EnterHyperlink(self, link, text)
  --print(link,text)
  local part = BOM.Tool.Split(link, ":")
  if part[1] == "spell" or part[1] == "unit" or part[1] == "item" then
    GameTooltip_SetDefaultAnchor(BuffOmat_Tooltip, UIParent)
    BuffOmat_Tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
    BuffOmat_Tooltip:ClearLines()
    BuffOmat_Tooltip:SetHyperlink(link)
    BuffOmat_Tooltip:Show()
  end
end
function BOM.LeaveHyperlink(self)
  BuffOmat_Tooltip:Hide()
end
function BOM.ClickHyperlink(self, link)
  local part = BOM.Tool.Split(link, ":")
  if part[1] == "unit" then
    if IsShiftKeyDown() then
      WhoRequest(part[3])
      --SendWho( req.name )
    else
      WhisperRequest(part[3])
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
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer,
  nameplateShowAll, timeMod
  for buffIndex = 1, 40 do
    local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer,
    nameplateShowAll, timeMod = BOM.UnitAura(dest, buffIndex, "HELPFUL")
    if name or icon or count or debuffType then
      print("Help:", name, spellId, duration, expirationTime, source, (expirationTime or 0) - GetTime())
    end

  end
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

BOM.IconGreen = "Interface\\COMMON\\Indicator-Green"
BOM.IconRed = "Interface\\COMMON\\Indicator-Red"
BOM.IconSelfCastOn = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon"
BOM.IconSelfCastOff = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon"
BOM.IconClasses = BOM.Tool.IconClassTextureWithoutBorder
BOM.IconClassesCoord = BOM.Tool.IconClassTextureCoord
BOM.IconEmpty = "Interface\\Buttons\\UI-MultiCheck-Disabled"

BOM.IconSettingOn = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
BOM.IconSettingOff = BOM.IconEmpty

BOM.IconWispherOn = "Interface\\Buttons\\UI-GuildButton-MOTD-Up"
BOM.IconWispherOff = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled"

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

local ONIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0:0:0:0:64:64:4:60:4:60|t"
local OFFIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:0:0:0:0:64:64:4:60:4:60|t"

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

local function BlessingOnClick(self)
  local saved = self._privat_DB[self._privat_Var]

  for i, spell in ipairs(BOM.Spells) do
    if spell.isBlessing then
      BOM.CurrentProfile.Spell[spell.ConfigID].Class[self._privat_Var] = false
    end
  end
  self._privat_DB[self._privat_Var] = saved

  BOM.MyButtonUpdateAll()
  BOM.OptionsUpdate()
end
local function MyButtonOnClick(self)
  BOM.OptionsUpdate()
end

local SpellSettingsFrames = {}
local function CreateSpellTab()
  local last
  local isHorde = (UnitFactionGroup("player")) == "Horde"
  if InCombatLockdown() then
    return
  end

  BOM.MyButtonHideAll()

  local dy = 0
  local section

  for i, spell in ipairs(BOM.Spells) do
    spell.frames = spell.frames or {}
    if spell.frames.info == nil then
      spell.frames.info = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, spell.Icon, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end
    if spell.isBuff then
      spell.frames.info:SetTooltipLink("item:" .. spell.item)
    else
      spell.frames.info:SetTooltipLink("spell:" .. spell.singleId)
    end

    dy = 12
    if spell.isOwn and section ~= "isOwn" then
      section = "isOwn"
    elseif spell.isTracking and section ~= "isTracking" then
      section = "isTracking"
    elseif spell.isResurrection and section ~= "isResurrection" then
      section = "isResurrection"
    elseif spell.isSeal and section ~= "isSeal" then
      section = "isSeal"
    elseif spell.isAura and section ~= "isAura" then
      section = "isAura"
    elseif spell.isBlessing and section ~= "isBlessing" then
      section = "isBlessing"
    elseif spell.isInfo and section ~= "isInfo" then
      section = "isInfo"
    elseif spell.isBuff and section ~= "isBuff" then
      section = "isBuff"
    else
      dy = 2
    end

    if last then
      spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
    else
      spell.frames.info:SetPoint("TOPLEFT")
    end

    local l = spell.frames.info
    local dx = 7

    if spell.frames.Enable == nil then
      spell.frames.Enable = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconGreen, BOM.IconRed)
    end

    spell.frames.Enable:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")
    spell.frames.Enable:SetOnClick(MyButtonOnClick)
    spell.frames.Enable:SetTooltip(L.TTEnable)
    l = spell.frames.Enable
    dx = 7

    if BOM.SpellHasClasses(spell) then
      if spell.frames.SelfCast == nil then
        spell.frames.SelfCast = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconSelfCastOn, BOM.IconSelfCastOff)
      end

      spell.frames.SelfCast:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")
      spell.frames.SelfCast:SetOnClick(MyButtonOnClick)
      spell.frames.SelfCast:SetTooltip(L.TTSelfCast)

      l = spell.frames.SelfCast
      dx = 2

      for ci, class in ipairs(BOM.Tool.Classes) do
        if spell.frames[class] == nil then
          spell.frames[class] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconClasses, BOM.IconEmpty, BOM.IconDisabled, BOM.IconClassesCoord[class])
        end
        spell.frames[class]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
        spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)
        spell.frames[class]:SetOnClick(BlessingOnClick)
        spell.frames[class]:SetTooltip(BOM.Tool.IconClass[class] .. " " .. BOM.Tool.ClassName[class])

        if (isHorde and class == "PALADIN") or (not isHorde and class == "SHAMAN") then
          spell.frames[class]:Hide()
        else
          l = spell.frames[class]
        end
      end

      if spell.frames["tank"] == nil then
        spell.frames["tank"] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconTank, BOM.IconEmpty, BOM.IconDisabled, BOM.IconTankCoord)
      end
      spell.frames["tank"]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
      spell.frames["tank"]:SetOnClick(BlessingOnClick)
      spell.frames["tank"]:SetTooltip(L.Tank)
      l = spell.frames["tank"]

      if spell.frames["pet"] == nil then
        spell.frames["pet"] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconPet, BOM.IconEmpty, BOM.IconDisabled, BOM.IconPetCoord)
      end
      spell.frames["pet"]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")
      spell.frames["pet"]:SetOnClick(BlessingOnClick)
      spell.frames["pet"]:SetTooltip(L.Pet)
      l = spell.frames["pet"]

      dx = 7

      if spell.frames.target == nil then
        spell.frames.target = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconTargetOn, BOM.IconTargetOff, BOM.IconDisabled)
      end
      spell.frames.target:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.target:SetOnClick(MyButtonOnClick)
      spell.frames.target:SetTooltip(L.TTTarget)

      l = spell.frames.target
      dx = 7

    end

    if (spell.isTracking or spell.isAura or spell.isSeal) and spell.needForm == nil then
      if spell.frames.Set == nil then
        spell.frames.Set = BOM.CreateMyButtonSecure(BuffOmat_SpellTab_Scroll_Child, BOM.IconChecked, BOM.IconUnChecked)
      end
      spell.frames.Set:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.Set:SetSpell(spell.singleId)

      l = spell.frames.Set
      dx = 7

    end

    if spell.isInfo and spell.allowWispher then
      if spell.frames.Wispher == nil then
        spell.frames.Wispher = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconWispherOn, BOM.IconWispherOff)
      end
      spell.frames.Wispher:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.Wispher:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Wispher")
      spell.frames.Wispher:SetOnClick(MyButtonOnClick)
      spell.frames.Wispher:SetTooltip(L.TTWispher)
      l = spell.frames.Wispher
      dx = 2
    end

    if spell.isWeapon then
      if spell.frames.MainHand == nil then
        spell.frames.MainHand = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconMainHandOn, BOM.IconMainHandOff, BOM.IconDisabled, BOM.IconMainHandOnCoord)
      end
      spell.frames.MainHand:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
      spell.frames.MainHand:SetOnClick(MyButtonOnClick)
      spell.frames.MainHand:SetTooltip(L.TTMainHand)
      l = spell.frames.MainHand
      dx = 2

      if spell.frames.OffHand == nil then
        spell.frames.OffHand = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconSecondaryHandOn, BOM.IconSecondaryHandOff, BOM.IconDisabled, BOM.IconSecondaryHandOnCoord)
      end
      spell.frames.OffHand:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
      spell.frames.OffHand:SetOnClick(MyButtonOnClick)
      spell.frames.OffHand:SetTooltip(L.TTOffHand)
      l = spell.frames.OffHand
      dx = 2

    end

    if spell.frames.buff == nil then
      spell.frames.buff = BuffOmat_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    if spell.isWeapon then
      spell.frames.buff:SetText((spell.single or "-") .. " (" .. L.TTAnyRank .. ")")
    else
      spell.frames.buff:SetText(spell.single or "-")
    end

    spell.frames.buff:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
    l = spell.frames.buff
    dx = 7

    spell.frames.info:Show()
    spell.frames.Enable:Show()
    if BOM.SpellHasClasses(spell) then
      spell.frames.SelfCast:Show()
      spell.frames.target:Show()

      for ci, class in ipairs(BOM.Tool.Classes) do
        if (isHorde and class == "PALADIN") or (not isHorde and class == "SHAMAN") then
          spell.frames[class]:Hide()
        else
          spell.frames[class]:Show()
        end
      end
      spell.frames["tank"]:Show()
      spell.frames["pet"]:Show()
    end

    if spell.frames.Set then
      spell.frames.Set:Show()
    end

    if spell.frames.buff then
      spell.frames.buff:Show()
    end

    if spell.frames.Wispher then
      spell.frames.Wispher:Show()
    end

    if spell.frames.MainHand then
      spell.frames.MainHand:Show()
    end

    if spell.frames.OffHand then
      spell.frames.OffHand:Show()
    end

    last = spell.frames.info
  end

  dy = 12
  for i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames = spell.frames or {}
    if spell.frames.info == nil then
      spell.frames.info = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, spell.Icon, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
      spell.frames.info:SetTooltipLink("spell:" .. spell.singleId)
    end
    if last then
      spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
    else
      spell.frames.info:SetPoint("TOPLEFT")
    end
    last = spell.frames.info

    if spell.frames.Enable == nil then
      spell.frames.Enable = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconBuffOn, BOM.IconBuffOff)
    end
    spell.frames.Enable:SetPoint("LEFT", spell.frames.info, "RIGHT", 7, 0)
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
    spell.frames.Enable:SetOnClick(MyButtonOnClick)
    spell.frames.Enable:SetTooltip(L.TTEnableBuff)

    if spell.OnlyCombat then
      if spell.frames.OnlyCombat == nil then
        spell.frames.OnlyCombat = BuffOmat_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      end
      spell.frames.OnlyCombat:SetText("(" .. L.TTOnlyCombat .. ")")
      spell.frames.OnlyCombat:SetPoint("TOPLEFT", spell.frames.Enable, "TOPRIGHT", 7, -1)
    end

    spell.frames.info:Show()
    spell.frames.Enable:Show()
    if spell.frames.OnlyCombat then
      spell.frames.OnlyCombat:Show()
    end
    dy = 2
  end

  if last then

    if SpellSettingsFrames.Settings == nil then
      SpellSettingsFrames.Settings = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconGear, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end

    SpellSettingsFrames.Settings:SetTooltip(L.BtnSettings)
    SpellSettingsFrames.Settings:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -12)

    last = SpellSettingsFrames.Settings
    local dx = 7
    local l = last

    if SpellSettingsFrames[0] == nil then
      SpellSettingsFrames[0] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconGroup, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end
    SpellSettingsFrames[0]:SetTooltip(L.HeaderWatchGroup)
    SpellSettingsFrames[0]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)

    l = SpellSettingsFrames[0]
    dx = 7
    for i = 1, 8 do
      if SpellSettingsFrames[i] == nil then
        SpellSettingsFrames[i] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconGroupItem, BOM.IconGroupNone)
      end
      SpellSettingsFrames[i]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      SpellSettingsFrames[i]:SetVariable(BOM.WatchGroup, i)
      SpellSettingsFrames[i]:SetText(i)
      SpellSettingsFrames[i]:SetTooltip(string.format(L.TTGroup, i))
      SpellSettingsFrames[i]:SetOnClick(MyButtonOnClick)
      l = SpellSettingsFrames[i]
      dx = 2
    end

    last = SpellSettingsFrames[0]

    for i, set in ipairs(settings) do
      local key = set[1]

      if BOM["Icon" .. key .. "On"] then
        if SpellSettingsFrames[key] == nil then
          SpellSettingsFrames[key] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM["Icon" .. key .. "On"], BOM["Icon" .. key .. "Off"], nil, BOM["Icon" .. key .. "OnCoord"], BOM["Icon" .. key .. "OffCoord"])
        end
        SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -2)
        SpellSettingsFrames[key]:SetVariable(BOM.DB, key)
        SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
        SpellSettingsFrames[key]:SetOnClick(MyButtonOnClick)
        l = SpellSettingsFrames[key]
        dx = 2

        if SpellSettingsFrames[key .. "txt"] == nil then
          SpellSettingsFrames[key .. "txt"] = BuffOmat_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end
        SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
        SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
        l = SpellSettingsFrames[key .. "txt"]
        dx = 7

        last = SpellSettingsFrames[key]
        dx = 0
      end
    end


    --last=SpellSettingsFrames.Settings
    --dx=SpellSettingsFrames.Settings:GetWidth()+7
    for i, set in ipairs(settings) do
      local key = set[1]

      if not BOM["Icon" .. key .. "On"] then
        if SpellSettingsFrames[key] == nil then
          SpellSettingsFrames[key] = BOM.CreateMyButton(BuffOmat_SpellTab_Scroll_Child, BOM.IconSettingOn, BOM.IconSettingOff, nil, nil, nil)
        end
        SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", dx, -2)
        SpellSettingsFrames[key]:SetVariable(BOM.DB, key)
        SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
        SpellSettingsFrames[key]:SetOnClick(MyButtonOnClick)
        l = SpellSettingsFrames[key]
        dx = 2

        if SpellSettingsFrames[key .. "txt"] == nil then
          SpellSettingsFrames[key .. "txt"] = BuffOmat_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end
        SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
        SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
        l = SpellSettingsFrames[key .. "txt"]
        dx = 7

        last = SpellSettingsFrames[key]
        dx = 0
      end
    end

    SpellSettingsFrames.Settings:Show()

    for i = 0, 8 do
      SpellSettingsFrames[i]:Show()
    end

    for i, set in ipairs(settings) do
      if SpellSettingsFrames[set[1]] then
        SpellSettingsFrames[set[1]]:Show()
      end
      if SpellSettingsFrames[set[1] .. "txt"] then
        SpellSettingsFrames[set[1] .. "txt"]:Show()
      end
    end

    last = SpellSettingsFrames.Settings

  end

end

function BOM.UpdateSpellsTab()
  if BOM.Spells == nil then
    return
  end
  if InCombatLockdown() then
    return
  end

  if not BOM.CreateSpellTab then
    CreateSpellTab()
    BOM.CreateSpellTab = true
  end

  for i, spell in ipairs(BOM.Spells) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")

    if BOM.SpellHasClasses(spell) then
      spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")

      for ci, class in ipairs(BOM.Tool.Classes) do
        spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)

        if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
          spell.frames[class]:Disable()
        else
          spell.frames[class]:Enable()
        end
      end

      spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
      spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")

      if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        spell.frames["tank"]:Disable()
        spell.frames["pet"]:Disable()
      else
        spell.frames["tank"]:Enable()
        spell.frames["pet"]:Enable()
      end

      if BOM.lastTarget ~= nil then
        spell.frames.target:Enable()
        spell.frames.target:SetTooltip(L.TTTarget .. "|n" .. BOM.lastTarget)
        if spell.isBlessing then
          spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[BOM.BLESSINGID], BOM.lastTarget, spell.ConfigID)
        else
          spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget, BOM.lastTarget, true)
        end

      else
        spell.frames.target:Disable()
        spell.frames.target:SetTooltip(L.TTTarget .. "|n" .. L.TTSelectTarget)
        spell.frames.target:SetVariable()
      end
    end

    if spell.isInfo and spell.allowWispher then
      spell.frames.Wispher:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Wispher")
    end

    if spell.isWeapon then
      spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
      spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
    end

    if (spell.isTracking or spell.isAura or spell.isSeal) and spell.needForm == nil then
      if (spell.isTracking and BOM.DBChar.LastTracking == spell.TrackingIcon) or
              (spell.isAura and spell.ConfigID == BOM.CurrentProfile.LastAura) or
              (spell.isSeal and spell.ConfigID == BOM.CurrentProfile.LastSeal) then
        spell.frames.Set:SetState(true)
      else
        spell.frames.Set:SetState(false)
      end
    end
  end

  for i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
  end
end

function BOM.MyButton_Update(self)
  if self._privat_disabled and self._IconDisabled then
    self._icon:SetTexture(self._IconDisabled, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconDisabledCoord))
    self._text:SetText("")

  elseif self._privat_state and self._IconSelected then
    self._icon:SetTexture(self._IconSelected, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconSelectedCoord))
    if self._privat_Text then
      self._text:SetText(self._privat_Text)
    end

  elseif self._IconUnSelected then
    self._icon:SetTexture(self._IconUnSelected, nil, nil, "LINEAR")
    self._icon:SetTexCoord(unpack(self._IconUnSelectedCoord))
    self._text:SetText("")
  end
end

function BOM.MyButton_SetOnClick(self, func)
  self._privat_OnClick = func
end
function BOM.MyButton_OnDisable(self)
  self._privat_disabled = true
  BOM.MyButton_Update(self)
end
function BOM.MyButton_OnEnable(self)
  self._privat_disabled = false
  BOM.MyButton_Update(self)
end
function BOM.MyButton_OnEnter(self)
  if self._privat_ToolTipLink or self._privat_ToolTipText then
    GameTooltip_SetDefaultAnchor(BuffOmat_Tooltip, UIParent)
    BuffOmat_Tooltip:SetOwner(BuffOmat_MainWindow, "ANCHOR_PRESERVE")
    BuffOmat_Tooltip:ClearLines()
    if self._privat_ToolTipLink then
      BuffOmat_Tooltip:SetHyperlink(self._privat_ToolTipLink)
    else
      local add = ""
      if (self._privat_DB and self._privat_Var) then
        add = " " .. (self._privat_state and ONIcon or OFFIcon)
      end
      BuffOmat_Tooltip:AddLine(self._privat_ToolTipText .. add)

    end
    BuffOmat_Tooltip:Show()
  end
  if ((self._privat_DB and self._privat_Var) or self._privat_isSecure) and not self._privat_disabled then
    self._iconHighlight:SetTexture(self._icon:GetTexture())
    self._iconHighlight:SetTexCoord(self._icon:GetTexCoord())
    if (self._iconHighlight:SetDesaturated(true)) then
      self._iconHighlight:SetVertexColor(1, 0.75, 0.25, 0.75);
      self._iconHighlight:SetBlendMode("ADD")
    else
      self._iconHighlight:SetColorTexture(1, 1, 1, 0.2);
    end
  end
end
function BOM.MyButton_OnLeave(self)
  BuffOmat_Tooltip:Hide()
  self._iconHighlight:SetColorTexture(1, 1, 1, 0)
  self._iconHighlight:SetVertexColor(1, 1, 1, 0);
end
function BOM.MyButton_OnMouseUp(self, button)
  if not self._privat_disabled then
    if self._privat_DB and self._privat_Var then
      if self._privat_Set == nil then
        self._privat_DB[self._privat_Var] = not self._privat_DB[self._privat_Var]
      else
        if self._privat_DB[self._privat_Var] ~= self._privat_Set then
          self._privat_DB[self._privat_Var] = self._privat_Set
        else
          self._privat_DB[self._privat_Var] = nil
        end
      end
      self:SetState()
      BOM.MyButton_OnEnter(self)
      if self._privat_OnClick then
        self._privat_OnClick(self, button)
      end
    end
  end
end
function BOM.MyButton_SetText(self, text)
  self._privat_Text = text
  BOM.MyButton_Update(self)
end
function BOM.MyButton_OnLoad(self, isSecure)
  self._privat_state = true
  self._privat_disabled = false
  self.SetState = BOM.MyButton_SetState
  self.SetTextures = BOM.MyButton_SetTextures
  self.SetTooltipLink = BOM.MyButton_SetTooltipLink
  self.SetTooltip = BOM.MyButton_SetTooltip
  self.SetVariable = BOM.MyButton_SetVariable
  self.SetText = BOM.MyButton_SetText
  if not isSecure then
    self:SetScript("OnMouseUp", BOM.MyButton_OnMouseUp)
    self.SetOnClick = BOM.MyButton_SetOnClick
    self.Disable = BOM.MyButton_OnDisable
    self.Enable = BOM.MyButton_OnEnable
  else
    self:SetScript("OnDisable", BOM.MyButton_OnDisable)
    self:SetScript("OnEnable", BOM.MyButton_OnEnable)
    self.SetSpell = BOM.MyButton_SetSpell
    self._privat_isSecure = true
  end
  self:SetScript("OnEnter", BOM.MyButton_OnEnter)
  self:SetScript("OnLeave", BOM.MyButton_OnLeave)
end

function BOM.MyButton_SetState(self, state)
  if state == nil then
    if self._privat_DB and self._privat_Var then
      if self._privat_Set == nil then
        self._privat_state = self._privat_DB[self._privat_Var]
      else
        self._privat_state = (self._privat_DB[self._privat_Var] == self._privat_Set)
      end
    end
  else
    self._privat_state = state
  end
  BOM.MyButton_Update(self)
end
local defaultcoord = { 0, 1, 0, 1 }
function BOM.MyButton_SetTextures(self, sel, unsel, dis, selCoord, unselCoord, disCoord)
  self._IconSelected = sel
  self._IconUnSelected = unsel
  self._IconDisabled = dis
  self._IconSelectedCoord = selCoord or defaultcoord
  self._IconUnSelectedCoord = unselCoord or defaultcoord
  self._IconDisabledCoord = disCoord or defaultcoord
  BOM.MyButton_Update(self)
end

function BOM.MyButton_SetVariable(self, db, var, set)
  self._privat_DB = db
  self._privat_Var = var
  self._privat_Set = set
  self:SetState()
end

function BOM.MyButton_SetTooltipLink(self, link)
  self._privat_ToolTipLink = link
  self._privat_ToolTipText = nil
end
function BOM.MyButton_SetTooltip(self, text)
  self._privat_ToolTipLink = nil
  self._privat_ToolTipText = text
end

function BOM.MyButton_SetSpell(self, spell)
  self:SetAttribute("type", "spell")
  self:SetAttribute("spell", spell)
  self:SetAttribute("unit", "player")
end

local MyButtonsFrames = {}
function BOM.CreateMyButton(parent, sel, unsel, dis, selCoord, unselCoord, disCoord)
  Frame = CreateFrame("frame", nil, parent, "BuffOmat_MyButton")
  BOM.MyButton_OnLoad(Frame)
  Frame:SetTextures(sel, unsel, dis, selCoord, unselCoord, disCoord)
  tinsert(MyButtonsFrames, Frame)
  return Frame
end
function BOM.CreateMyButtonSecure(parent, sel, unsel, dis, selCoord, unselCoord, disCoord)
  Frame = CreateFrame("Button", nil, parent, "BuffOmat_MyButtonSecure")
  BOM.MyButton_OnLoad(Frame, true)
  Frame:SetTextures(sel, unsel, dis, selCoord, unselCoord, disCoord)
  tinsert(MyButtonsFrames, Frame)
  return Frame
end
function BOM.MyButtonUpdateAll()
  for i, Frame in ipairs(MyButtonsFrames) do
    if Frame.SetState then
      Frame:SetState()
    end
  end
end
function BOM.MyButtonHideAll()
  for i, Frame in ipairs(MyButtonsFrames) do
    Frame:Hide()
  end
end
