--TODO: Rename to Unit.lua
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomUnitModule
local unitModule = BomModuleManager.unitModule ---@type BomUnitModule

local buffomatModule = BomModuleManager.buffomatModule
local buffModule = BomModuleManager.buffModule
local partyModule = BomModuleManager.partyModule
local toolboxModule = BomModuleManager.toolboxModule

---@class BomUnit
---@field allBuffs table<number, boolean> Availability of all auras even those not supported by BOM, by id, no extra detail stored
---@field class BomClassName
---@field distance number
---@field group number Raid group number (9 if temporary moved out of the raid by BOM)
---@field hasReputationTrinket boolean Has AD reputation trinket equipped
---@field hasRidingTrinket boolean Has carrot riding trinket equipped
---@field hasResurrection boolean Was recently resurrected
---@field isConnected boolean Is online
---@field isDead boolean Is this member dead
---@field isGhost boolean Is dead and corpse released
---@field isPlayer boolean Is this a player
---@field isSameZone boolean Is in the same zone
---@field isTank boolean Is this member marked as tank
---@field knownBuffs {[BomSpellId]: BomUnitBuff} Buffs on player keyed by spell id, only buffs supported by Buffomat are stored
---@field link string
---@field MainhandBuff number|nil Temporary enchant on main hand
---@field name string
---@field NeedBuff boolean
---@field OffhandBuff number|nil Temporary enchant on off-hand
---@field owner BomUnit|nil Owner for pet
---@field unitGUID string
local unitClass = {}
unitClass.__index = unitClass

---@return BomUnit
function unitModule:New(fields)
  fields = fields or {}
  setmetatable(fields, unitClass)
  return fields
end

---Force updates buffs for one party member
---@param playerUnit BomUnit
function unitClass:ForceUpdateBuffs(playerUnit)
  self.isPlayer = (self == playerUnit)
  self.isDead = UnitIsDeadOrGhost(self.unitGUID) and not UnitIsFeignDeath(self.unitGUID)
  self.isGhost = UnitIsGhost(self.unitGUID)
  self.isConnected = UnitIsConnected(self.unitGUID)

  self.NeedBuff = true

  wipe(self.knownBuffs)
  wipe(self.allBuffs)

  BOM.somebodyIsGhost = BOM.somebodyIsGhost or self.isGhost

  if self.isDead then
    -- Clear known buffs for self, as we're very dead atm
    partyModule.buffs[self.name] = nil
  else
    self.hasReputationTrinket = false
    self.hasRidingTrinket = false

    local buffIndex = 0

    repeat
      buffIndex = buffIndex + 1

      local unitAura = buffomatModule:UnitAura(self.unitGUID, buffIndex, "HELPFUL")

      if unitAura.spellId then
        self.allBuffs[unitAura.spellId] = true -- save all buffids even those not supported
        if tContains(BOM.AllDrink, unitAura.spellId) then
          BOM.drinkingPersonCount = BOM.drinkingPersonCount + 1
        end
      end

      local spellId = BOM.spellToSpellLookup[unitAura.spellId] or unitAura.spellId

      if spellId then
        -- Skip members who have a buff on the global ignore list - example phaseshifted imps
        if tContains(BOM.buffIgnoreAll, spellId) then
          wipe(self.knownBuffs)
          self.NeedBuff = false
          break
        end

        --if tContains(BOM.ReputationTrinket.spells, spellId) then
        --  self.hasReputationTrinket = true
        --end

        --if tContains(BOM.Carrot.spells, spellId) then
        --  self.hasCarrot = true
        --end

        if tContains(BOM.allSpellIds, spellId) then
          local configKey = BOM.spellIdtoBuffId[spellId]

          self.knownBuffs[configKey] = buffModule:New(
                  spellId,
                  unitAura.duration,
                  unitAura.expirationTime,
                  unitAura.source,
                  BOM.spellIdIsSingleLookup[spellId])
        end
      end

    until (not unitAura.name)
  end -- if is not dead
end

---@param unitid string
---@param name string
---@param group number
---@param class BomClassName
---@param link string
---@param isTank boolean
function unitClass:Construct(unitid, name, group, class, link, isTank)
  self.distance = 1000044 -- special value to find out that the range error originates from this module
  self.unitGUID = unitid
  self.name = name
  self.group = group
  self.hasResurrection = self.hasResurrection or false
  self.class = class
  self.link = link
  self.isTank = isTank
  self.knownBuffs = self.knownBuffs or {}
  self.allBuffs = self.allBuffs or {}
end

function unitClass:GetDistance()
  return self.distance
end

---@param id BomSpellId
function unitClass:HaveBuff(id)
  return self.knownBuffs[id] ~= nil or self.allBuffs[id] ~= nil
end

function unitClass:GetText()
  return self.link or self.name
end

function unitClass:ClearMainhandBuff()
  self.MainhandBuff = nil
end

---@param enchantmentId BomEnchantmentId
---@param expiration number
function unitClass:SetMainhandBuff(enchantmentId, expiration)
  local enchantBuffId = BOM.enchantToSpellLookup[enchantmentId]
  local duration

  if BOM.buffFromSpellIdLookup[enchantBuffId]
          and BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
  then
    duration = BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
  else
    duration = 300
  end

  self.knownBuffs[enchantBuffId] = buffModule:New(
          enchantBuffId,
          duration,
          GetTime() + expiration / 1000,
          "player",
          true)
  self.MainhandBuff = enchantBuffId
end

function unitClass:ClearOffhandBuff()
  self.OffhandBuff = nil
end

---@param enchantmentId BomEnchantmentId
---@param expiration number
function unitClass:SetOffhandBuff(enchantmentId, expiration)
  local enchantBuffId = BOM.enchantToSpellLookup[enchantmentId]
  local duration

  if BOM.buffFromSpellIdLookup[enchantBuffId]
          and BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
  then
    duration = BOM.buffFromSpellIdLookup[enchantBuffId].singleDuration
  else
    duration = 300
  end

  self.knownBuffs[-enchantBuffId] = buffModule:New(
          -enchantBuffId,
          duration,
          GetTime() + expiration / 1000,
          "player",
          true)

  self.OffhandBuff = enchantBuffId
end


---@param party BomParty
---@param playerZone number
function unitClass:UpdateBuffs(party, playerZone)
  self.isSameZone = (C_Map.GetBestMapForUnit(self.unitGUID) == playerZone)
          or self.isGhost
          or self.unitGUID == "target"

  if not self.isDead
          or BOM.declineHasResurrection
  then
    self.hasResurrection = false
    self.distance = toolboxModule:UnitDistanceSquared(self.unitGUID)
  else
    self.hasResurrection = UnitHasIncomingResurrection(self.unitGUID)
            or self.hasResurrection
  end

  local invalidation = partyModule.partyCacheInvalidation
  local updateBuffs = next(buffomatModule.forceUpdateRequestedBy) ~= nil
          or (invalidation == "clear")
          or (type(invalidation) == "table" and tContains(invalidation, self.group))

  if updateBuffs then
    self:ForceUpdateBuffs(party.player)
  end -- if force update
end
