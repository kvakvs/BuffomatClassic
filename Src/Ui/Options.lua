--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomOptionsModule
---@field optionsOrder number Counter for increasing option id
local optionsModule = BomModuleManager.optionsModule ---@type BomOptionsModule
optionsModule.optionsOrder = 0

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local eventsModule = BomModuleManager.eventsModule
local taskScanModule = BomModuleManager.taskScanModule

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
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get   = function(info)
      if dict then
        return (--[[---@not nil]] dict)[key] == true
      else
        return nil
      end
    end,
  }
end

---@param name string
---@param onClick function Call this when button is pressed
function optionsModule:TemplateButton(name, onClick)
  self.optionsOrder = self.optionsOrder + 1

  dict = dict or buffomatModule.shared
  key = key or name

  return {
    name  = _t("options.short." .. name),
    desc  = _t("options.long." .. name),
    type  = "execute",
    width = "half",
    order = self.optionsOrder,
    func   = onClick,
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
      if dict then
        (--[[---@not nil]]  dict)[key] = value
        if notifyFn then
          (--[[---@not nil]] notifyFn)(key, value)
        end
      end
    end,
    get    = getFn or function(state, key)
      if dict then
        return (--[[---@not nil]] dict)[key] == true
      else
        return nil
      end
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
      if dict then
        (--[[---@not nil]] dict)[name] = value
        if notifyFn then
          (--[[---@not nil]] notifyFn)(value)
        end
      end
    end,
    get    = getFn or function(info)
      if dict then
        return (--[[---@not nil]] dict)[name]
      else
        return nil
      end
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
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get   = function(info)
      if dict then
        return self:ValueToText(type, (--[[---@not nil]] dict)[key])
      else
        return nil
      end
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
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get   = function(info)
      if dict then
        return (--[[---@not nil]] dict)[key]
      else
        return nil
      end
    end,
  }
end

function optionsModule:CreateGeneralOptionsTable()
  local sounds = {}
  for i, sound in ipairs(constModule.TASK_NOTIFICATION_SOUNDS) do
    sounds[sound .. ".mp3"] = sound
  end

  return {
    type = "group",
    name = "1. " .. _t("options.general.group.General"),
    args = {
      autoOpen              = self:TemplateCheckbox("AutoOpen", nil, nil, nil),
      fadeWhenNothingToDo   = self:TemplateRange(
              "FadeWhenNothingToDo", 0.25, 1.0, 0.05,
              buffomatModule.shared, "FadeWhenNothingToDo",
              function(_key, val)
                BomC_MainWindow:SetAlpha(val)
              end
      ),
      useProfiles           = self:TemplateCheckbox("UseProfiles", buffomatModule.character, nil, nil),
      slowerHardware        = self:TemplateCheckbox("SlowerHardware", nil, nil, nil),
      minimapButtonShow     = self:TemplateCheckbox(
              "ShowMinimapButton", buffomatModule.shared.Minimap, "visible",
              function(key, value)
                if value then
                  BOM.minimapButton:Show()
                else
                  BOM.minimapButton:Hide()
                end
              end),
      minimapButtonLock     = self:TemplateCheckbox(
              "LockMinimapButton", buffomatModule.shared.Minimap, "lock", nil),
      minimapButtonLockDist = self:TemplateCheckbox(
              "LockMinimapButtonDistance", buffomatModule.shared.Minimap, "lockDistance", nil),
      --uiWindowScale         = self:TemplateInput("float", "UIWindowScale"),
      uiWindowScale         = self:TemplateRange(
              "UIWindowScale", 0.35, 2.0, 0.05,
              buffomatModule.shared, "UIWindowScale",
              function(_key, val)
                buffomatModule:SetWindowScale(val)
              end
      ),
      -- Play from Interface/Addons/Buffomat/Sounds/...
      playSoundWhenTask     = self:TemplateSelect("PlaySoundWhenTask", sounds, "dropdown",
              nil, nil, nil, nil),
      soundTest = self:TemplateButton("PlaySoundWhenTask.test", function()
        taskScanModule:PlayTaskSound()
      end),
      debugLogging          = self:TemplateCheckbox("DebugLogging", nil, nil, nil),
    }
  }
end

function optionsModule:CreateScanOptionsTable()
  return {
    type = "group",
    name = "2. " .. _t("options.general.group.Scan"),
    args = {
      scanInRestArea   = self:TemplateCheckbox("ScanInRestArea", nil, nil, nil),
      scanInStealth    = self:TemplateCheckbox("ScanInStealth", nil, nil, nil),
      scanWhileMounted = self:TemplateCheckbox("ScanWhileMounted", nil, nil, nil),
      inWorld          = self:TemplateCheckbox("InWorld", nil, nil, nil),
      inPVP            = self:TemplateCheckbox("InPVP", nil, nil, nil),
      inInstance       = self:TemplateCheckbox("InInstance", nil, nil, nil),
      sameZone         = self:TemplateCheckbox("SameZone", nil, nil, nil),
    }
  }
end

function optionsModule:CreateAutoActionOptionsTable()
  return {
    type = "group",
    name = "3. " .. _t("options.general.group.AutoActions"),
    args = {
      autoCrusaderAura   = self:TemplateCheckbox("AutoCrusaderAura", nil, nil, nil),
      autoDismount       = self:TemplateCheckbox("AutoDismount", nil, nil, nil),
      autoDismountFlying = self:TemplateCheckbox("AutoDismountFlying", nil, nil, nil),
      autoStand          = self:TemplateCheckbox("AutoStand", nil, nil, nil),
      autoDisTravel      = self:TemplateCheckbox("AutoDisTravel", nil, nil, nil),
    }
  }
end

function optionsModule:CreateConvenienceOptionsTable()
  return {
    type = "group",
    name = "4. " .. _t("options.general.group.Convenience"),
    args = {
      preventPVPTag          = self:TemplateCheckbox("PreventPVPTag", nil, nil, nil),
      deathBlock             = self:TemplateCheckbox("DeathBlock", nil, nil, nil),
      noGroupBuff            = self:TemplateCheckbox("NoGroupBuff", nil, nil, nil),
      resGhost               = self:TemplateCheckbox("ResGhost", nil, nil, nil),
      replaceSingle          = self:TemplateCheckbox("ReplaceSingle", nil, nil, nil),
      argentumDawn           = self:TemplateCheckbox("ReputationTrinket", nil, nil, nil),
      carrot                 = self:TemplateCheckbox("Carrot", nil, nil, nil),
      mainHand               = self:TemplateCheckbox("MainHand", nil, nil, nil),
      secondaryHand          = self:TemplateCheckbox("SecondaryHand", nil, nil, nil),
      useRank                = self:TemplateCheckbox("UseRank", nil, nil, nil),
      buffTarget             = self:TemplateCheckbox("BuffTarget", nil, nil, nil),
      openLootable           = self:TemplateCheckbox("OpenLootable", nil, nil, nil),
      selfFirst              = self:TemplateCheckbox("SelfFirst", nil, nil, nil),
      dontUseConsumables     = self:TemplateCheckbox("DontUseConsumables", nil, nil, nil),
      someoneIsDrinking      = self:TemplateSelect("SomeoneIsDrinking", {
        ["hide"]     = _t("options.convenience.SomeoneIsDrinking.Hide"),
        ["low-prio"] = _t("options.convenience.SomeoneIsDrinking.LowPrio"),
        ["show"]     = _t("options.convenience.SomeoneIsDrinking.Show"),
      }, "dropdown", nil, nil, nil, nil),
      activateBomOnSpiritTap = self:TemplateRange("ActivateBomOnSpiritTap", 0, 100, 10, nil, nil, nil),
    },
  }
end

function optionsModule:CreateBuffingOptionsTable()
  return {
    type = "group",
    name = "5. " .. _t("options.general.group.Buffing"),
    args = {
      minBuff        = self:TemplateRange("MinBuff", 1, 5, 1, nil, nil, nil),
      minBlessing    = self:TemplateRange("MinBlessing", 1, 40, 1, nil, nil, nil),
      rebuffTime60   = self:TemplateRange("Time60", 10, 50, 5, nil, nil, nil),
      rebuffTime300  = self:TemplateRange("Time300", 30, 300 - 60, 10, nil, nil, nil),
      rebuffTime600  = self:TemplateRange("Time600", 30, 600 - 120, 10, nil, nil, nil),
      rebuffTime1800 = self:TemplateRange("Time1800", 30, 600 - 30, 30, nil, nil, nil),
      rebuffTime3600 = self:TemplateRange("Time3600", 30, 600 - 30, 30, nil, nil, nil),
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
              function(state,  key, value)
                buffomatModule.character.BuffCategoriesHidden[--[[---@type string]] key] = not value -- invert
                eventsModule.Event_SpellsChanged()
              end,
              function(state, key)
                return buffomatModule.character.BuffCategoriesHidden[--[[---@type string]] key] ~= true -- invert
              end
      ),
    } -- end args
  }
end

function optionsModule:CreateClassOptionsTable()
  return {
    type = "group",
    name = "9. " .. _t("options.general.group.Class"),
    args = {
      shamanFlametongueRanked = self:TemplateCheckbox("ShamanFlametongueRanked", nil, nil, nil),
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
      classOptions       = self:CreateClassOptionsTable(),
    } -- end args
  } -- end
end

---Called from options' Default button
function optionsModule:ResetDefaultOptions()
end
