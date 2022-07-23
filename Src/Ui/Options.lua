local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomOptionsModule
local optionsModule = BuffomatModule.New("Options") ---@type BomOptionsModule
optionsModule.optionsOrder = 0

local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule

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

  dict = dict or buffomatModule.shared
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

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table|nil
---@param key string|nil
---@param notifyFn function|nil Call this with (key, value) on option change
function optionsModule:TemplateMultiselect(name, values, dict, notifyFn, setFn, getFn)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or buffomatModule.shared

  return {
    name   = _t("options.short." .. name),
    desc   = _t("options.long." .. name),
    type   = "multiselect",
    width  = "full",
    order  = self.optionsOrder,
    values = values,

    set    = setFn or function(state, key, value)
      dict[key] = value
      if notifyFn then
        notifyFn(key, value)
      end
    end,
    get    = getFn or function(state, key)
      return dict[key] == true
    end,
  }
end

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table|nil
---@param key string|nil
---@param style string|nil "dropdown" or "radio"
---@param notifyFn function|nil Call this with (key, value) on option change
function optionsModule:TemplateSelect(name, values, style, dict, notifyFn, setFn, getFn)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or buffomatModule.shared

  return {
    desc   = _t("options.long." .. name),
    name   = _t("options.short." .. name),
    order  = self.optionsOrder,
    style  = style or "dropdown",
    type   = "select",
    values = values,
    width  = 2.0,

    set    = setFn or function(info, value)
      dict[name] = value
      if notifyFn then
        notifyFn(value)
      end
    end,
    get    = getFn or function(info)
      return dict[name]
    end,
  }
end

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateInput(type, name, dict, key, notify)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or buffomatModule.shared
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

  dict = dict or buffomatModule.shared
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

function optionsModule:CreateGeneralOptionsTable()
  return {
    type = "group",
    name = "1. " .. _t("options.general.group.General"),
    args = {
      autoOpen              = self:TemplateCheckbox("AutoOpen"),
      useProfiles           = self:TemplateCheckbox("UseProfiles", buffomatModule.character),
      slowerHardware        = self:TemplateCheckbox("SlowerHardware"),
      minimapButtonShow     = self:TemplateCheckbox(
              "ShowMinimapButton", buffomatModule.shared.Minimap, "visible"),
      minimapButtonLock     = self:TemplateCheckbox(
              "LockMinimapButton", buffomatModule.shared.Minimap, "lock"),
      minimapButtonLockDist = self:TemplateCheckbox(
              "LockMinimapButtonDistance", buffomatModule.shared.Minimap, "lockDistance"),
      uiWindowScale         = self:TemplateInput("float", "UIWindowScale"),
    }
  }
end

function optionsModule:CreateScanOptionsTable()
  return {
    type = "group",
    name = "2. " .. _t("options.general.group.Scan"),
    args = {
      scanInRestArea   = self:TemplateCheckbox("ScanInRestArea"),
      scanInStealth    = self:TemplateCheckbox("ScanInStealth"),
      scanWhileMounted = self:TemplateCheckbox("ScanWhileMounted"),
      inWorld          = self:TemplateCheckbox("InWorld"),
      inPVP            = self:TemplateCheckbox("InPVP"),
      inInstance       = self:TemplateCheckbox("InInstance"),
      sameZone         = self:TemplateCheckbox("SameZone"),
    }
  }
end

function optionsModule:CreateAutoActionOptionsTable()
  return {
    type = "group",
    name = "3. " .. _t("options.general.group.AutoActions"),
    args = {
      autoCrusaderAura   = self:TemplateCheckbox("AutoCrusaderAura"),
      autoDismount       = self:TemplateCheckbox("AutoDismount"),
      autoDismountFlying = self:TemplateCheckbox("AutoDismountFlying"),
      autoStand          = self:TemplateCheckbox("AutoStand"),
      autoDisTravel      = self:TemplateCheckbox("AutoDisTravel"),
    }
  }
end

function optionsModule:CreateConvenienceOptionsTable()
  return {
    type = "group",
    name = "4. " .. _t("options.general.group.Convenience"),
    args = {
      preventPVPTag          = self:TemplateCheckbox("PreventPVPTag"),
      deathBlock             = self:TemplateCheckbox("DeathBlock"),
      noGroupBuff            = self:TemplateCheckbox("NoGroupBuff"),
      resGhost               = self:TemplateCheckbox("ResGhost"),
      replaceSingle          = self:TemplateCheckbox("ReplaceSingle"),
      argentumDawn           = self:TemplateCheckbox("ArgentumDawn"),
      carrot                 = self:TemplateCheckbox("Carrot"),
      mainHand               = self:TemplateCheckbox("MainHand"),
      secondaryHand          = self:TemplateCheckbox("SecondaryHand"),
      useRank                = self:TemplateCheckbox("UseRank"),
      buffTarget             = self:TemplateCheckbox("BuffTarget"),
      openLootable           = self:TemplateCheckbox("OpenLootable"),
      selfFirst              = self:TemplateCheckbox("SelfFirst"),
      dontUseConsumables     = self:TemplateCheckbox("DontUseConsumables"),
      someoneIsDrinking      = self:TemplateSelect("SomeoneIsDrinking", {
        ["hide"]     = _t("options.convenience.SomeoneIsDrinking.Hide"),
        ["low-prio"] = _t("options.convenience.SomeoneIsDrinking.LowPrio"),
        ["show"]     = _t("options.convenience.SomeoneIsDrinking.Show"),
      }, "dropdown"),
      activateBomOnSpiritTap = self:TemplateRange("ActivateBomOnSpiritTap", 0, 100, 10),
    },
  }
end

function optionsModule:CreateBuffingOptionsTable()
  return {
    type = "group",
    name = "5. " .. _t("options.general.group.Buffing"),
    args = {
      minBuff        = self:TemplateRange("MinBuff", 1, 5, 1),
      minBlessing    = self:TemplateRange("MinBlessing", 1, 40, 1),
      rebuffTime60   = self:TemplateRange("Time60", 10, 50, 5),
      rebuffTime300  = self:TemplateRange("Time300", 30, 300 - 60, 10),
      rebuffTime600  = self:TemplateRange("Time600", 30, 600 - 120, 10),
      rebuffTime1800 = self:TemplateRange("Time1800", 30, 600 - 30, 30),
      rebuffTime3600 = self:TemplateRange("Time3600", 30, 600 - 30, 30),
    } -- end args
  }
end

function optionsModule:CreateVisibilityOptionsTable()
  return {
    type = "group",
    name = "6. " .. _t("options.general.group.Visibility"),
    args = {
      categories = self:TemplateMultiselect(
              "VisibleCategories",
              allBuffsModule:GetBuffCategories(), -- all categories ordered
              buffomatModule.character.BuffCategoriesHidden, -- settings table
              nil,
              function(state, key, value)
                buffomatModule.character.BuffCategoriesHidden[key] = not value -- invert
                BOM.OnSpellsChanged()
              end,
              function(state, key)
                return buffomatModule.character.BuffCategoriesHidden[key] ~= true -- invert
              end
      ),
    } -- end args
  }
end

function optionsModule:CreateOptionsTable()
  self.optionsOrder = 0

  return {
    type = "group",
    args = {
      generalOptions     = self:CreateGeneralOptionsTable(),
      scanOptions        = self:CreateScanOptionsTable(),
      autoActionOptions  = self:CreateAutoActionOptionsTable(),
      convenienceOptions = self:CreateConvenienceOptionsTable(),
      buffingOptions     = self:CreateBuffingOptionsTable(),
      visibilityOptions  = self:CreateVisibilityOptionsTable(),
    } -- end args
  } -- end
end

---Called from options' Default button
function optionsModule:ResetDefaultOptions()
end
