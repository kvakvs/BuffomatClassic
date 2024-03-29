--local TOCNAME, _ = ...

---@shape BomBuffomatModule
---@field [string] any
---@field shared BomSharedSettings Refers to BuffomatShared global
---@field character BomCharacterSettings Refers to BuffomatCharacter global
---@field currentProfileName string
---@field currentProfile BomProfile
---@field taskRescanRequestedBy {[string]: number} Reasons for force update, with count
local buffomatModule = BomModuleManager.buffomatModule ---@type BomBuffomatModule
buffomatModule.taskRescanRequestedBy = --[[---@type {[string]: number}]] {}

local kvEnvModule = KvModuleManager.envModule
local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local characterSettingsModule = BomModuleManager.characterSettingsModule
local characterStateModule = BomModuleManager.characterSettingsModule
local constModule = BomModuleManager.constModule
local eventsModule = BomModuleManager.eventsModule
local languagesModule = BomModuleManager.languagesModule
local macroModule = BomModuleManager.macroModule
local managedUiModule = BomModuleManager.myButtonModule
local optionsModule = BomModuleManager.optionsModule
local optionsPopupModule = BomModuleManager.optionsPopupModule
local partyModule = BomModuleManager.partyModule
local popupModule = BomModuleManager.popupModule
local profileModule = BomModuleManager.profileModule
local sharedStateModule = BomModuleManager.sharedSettingsModule
local slashModule = BomModuleManager.slashCommandsModule
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule
local taskScanModule = BomModuleManager.taskScanModule
local texturesModule = BomModuleManager.texturesModule
local toolboxModule = BomModuleManager.toolboxModule

---@alias BomCastingState "cast"|"channel"|nil

---global, visible from XML files and from script console and chat commands
---@class BomAddon
---@field activePaladinAura nil|number Spell id of aura if an unique aura was casted (only one can be active)
---@field activePaladinSeal nil|number Spell id of weapon seal, if an seal-type temporary enchant was used (only one can be active)
---@field ALL_PROFILES BomProfileName[] Lists all buffomat profile names (group, solo... etc)
---@field buffExchangeId table<number, number[]> Combines spell ids of spellrank flavours into main spell id
---@field buffIgnoreAll number[] Having this buff on target excludes the target (phaseshifted imp for example)
---@field cachedPlayerBag BomCachedPlayerBag Items in player's bag
---@field cancelBuffs BomBuffDefinition[] All spells to be canceled on detection
---@field cancelBuffSource string Unit who casted the buff to be auto-canceled
---@field castFailedBuff BomBuffDefinition|nil
---@field castFailedBuffTarget BomUnit|nil
---@field castFailedSpellId number|nil
---@field checkCooldown number|nil Spell id to check cooldown for
---@field checkForError boolean Used by error suppression code
---@field currentProfile BomProfile Current profile from CharacterState.Profiles
---@field declineHasResurrection boolean Set to true on combat start, stop, holding Alt, cleared on party update
---@field drinkingPersonCount number Used for warning "X persons is/are drinking"
---@field AllDrink WowSpellId[] Used for warning "X persons is/are drinking"
---@field enchantList {[WowSpellId]: number[]} Spell ids mapping to enchantment ids
---@field forceProfile BomProfileName|nil Nil will choose profile name automatically, otherwise this profile will be used
---@field forceTracking WowIconId|nil Defines icon id for enforced tracking
---@field forceUpdate boolean Requests immediate spells/buffs refresh
---@field inLoadingScreen boolean True while in the loading screen
---@field isPlayerCasting BomCastingState Indicates that the player is currently casting (updated in event handlers)
---@field isPlayerMoving boolean Indicated that the player is moving (updated in event handlers)
---@field itemList number[][] Group different ranks of item together
---@field lastAura BomBuffId|nil Buff id of active or last active aura
---@field lastTarget string|nil Last player's target
---@field loadingScreenTimeOut number|nil
---@field theMacro BomMacro
---@field MANA_CLASSES BomClassName[] Classes with mana resource
---@field minimapButton BomMinimapButtonPlaceholder Minimap button control
---@field nextCooldownDue number Set this to next spell cooldown to force update
---@field isPartyUpdateNeeded boolean Requests player party update
---@field popupMenuDynamic BomPopupDynamic
---@field quickSingleBuffToggleButton BomGPIControl Button for single/group buff toggling next to cast button
---@field repeatUpdate boolean Requests some sort of spells update similar to ForceUpdate
---@field reputationTrinketZones BomReputationTrinketZones Equipped AD trinket: Spell to and zone ids to check
---@field RESURRECT_CLASS BomClassName[] Classes who can resurrect others
---@field ridingSpeedZones BomRidingSpeedZones Equipped Riding trinket: Spell to and zone ids to check
---@field SaveTargetName string|nil
---@field scanModifierKeyDown boolean Will update buffomat when modifier key is held down
---@field somebodyIsGhost boolean [unused?] Someone in the party is a ghost
---@field spellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field wipeCachedItems boolean Command to reset cached items on the next call to itemListCacheModule; TODO move to itemListCacheModule
---@field Print fun(self: BomAddon, msg: string): void
---@field RegisterEvent fun(self: BomAddon, event: string, handler: function): void
---@field setupAvailableSpellsFn function

BuffomatAddon = LibStub("AceAddon-3.0"):NewAddon(
        "Buffomat", "AceConsole-3.0", "AceEvent-3.0") ---@type BomAddon
local BOM = BuffomatAddon

---@shape BomCachedBagItem
---@field a boolean Player has item
---@field b number Bag
---@field c number Slot
---@field d number Count

---@alias BomCachedPlayerBag table<string, BomCachedBagItem>

---@type table<string, BomCachedBagItem>
BOM.cachedPlayerBag = {}

---Print a text with "BomDebug: " prefix in the game chat window
---@param t string
function BOM:Debug(t)
  if buffomatModule.shared.DebugLogging then
    DEFAULT_CHAT_FRAME:AddMessage(tostring(GetTime()) .. " " .. buffomatModule:Color("883030", "BOM ") .. t)
  end
end

function buffomatModule:Color(hex, text)
  return "|cff" .. hex .. text .. "|r"
end

---Creates a string which will display a picture in a FontString
---@param texture WowIconId - path to UI texture file (for example can come from C_Container.GetContainerItemInfo(bag, slot) or spell info etc
function BOM.FormatTexture(texture)
  return string.format(constModule.ICON_FORMAT, texture)
end

function BOM.BtnClose()
  BOM.HideWindow()
end

function BOM.BtnSettings(settingsButton)
  optionsPopupModule:Setup(settingsButton, false)
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
  wipe(self.taskRescanRequestedBy)
end

---@param reason string
function buffomatModule:RequestTaskRescan(reason)
  self.taskRescanRequestedBy[reason] = (self.taskRescanRequestedBy[reason] or 0) + 1
end

---@param castingState BomCastingState
function buffomatModule:SetPlayerCasting(castingState)
  BOM.isPlayerCasting = castingState
end

-- Something changed (buff gained possibly?) update all spells and spell tabs
function buffomatModule.OptionsUpdate()
  buffomatModule:RequestTaskRescan("optionsUpdate")
  taskScanModule:ScanTasks("OptionsUpdate")

  spellButtonsTabModule:UpdateSpellsTab("OptionsUpdate")
  managedUiModule:UpdateAll()
  BOM.minimapButton:UpdatePosition()
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
    BOM:Print("Unknown profile: " .. profile)
    return
  end

  taskScanModule:ClearSkip()
  BOM.popupMenuDynamic:Wipe(nil)
  buffomatModule:RequestTaskRescan("profileSelected")
  taskScanModule:ScanTasks("profileSelected")

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

  BOM:Print("Using profile " .. _t("profile_" .. profileName))
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
  if BOM.quickSingleBuffToggleButton == nil then
    BOM.quickSingleBuffToggleButton = managedUiModule:CreateManagedButton(
            parent_frame,
            texturesModule.ICON_SELF_CAST_ON,
            texturesModule.ICON_SELF_CAST_OFF,
            nil, nil, nil, nil, nil)
    BOM.quickSingleBuffToggleButton:SetPoint("BOTTOMLEFT", parent_frame, "BOTTOMRIGHT", -18, 0);
    BOM.quickSingleBuffToggleButton:SetPoint("BOTTOMRIGHT", parent_frame, "BOTTOMRIGHT", -2, 12);
    BOM.quickSingleBuffToggleButton:SetVariable(buffomatModule.shared, "NoGroupBuff", nil)
    BOM.quickSingleBuffToggleButton:SetOnClick(BOM.MyButtonOnClick)
    toolboxModule:TooltipText(
            BOM.quickSingleBuffToggleButton,
            BOM.FormatTexture(texturesModule.ICON_SELF_CAST_ON) .. " - " .. _t("options.long.NoGroupBuff")
                    .. "|n"
                    .. BOM.FormatTexture(texturesModule.ICON_SELF_CAST_OFF) .. " - " .. _t("options.long.GroupBuff"))

    BOM.quickSingleBuffToggleButton:Show()
  end
end

local libDB = LibStub("LibDataBroker-1.1")
local libIcon = LibStub("LibDBIcon-1.0")

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

  BOM.popupMenuDynamic = popupModule:CreatePopup(buffomatModule.OptionsUpdate)

  local function onMinimapClick(self1, button)
    if button == "LeftButton" then
      buffomatModule:ToggleWindow()
    else
      optionsPopupModule:Setup(Minimap, true)
    end
  end

  local buffomatLDB = libDB:NewDataObject("BuffomatIcon", {
    type = "data source",
    text = "Buffomat",
    icon = constModule.BOM_BEAR_ICON_FULLPATH,
    OnClick = onMinimapClick,
  })
  libIcon:Register("BuffomatIcon", buffomatLDB, self.shared.Minimap)

  buffomatModule:OptionsInit()
  partyModule:InvalidatePartyCache()
  BOM.repeatUpdate = false

  -- Make main frame draggable
  toolboxModule:EnableMoving(BomC_MainWindow, BOM.SaveWindowPosition)
  if BomC_MainWindow.SetMinResize ~= nil then BomC_MainWindow:SetMinResize(180, 90) end

  toolboxModule:AddTab(--[[---@type WowControl]] BomC_MainWindow, _t("TabBuff"), BomC_ListTab, true)
  toolboxModule:AddTab(--[[---@type WowControl]] BomC_MainWindow, _t("TabSpells"), BomC_SpellTab, true)
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
  buffomatModule.character = characterStateModule:New(loadedChar)
  BuffomatCharacter = buffomatModule.character

  if self.character.remainingDurations then
    self.shared.Duration = self.character.remainingDurations
    self.character.remainingDurations = --[[---@type BomSpellDurationsTable]] {}
  elseif not self.shared.Duration then
    self.shared.Duration = --[[---@type BomSpellDurationsTable]] {}
  end

  if not self.character[profileModule.ALL_PROFILES[1]] then
    local newProfile = profileModule:New()
    --newProfile.CancelBuff = self.character.CancelBuff or {}
    newProfile.Spell = self.character.Spell or {}
    newProfile.LastAura = self.character.LastAura
    newProfile.LastSeal = self.character.LastSeal
    self.character[profileModule.ALL_PROFILES[1]] = newProfile

    self.character.CancelBuff = nil
    self.character.Spell = --[[---@type BomBuffDefinitionDict]] {}
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

---@return BomSlashCommand[]
function BuffomatAddon:MakeSlashCommand()
  return --[[---@type BomSlashCommand[] ]] {
    { command = "debug", description = "", handler = {
      { command = "buff", description = "", handler = buffomatModule.Slash_DebugBuffList },
      { command = "target", description = "", handler = buffomatModule.Slash_DebugBuffs, target = "target" },
    },
    },
    { command = "profile", description = "", handler = {
      { command = "%", description = _t("SlashProfile"), handler = buffomatModule.ChooseProfile }
    },
    },
    { command = "spellbook", description = _t("SlashSpellBook"), handler = BOM.setupAvailableSpellsFn },
    { command = "update", description = _t("SlashUpdate"),
      handler = function()
        buffomatModule:RequestTaskRescan("macro-/update")
        taskScanModule:ScanTasks("macro-/update")
      end },
    { command = "updatespellstab", description = "", handler = spellButtonsTabModule.UpdateSpellsTab },
    { command = "close", description = _t("SlashClose"), handler = BOM.HideWindow },
    { command = "reset", description = _t("SlashReset"), handler = BOM.ResetWindow },
    { command = "_checkforerror", description = "",
      handler = function()
        if not InCombatLockdown() then
          BOM.checkForError = true
        end
      end },
    { command = "", description = _t("SlashOpen"), handler = BOM.ShowWindow },
  }
end

---Called from event handler on Addon Loaded event
---Execution start here
function BuffomatAddon:Init()
  languagesModule:SetupTranslations()
  allBuffsModule:SetupSpells()
  allBuffsModule:SetupCancelBuffs()

  BOM.theMacro = macroModule:NewMacro(constModule.MACRO_NAME, nil)

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

  slashModule:RegisterSlashCommandHandler({ "/bom", "/buffomat" },
          self:MakeSlashCommand())

  buffomatModule:InitUI()

  -- Which groups are watched by the buff scanner - save in character state
  if not buffomatModule.character.WatchGroup then
    buffomatModule.character.WatchGroup = {}
    for i = 1, 8 do
      buffomatModule.character.WatchGroup[i] = true
    end
  end

  buffomatModule:UpdateBuffTabText()
  buffomatModule:RegisterBindings()
end

-- Key Binding section header and key translations (see Bindings.XML)
function buffomatModule:RegisterBindings()
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
  kvEnvModule:DetectVersions()
end

---AceAddon handler
function BuffomatAddon:OnEnable()
  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize
  self:Init()
  eventsModule:InitEvents()

  local onClick = function(control, button)
    if button == "LeftButton" then
      buffomatModule:ToggleWindow()
    else
      optionsPopupModule:Setup(control, true)
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
          and (--[[---@not nil]] BOM.castFailedBuff).skipList
          and BOM.castFailedBuffTarget then
    local level = UnitLevel((--[[---@not nil]] BOM.castFailedBuffTarget).unitId)

    if level ~= nil and level > -1 then
      if self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] == nil
              or self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] < level
      then
        self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] = level
        self:FastUpdateTimer()
        self:RequestTaskRescan("Downgrade")
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
  if InCombatLockdown() then
    return
  end

  local now = GetTime()

  if BOM.inLoadingScreen and BOM.loadingScreenTimeOut then
    if BOM.loadingScreenTimeOut > now then
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
    buffomatModule:RequestTaskRescan("cdDue")
  end

  if BOM.checkCooldown then
    local cdtest = GetSpellCooldown(BOM.checkCooldown)
    if cdtest == 0 then
      BOM.checkCooldown = nil
      buffomatModule:RequestTaskRescan("checkCd")
    end
  end

  if BOM.scanModifierKeyDown and buffomatModule.lastModifierKeyState ~= IsModifierKeyDown() then
    buffomatModule.lastModifierKeyState = IsModifierKeyDown()
    buffomatModule:RequestTaskRescan("ModifierKeyDown")
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

  local needForceUpdate = next(buffomatModule.taskRescanRequestedBy) ~= nil

  if (needForceUpdate or BOM.repeatUpdate)
          and now - (buffomatModule.lastUpdateTimestamp or 0) > updateTimerLimit
          and InCombatLockdown() == false
  then
    buffomatModule.lastUpdateTimestamp = now
    buffomatModule.fpsCheck = debugprofilestop()

    -- Debug: Print the callers as reasons to force update
    -- buffomatModule:PrintCallers("Update: ", buffomatModule.forceUpdateRequestedBy)
    buffomatModule:ClearForceUpdate(nil)
    taskScanModule:ScanTasks("timer")

    -- If updatescan call above took longer than 32 ms, and repeated update, then
    -- bump the slow alarm counter, once it reaches 32 we consider throttling.
    -- 1000 ms / 32 ms = 31.25 fps
    if (debugprofilestop() - buffomatModule.fpsCheck) > 32 and BOM.repeatUpdate then
      buffomatModule.slowCount = buffomatModule.slowCount + 1

      if buffomatModule.slowCount >= 20 and updateTimerLimit < 1 then
        buffomatModule.updateTimerLimit = buffomatModule.BOM_THROTTLE_TIMER_LIMIT
        buffomatModule.slowerhardwareUpdateTimerLimit = buffomatModule.BOM_THROTTLE_SLOWER_HARDWARE_TIMER_LIMIT
        BOM:Print("Overwhelmed - slowing down the scans!")
      end
    else
      buffomatModule.slowCount = 0
    end
  end
end

function buffomatModule:FastUpdateTimer()
  buffomatModule.lastUpdateTimestamp = 0
end

partyModule.unitAurasLastUpdated = --[[---@type BomBuffUpdatesPerUnit]] {}

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
    BOM:Print(prefix .. callers)
  end
end

buffomatModule.autoHelper = "open"

function BOM.HideWindow()
  if not InCombatLockdown() then
    if BOM.WindowVisible() then
      BomC_MainWindow:Hide()
      buffomatModule.autoHelper = "KeepClose"
      buffomatModule:RequestTaskRescan("hideWindow")
      taskScanModule:ScanTasks("hideWindow")
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
    buffomatModule:RequestTaskRescan("toggleWindow")
    taskScanModule:ScanTasks("toggleWindow")
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
  BOM:Print("Window position is reset.")
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

--function buffomatModule.Slash_DebugBuffs(dest)
--  dest = dest or "player"
--
--  print("LastTracking:", buffomatModule.character.lastTrackingIconId, " ")
--  print("ForceTracking:", BOM.forceTracking, " ")
--  print("ActivAura:", BOM.activePaladinAura, " ")
--  print("LastAura:", BOM.currentProfile.LastAura, " ")
--  print("ActivSeal:", BOM.activePaladinSeal, " ")
--  print("LastSeal:", BOM.currentProfile.LastSeal, " ")
--  print("Shapeshift:", GetShapeshiftFormID(), " ")
--  print("Weaponenchantment:", GetWeaponEnchantInfo())
--
--  --local name, icon, count, debuffType, duration, expirationTime, source,
--  --isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff,
--  --castByPlayer, nameplateShowAll, timeMod
--  for buffIndex = 1, 40 do
--    local unitAura = buffomatModule:UnitAura(dest, buffIndex, "HELPFUL")
--
--    if unitAura.name or unitAura.icon or unitAura.count or unitAura.debuffType then
--      print("Help:", unitAura.name, unitAura.spellId, unitAura.duration,
--              unitAura.expirationTime, unitAura.source,
--              (unitAura.expirationTime or 0) - GetTime())
--    end
--  end -- for 40 buffs
--end

function buffomatModule.Slash_DebugBuffList()
--  print("PlayerBuffs stored ", #partyModule.unitAurasLastUpdated)
--
--  for name, spellist in pairs(partyModule.unitAurasLastUpdated) do
--    print(name)
--
--    for spellname, ti in pairs(spellist) do
--      print(name, spellname, ti, GetTime() - ti)
--    end
--  end
end

function BOM.ShowSpellSettings()
  InterfaceOptionsFrame:Hide()
  GameMenuFrame:Hide()
  BOM.ShowWindow(2)
end

function BOM.MyButtonOnClick(self)
  buffomatModule:OptionsUpdate()
end

function buffomatModule:FadeBuffomatWindow()
  if BomC_ListTab_Button:IsEnabled() then
    BomC_MainWindow:SetAlpha(1.0)
  else
    local fade = self.shared.FadeWhenNothingToDo
    if type(fade) ~= "number" then
      fade = 0.65
    end
    BomC_MainWindow:SetAlpha(fade) -- fade the window, default 65%
  end
end
