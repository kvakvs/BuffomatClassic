---@class BuffomatModule
---@field shared SharedSettings Refers to BuffomatShared global
---@field character CharacterSettings Refers to BuffomatCharacter global
---@field currentProfileName string
---@field currentProfile ProfileSettings
---@field taskRescanRequestedBy {[string]: number} Reasons for force update, with count

local buffomatModule = LibStub("Buffomat-Buffomat") --[[@as BuffomatModule]]
buffomatModule.taskRescanRequestedBy = --[[@as {[string]: number}]] {}
local _t = LibStub("Buffomat-Languages") --[[@as LanguagesModule]]
local languagesModule = _t
local allBuffsModule = LibStub("Buffomat-AllBuffs") --[[@as AllBuffsModule]]
local characterSettingsModule = LibStub("Buffomat-CharacterSettings") --[[@as CharacterSettingsModule]]
local constModule = LibStub("Buffomat-Const") --[[@as ConstModule]]
local eventsModule = LibStub("Buffomat-Events") --[[@as EventsModule]]
local macroModule = LibStub("Buffomat-Macro") --[[@as MacroModule]]
local optionsModule = LibStub("Buffomat-Options") --[[@as OptionsModule]]
local optionsPopupModule = LibStub("Buffomat-OptionsPopup") --[[@as OptionsPopupModule]]
local partyModule = LibStub("Buffomat-Party") --[[@as PartyModule]]
local popupModule = LibStub("Buffomat-Popup") --[[@as PopupModule]]
local profileModule = LibStub("Buffomat-Profile") --[[@as ProfileModule]]
local slashModule = LibStub("Buffomat-SlashCommands") --[[@as SlashCommandsModule]]
local taskScanModule = LibStub("Buffomat-TaskScan") --[[@as TaskScanModule]]
local toolboxModule = LibStub("Buffomat-LegacyToolbox") --[[@as LegacyToolboxModule]]
local taskListPanelModule = LibStub("Buffomat-TaskListPanel") --[[@as TaskListPanelModule]]
local throttleModule = LibStub("Buffomat-Throttle") --[[@as ThrottleModule]]
local ngStringsModule = LibStub("Buffomat-NgStrings") --[[@as NgStringsModule]]

---@alias BomCastingState "cast"|"channel"|nil

---global, visible from XML files and from script console and chat commands
---@class BomAddon : AceAddon
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
---@field currentProfile ProfileSettings Current profile from CharacterState.Profiles
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
---@field nextCooldownDue number Set this to next spell cooldown to force update
---@field isPartyUpdateNeeded boolean Requests player party update
---@field popupMenuDynamic GPIPopupDynamic
---@field repeatUpdate boolean Requests some sort of spells update similar to ForceUpdate
---@field reputationTrinketZones BomReputationTrinketZones Equipped AD trinket: Spell to and zone ids to check
---@field RESURRECT_CLASS BomClassName[] Classes who can resurrect others
---@field ridingSpeedZones BomRidingSpeedZones Equipped Riding trinket: Spell to and zone ids to check
---@field SaveTargetName string|nil
---@field scanModifierKeyDown boolean Will update buffomat when modifier key is held down
---@field somebodyIsGhost boolean [unused?] Someone in the party is a ghost
---@field spellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field wipeCachedItems boolean Command to reset cached items on the next call to itemListCacheModule; TODO move to itemListCacheModule
---@field setupAvailableSpellsFn function
-- -@field Print fun(self: BomAddon, msg: string): void
-- -@field RegisterEvent fun(self: BomAddon, event: string, handler: function): void

BuffomatAddon = LibStub("AceAddon-3.0"):NewAddon("Buffomat", "AceConsole-3.0", "AceEvent-3.0") --[[@as BomAddon]]
local BOM = BuffomatAddon
local libDB = LibStub("LibDataBroker-1.1")
local libIcon = LibStub("LibDBIcon-1.0")

---@class BomCachedBagItem
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

  --spellButtonsTabModule:UpdateSpellsTab("OptionsUpdate")
  managedUiModule:UpdateAll()
  --BOM.minimapButton:UpdatePosition()
  --BOM.legacyOptions.DoCancel()
end

function buffomatModule:OptionsInit()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(
    constModule.SHORT_TITLE, optionsModule:CreateOptionsTable(), {})

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
  elseif buffomatModule.character.profiles[profile] then
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

  local selectedProfile = characterSettingsModule:GetProfile(profileName)
  buffomatModule.currentProfile = selectedProfile

  taskListPanelModule.titleProfile = ngStringsModule:FormatTexture(constModule.BOM_BEAR_ICON_FULLPATH) .. " " .. _t("profile_" .. profileName)
  taskListPanelModule:SetTitle()

  BOM:Print("Using profile " .. _t("profile_" .. profileName))
end

---When BomCharacterState.WatchGroup has changed, update the buff tab text to show what's
---being buffed. Example: "Buff All", "Buff G3,5-7"...
function buffomatModule:UpdateBuffTabText()
  local selectedGroups = 0

  for i = 1, 8 do
    if self.character.WatchGroup[i] then
      selectedGroups = selectedGroups + 1
    end
  end

  if selectedGroups == 8 then
    taskListPanelModule.titleBuffGroups = _t("TabBuff")
    taskListPanelModule:SetTitle()
    --removeme
    -- PanelTemplates_TabResize(t, 0)
    return
  end

  if selectedGroups == 0 then
    taskListPanelModule.titleBuffGroups = _t("TabBuffOnlySelf")
    taskListPanelModule:SetTitle()
    --removeme
    -- PanelTemplates_TabResize(t, 0)
    return
  end

  local function endsWith(str, ending)
    return ending == "" or str:sub(- #ending) == ending
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
  taskListPanelModule.titleBuffGroups = _t("TabBuff") .. " G" .. groups
  taskListPanelModule:SetTitle()
  --removeme
  -- PanelTemplates_TabResize(t, 0)
end

function buffomatModule:InitUI()
  taskListPanelModule:ShowWindow()

  toolboxModule:OnUpdate(function(elapsed) throttleModule:UpdateTimer(elapsed) end)

  BOM.popupMenuDynamic = popupModule:CreatePopup(buffomatModule.OptionsUpdate)

  local function onMinimapClick(_self1, button)
    if button == "LeftButton" then
      taskListPanelModule:ToggleWindow()
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
end

function buffomatModule:InitGlobalStates()
  buffomatModule.shared = BuffomatShared --[[@as SharedSettings]]
  buffomatModule.character = BuffomatCharacter --[[@as CharacterSettings]]

  -- Upgrade from previous Buffomat State if values are found
  if not self.character.profiles then
    self.character.profiles = {}
  end
  -- Upgrade: Move each named profile settings section into profiles table
  for _i, profileName in ipairs(profileModule.ALL_PROFILES) do
    if self.character[profileName] then
      self.character.profiles[profileName] = self.character[profileName]
      self.character[profileName] = nil
    else
      if not self.character.profiles[profileName] then
        self.character.profiles[profileName] = profileModule:New()
      end
    end
  end

  local soloProfileName = profileModule:SoloProfile()
  BOM.currentProfile = self.character.profiles[soloProfileName or "solo"]
end

---@return BomSlashCommand[]
function BuffomatAddon:MakeSlashCommand()
  return --[[@as BomSlashCommand[] ]] {
    {
      command = "debug",
      description = "",
      handler = {
        {
          command = "buff",
          description = "",
          handler = buffomatModule.Slash_DebugBuffList
        },
        {
          command = "target",
          description = "",
          handler = buffomatModule.Slash_DebugBuffs,
          target = "target"
        },
      },
    },
    {
      command = "profile",
      description = "",
      handler = {
        {
          command = "%",
          description = _t("SlashProfile"),
          handler = buffomatModule.ChooseProfile
        }
      },
    },
    {
      command = "spellbook",
      description = _t("SlashSpellBook"),
      handler = BOM.setupAvailableSpellsFn
    },
    {
      command = "update",
      description = _t("SlashUpdate"),
      handler = function()
        buffomatModule:RequestTaskRescan("macro-/update")
        taskScanModule:ScanTasks("macro-/update")
      end
    },
    -- {
    --   command = "updatespellstab",
    --   description = "",
    --   handler = spellButtonsTabModule.UpdateSpellsTab
    -- },
    {
      command = "close",
      description = _t("SlashClose"),
      handler = function()
        taskListPanelModule:HideWindow()
      end
    },
    {
      command = "reset",
      description = _t("SlashReset"),
      handler = function() taskListPanelModule:ResetWindow() end
    },
    {
      command = "_checkforerror",
      description = "",
      handler = function()
        if not InCombatLockdown() then
          BOM.checkForError = true
        end
      end
    },
    {
      command = "",
      description = _t("SlashOpen"),
      handler = function() taskListPanelModule:ShowWindow() end
    },
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
  taskListPanelModule:ShowWindow()
  slashModule:RegisterSlashCommandHandler({ "/bom", "/buffomat" }, self:MakeSlashCommand())
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
      taskListPanelModule:ToggleWindow()
    else
      optionsPopupModule:Setup(control, true)
    end
  end

  toolboxModule:AddDataBroker(constModule.BOM_BEAR_ICON_FULLPATH, onClick, nil, nil)
  buffomatModule:UseProfile(profileModule:SoloProfile())
end

---AceAddon handler
function BuffomatAddon:OnDisable()
end

function buffomatModule:DownGrade()
  if BOM.castFailedBuff
      and (BOM.castFailedBuff).skipList
      and BOM.castFailedBuffTarget then
    local level = UnitLevel((BOM.castFailedBuffTarget).unitId)

    if level ~= nil and level > -1 then
      if self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] == nil
          or self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] < level
      then
        self.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] = level
        throttleModule:FastUpdateTimer()
        self:RequestTaskRescan("Downgrade")
        self:P(string.format(_t("MsgDownGrade"),
          (BOM.castFailedBuff).singleText,
          ((BOM.castFailedBuffTarget).name)))
      elseif buffomatModule.shared.SpellGreaterEqualThan[BOM.castFailedSpellId] >= level then
        BOM.AddMemberToSkipList()
      end
    else
      BOM.AddMemberToSkipList()
    end
  end
end

partyModule.unitAurasLastUpdated = --[[@as BomBuffUpdatesPerUnit]] {}

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

function buffomatModule:AutoOpen()
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
    if not taskListPanelModule:IsWindowVisible() and buffomatModule.autoHelper == "open" then
      buffomatModule.autoHelper = "close"
      taskListPanelModule:ShowWindow()
      taskListPanelModule:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)
    end
  end
end

function buffomatModule:AutoClose()
  if not InCombatLockdown() and buffomatModule.shared.AutoOpen then
    if taskListPanelModule:IsWindowVisible() then
      if buffomatModule.autoHelper == "close" then
        taskListPanelModule:HideWindow()
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


function buffomatModule.Slash_DebugBuffList()
end

function BOM.ShowSpellSettings()
  InterfaceOptionsFrame:Hide()
  GameMenuFrame:Hide()
  BOM:Print("TODO: Show Spell Settings")
  taskListPanelModule:ShowWindow()
end

function BOM.MyButtonOnClick(self)
  buffomatModule:OptionsUpdate()
end

function buffomatModule:FadeBuffomatWindow()
  if taskListPanelModule:IsBuffButtonEnabled() then
    taskListPanelModule:SetAlpha(1.0)
  else
    local fade = self.shared.FadeWhenNothingToDo or 0.65
    taskListPanelModule:SetAlpha(fade) -- fade the window, default 65%
  end
end