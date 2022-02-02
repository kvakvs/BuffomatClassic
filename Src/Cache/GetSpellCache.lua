local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSpellCacheModule
local spellCacheModule = BuffomatModule.DeclareModule("SpellCache") ---@type BomSpellCacheModule

---@class GSICacheItem
---@field name string
---@field rank string
---@field icon string
---@field castTime number
---@field minRange number
---@field maxRange number
---@field spellId number

---@type table<number|string, GSICacheItem> Stores arg to results mapping for GetItemInfo
local bom_gsi_cache = {}

---Calls GetSpellInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return GSICacheItem|nil
function BOM.GetSpellInfo(arg)
  if bom_gsi_cache[arg] ~= nil then
    return bom_gsi_cache[arg]
  end

  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(arg)
  if name == nil then
    return nil
  end

  name = name or "MISSING NAME"
  icon = icon or "MISSING ICON"

  local cache_item = {
    name = name,
    rank = rank,
    icon = icon,
    castTime = castTime,
    minRange = minRange,
    maxRange = maxRange,
    spellId = spellId,
  }

  bom_gsi_cache[arg] = cache_item
  return cache_item
end
