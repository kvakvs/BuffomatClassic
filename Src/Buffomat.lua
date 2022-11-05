--local TOCNAME, _ = ...

---@shape BomBuffomatModule
---@field [string] any
---@field shared BomSharedSettings Refers to BuffomatShared global
---@field character BomCharacterSettings Refers to BuffomatCharacter global
---@field currentProfileName string
---@field currentProfile BomProfile
---@field forceUpdateRequestedBy table<string, number> Reasons for force update, with count
local buffomatModule = { forceUpdateRequestedBy = {} }
BomModuleManager.buffomatModule = buffomatModule

local characterSettingsModule = BomModuleManager.characterSettingsModule
local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local characterStateModule = BomModuleManager.characterSettingsModule
local constModule = BomModuleManager.constModule
local eventsModule = BomModuleManager.eventsModule
local languagesModule = BomModuleManager.languagesModule
local managedUiModule = BomModuleManager.myButtonModule
local optionsModule = BomModuleManager.optionsModule
local optionsPopupModule = BomModuleManager.optionsPopupModule
local profileModule = BomModuleManager.profileModule
local sharedStateModule = BomModuleManager.sharedSettingsModule
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule
local taskScanModule = BomModuleManager.taskScanModule
local toolboxModule = BomModuleManager.toolboxModule
local macroModule = BomModuleManager.macroModule

---Collection of tables of buffs, indexed per unit name
---@shape BomBuffCollectionPerUnit
---@field [string] BomBuffExpirations Buffs on that unit

---Table of buff expirations, indexed per buff name
---@shape BomBuffExpirations
---@field [string] number Expiration time

---global, visible from XML files and from script console and chat commands
---@class BomAddon
---@field activePaladinAura nil|number Spell id of aura if an unique aura was casted (only one can be active)
---@field activePaladinSeal nil|number Spell id of weapon seal, if an seal-type temporary enchant was used (only one can be active)
---@field ALL_PROFILES BomProfileName[] Lists all buffomat profile names (group, solo... etc)
---@field allBuffomatBuffs BomAllBuffsTable All spells known to Buffomat
---@field allSpellIds number[]
---@field reputationTrinketZones table Equipped AD trinket: Spell to and zone ids to check
---@field buffExchangeId table<number, number[]> Combines spell ids of spellrank flavours into main spell id
---@field buffIgnoreAll number[] Having this buff on target excludes the target (phaseshifted imp for example)
---@field cachedPlayerBag table<string, CachedItem> Items in player's bag
---@field cancelBuffs BomBuffDefinition[] All spells to be canceled on detection
---@field cancelBuffSource string Unit who casted the buff to be auto-canceled
---@field cancelForm table<number, number> Spell ids which cancel shapeshift form
---@field ridingSpeedZones BomRidingSpeedZones Equipped Riding trinket: Spell to and zone ids to check
---@field castFailedBuff BomBuffDefinition|nil
---@field castFailedBuffTarget BomUnit|nil
---@field castFailedSpellId number
---@field checkCooldown number|nil Spell id to check cooldown for
---@field checkForError boolean Used by error suppression code
---@field configToSpellLookup BomAllBuffsTable
---@field currentProfile BomProfile Current profile from CharacterState.Profiles
---@field declineHasResurrection boolean Set to true on combat start, stop, holding Alt, cleared on party update
---@field enchantList {[BomSpellId] number[]} Spell ids mapping to enchantment ids
---@field enchantToSpellLookup {[number] BomSpellId} Reverse-maps enchantment ids back to spells
---@field forceProfile BomProfileName|nil Nil will choose profile name automatically, otherwise this profile will be used
---@field forceTracking number|nil Defines icon id for enforced tracking
---@field forceUpdate boolean Requests immediate spells/buffs refresh
---@field haveTBC boolean Whether we are running TBC classic or later
---@field haveWotLK boolean Whether we are running Wrath of the Lich King or later
---@field inLoadingScreen boolean True while in the loading screen
---@field isClassic boolean Whether we are running Classic Era or Season of Mastery
---@field isPlayerMoving boolean Indicated that the player is moving (updated in event handlers)
---@field isTBC boolean Whether we are running TBC classic
---@field isWotLK boolean Whether we are running Wrath of the Lich King
---@field itemCache {[BomItemId] BomItemCacheElement} Precreated precached items
---@field itemIdLookup {[string] table<string, number>} Map of item name to id
---@field itemList number[][] Group different ranks of item together
---@field itemListSpellLookup table<number, number> Map itemid to spell?
---@field itemListTarget table<number, string> Remember who casted item buff on you?
---@field lastTarget string|nil Last player's target
---@field legacyOptions BomLegacyUiOptions
---@field LoadingScreenTimeOut number
---@field Macro BomMacro
---@field MANA_CLASSES BomClass[] Classes with mana resource
---@field ManaLimit number Player max mana
---@field MinimapButton GPIMinimapButton Minimap button control
---@field nextCooldownDue number Set this to next spell cooldown to force update
---@field PartyUpdateNeeded boolean Requests player party update
---@field PlayerBuffs BomBuffCollectionPerUnit
---@field PlayerCasting string|nil Indicates that the player is currently casting (updated in event handlers)
---@field PopupDynamic BomPopupDynamic
---@field QuickSingleBuff BomLegacyControl Button for single/group buff toggling next to cast button
---@field RepeatUpdate boolean Requests some sort of spells update similar to ForceUpdate
---@field RESURRECT_CLASS BomClass[] Classes who can resurrect others
---@field ScanModifier boolean Will update buffomat when modifier key is held down
---@field SelectedSpells BomAllBuffsTable
---@field SetupAvailableSpells function
---@field SomeBodyGhost boolean [unused?] Someone in the party is a ghost
---@field SpellId table<string, table<string, number>> Map of spell name to id
---@field SpellIdIsSingle table<number, boolean> Whether spell ids are single buffs
---@field SpellIdtoConfig table<number, number> Maps spell ids to the key id of spell in the AllSpells
---@field SpellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field SpellToSpell table<number, number> Maps spells ids to other spell ids
---@field TBC boolean Whether we are running TBC classic
---@field WipeCachedItems boolean Command to reset cached items

BuffomatAddon = LibStub("AceAddon-3.0"):NewAddon(
        "Buffomat", "AceConsole-3.0", "AceEvent-3.0") ---@type BomAddon
local BOM = BuffomatAddon

local _, _, _, tocversion = GetBuildInfo()
BOM.isWotLK = (tocversion >= 30000 and tocversion <= 39999) -- TODO: change to WOTLK detection via WOW_PROJECT_..._CLASSIC
BOM.haveWotLK = BOM.isWotLK

BOM.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
BOM.haveTBC = BOM.isWotLK or BOM.isTBC

BOM.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

---Print a text with "BomDebug: " prefix in the game chat window
---@param t string
function BOM:Debug(t)
  if buffomatModule.shared.DebugLogging then
    DEFAULT_CHAT_FRAME:AddMessage(tostring(GetTime()) .. " " .. buffomatModule:Color("883030", "BOM") .. t)
  end
end

---@param t string
function buffomatModule:P(t)
  -- -@diagnostic disable-next-line
  BOM:Print(t)
end

function buffomatModule:Color(hex, text)
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
  optionsPopupModule:Setup(self, nil)
end

---Bound the the macro cast button in the buff tab
function BOM.BtnMacro()
  PickupMacro(constModule.MACRO_NAME)
end

function BOM.ScrollMessage(self, delta)
  self:SetScrollOffset(self:GetScrollOffset() + delta * 5);
  self:ResetAllFadeTimes()
end

function buffomatModule:ClearForceUpdate(debugCallerLocation)
  if debugCallerLocation then
    BOM:Debug("clearForceUpdate from " .. debugCallerLocation)
  end
  wipe(self.forceUpdateRequestedBy)
end

---@param reason string
function buffomatModule:SetForceUpdate(reason)
  self.forceUpdateRequestedBy[reason] = (self.forceUpdateRequestedBy[reason] or 0) + 1
end

-- Something changed (buff gained possibly?) update all spells and spell tabs
function buffomatModule:OptionsUpdate()
  buffomatModule:SetForceUpdate("optionsUpdate")
  taskScanModule:ScanNow("OptionsUpdate")

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
---@param profile BomProfileName
function buffomatModule.ChooseProfile(profile)
  if profile == nil or profile == "" or profile == "auto" then
    BOM.forceProfile = nil
  elseif buffomatModule.character[profile] then
    BOM.forceProfile = profile
  else
    buffomatModule:P("Unknown profile: " .. profile)
    return
  end

  taskScanModule:ClearSkip()
  BOM.PopupDynamic:Wipe()
  buffomatModule:SetForceUpdate("profileSelected")
  taskScanModule:ScanNow("profileSelected")

  buffomatModule:UseProfile(profile)
end

---@param profileName BomProfileName
function buffomatModule:UseProfile(profileName)
  if buffomatModule.currentProfileName == profileName then
    return
  end

  buffomatModule.currentProfileName = profileName

  local selectedProfile = self.character[profileName] or characterSettingsModule:New(nil)
  buffomatModule.currentProfile = selectedProfile

  BomC_MainWindow_Title:SetText(BOM.FormatTexture(constModule.BOM_BEAR_ICON_FULLPATH) .. _t("profile_" .. profileName))
  -- .. " - " .. constModule.SHORT_TITLE

  buffomatModule:P("Using profile " .. _t("profile_" .. profileName))
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
            texturesModule.ICON_SELF_CAST_ON,
            texturesModule.ICON_SELF_CAST_OFF,
            nil, nil, nil, nil, nil)
    BOM.QuickSingleBuff:SetPoint("BOTTOMLEFT", parent_frame, "BOTTOMRIGHT", -18, 0);
    BOM.QuickSingleBuff:SetPoint("BOTTOMRIGHT", parent_frame, "BOTTOMRIGHT", -2, 12);
    BOM.QuickSingleBuff:SetVariable(buffomatModule.shared, "NoGroupBuff", nil)
    BOM.QuickSingleBuff:SetOnClick(BOM.MyButtonOnClick)
    toolboxModule:TooltipText(
            BOM.QuickSingleBuff,
            BOM.FormatTexture(texturesModule.ICON_SELF_CAST_ON) .. " - " .. _t("options.long.NoGroupBuff")
                    .. "|n"
                    .. BOM.FormatTexture(texturesModule.ICON_SELF_CAST_OFF) .. " - " .. _t("options.long.GroupBuff"))

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

  buffomatModule:OptionsInit()
  BOM.PartyUpdateNeeded = true
  BOM.RepeatUpdate = false

  -- Make main frame draggable
  toolboxModule:EnableMoving(BomC_MainWindow, BOM.SaveWindowPosition)
  BomC_MainWindow:SetMinResize(180, 90)

  toolboxModule:AddTab(BomC_MainWindow, _t("TabBuff"), BomC_ListTab, true)
  toolboxModule:AddTab(BomC_MainWindow, _t("TabSpells"), BomC_SpellTab, true)
  toolboxModule:SelectTab(BomC_MainWindow, 1)
end

function buffomatModule:InitGlobalStates()
  -- Upgrade from legacy Buffomat State if found
  ---@type BomSharedSettings
  local loadedShared = (--[[---@type BomSharedSettings]] BomSharedState or BuffomatShared) or {}
  if BomSharedState then
    BomSharedState = nil -- reset after reimport
  end
  BuffomatShared = sharedStateModule:New(loadedShared) ---@type BomSharedSettings
  buffomatModule.shared = BuffomatShared

  -- Upgrade from legacy Buffomat State if found
  local loadedChar = (--[[---@type BomCharacterSettings]] BomCharacterState or BuffomatCharacter) or {}
  if BomCharacterState then
    BomCharacterState = nil -- reset after reimport
  end
  BuffomatCharacter = characterStateModule:New(loadedChar) ---@type BomCharacterSettings
  buffomatModule.character = BuffomatCharacter

  if self.character.Duration then
    self.shared.Duration = self.character.Duration
    self.character.Duration = --[[---@type BomSpellCooldownsTable]] {}
  elseif not self.shared.Duration then
    self.shared.Duration = --[[---@type BomSpellCooldownsTable]] {}
  end

  if not self.character[profileModule.ALL_PROFILES[1]] then
    local newProfile = profileModule:New()
    newProfile.CancelBuff = self.character.CancelBuff
    newProfile.Spell = self.character.Spell
    newProfile.LastAura = self.character.LastAura
    newProfile.LastSeal = self.character.LastSeal
    self.character[profileModule.ALL_PROFILES[1]] = newProfile

    self.character.CancelBuff = nil
    self.character.Spell = nil
    self.character.LastAura = nil
    self.character.LastSeal = nil
  end

  for i, each_profile in ipairs(profileModule.ALL_PROFILES) do
    if not self.character[each_profile] then
      self.character[each_profile] = profileModule:New()
    end
  end

  --BOM.SharedState = self.shared
  --BOM.CharacterState = self.character
  local soloProfile = profileModule:SoloProfile()
  BOM.currentProfile = self.character[soloProfile or "solo"]
end

---Called from event handler on Addon Loaded event
---Execution start here
function BuffomatAddon:Init()
  languagesModule:SetupTranslations()
  allBuffsModule:SetupSpells()
  allBuffsModule:SetupCancelBuffs()
  --BOM.SetupItemCache()
  taskScanModule:SetupTasklist()

  BOM.Macro = macroModule:NewMacro(constModule.MACRO_NAME, nil)

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

  toolboxModule:EnableSize(BomC_MainWindow, 8, nil, function()
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

    buffomatModule:P("Set " .. var .. " to " .. tostring(DB[var]))
    buffomatModule:OptionsUpdate()
  end

  toolboxModule:SlashCommand({ "/bom", "/buffomat" }, {
    { "debug", "", {
      { "buff", "", BOM.DebugBuffList },
      { "target", "", BOM.DebugBuffs, "target" },
    },
    },
    { "profile", "", {
      { "%", _t("SlashProfile"), buffomatModule.ChooseProfile }
    },
    },
    { "spellbook", _t("SlashSpellBook"), BOM.SetupAvailableSpells },
    { "update", _t("SlashUpdate"),
      function()
        buffomatModule:SetForceUpdate("macro-/update")
        taskScanModule:ScanNow("macro-/update")
      end },
    { "updatespellstab", "", spellButtonsTabModule.UpdateSpellsTab },
    { "close", _t("SlashClose"), BOM.HideWindow },
    { "reset", _t("SlashReset"), BOM.ResetWindow },
    { "_checkforerror", "",
      function()
        if not InCombatLockdown() then
          BOM.checkForError = true
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
end

---AceAddon handler
function BuffomatAddon:OnEnable()
  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize
  self:Init()
  eventsModule:InitEvents()
  local onClick = function(self, button)
    if button == "LeftButton" then
      buffomatModule:ToggleWindow()
    else
      optionsPopupModule:Setup(self, true)
    end
  end
  toolboxModule:AddDataBroker(
          constModule.BOM_BEAR_ICON_FULLPATH,
          onClick, nil, nil)
  buffomatModule:UseProfile(profileModule:SoloProfile())
end

---AceAddon handler
function BuffomatAddon:OnDisable()
end

function buffomatModule:DownGrade()
  if BOM.castFailedBuff
          and (--[[---@not nil]] BOM.castFailedBuff).SkipList
          and BOM.castFailedBuffTarget then
    local level = UnitLevel((--[[---@not nil]] BOM.castFailedBuffTarget).unitId)

    if level ~= nil and level > -1 then
      if self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] == nil
              or self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] < level
      then
        self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] = level
        self:FastUpdateTimer()
        self:SetForceUpdate("Downgrade")
        self:P(string.format(_t("MsgDownGrade"),
                (--[[---@not nil]] BOM.castFailedBuff).singleText,
                ((--[[---@not nil]] BOM.castFailedBuffTarget).name)))

      elseif buffomatModule.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] >= level then
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
buffomatModule.SPELLS_TAB_UPDATE_DELAY = 2.0

---bumped from 0.1 which potentially causes Naxxramas lag?
---Checking BOM.SharedState.SlowerHardware will use bom_slowerhardware_update_timer_limit
buffomatModule.updateTimerLimit = 0.500
buffomatModule.slowerhardwareUpdateTimerLimit = 1.500
-- This is written to updateTimerLimit if overload is detected in a large raid or slow hardware
buffomatModule.BOM_THROTTLE_TIMER_LIMIT = 1.000
buffomatModule.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT = 2.000

buffomatModule.lastSpellsTabUpdate = 0

---This runs every frame, do not do any excessive work here
function buffomatModule.UpdateTimer(elapsed)
  --if elapsed > 0.1 then buffomatModule:P("Elapsed: " .. elapsed) end

  local now = GetTime()

  if BOM.inLoadingScreen and BOM.LoadingScreenTimeOut then
    if BOM.LoadingScreenTimeOut > now then
      return
    else
      BOM.inLoadingScreen = false
      eventsModule:OnCombatStop()
    end
  end

  -- Update spells tab if necessary and update last update time if successful
  if now - buffomatModule.lastSpellsTabUpdate > buffomatModule.SPELLS_TAB_UPDATE_DELAY then
    if spellButtonsTabModule:UpdateSpellsTab_Throttled() then
      buffomatModule.lastSpellsTabUpdate = now
    end
  end

  if BOM.nextCooldownDue and BOM.nextCooldownDue <= now then
    buffomatModule:SetForceUpdate("cdDue")
  end

  if BOM.checkCooldown then
    local cdtest = GetSpellCooldown(BOM.checkCooldown)
    if cdtest == 0 then
      BOM.checkCooldown = nil
      buffomatModule:SetForceUpdate("checkCd")
    end
  end

  if BOM.ScanModifier and buffomatModule.lastModifierKeyState ~= IsModifierKeyDown() then
    buffomatModule.lastModifierKeyState = IsModifierKeyDown()
    buffomatModule:SetForceUpdate("ModifierKeyDown")
  end

  --
  -- Update timers, slow hardware and auto-throttling
  -- This will trigger update on timer, regardless of other conditions
  --
  --buffomatModule.fpsCheck = buffomatModule.fpsCheck + 1

  local updateTimerLimit = buffomatModule.updateTimerLimit
  if buffomatModule.shared.SlowerHardware then
    updateTimerLimit = buffomatModule.slowerhardwareUpdateTimerLimit
  end

  local needForceUpdate = next(buffomatModule.forceUpdateRequestedBy) ~= nil

  if (needForceUpdate or BOM.RepeatUpdate)
          and now - (buffomatModule.lastUpdateTimestamp or 0) > updateTimerLimit
          and InCombatLockdown() == false
  then
    buffomatModule.lastUpdateTimestamp = now
    buffomatModule.fpsCheck = debugprofilestop()

    -- Debug: Print the callers as reasons to force update
    -- buffomatModule:PrintCallers("Update: ", buffomatModule.forceUpdateRequestedBy)
    buffomatModule:ClearForceUpdate(nil)
    taskScanModule:ScanNow("timer")

    -- If updatescan call above took longer than 32 ms, and repeated update, then
    -- bump the slow alarm counter, once it reaches 32 we consider throttling.
    -- 1000 ms / 32 ms = 31.25 fps
    if (debugprofilestop() - buffomatModule.fpsCheck) > 32 and BOM.RepeatUpdate then
      buffomatModule.slowCount = buffomatModule.slowCount + 1

      if buffomatModule.slowCount >= 20 and updateTimerLimit < 1 then
        buffomatModule.updateTimerLimit = buffomatModule.BOM_THROTTLE_TIMER_LIMIT
        buffomatModule.slowerhardwareUpdateTimerLimit = buffomatModule.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT
        buffomatModule:P("Overwhelmed - slowing down the scans!")
      end
    else
      buffomatModule.slowCount = 0
    end
  end
end

function buffomatModule:FastUpdateTimer()
  buffomatModule.lastUpdateTimestamp = 0
end

BOM.PlayerBuffs = --[[---@type BomBuffCollectionPerUnit]] {}

---@shape BomUnitAuraResult
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

function buffomatModule:PrintCallers(prefix, callersCollection)
  if next(callersCollection) then
    local callers = ""
    for caller, count in pairs(callersCollection) do
      if count > 1 then
        callers = callers .. string.format("%s:%d; ", caller, count)
      else
        callers = callers .. string.format("%s; ", caller)
      end
    end
    buffomatModule:P(prefix .. callers)
  end
end

---Handles UnitAura WOW API call.
---For spells that are tracked by Buffomat the data is also stored in BOM.PlayerBuffs
---@param unitId string
---@param buffIndex number Index of buff/debuff slot starts 1 max 40?
---@param filter string Filter string like "HELPFUL", "PLAYER", "RAID"... etc
---@return BomUnitAuraResult
function buffomatModule:UnitAura(unitId, buffIndex, filter)
  ---@type string, string, number, string, number, number, string, boolean, boolean, number, boolean, boolean, boolean, boolean, number
  local name, icon, count, debuffType, duration, expirationTime, source, isStealable
  , nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer
  , nameplateShowAll, timeMod = UnitAura(unitId, buffIndex, filter)

  if spellId and BOM.allSpellIds and tContains(BOM.allSpellIds, spellId) then

    if source ~= nil and source ~= "" and UnitIsUnit(source, "player") then
      if UnitIsUnit(unitId, "player") and duration ~= nil and duration > 0 then
        self.shared.Duration[name] = duration
      end

      if duration == nil or duration == 0 then
        duration = self.shared.Duration[name] or 0
      end

      if duration > 0 and (expirationTime == nil or expirationTime == 0) then
        local destName = UnitFullName(unitId) ---@type string

        if BOM.PlayerBuffs[destName] and BOM.PlayerBuffs[destName][name] then
          expirationTime = BOM.PlayerBuffs[destName][name] + duration

          local now = GetTime()

          if expirationTime <= now then
            BOM.PlayerBuffs[destName][name] = now
            expirationTime = now + duration
          end
        end
      end

      if expirationTime == 0 then
        duration = 0
      end
    end

  end

  return {
    name                  = name,
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
    timeMod               = timeMod
  }
end

buffomatModule.autoHelper = "open"

function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      buffomatModule.autoHelper = "KeepClose"
      buffomatModule:SetForceUpdate("hideWindow")
      taskScanModule:ScanNow("hideWindow")
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
    buffomatModule:P(_t("message.ShowHideInCombat"))
  end
end

function BOM.WindowVisible()
  return BomC_MainWindow:IsVisible()
end

function buffomatModule:ToggleWindow()
  if BomC_MainWindow:IsVisible() then
    BOM.HideWindow()
  else
    buffomatModule:SetForceUpdate("toggleWindow")
    taskScanModule:ScanNow("toggleWindow")
    BOM.ShowWindow(nil)
  end
end

function buffomatModule:AutoOpen()
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
    if not BOM.WindowVisible() and buffomatModule.autoHelper == "open" then
      buffomatModule.autoHelper = "close"
      BomC_MainWindow:Show()
      BomC_MainWindow:SetScale(tonumber(buffomatModule.shared. UIWindowScale) or 1.0)
      toolboxModule:SelectTab(BomC_MainWindow, 1)
    end
  end
end

function buffomatModule:AutoClose()
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
  buffomatModule:P("Window position is reset.")
end

local function perform_who_request(name)
  DEFAULT_CHAT_FRAME.editBox:SetText("/who " .. name)
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox)
end

local function perform_whisper_request(name)
  ChatFrame_OpenChat("/w " .. name .. " ")
end

function BOM.EnterHyperlink(_control, link)
  --print(link,text)
  local part = toolboxModule:Split(link, ":")
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
  local part = toolboxModule:Split(link, ":")
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
  print("ForceTracking:", BOM.forceTracking, " ")
  print("ActivAura:", BOM.activePaladinAura, " ")
  print("LastAura:", BOM.currentProfile.LastAura, " ")
  print("ActivSeal:", BOM.activePaladinSeal, " ")
  print("LastSeal:", BOM.currentProfile.LastSeal, " ")
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
