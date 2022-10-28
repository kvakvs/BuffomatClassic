local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomSpellCacheModule
local spellCacheModule = BuffomatModule.New("SpellCache") ---@type BomSpellCacheModule
---@type table<number|string, BomSpellCacheElement> Stores arg to results mapping for GetItemInfo
spellCacheModule.cache = {}

local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

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

function spellCacheModule:HasSpellCached(arg)
  return self.cache[arg] ~= nil
end

---Precache spell and store it
---@param spellId number
---@param onLoaded function Called with loaded BomSpellCacheElement
function spellCacheModule:LoadSpell(spellId, onLoaded)
  if spellCacheModule.cache[arg] ~= nil then
    onLoaded(spellCacheModule.cache[arg])
    return
  end

  local spellMixin = Spell:CreateFromSpellID(spellId)

  local cacheSpell = {} ---@type BomSpellCacheElement
  cacheSpell.spellId = spellId

  local spellInfoReady_func = function()
    local spellDef = buffDefModule.allSpells[spellId]

    -- Assume the spell info is loaded here and the response is instant
    local name, rank, icon, castTime, minRange, maxRange, _spellId = GetSpellInfo(spellId)
    if name == nil then
      return
    end

    cacheSpell.name = spellMixin:GetSpellName()
    spellDef.name = cacheSpell.name

    cacheSpell.rank = rank
    cacheSpell.icon = icon
    cacheSpell.castTime = castTime
    cacheSpell.minRange = minRange
    cacheSpell.maxRange = maxRange

    self.cache[spellId] = cacheSpell
    buffomatModule:SetForceUpdate(string.format("sp:%d", spellId))

    if onLoaded ~= nil then
      onLoaded(cacheSpell)
    end
  end

  if C_Spell.DoesSpellExist(spellId) then
    spellMixin:ContinueOnSpellLoad(spellInfoReady_func)
  end
end
