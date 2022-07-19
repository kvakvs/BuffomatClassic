--TODO: Rename to Unit.lua
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomMemberModule
local memberModule = BuffomatModule.New("Member") ---@type BomMemberModule

local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule

BOM.Class = BOM.Class or {}

---@class BomUnit
---@field buffs table<number, Buff> Buffs on player keyed by spell id, only buffs supported by Buffomat are stored
---@field buffExists table<number, boolean> Availability of all auras even those not supported by BOM, by id, no extra detail stored
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

---@type BomUnit
BOM.Class.Member = {}
BOM.Class.Member.__index = BOM.Class.Member

local M_CLASS_TAG = "member"

function BOM.Class.Member:new(fields)
  fields = fields or {}
  setmetatable(fields, BOM.Class.Member)
  fields.t = M_CLASS_TAG
  return fields
end

---Force updates buffs for one party member
---@param player_member BomUnit
---@param self BomUnit
function BOM.Class.Member:ForceUpdateBuffs(player_member)

  self.isPlayer = (self == player_member)
  self.isDead = UnitIsDeadOrGhost(self.unitId) and not UnitIsFeignDeath(self.unitId)
  self.isGhost = UnitIsGhost(self.unitId)
  self.isConnected = UnitIsConnected(self.unitId)

  self.NeedBuff = true

  wipe(self.buffs)
  wipe(self.buffExists)

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
        self.buffExists[unitAura.spellId] = true -- save all buffids even those not supported
        if tContains(BOM.AllDrink, unitAura.spellId) then
          BOM.drinkingPersonCount = BOM.drinkingPersonCount + 1
        end
      end

      local spellId = BOM.SpellToSpell[unitAura.spellId] or unitAura.spellId

      if spellId then
        -- Skip members who have a buff on the global ignore list - example phaseshifted imps
        if tContains(BOM.BuffIgnoreAll, spellId) then
          wipe(self.buffs)
          self.NeedBuff = false
          break
        end

        --if tContains(BOM.ArgentumDawn.spells, spellId) then
        --  self.hasArgentumDawn = true
        --end

        --if tContains(BOM.Carrot.spells, spellId) then
        --  self.hasCarrot = true
        --end

        if tContains(BOM.AllSpellIds, spellId) then
          local configKey = BOM.SpellIdtoConfig[spellId]

          self.buffs[configKey] = BOM.Class.Buff:new(
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
function BOM.Class.Member:Construct(unitid, name, group, class, link, isTank)
  self.distance = 100000
  self.unitId = unitid
  self.name = name
  self.group = group
  self.hasResurrection = self.hasResurrection or false
  self.class = class
  self.link = link
  self.isTank = isTank
  self.buffs = self.buffs or {}
  self.buffExists = self.buffExists or {}
end

function BOM.Class.Member.GetDistance(self)
  return self.distance
end

function BOM.Class.Member.GetText(self)
  return self.link or self.name
end
