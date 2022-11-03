local BOM = BuffomatAddon ---@type BomAddon

---@class BomLanguagesModule
---@overload fun(key: string): string
local languagesModule = {}
BomModuleManager.languagesModule = languagesModule

local buffomatModule = BomModuleManager.buffomatModule
local englishModule = BomModuleManager.languageEnglishModule
local germanModule = BomModuleManager.languageGermanModule
local frenchModule = BomModuleManager.languageFrenchModule
local russianModule = BomModuleManager.languageRussianModule
local chineseModule = BomModuleManager.languageChineseModule

---@deprecated
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

setmetatable(languagesModule, {
  __call = function(_, k)
    if BOM.L and BOM.L[k] then
      return BOM.L[k] or ("¶" .. k)
    else
      return "¶" .. k
    end
  end
})

---@alias BomLanguage table<string, string>

---@shape BomTranslationsDict
---@field enEN BomLanguage
---@field deDE BomLanguage
---@field frFR BomLanguage
---@field ruRU BomLanguage
---@field zhCN BomLanguage

function languagesModule:SetupTranslations()
  -- Always add english and add one language that is supported and is current
  BOM.locales = {
    enEN = englishModule:Translations(),
    deDE = {},
    frFR = {},
    ruRU = {},
    zhCN = {},
  }

  local currentLang = GetLocale()

  if currentLang == "deDE" then
    BOM.locales.deDE = germanModule:Translations()
  end
  if currentLang == "frFR" then
    BOM.locales.frFR = frenchModule:Translations()
  end

  if currentLang == "ruRU" then
    BOM.locales.ruRU = russianModule:Translations()
  end

  if currentLang == "zhCN" then
    BOM.locales.zhCN = chineseModule:Translations()
  end

  BOM.L = BOM.locales[GetLocale()] or {}
  setmetatable(BOM.L, {
    __index = BOM.locales["enEN"]
  })
  BOM.L.AboutCredits = "nanjuekaien1 & wellcat for the Chinese translation|n" ..
          "OlivBEL for the french translation|n" ..
          "Arrogant_Dreamer & kvakvs for the russian translation|n"
end

function languagesModule:LocalizationInit()
  if buffomatModule.shared and buffomatModule.shared.CustomLocales then
    for key, value in pairs(buffomatModule.shared.CustomLocales) do
      if value ~= nil and value ~= "" then
        BOM.L[key .. "_org"] = BOM.L[key]
        BOM.L[key] = value
      end
    end
  end
end
