--local TOCNAME, _ = ...

---@class BomBuffomatModule
---@field shared BomSharedSettings Refers to BuffomatShared global
---@field character BomCharacterSettings Refers to BuffomatCharacter global
---@field currentProfileName string
---@field currentProfile BomProfile
local buffomatModule = BuffomatModule.New("Buffomat") ---@type BomBuffomatModule

local characterSettingsModule = BuffomatModule.New("CharacterSettings") ---@type BomCharacterSettingsModule
local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local characterStateModule = BuffomatModule.Import("CharacterSettings") ---@type BomCharacterSettingsModule
local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local eventsModule = BuffomatModule.Import("Events") ---@type BomEventsModule
local languagesModule = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local managedUiModule = BuffomatModule.New("Ui/MyButton") ---@type BomUiMyButtonModule
local optionsModule = BuffomatModule.Import("Options") ---@type BomOptionsModule
local optionsPopupModule = BuffomatModule.Import("OptionsPopup") ---@type BomOptionsPopupModule
local profileModule = BuffomatModule.Import("Profile") ---@type BomProfileModule
local sharedStateModule = BuffomatModule.Import("SharedSettings") ---@type BomSharedSettingsModule
local spellButtonsTabModule = BuffomatModule.Import("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
local taskScanModule = BuffomatModule.Import("TaskScan") ---@type BomTaskScanModule
local toolboxModule = BuffomatModule.Import("Toolbox") ---@type BomToolboxModule

---global, visible from XML files and from script console and chat commands
---@class BomAddon
---@field ForceUpdate boolean Set to true to force recheck buffs on timer
-- -@field ForceUpdateSpellsTab boolean Set to true to force clear and rebuild spells tab. This activity is throttled to 1 per second
---@field ALL_PROFILES table<string> Lists all buffomat profile names (group, solo... etc)
---@field RESURRECT_CLASS table<string> Classes who can resurrect others
---@field MANA_CLASSES table<string> Classes with mana resource
---@field locales BuffomatTranslations (same as BOM.L)
---@field L BuffomatTranslations (same as BOM.locales)
---@field AllBuffomatBuffs table<number, BomBuffDefinition> All spells known to Buffomat
---@field EnchantList table<number, table<number>> Spell ids mapping to enchant ids
---@field CancelBuffs table<number, BomBuffDefinition> All spells to be canceled on detection
---@field ItemCache table<number, BomItemCacheElement> Precreated precached items
---@field ActivePaladinAura nil|number Spell id of aura if an unique aura was casted (only one can be active)
---@field ActivePaladinSeal nil|number Spell id of weapon seal, if an seal-type temporary enchant was used (only one can be active)
---
---@field ForceProfile string|nil Nil will choose profile name automatically, otherwise this profile will be used
---@field ArgentumDawn table Equipped AD trinket: Spell to and zone ids to check
---@field BuffExchangeId table<number, table<number>> Combines spell ids of spellrank flavours into main spell id
---@field BuffIgnoreAll table<number> Having this buff on target excludes the target (phaseshifted imp for example)
---@field CachedHasItems table<string, CachedItem> Items in player's bag
---@field CancelBuffSource string Unit who casted the buff to be auto-canceled
---@field Carrot table Equipped Riding trinket: Spell to and zone ids to check
---@field CheckForError boolean Used by error suppression code
---@field CurrentProfile BomProfile Current profile from CharacterState.Profiles
-- -@field CharacterState BomCharacterState Copy of state only for the current character, with separate states per profile
-- -@field SharedState BomProfile Copy of state shared with all accounts
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
---@field SelectedSpells table<number, BomBuffDefinition>
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
        "Buffomat", "AceConsole-3.0", "AceEvent-3.0") ---@type BomAddon
local BOM = BuffomatAddon

local _, _, _, tocversion = GetBuildInfo()
BOM.IsWotLK = (tocversion >= 30000 and tocversion <= 39999) -- TODO: change to WOTLK detection via WOW_PROJECT_..._CLASSIC
BOM.HaveWotLK = BOM.IsWotLK

BOM.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
BOM.HaveTBC = BOM.IsWotLK or BOM.IsTBC

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

---Bound the the macro cast button in the buff tab
function BOM.BtnMacro()
  PickupMacro(constModule.MACRO_NAME)
end

function BOM.ScrollMessage(self, delta)
  self:SetScrollOffset(self:GetScrollOffset() + delta * 5);
  self:ResetAllFadeTimes()
end

function BOM.SetForceUpdate(reason)
  BOM.ForceUpdate = true
end

-- Something changed (buff gained possibly?) update all spells and spell tabs
function buffomatModule:OptionsUpdate()
  BOM.SetForceUpdate("OptionsUpdate")
  taskScanModule:UpdateScan("OptionsUpdate")
  spellButtonsTabModule:UpdateSpellsTab("OptionsUpdate")
  managedUiModule:UpdateAll()
  BOM.MinimapButton.UpdatePosition()
  --BOM.legacyOptions.DoCancel()
end

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
end

---ChooseProfile
---BOM profile selection, using 'auto' by default
---@param profile table
function buffomatModule.ChooseProfile(profile)
  if profile == nil or profil == "" or profile == "auto" then
    BOM.ForceProfile = nil
  elseif buffomatModule.character[profile] then
    BOM.ForceProfile = profile
  else
    BOM:Print("Unknown profile: " .. profile)
    return
  end

  BOM.ClearSkip()
  BOM.PopupDynamic:Wipe()
  BOM.SetForceUpdate("ChooseProfile")

  buffomatModule:UseProfile(profile)
  taskScanModule:UpdateScan("ChooseProfile")
end

function buffomatModule:UseProfile(profile)
  if buffomatModule.currentProfileName == profile then
    return
  end

  buffomatModule.currentProfileName = profile

  local selectedProfile = self.character[profile] or characterSettingsModule:New()
  buffomatModule.currentProfile = selectedProfile

  BOM:Print("Using profile " .. _t("profile_" .. profile))
end

---When BomCharacterState.WatchGroup has changed, update the buff tab text to show what's
---being buffed. Example: "Buff All", "Buff G3,5-7"...
function buffomatModule:UpdateBuffTabText()
  local selectedGroups = 0
  local t = BomC_MainWindow.Tabs[1]

  for i = 1, 8 do
    if self.character.WatchGroup[i] then
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
    if self.character.WatchGroup[i] then
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
    BOM.QuickSingleBuff = managedUiModule:CreateManagedButton(
            parent_frame,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF,
            nil, nil, nil, nil, nil)
    BOM.QuickSingleBuff:SetPoint("BOTTOMLEFT", parent_frame, "BOTTOMRIGHT", -18, 0);
    BOM.QuickSingleBuff:SetPoint("BOTTOMRIGHT", parent_frame, "BOTTOMRIGHT", -2, 12);
    BOM.QuickSingleBuff:SetVariable(buffomatModule.shared, "NoGroupBuff")
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
          self.shared.Minimap,
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

function buffomatModule:InitGlobalStates()
  local loadedShared = (BomSharedState or BuffomatShared) or {} -- Upgrade from legacy Buffomat State if found
  if BomSharedState then
    BomSharedState = nil -- reset after reimport
  end
  BuffomatShared = sharedStateModule:New(loadedShared) ---@type BomSharedSettings
  buffomatModule.shared = BuffomatShared

  local loadedChar = (BomCharacterState or BuffomatCharacter) or {} -- Upgrade from legacy Buffomat State if found
  if BomCharacterState then
    BomCharacterState = nil -- reset after reimport
  end
  BuffomatCharacter = characterStateModule:New(loadedChar) ---@type BomCharacterSettings
  buffomatModule.character = BuffomatCharacter

  if self.character.Duration then
    self.shared.Duration = self.character.Duration
    self.character.Duration = nil
  elseif not self.shared.Duration then
    self.shared.Duration = {}
  end

  if not self.character[profileModule.ALL_PROFILES[1]] then
    self.character[profileModule.ALL_PROFILES[1]] = {
      ["CancelBuff"] = self.character.CancelBuff,
      ["Spell"]      = self.character.Spell,
      ["LastAura"]   = self.character.LastAura,
      ["LastSeal"]   = self.character.LastSeal,
    }
    self.character.CancelBuff = nil
    self.character.Spell = nil
    self.character.LastAura = nil
    self.character.LastSeal = nil
  end

  for i, each_profile in ipairs(profileModule.ALL_PROFILES) do
    if not self.character[each_profile] then
      self.character[each_profile] = {}
    end
  end

  --BOM.SharedState = self.shared
  --BOM.CharacterState = self.character
  local soloProfile = profileModule:SoloProfile()
  BOM.CurrentProfile = self.character[profileModule.ALL_PROFILES[soloProfile] or {}]
end

---Called from event handler on Addon Loaded event
---Execution start here
function BuffomatAddon:Init()
  languagesModule:SetupTranslations()
  allBuffsModule:SetupSpells()
  allBuffsModule:SetupCancelBuffs()
  --BOM.SetupItemCache()
  taskScanModule:SetupTasklist()

  BOM.Macro = BOM.Class.Macro:new(constModule.MACRO_NAME)

  languagesModule:LocalizationInit()

  do
    -- addon window position
    local x, y = buffomatModule.shared.X, buffomatModule.shared.Y
    local w, h = buffomatModule.shared.Width, buffomatModule.shared.Height

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
        taskScanModule:UpdateScan("Macro /bom update")
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
  if not buffomatModule.character.WatchGroup then
    buffomatModule.character.WatchGroup = {}
    for i = 1, 8 do
      buffomatModule.character.WatchGroup[i] = true
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
  profileModule:Setup()
  buffomatModule:InitGlobalStates()
  buffomatModule:UseProfile(profileModule:SoloProfile()) -- after initglobalstates
end

---AceAddon handler
function BuffomatAddon:OnEnable()
  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize
  self:Init()
  eventsModule:InitEvents()
  toolboxModule:AddDataBroker(
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

function buffomatModule:DownGrade()
  if BOM.CastFailedSpell
          and BOM.CastFailedSpell.SkipList
          and BOM.CastFailedSpellTarget then
    local level = UnitLevel(BOM.CastFailedSpellTarget.unitId)

    if level ~= nil and level > -1 then
      if buffomatModule.shared.SpellGreatherEqualThan[BOM.CastFailedSpellId] == nil
              or buffomatModule.shared.SpellGreatherEqualThan[BOM.CastFailedSpellId] < level
      then
        buffomatModule.shared.SpellGreatherEqualThan[BOM.CastFailedSpellId] = level
        BOM.FastUpdateTimer()
        BOM.SetForceUpdate("Downgrade")
        BOM:Print(string.format(_t("MsgDownGrade"),
                BOM.CastFailedSpell.singleText,
                BOM.CastFailedSpellTarget.name))

      elseif buffomatModule.shared.SpellGreatherEqualThan[BOM.CastFailedSpellId] >= level then
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
  if buffomatModule.shared.SlowerHardware then
    updateTimerLimit = buffomatModule.slowerhardwareUpdateTimerLimit
  end

  if (BOM.ForceUpdate or BOM.RepeatUpdate)
          and GetTime() - (buffomatModule.lastUpdateTimestamp or 0) > updateTimerLimit
          and InCombatLockdown() == false
  then
    buffomatModule.lastUpdateTimestamp = GetTime()
    buffomatModule.fpsCheck = debugprofilestop()

    taskScanModule:UpdateScan("Timer")

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

---@class BomUnitAuraResult
---@field name string The name of the spell or effect of the debuff. This is the name shown in yellow when you mouse over the icon
---@field icon string The path to the icon file
---@field count number The number of times the debuff has been applied to the target. Returns 0 for any debuff which doesn't stack.
---@field debuffType string The type of the debuff: Magic, Disease, Poison, Curse, or nothing for those with out a type
---@field duration number The full duration of the debuff in seconds
---@field expirationTime number The time in seconds (like what returns GetTime()) when the aura will expire.
---@field source string
---@field isStealable boolean 1 or nil depending on if the aura can be spellstolen
---@field nameplateShowPersonal boolean
---@field spellId number
---@field canApplyAura boolean
---@field isBossDebuff boolean
---@field castByPlayer boolean
---@field nameplateShowAll boolean
---@field timeMod


---Handles UnitAura WOW API call.
---For spells that are tracked by Buffomat the data is also stored in BOM.PlayerBuffs
---@param unitId string
---@param buffIndex number Index of buff/debuff slot starts 1 max 40?
---@param filter string Filter string like "HELPFUL", "PLAYER", "RAID"... etc
---@return BomUnitAuraResult
function buffomatModule:UnitAura(unitId, buffIndex, filter)
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable
  , nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer
  , nameplateShowAll, timeMod = UnitAura(unitId, buffIndex, filter)

  if spellId and BOM.AllSpellIds and tContains(BOM.AllSpellIds, spellId) then

    if source ~= nil and source ~= "" and UnitIsUnit(source, "player") then
      if UnitIsUnit(unitId, "player") and duration ~= nil and duration > 0 then
        self.shared.Duration[name] = duration
      end

      if duration == nil or duration == 0 then
        duration = self.shared.Duration[name] or 0
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

  return { name                  = name,
           icon                  = icon,
           count                 = count,
           debuffType            = debuffType,
           duration              = duration,
           expirationTime        = expirationTime,
           source                = source,
           isStealable           = isStealable,
           nameplateShowPersonal = nameplateShowPersonal,
           spellId               = spellId,
           canApplyAura          = canApplyAura,
           isBossDebuff          = isBossDebuff,
           castByPlayer          = castByPlayer,
           nameplateShowAll      = nameplateShowAll,
           timeMod               = timeMod }
end

buffomatModule.autoHelper = "open"

function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      buffomatModule.autoHelper = "KeepClose"
      BOM.SetForceUpdate("HideWindow")
      taskScanModule:UpdateScan("HideWindow")
    end
  end
end

function buffomatModule:SetWindowScale(s)
  BomC_MainWindow:SetScale(s)
end

function BOM.ShowWindow(tab)
  if not InCombatLockdown() then
    if not BOM.WindowVisible() then
      BomC_MainWindow:Show()
      buffomatModule:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)
      buffomatModule.autoHelper = "KeepOpen"
    else
      BOM.BtnClose()
    end
    toolboxModule:SelectTab(BomC_MainWindow, tab or 1)
  else
    BOM:Print(_t("message.ShowHideInCombat"))
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
    taskScanModule:UpdateScan("ToggleWindow")
    BOM.ShowWindow()
  end
end

function BOM.AutoOpen()
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
    if not BOM.WindowVisible() and buffomatModule.autoHelper == "open" then
      buffomatModule.autoHelper = "close"
      BomC_MainWindow:Show()
      BomC_MainWindow:SetScale(tonumber(buffomatModule.shared. UIWindowScale) or 1.0)
      toolboxModule:SelectTab(BomC_MainWindow, 1)
    end
  end
end

function BOM.AutoClose(x)
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
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
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
    if buffomatModule.autoHelper == "KeepClose" then
      buffomatModule.autoHelper = "open"
    end
  end
end

function BOM.SaveWindowPosition()
  buffomatModule.shared.X = BomC_MainWindow:GetLeft()
  buffomatModule.shared.Y = BomC_MainWindow:GetTop()
  buffomatModule.shared.Width = BomC_MainWindow:GetWidth()
  buffomatModule.shared.Height = BomC_MainWindow:GetHeight()
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

  print("LastTracking:", buffomatModule.character.LastTracking, " ")
  print("ForceTracking:", BOM.ForceTracking, " ")
  print("ActivAura:", BOM.ActivePaladinAura, " ")
  print("LastAura:", BOM.CurrentProfile.LastAura, " ")
  print("ActivSeal:", BOM.ActivePaladinSeal, " ")
  print("LastSeal:", BOM.CurrentProfile.LastSeal, " ")
  print("Shapeshift:", GetShapeshiftFormID(), " ")
  print("Weaponenchantment:", GetWeaponEnchantInfo())

  --local name, icon, count, debuffType, duration, expirationTime, source,
  --isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff,
  --castByPlayer, nameplateShowAll, timeMod
  for buffIndex = 1, 40 do
    local unitAura = buffomatModule:UnitAura(dest, buffIndex, "HELPFUL")

    if unitAura.name or unitAura.icon or unitAura.count or unitAura.debuffType then
      print("Help:", unitAura.name, unitAura.spellId, unitAura.duration,
              unitAura.expirationTime, unitAura.source,
              (unitAura.expirationTime or 0) - GetTime())
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
