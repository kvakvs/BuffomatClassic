---@class LanguagesModule
---@overload fun(key: string): string
---@field currentLocale BomLocaleDict
---@field english BomLocaleDict

local languagesModule = --[[@as LanguagesModule]] LibStub("Buffomat-Languages")
local buffomatModule = --[[@as BuffomatModule]] LibStub("Buffomat-Buffomat")
local englishModule = --[[@as BomLanguageEnglishModule]] LibStub("Buffomat-LanguageEnglish")
local germanModule = --[[@as BomLanguageGermanModule]] LibStub("Buffomat-LanguageGerman")
local frenchModule = --[[@as BomLanguageFrenchModule]] LibStub("Buffomat-LanguageFrench")
local russianModule = --[[@as BomLanguageRussianModule]] LibStub("Buffomat-LanguageRussian")
local chineseModule = --[[@as BomLanguageChineseModule]] LibStub("Buffomat-LanguageChinese")

setmetatable(languagesModule, {
  __call = ---@param k string
      function(_, k)
        if languagesModule.currentLocale and languagesModule.currentLocale[k] then
          return languagesModule.currentLocale[k] or ("¶" .. k)
        else
          return "¶" .. k
        end
      end
})

---@alias BomLanguageId "enUS" | "deDE" | "frFR" | "ruRU" | "zhCN"
---@alias BomLocaleDict table<string, string>

---@class BomAllLocalesCollection
---@field [BomLanguageId] BomLocaleDict
---@field enUS BomLocaleDict
---@field deDE BomLocaleDict
---@field frFR BomLocaleDict
---@field ruRU BomLocaleDict
---@field zhCN BomLocaleDict

function languagesModule:LoadLanguage(locale)
  local currentLang = GetLocale()

  if currentLang == "deDE" then
    return germanModule:Translations()
  end
  if currentLang == "frFR" then
    return frenchModule:Translations()
  end
  if currentLang == "ruRU" then
    return russianModule:Translations()
  end
  if currentLang == "zhCN" then
    return chineseModule:Translations()
  end
end

function languagesModule:SetupTranslations()
  self.currentLocale = self:LoadLanguage(GetLocale()) or {}

  for englishKey, englishText in pairs(englishModule:Translations()) do
    if not self.currentLocale[englishKey] then
      self.currentLocale[englishKey] = englishText
    end
  end

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