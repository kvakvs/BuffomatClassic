---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class BuffomatTranslations Contains translated strings
---@field enEN table<string, string>
---@field deDE table<string, string>
---@field frFR table<string, string>
---@field ruRU table<string, string>
---@field zhCN table<string, string>
BOM.Class.BuffomatTranslations = {}
BOM.Class.BuffomatTranslations.__index = BOM.Class.BuffomatTranslations

local CLASS_TAG = "buffomat_translations"
