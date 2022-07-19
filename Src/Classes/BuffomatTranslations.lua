local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomTranslationsModule
local translationsModule = BuffomatModule.New("Translations") ---@type BomTranslationsModule

BOM.Class = BOM.Class or {}

---@class BuffomatTranslations Contains translated strings
---@field enEN table<string, string>
---@field deDE table<string, string>
---@field frFR table<string, string>
---@field ruRU table<string, string>
---@field zhCN table<string, string>

---@type BuffomatTranslations
BOM.Class.BuffomatTranslations = {}
BOM.Class.BuffomatTranslations.__index = BOM.Class.BuffomatTranslations

