--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomLanguagesModule
---@overload fun(key: string): string
---@field currentLocale BomLocaleDict
---@field english BomLocaleDict
local languagesModule = BomModuleManager.languagesModule ---@type BomLanguagesModule

local buffomatModule = BomModuleManager.buffomatModule
local englishModule = BomModuleManager.languageEnglishModule
local germanModule = BomModuleManager.languageGermanModule
local frenchModule = BomModuleManager.languageFrenchModule
local russianModule = BomModuleManager.languageRussianModule
local chineseModule = BomModuleManager.languageChineseModule

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

---@shape BomAllLocalesCollection
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
