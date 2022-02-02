local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomOptionsModule
local optionsModule = BuffomatModule.DeclareModule("Options") ---@type BomOptionsModule
optionsModule.optionsOrder = 0

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateCheckbox(name, dict, key, notify)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or BOM.SharedState
  key = key or name

  return {
    name  = _t("options.short." .. name),
    desc  = _t("options.long." .. name),
    type  = "toggle",
    width = "full",
    order = self.optionsOrder,

    set   = function(info, val)
      dict[key] = val
      if notify then
        notify(key, val)
      end
    end,
    get   = function(info)
      return dict[key] == true
    end,
  }
end

function optionsModule:CreateOptionsTable()
  self.optionsOrder = 0

  return {
    type = "group",
    args = {
      generalOptions     = {
        type = "group",
        name = _t("options.general.group.General"),
        args = {
          autoOpen              = self:TemplateCheckbox("AutoOpen"),
          useProfiles           = self:TemplateCheckbox("UseProfiles", BOM.CharacterState),
          slowerHardware        = self:TemplateCheckbox("SlowerHardware"),
          minimapButtonShow     = self:TemplateCheckbox(
                  "ShowMinimapButton", BOM.SharedState.Minimap, "visible"),
          minimapButtonLock     = self:TemplateCheckbox(
                  "LockMinimapButton", BOM.SharedState.Minimap, "lock"),
          minimapButtonLockDist = self:TemplateCheckbox(
                  "LockMinimapButtonDistance", BOM.SharedState.Minimap, "lockDistance"),
        }
      },
      scanOptions        = {
        type = "group",
        name = _t("options.general.group.Scan"),
        args = {
          scanInRestArea   = self:TemplateCheckbox("ScanInRestArea"),
          scanInStealth    = self:TemplateCheckbox("ScanInStealth"),
          scanWhileMounted = self:TemplateCheckbox("ScanWhileMounted"),
          inWorld          = self:TemplateCheckbox("InWorld"),
          inPVP            = self:TemplateCheckbox("InPVP"),
          inInstance       = self:TemplateCheckbox("InInstance"),
          sameZone         = self:TemplateCheckbox("SameZone"),
        }
      },
      autoActionOptions  = {
        type = "group",
        name = _t("options.general.group.AutoActions"),
        args = {
          autoCrusaderAura   = self:TemplateCheckbox("AutoCrusaderAura"),
          autoDismount       = self:TemplateCheckbox("AutoDismount"),
          autoDismountFlying = self:TemplateCheckbox("AutoDismountFlying"),
          autoStand          = self:TemplateCheckbox("AutoStand"),
          autoDisTravel      = self:TemplateCheckbox("AutoDisTravel"),
        }
      },
      convenienceOptions = {
        type = "group",
        name = _t("options.general.group.Convenience"),
        args = {
          preventPVPTag            = self:TemplateCheckbox("PreventPVPTag"),
          deathBlock               = self:TemplateCheckbox("DeathBlock"),
          noGroupBuff              = self:TemplateCheckbox("NoGroupBuff"),
          resGhost                 = self:TemplateCheckbox("ResGhost"),
          replaceSingle            = self:TemplateCheckbox("ReplaceSingle"),
          argentumDawn             = self:TemplateCheckbox("ArgentumDawn"),
          carrot                   = self:TemplateCheckbox("Carrot"),
          mainHand                 = self:TemplateCheckbox("MainHand"),
          secondaryHand            = self:TemplateCheckbox("SecondaryHand"),
          useRank                  = self:TemplateCheckbox("UseRank"),
          buffTarget               = self:TemplateCheckbox("BuffTarget"),
          openLootable             = self:TemplateCheckbox("OpenLootable"),
          selfFirst                = self:TemplateCheckbox("SelfFirst"),
          dontUseConsumables       = self:TemplateCheckbox("DontUseConsumables"),
          hideSomeoneIsDrinking    = self:TemplateCheckbox("HideSomeoneIsDrinking"),
          deactivateBomOnSpiritTap = self:TemplateCheckbox("DeactivateBomOnSpiritTap"),
        }
      },
    }
  }
end

---Called from options' Default button
function optionsModule:ResetDefaultOptions()
end
