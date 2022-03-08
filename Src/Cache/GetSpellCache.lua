local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSpellCacheModule
local spellCacheModule = BuffomatModule.DeclareModule("SpellCache") ---@type BomSpellCacheModule
---@type table<number|string, BomSpellCacheElement> Stores arg to results mapping for GetItemInfo
spellCacheModule.cache = {}

---@class BomSpellCacheElement
---@field name string
---@field rank string
---@field icon string
---@field castTime number
---@field minRange number
---@field maxRange number
---@field spellId number

---Calls GetSpellInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return BomSpellCacheElement|nil
function BOM.GetSpellInfo(arg)
  if spellCacheModule.cache[arg] ~= nil then
    return spellCacheModule.cache[arg]
  end

  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(arg)
  if name == nil then
    return nil
  end

  name = name or "MISSING NAME"
  icon = icon or "MISSING ICON"

  local cacheSpell = {} ---@type BomSpellCacheElement
  cacheSpell.name = name
  cacheSpell.rank = rank
  cacheSpell.icon = icon
  cacheSpell.castTime = castTime
  cacheSpell.minRange = minRange
  cacheSpell.maxRange = maxRange
  cacheSpell.spellId = spellId

  spellCacheModule.cache[arg] = cacheSpell
  return cacheSpell
end

---Precache spell and store it
function spellCacheModule:LoadSpell(spellId)
  local spellMixin = Spell:CreateFromSpellID(spellId)

  local cacheSpell = {} ---@type BomSpellCacheElement
  cacheSpell.spellId = spellId

  local spellInfoReady_func = function()
    local spellDef = spellDefModule.allSpells[spellId]

    -- Assume the spell info is loaded here and the response is instant
    local _name, rank, icon, castTime, minRange, maxRange, _spellId = GetSpellInfo(spellId)
    if name == nil then
      return
    end

    spellDef.name = spellMixin:GetSpellName()
    cacheSpell.rank = rank
    cacheSpell.icon = icon
    cacheSpell.castTime = castTime
    cacheSpell.minRange = minRange
    cacheSpell.maxRange = maxRange
    self.cache[spellId] = cacheSpell

    --BOM:Print("Loaded spell " .. spellId .. ": " .. spellDef.spellName)
    BOM.ForceUpdate = true
  end

  if C_Spell.DoesSpellExist(spellId) then
    spellMixin:ContinueOnSpellLoad(spellInfoReady_func)
  end
end