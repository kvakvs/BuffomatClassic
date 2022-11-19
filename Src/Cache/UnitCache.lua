local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomUnitCacheModule
---@field unitCache table<string, BomUnit>
---@field partyCache BomParty
local unitCacheModule = BomModuleManager.unitCacheModule ---@type BomUnitCacheModule
unitCacheModule.unitCache = {}

local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local partyModule = BomModuleManager.partyModule
local taskScanModule = BomModuleManager.taskScanModule
local texturesModule = BomModuleManager.texturesModule
local toolboxModule = BomModuleManager.toolboxModule
local unitModule = BomModuleManager.unitModule

---@alias BomRaidRole "MAINTANK"|"MAINASSIST"|"NONE"
---@alias BomNameRoleMap {[string]: BomRaidRole}
---@alias BomNameGroupMap {[string]: number}

---@param unitid string Player name or special name like "raidpet#"
---@param nameGroupMap BomNameGroupMap|number|nil Maps name to group number in raid; Or a group number if number.
---@param nameRoleMap BomNameRoleMap|nil Maps name to role in raid
---@param specialName boolean|nil
---@return BomUnit|nil
function unitCacheModule:GetUnit(unitid, nameGroupMap, nameRoleMap, specialName)
  local name, _unitRealm = UnitFullName(unitid) ---@type string, string
  if name == nil then
    return nil
  end

  local group ---@type number
  if type(nameGroupMap) == "number" then
    group = --[[---@type number]] nameGroupMap
  else
    group = nameGroupMap and (--[[---@type BomNameGroupMap]] nameGroupMap)[name] or 1
  end

  nameRoleMap = nameRoleMap or --[[---@type BomNameRoleMap]] {}
  local isTank = nameRoleMap and ((--[[---@not nil]] nameRoleMap)[name] == "MAINTANK") or false

  local guid = UnitGUID(unitid)
  local _, class, link ---@type any, BomClassName, string|nil

  if guid then
    _, class = GetPlayerInfoByGUID(guid)
    if class then
      link = constModule.CLASS_ICONS[--[[---@not ""]] class] .. "|Hunit:" .. guid .. ":" .. name
              .. "|h|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r|h"
    else
      class = "pet"
      link = BOM.FormatTexture(texturesModule.ICON_PET) .. name
    end
  else
    class = "pet"
    link = BOM.FormatTexture(texturesModule.ICON_PET) .. name
  end

  if specialName then
    -- do not cache just construct
    local unit1 = unitModule:New({})
    unit1:Construct(unitid, name, group, class, link or "", isTank)
    return unit1
  else
    -- store in cache
    unitCacheModule.unitCache[unitid] = unitCacheModule.unitCache[unitid] or unitModule:New({})
    local unit2 = unitCacheModule.unitCache[unitid]
    unit2:Construct(unitid, name, group, class, link or "", isTank)
    return unit2
  end
end

---Fail if unit full name doesn't match saved member name
---@param party BomParty
---@return boolean
local function validatePartyMembers(party)
  for i, member in pairs(party.byUnitGUID) do
    local name = UnitFullName(member.unitGUID)

    if name ~= member.name then
      return false
    end
  end

  return true
end

---@param party BomParty
local function updatePlayerWeaponEnchantments(party)
  ---@type boolean, number, number, BomEnchantmentId, boolean, number, number, BomEnchantmentId
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID
  , hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

  if hasMainHandEnchant and mainHandEnchantID
          and BOM.enchantToSpellLookup[mainHandEnchantID] then
    party.player:SetMainhandBuff(mainHandEnchantID, mainHandExpiration)
  else
    party.player:ClearMainhandBuff()
  end

  if hasOffHandEnchant
          and offHandEnchantId
          and BOM.enchantToSpellLookup[offHandEnchantId] then
    party.player:SetOffhandBuff(offHandEnchantId, offHandExpiration)
  else
    party.player:ClearOffhandBuff()
  end
end

---@return BomParty
function unitCacheModule:GetPartyMembers()
  -- and buffs
  local party ---@type BomParty
  local invalidGroups = partyModule:GetInvalidGroups()

  BOM.drinkingPersonCount = 0

  -- check if stored party is correct!
  if partyModule.partyCacheInvalidation ~= "clear"
          and self.partyCache ~= nil then

    if #self.partyCache == partyModule:GetPartySize() + (BOM.SaveTargetName and 1 or 0) then
      if validatePartyMembers(self.partyCache) then
        -- Cache is valid, take that as a start value
        party = self.partyCache
      end
    end
  end

  if party ~= nil then
    -- Partial refresh of existing raid or full party refresh
    party = partyModule:RefreshParty(party, invalidGroups)
  else
    -- If previous cache partial refresh failed, do full refresh
    party = partyModule:RefreshParty(partyModule:New(), {})
  end

  BOM.somebodyIsGhost = false

  local playerZone = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.declineHasResurrection = true
    taskScanModule:ClearSkip()
  end

  -- For every party member which is in same zone, not a ghost or is a target
  for _i, member in pairs(party.byUnitGUID) do
    if tContains(invalidGroups, member.group) then
      member:UpdateBuffs(party, playerZone)
    end
  end -- for all in party

  -- For group 1 always refresh self and self-pet
  if tContains(invalidGroups, 1) then
    party.player:UpdateBuffs(party, playerZone)

    if party.playerPet ~= nil then
      (--[[---@not nil]] party.playerPet):UpdateBuffs(party, playerZone)
    end
  end

  updatePlayerWeaponEnchantments(party)

  -- Refresh weapon-buffs
  -- Clear old
  local OldMainHandBuff = party.player.MainhandBuff
  local OldOffHandBuff = party.player.OffhandBuff

  updatePlayerWeaponEnchantments(party)

  if OldMainHandBuff ~= party.player.MainhandBuff then
    buffomatModule:SetForceUpdate("mainHandBuffChanged")
  end

  if OldOffHandBuff ~= party.player.OffhandBuff then
    buffomatModule:SetForceUpdate("offhandBuffChanged")
  end

  BOM.declineHasResurrection = false
  return party
end

function unitCacheModule:ClearCache()
  self.partyCache = partyModule:New()
end