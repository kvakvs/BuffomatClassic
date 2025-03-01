---@class KvSharedEnvModule
---@field isClassic boolean
---@field isTBC boolean
---@field haveTBC boolean
---@field isWotLK boolean
---@field haveWotLK boolean
---@field isCata boolean
---@field haveCata boolean
---@field playerClass ClassName

local envModule = LibStub("KvLibShared-Env") --[[@as KvSharedEnvModule]]

local _, _, _, tocversion = GetBuildInfo()
envModule.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
envModule.haveCata = envModule.isCata

envModule.isWotLK = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
envModule.haveWotLK = envModule.isWotLK or envModule.isCata

envModule.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
envModule.haveTBC = envModule.isWotLK or envModule.isTBC or envModule.isCata

envModule.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

envModule.GetContainerNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
envModule.GetContainerItemInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
envModule.GetContainerItemCooldown = (C_Container and C_Container.GetContainerItemCooldown) or GetContainerItemCooldown

envModule.playerClass = select(2, UnitClass("player"))