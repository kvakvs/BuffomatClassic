local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomOptionsModule
local optionsModule = BuffomatModule.DeclareModule("Options") ---@type BomOptionsModule
optionsModule.optionsOrder = 0

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule

function optionsModule:ValueToText(type, value)
  if type == "string" then
    return value
  elseif type == "float" then
    return string.format("%.02f", value or 0)
  elseif type == "integer" then
    return string.format("%d", value or 0)
  end
end

function optionsModule:TextToValue(type, editFieldText)
  if type == "string" then
    return editFieldText
  elseif type == "float" then
    return tonumber(editFieldText)
  elseif type == "integer" then
    return tonumber(editFieldText)
  end
end

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

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateInput(type, name, dict, key, notify)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or BOM.SharedState
  key = key or name

  return {
    name  = _t("options.short." .. name),
    desc  = _t("options.long." .. name),
    type  = "input",
    width = "full",
    order = self.optionsOrder,

    set   = function(info, val)
      val = self:TextToValue(type, val)
      dict[key] = val

      if notify then
        notify(key, val)
      end
    end,
    get   = function(info)
      return self:ValueToText(type, dict[key])
    end,
  }
end

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateRange(name, rangeFrom, rangeTo, step, dict, key, notify)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or BOM.SharedState
  key = key or name

  return {
    name  = _t("options.short." .. name),
    desc  = _t("options.long." .. name),
    type  = "range",
    min   = rangeFrom,
    max   = rangeTo,
    step  = step,
    width = "full",
    order = self.optionsOrder,

    set   = function(info, val)
      dict[key] = val
      if notify then
        notify(key, val)
      end
    end,
    get   = function(info)
      return dict[key]
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
          uiWindowScale         = self:TemplateInput("float", "UIWindowScale"),
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
          activateBomOnSpiritTap = self:TemplateRange("ActivateBomOnSpiritTap", 0, 100, 10),
        },
      }, -- end convenience options
      buffingOptions     = {
        type = "group",
        name = _t("options.general.group.Buffing"),
        args = {
          minBuff        = self:TemplateRange("MinBuff", 1, 5, 1),
          minBlessing    = self:TemplateRange("MinBlessing", 1, 40, 1),
          rebuffTime60   = self:TemplateRange("Time60", 10, 50, 5),
          rebuffTime300  = self:TemplateRange("Time300", 30, 300 - 60, 10),
          rebuffTime600  = self:TemplateRange("Time600", 30, 600 - 120, 10),
          rebuffTime1800 = self:TemplateRange("Time1800", 30, 600 - 30, 30),
          rebuffTime3600 = self:TemplateRange("Time3600", 30, 600 - 30, 30),
        } -- end args
      }, -- end buffing options
    } -- end args
  } -- end
end

---Called from options' Default button
function optionsModule:ResetDefaultOptions()
end
