local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomProfileModule
---@field ALL_PROFILES BomProfileName[]
local profileModule = {}
BomModuleManager.profileModule = profileModule

local buffomatModule = BomModuleManager.buffomatModule
local _t = BomModuleManager.languagesModule

---@shape BomProfile Snapshot of current options state as selected by the player
---Named options: Are addressed by their string name in translations, control names, etc
---@field ArgentumDawn boolean Warn if AD trinket is equipped while in an instance 
---@field AutoDismount boolean Dismount if necessary for buff cast 
---@field AutoDisTravel boolean Remove travel form if necessary for buff cast 
---@field AutoOpen boolean Open buffomat if required 
---@field AutoStand boolean Stand up if required for a cast 
---@field BuffTarget boolean Also try and buff the current target 
---@field Carrot boolean Whether to track carrot equipped in dungeons 
---@field DeathBlock boolean Don't cast group buffs, when somebody is dead
---@field DisableInRestArea boolean Hide BOM and clear tasks if in resting area ZZZ/city or inn
---@field DontUseConsumables boolean Prevent use of consumables
---@field SomeoneIsDrinking string When someone is drinking low-prio - Show as a comment; hide - no show; show - Show as a task and show buffomat window
---@field ActivateBomOnSpiritTap number Activate Buffomat while Priest talent 'Spirit tap' is active and mana is below X%
---@field InInstance boolean Buff while in an instance
---@field InPVP boolean Buff while in PvP instance
---@field InWorld boolean Buff in the open world
---@field MainHand boolean Warn about mainhand missing temporary enchant
---@field NoGroupBuff boolean Avoid casting group buffs
---@field OpenLootable boolean List lootable items for opening in the task list
---@field ReplaceSingle boolean Replace single buffs with group
---@field ResGhost boolean Attempt resurrecting ghosts
---@field SameZone boolean Check only in the same zone
---@field SecondaryHand boolean Warn about offhand temporary enchant missing
---@field SelfFirst boolean Buff self first
---@field ShowClassicConsumables boolean Will show pre-TBC consumables
---@field ShowTBCConsumables boolean Will show TBC consumables in the list
---@field UseRank boolean Use ranked spells
---@field SlowerHardware boolean Less frequent updates
---@field Cache table<number, table> Caches responses from GetItemInfo() and GetSpellInfo()
---@field CancelBuff table|nil
---@field Spell BomBuffDefinition[]|nil
---@field LastSeal number|nil
---@field LastAura number|nil

---@return BomProfile
function profileModule:New()
  local profile = --[[---@type BomProfile]] {}
  profile.AutoOpen = true
  profile.AutoStand = true
  profile.BuffTarget = true
  profile.DeathBlock = true
  profile.DisableInRestArea = true
  profile.SomeoneIsDrinking = "low-prio"
  profile.InInstance = true
  profile.InPVP = true
  profile.InWorld = true
  profile.OpenLootable = true
  profile.ReplaceSingle = true
  profile.SameZone = true
  profile.SelfFirst = true
  return profile
end

function profileModule:Setup()
  if BOM.HaveWotLK or GetActiveTalentGroup then
    self.ALL_PROFILES = {
      "solo", "solo_spec2",
      "group", "group_spec2",
      "raid", "raid_spec2",
      "battleground", "battleground_spec2"
    }
  else
    self.ALL_PROFILES = { "solo", "group", "raid", "battleground" }
  end
end

local function bomGetActiveTalentGroup()
  if BOM.HaveWotLK then
    return GetActiveTalentGroup()
  else
    return nil
  end
end

---@return BomProfileName
function profileModule:SoloProfile()
  local spec = bomGetActiveTalentGroup()
  if spec == 1 or spec == nil then
    return "solo"
  else
    return "solo_spec2"
  end
end

---@return BomProfileName
function profileModule:GroupProfile()
  local spec = bomGetActiveTalentGroup()
  if spec == 1 or spec == nil then
    return "group"
  else
    return "group_spec2"
  end
end

---@return BomProfileName
function profileModule:RaidProfile()
  local spec = bomGetActiveTalentGroup()
  if spec == 1 or spec == nil then
    return "raid"
  else
    return "raid_spec2"
  end
end

---@return BomProfileName
function profileModule:BattlegroundProfile()
  local spec = bomGetActiveTalentGroup()
  if spec == 1 or spec == nil then
    return "battleground"
  else
    return "battleground_spec2"
  end
end

---Based on profile settings and current PVE or PVP instance choose the mode
---of operation
---@return BomProfileName
function profileModule:ChooseProfile()
  local _inInstance, instanceType = IsInInstance()
  local selectedProfile = self:SoloProfile()

  if IsInRaid() then
    selectedProfile = self:RaidProfile()
  elseif IsInGroup() then
    selectedProfile = self:GroupProfile()
  end

  -- TODO: Refactor isDisabled into a function, also return reason why is disabled
  if BOM.ForceProfile then
    selectedProfile = BOM.ForceProfile
  elseif not buffomatModule.character.UseProfiles then
    selectedProfile = self:SoloProfile()
  elseif instanceType == "pvp" or instanceType == "arena" then
    selectedProfile = self:BattlegroundProfile()
  end

  return selectedProfile
end
