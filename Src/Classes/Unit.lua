--TODO: Rename to Unit.lua
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomUnitModule
local unitModule = {}
BomModuleManager.unitModule = unitModule

local buffomatModule = BomModuleManager.buffomatModule
local buffModule = BomModuleManager.buffModule

---@class BomUnit
---@field knownBuffs table<number, BomUnitBuff> Buffs on player keyed by spell id, only buffs supported by Buffomat are stored
---@field allBuffs table<number, boolean> Availability of all auras even those not supported by BOM, by id, no extra detail stored
---@field class string
---@field distance number
---@field group number Raid group number (9 if temporary moved out of the raid by BOM)
---@field hasArgentumDawn boolean Has AD reputation trinket equipped
---@field hasCarrot boolean Has carrot riding trinket equipped
---@field hasResurrection boolean Was recently resurrected
---@field isConnected boolean Is online
---@field isDead boolean Is this member dead
---@field isGhost boolean Is dead and corpse released
---@field isPlayer boolean Is this a player
---@field isTank boolean Is this member marked as tank
---@field link string
---@field MainHandBuff number|nil Temporary enchant on main hand
---@field name string
---@field NeedBuff boolean
---@field OffHandBuff number|nil Temporary enchant on off-hand
---@field unitId string
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
  self.isDead = UnitIsDeadOrGhost(self.unitId) and not UnitIsFeignDeath(self.unitId)
  self.isGhost = UnitIsGhost(self.unitId)
  self.isConnected = UnitIsConnected(self.unitId)

  self.NeedBuff = true

  wipe(self.knownBuffs)
  wipe(self.allBuffs)

  BOM.SomeBodyGhost = BOM.SomeBodyGhost or self.isGhost

  if self.isDead then
    BOM.PlayerBuffs[self.name] = nil
  else
    self.hasArgentumDawn = false
    self.hasCarrot = false

    local buffIndex = 0

    repeat
      buffIndex = buffIndex + 1

      local unitAura = buffomatModule:UnitAura(self.unitId, buffIndex, "HELPFUL")

      if unitAura.spellId then
        self.allBuffs[unitAura.spellId] = true -- save all buffids even those not supported
        if tContains(BOM.AllDrink, unitAura.spellId) then
          BOM.drinkingPersonCount = BOM.drinkingPersonCount + 1
        end
      end

      local spellId = BOM.SpellToSpell[unitAura.spellId] or unitAura.spellId

      if spellId then
        -- Skip members who have a buff on the global ignore list - example phaseshifted imps
        if tContains(BOM.buffIgnoreAll, spellId) then
          wipe(self.knownBuffs)
          self.NeedBuff = false
          break
        end

        --if tContains(BOM.ArgentumDawn.spells, spellId) then
        --  self.hasArgentumDawn = true
        --end

        --if tContains(BOM.Carrot.spells, spellId) then
        --  self.hasCarrot = true
        --end

        if tContains(BOM.allSpellIds, spellId) then
          local configKey = BOM.SpellIdtoConfig[spellId]

          self.knownBuffs[configKey] = buffModule:New(
                  spellId,
                  unitAura.duration,
                  unitAura.expirationTime,
                  unitAura.source,
                  BOM.SpellIdIsSingle[spellId])
        end
      end

    until (not unitAura.name)
  end -- if is not dead
end

---@param unitid string
---@param name string
---@param group number
---@param class string
---@param link string
---@param isTank boolean
function unitClass:Construct(unitid, name, group, class, link, isTank)
  self.distance = 1000044 -- special value to find out that the range error originates from this module
  self.unitId = unitid
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

function unitClass:HaveBuff(id)
  return self.knownBuffs[id] ~= nil or self.allBuffs[id] ~= nil
end

function unitClass:GetText()
  return self.link or self.name
end
