---@type BuffomatAddon
local TOCNAME, BOM = ...

---@class BuffomatTranslations Contains translated strings
---@field enEN table<string, string>
---@field deDE table<string, string>
---@field frFR table<string, string>
---@field ruRU table<string, string>
---@field zhCN table<string, string>
BOM.BuffomatTranslations = {}
BOM.BuffomatTranslations.__index = BOM.BuffomatTranslations

local CLASS_TAG = "buffomat_translations"
