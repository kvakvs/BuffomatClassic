--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomLanguagesModule
---@overload fun(key: string): string
---@field locales BomAllLocalesCollection
---@field currentLocale BomLocaleDict
local languagesModule = BomModuleManager.languagesModule ---@type BomLanguagesModule
local buffomatModule = BomModuleManager.buffomatModule
local englishModule = BomModuleManager.languageEnglishModule
local germanModule = BomModuleManager.languageGermanModule
local frenchModule = BomModuleManager.languageFrenchModule
local russianModule = BomModuleManager.languageRussianModule
local chineseModule = BomModuleManager.languageChineseModule

setmetatable(languagesModule, {
  __call = function(_, k)
    if languagesModule.currentLocale and languagesModule.currentLocale[--[[---@type BomLanguageId]] k] then
      return languagesModule.currentLocale[--[[---@type BomLanguageId]] k] or ("¶" .. k)
    else
      return "¶" .. k
    end
  end
})

---@alias BomLanguageId "enUS" | "deDE" | "frFR" | "ruRU" | "zhCN" | "zhTW"
---@alias BomLocaleDict table<string, string>

---@shape BomAllLocalesCollection
---@field [BomLanguageId] BomLocaleDict
---@field enUS BomLocaleDict
---@field deDE BomLocaleDict
---@field frFR BomLocaleDict
---@field ruRU BomLocaleDict
---@field zhCN BomLocaleDict
---@field zhTW BomLocaleDict

function languagesModule:SetupTranslations()
  -- Always add english and add one language that is supported and is current
  self.locales = --[[---@type BomAllLocalesCollection]] {
    enUS = englishModule:Translations(),
    deDE = {},
    frFR = {},
    ruRU = {},
    zhCN = {},
    zhTW = {},
  }

  local currentLang = GetLocale()

  if currentLang == "deDE" then
    self.locales.deDE = germanModule:Translations()
  end
  if currentLang == "frFR" then
    self.locales.frFR = frenchModule:Translations()
  end

  if currentLang == "ruRU" then
    self.locales.ruRU = russianModule:Translations()
  end

  if currentLang == "zhCN" then
    self.locales.zhCN = chineseModule:Translations()
  end

  if currentLang == "zhTW" then
    self.locales.zhTW = chineseModule:Translations()
  end

  self.currentLocale = self.locales[GetLocale()] or {}

  self.currentLocale["AboutCredits"] = "nanjuekaien1 & wellcat for the Chinese translation|n" ..
          "OlivBEL for the french translation|n" ..
          "Arrogant_Dreamer & kvakvs for the russian translation|n"
end

function languagesModule:LocalizationInit()
  if buffomatModule.shared and buffomatModule.shared.CustomLocales then
    for key, value in pairs(buffomatModule.shared.CustomLocales) do
      if value ~= nil and value ~= "" then
        self.currentLocale[key .. "_org"] = self.currentLocale[key]
        self.currentLocale[key] = value
      end
    end
  end
end
