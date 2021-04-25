local TOCNAME, BOM = ...

---@class Profile
---@field Spell table<number, SpellDef> All spells selected for the current character
BOM.Profile = {}
BOM.Profile.__index = BOM.Profile

local CLASS_TAG = "profile"

---Creates a new Profile
---@return Profile
function BOM.Profile:new()
  local fields = {}
  setmetatable(fields, BOM.Profile)

  fields.t = CLASS_TAG

  return fields
end
