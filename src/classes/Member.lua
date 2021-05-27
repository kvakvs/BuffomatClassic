---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Member
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
---@field name string
---@field NeedBuff boolean
---@field unitId number
---
---@field MainHandBuff number|nil Temporary enchant on main hand
---@field OffHandBuff number|nil Temporary enchant on off-hand
---@field buffs table<number, Buff> Buffs on player keyed by spell id
BOM.Class.Member = {}
BOM.Class.Member.__index = BOM.Class.Member

local CLASS_TAG = "member"

function BOM.Class.Member:new(fields)
  fields = fields or {}
  setmetatable(fields, BOM.Class.Member)
  return fields
end

---Force updates buffs for one party member
---@param self Member
---@param player_member Member
function BOM.Class.Member:ForceUpdateBuffs(player_member)

  self.isPlayer = (self == player_member)
  self.isDead = UnitIsDeadOrGhost(self.unitId) and not UnitIsFeignDeath(self.unitId)
  self.isGhost = UnitIsGhost(self.unitId)
  self.isConnected = UnitIsConnected(self.unitId)

  self.NeedBuff = true

  wipe(self.buffs)

  BOM.SomeBodyGhost = BOM.SomeBodyGhost or self.isGhost

  if self.isDead then
    BOM.PlayerBuffs[self.name] = nil
  else
    self.hasArgentumDawn = false
    self.hasCarrot = false

    local buffIndex = 0

    repeat
      buffIndex = buffIndex + 1

      local name, icon, count, debuffType, duration, expirationTime, source, isStealable
      , nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer
      , nameplateShowAll, timeMod = BOM.UnitAura(self.unitId, buffIndex, "HELPFUL")

      spellId = BOM.SpellToSpell[spellId] or spellId

      if spellId then
        -- Skip members who have a buff on the global ignore list - example phaseshifted imps
        if tContains(BOM.BuffIgnoreAll, spellId) then
          wipe(self.buffs)
          self.NeedBuff = false
          break
        end

        if spellId == BOM.ArgentumDawn.spell then
          self.hasArgentumDawn = true
        end

        if spellId == BOM.Carrot.spell then
          self.hasCarrot = true
        end

        if tContains(BOM.AllSpellIds, spellId) then
          self.buffs[BOM.SpellIdtoConfig[spellId]] = {
            ["duration"]       = duration,
            ["expirationTime"] = expirationTime,
            ["source"]         = source,
            ["isSingle"]       = BOM.SpellIdIsSingle[spellId],
          }
        end
      end

    until (not name)
  end -- if is not dead
end
