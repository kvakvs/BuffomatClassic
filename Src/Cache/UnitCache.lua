local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomUnitCacheModule
---@field unitCache table<string, BomUnit>
local unitCacheModule = BomModuleManager.unitCacheModule ---@type BomUnitCacheModule
unitCacheModule.unitCache = {}

local constModule = BomModuleManager.constModule
local partyModule = BomModuleManager.partyModule
local texturesModule = BomModuleManager.texturesModule
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

function unitCacheModule:ClearCache()
  self.partyCache = partyModule:New()
end