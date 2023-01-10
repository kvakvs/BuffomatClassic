---@class KvOptionsModule
---@field optionsOrder number
local optionsModule = KvModuleManager.optionsModule --[[---@type KvOptionsModule]]
optionsModule.optionsOrder = 0

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

---@param dict table
---@param key string
---@param notify function|nil Call this with (key, value) on option change
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateCheckbox(name, dict, key, notify, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name = _t("options.short." .. name),
    desc = _t("options.long." .. name),
    type = "toggle",
    width = "full",
    order = self.optionsOrder,

    set = function(info, val)
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get = function(info)
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
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateButton(name, onClick, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name = _t("options.short." .. name),
    desc = _t("options.long." .. name),
    type = "execute",
    width = "half",
    order = self.optionsOrder,
    func = onClick,
  }
end

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table|nil
---@param notifyFn function|nil Call this with (key, value) on option change
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateMultiselect(name, values, dict, notifyFn, setFn, getFn, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name = _t("options.short." .. name),
    desc = _t("options.long." .. name),
    type = "multiselect",
    width = "full",
    order = self.optionsOrder,
    values = values,

    set = setFn or function(state, key, value)
      if dict then
        (--[[---@not nil]]  dict)[key] = value
        if notifyFn then
          (--[[---@not nil]] notifyFn)(key, value)
        end
      end
    end,
    get = getFn or function(state, key)
      if dict then
        return (--[[---@not nil]] dict)[key] == true
      else
        return nil
      end
    end,
  }
end

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table
---@param style string|nil "dropdown" or "radio"
---@param notifyFn function|nil Call this with (key, value) on option change
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateSelect(name, values, style, dict, notifyFn, setFn, getFn, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    desc = _t("options.long." .. name),
    name = _t("options.short." .. name),
    order = self.optionsOrder,
    style = style or "dropdown",
    type = "select",
    values = values,
    width = 2.0,

    set = setFn or function(info, value)
      if dict then
        (--[[---@not nil]] dict)[name] = value
        if notifyFn then
          (--[[---@not nil]] notifyFn)(value)
        end
      end
    end,
    get = getFn or function(info)
      if dict then
        return (--[[---@not nil]] dict)[name]
      else
        return nil
      end
    end,
  }
end

---@alias RsInputValueType "string"|"float"|"integer"

---@param type RsInputValueType
---@param dict table
---@param key string
---@param notify function|nil Call this with (key, value) on option change
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateInput(type, name, dict, key, notify, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name = _t("options.short." .. name),
    desc = _t("options.long." .. name),
    type = "input",
    width = "full",
    order = self.optionsOrder,

    set = function(info, val)
      val = self:TextToValue(type, val)
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get = function(info)
      if dict then
        return self:ValueToText(type, (--[[---@not nil]] dict)[key])
      else
        return nil
      end
    end,
  }
end

---@param dict table
---@param key string
---@param notify function|nil Call this with (key, value) on option change
---@param _t fun(key:string):string Translation callable
function optionsModule:TemplateRange(name, rangeFrom, rangeTo, step, dict, key, notify, _t)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name = _t("options.short." .. name),
    desc = _t("options.long." .. name),
    type = "range",
    min = rangeFrom,
    max = rangeTo,
    step = step,
    width = "full",
    order = self.optionsOrder,

    set = function(info, val)
      if dict then
        (--[[---@not nil]] dict)[key] = val
        if notify then
          (--[[---@not nil]] notify)(key, val)
        end
      end
    end,
    get = function(info)
      if dict then
        return (--[[---@not nil]] dict)[key]
      else
        return nil
      end
    end,
  }
end
