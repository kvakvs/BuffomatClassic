local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomPopupModule
local popupModule = {}
BomModuleManager.popupModule = popupModule

---@class BomPopupDynamic
---@field _Frame BomGPIControl
---@field AddItem function
---@field SubMenu function
---@field Show function
---@field Wipe function

---@class BomGPIControlPopup: BomGPIControl
---@field _Frame BomGPIControl Popup currently open in the game (to see if its our popup or not)
---@field _where string Where to show the popup (cursor, mouse, center)
---@field _x number X offset
---@field _y number Y offset

local PopupDepth ---@type number|nil

---Handler for popup menu clicks
---@param self BomPopupInfo
function popupModule.PopupClick(self, arg1, arg2, checked)
  if type(self.value) == "table" then
    self.value[arg1] = not self.value[arg1]
    self.checked = self.value[arg1]
    if arg2 then
      arg2(self.value, arg1, checked)
    end

  elseif type(self.value) == "function" then
    self.value(arg1, arg2)
  end
end

function popupModule.PopupAddItem(self, text, disabled, value, arg1, arg2)
  local c = self._Frame._GPIPRIVAT_Items.count + 1
  self._Frame._GPIPRIVAT_Items.count = c

  if not self._Frame._GPIPRIVAT_Items[c] then
    self._Frame._GPIPRIVAT_Items[c] = {}
  end

  local t = self._Frame._GPIPRIVAT_Items[c] ---@type BomPopupInfo

  t.text = text or ""
  t.disabled = disabled or false
  t.value = value
  t.arg1 = arg1
  t.arg2 = arg2
  t.MenuDepth = PopupDepth or 0
end

---@param self BomGPIControlPopup
function popupModule.PopupAddSubMenu(self, text, value)
  if text ~= nil and text ~= "" then
    popupModule.PopupAddItem(self, text, "MENU", value, nil, nil)
    PopupDepth = value
  else
    PopupDepth = nil
  end
end

local PopupLastWipeName ---@type string

---@param self BomGPIControlPopup
---@param WipeName string
function popupModule.PopupWipe(self, WipeName)
  self._Frame.gpiPopupMenuItems.count = 0
  PopupDepth = nil

  if UIDROPDOWNMENU_OPEN_MENU == self._Frame then
    ToggleDropDownMenu(nil, nil, self._Frame, self._where, self._x, self._y)
    if WipeName == PopupLastWipeName then
      return false
    end
  end

  PopupLastWipeName = WipeName
  return true
end

---@class BomPopupInfo
---@field text string
---@field notCheckable boolean
---@field checked boolean
---@field disabled boolean
---@field value any
---@field arg1 any
---@field arg2 any
---@field func function|nil
---@field hasArrow boolean
---@field menuList any
---@field MenuDepth number
---@field keepShownOnClick boolean

---@param frame BomGPIControl
---@param menuList any
function popupModule.PopupCreate(frame, level, menuList)
  if level == nil then
    return
  end

  local info = UIDropDownMenu_CreateInfo() ---@type BomPopupInfo

  for i = 1, frame.gpiPopupMenuItems.count do
    local val = frame.gpiPopupMenuItems[i]

    if val.MenuDepth == menuList then
      if val.disabled == "MENU" then
        -- Submenu entry
        info.text = val.text
        info.notCheckable = true
        info.disabled = false
        info.value = nil
        info.arg1 = nil
        info.arg2 = nil
        info.func = nil
        info.hasArrow = true
        info.menuList = val.value
        --info.isNotRadio=true
      else
        -- Normal menu item
        info.text = val.text
        if type(val.value) == "table" then
          info.checked = val.value[val.arg1] or false
          info.notCheckable = false
        else
          info.notCheckable = true
        end
        info.disabled = (val.disabled == true or val.text == "")
        info.keepShownOnClick = (val.disabled == "keep")
        info.value = val.value
        info.arg1 = val.arg1
        if type(val.value) == "table" then
          info.arg2 = frame.gpiPopupCallback
        elseif type(val.value) == "function" then
          info.arg2 = val.arg2
        end
        info.func = popupModule.PopupClick
        info.hasArrow = false
        info.menuList = nil
        --info.isNotRadio=true
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end
end

function popupModule.PopupShow(self, where, x, y)
  where = where or "cursor"
  if UIDROPDOWNMENU_OPEN_MENU ~= self._Frame then
    UIDropDownMenu_Initialize(self._Frame, popupModule.PopupCreate, "MENU")
  end
  ToggleDropDownMenu(nil, nil, self._Frame, where, x, y)
  self._where = where
  self._x = x
  self._y = y
end

---@return BomPopupDynamic
---@param callbackFn function
function popupModule:CreatePopup(callbackFn)
  local popup = --[[---@type BomPopupDynamic]] {}
  popup._Frame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate") ---@type BomGPIControl
  popup._Frame.gpiPopupCallback = callbackFn
  popup._Frame.gpiPopupMenuItems = --[[---@type BomGPIPopupItems]] { count = 0 }
  popup.AddItem = popupModule.PopupAddItem
  popup.SubMenu = popupModule.PopupAddSubMenu
  popup.Show = popupModule.PopupShow
  popup.Wipe = popupModule.PopupWipe
  return popup
end
