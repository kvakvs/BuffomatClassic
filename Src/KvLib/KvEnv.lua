---@class KvLibEnvModule
---@field isClassic boolean
---@field isTBC boolean
---@field haveTBC boolean
---@field isWotLK boolean
---@field haveWotLK boolean
local envModule = { }

---@class KvModuleManager
---@field envModule KvLibEnvModule
---@field optionsModule KvOptionsModule
KvModuleManager = {
  envModule = envModule,
  optionsModule = --[[---@type KvOptionsModule]] {},
}

function envModule:DetectVersions()
  local _, _, _, tocversion = GetBuildInfo()
  self.isWotLK = (tocversion >= 30000 and tocversion <= 39999) -- TODO: change to WOTLK detection via WOW_PROJECT_..._CLASSIC
  self.haveWotLK = self.isWotLK

  self.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
  self.haveTBC = self.isWotLK or self.isTBC

  self.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end
