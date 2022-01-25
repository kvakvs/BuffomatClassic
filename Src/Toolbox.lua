local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })
---@class BuffomatTool
---@field IconClass table<string, string> Class icon strings indexed by class name
---@field IconClassBig table<string, string> Class icon strings indexed by class name
---@field RaidIconNames table<string, number>
---@field RaidIcon table<string>
---@field Classes table<string>
---@field ClassName table<string> Localized class names (male)
---@field ClassColor table<string, table> Localized class colors
---@field NameToClass table<string, string> Reverse class name lookup
---@field _EditBox Control

BOM.Tool = BOM.Tool or {} ---@type BuffomatTool
local Tool = BOM.Tool ---@type BuffomatTool

--Tool.IconClassTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
--Tool.IconClassTextureWithoutBorder = "Interface\\WorldStateFrame\\ICONS-CLASSES"
--Tool.IconClassTextureCoord = CLASS_ICON_TCOORDS
Tool.IconClass = {
  ["WARRIOR"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:0:64|t",
  ["MAGE"]    = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:0:64|t",
  ["ROGUE"]   = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:192:0:64|t",
  ["DRUID"]   = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:192:256:0:64|t",
  ["HUNTER"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:64:128|t",
  ["SHAMAN"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:64:128|t",
  ["PRIEST"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:192:64:128|t",
  ["WARLOCK"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:192:256:64:128|t",
  ["PALADIN"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:128:192|t",
}
Tool.IconClassBig = {
  ["WARRIOR"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:0:64|t",
  ["MAGE"]    = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:64:128:0:64|t",
  ["ROGUE"]   = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:128:192:0:64|t",
  ["DRUID"]   = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:192:256:0:64|t",
  ["HUNTER"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:64:128|t",
  ["SHAMAN"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:64:128:64:128|t",
  ["PRIEST"]  = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:128:192:64:128|t",
  ["WARLOCK"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:192:256:64:128|t",
  ["PALADIN"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:128:192|t",
}

Tool.RaidIconNames = ICON_TAG_LIST
Tool.RaidIcon = {
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t", -- [1]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t", -- [2]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t", -- [3]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t", -- [4]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t", -- [5]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t", -- [6]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t", -- [7]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t", -- [8]
}

Tool.Classes = CLASS_SORT_ORDER
Tool.ClassName = LOCALIZED_CLASS_NAMES_MALE
Tool.ClassColor = RAID_CLASS_COLORS

Tool.NameToClass = {}
for eng, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
  Tool.NameToClass[name] = eng
  Tool.NameToClass[eng] = eng
end
for eng, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
  Tool.NameToClass[name] = eng
end

---Converts accented letters to ASCII equivalent for sorting
local bom_special_letter_to_ascii = {
  ["�"] = "A", ["�"] = "A", ["�"] = "A", ["�"] = "A", ["�"] = "Ae", ["�"] = "A",
  ["�"] = "AE", ["�"] = "C", ["�"] = "E", ["�"] = "E", ["�"] = "E", ["�"] = "E",
  ["�"] = "I", ["�"] = "I", ["�"] = "I", ["�"] = "I", ["�"] = "D", ["�"] = "N",
  ["�"] = "O", ["�"] = "O", ["�"] = "O", ["�"] = "O", ["�"] = "Oe", ["�"] = "O",
  ["�"] = "U", ["�"] = "U", ["�"] = "U", ["�"] = "Ue", ["�"] = "Y", ["�"] = "P",
  ["�"] = "s", ["�"] = "a", ["�"] = "a", ["�"] = "a", ["�"] = "a", ["�"] = "ae",
  ["�"] = "a", ["�"] = "ae", ["�"] = "c", ["�"] = "e", ["�"] = "e", ["�"] = "e",
  ["�"] = "e", ["�"] = "i", ["�"] = "i", ["�"] = "i", ["�"] = "i", ["�"] = "eth",
  ["�"] = "n", ["�"] = "o", ["�"] = "o", ["�"] = "o", ["�"] = "o", ["�"] = "oe",
  ["�"] = "o", ["�"] = "u", ["�"] = "u", ["�"] = "u", ["�"] = "ue", ["�"] = "y",
  ["�"] = "p", ["�"] = "y", ["�"] = "ss",
}

-- Hyperlink

local function bom_on_enter_hyperlink(self, link, text)
  --print(link,text)
  local part = Tool.Split(link, ":")
  if part[1] == "spell"
          or part[1] == "unit"
          or part[1] == "item"
          or part[1] == "enchant"
          or part[1] == "player"
          or part[1] == "quest"
          or part[1] == "trade" then
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
    GameTooltip:ClearLines()
    GameTooltip:SetHyperlink(link)
    GameTooltip:Show()
  end
end

local function bom_on_leave_hyperlink(self)
  GameTooltip:Hide()
end

function Tool.EnableHyperlink(frame)
  frame:SetHyperlinksEnabled(true);
  frame:SetScript("OnHyperlinkEnter", bom_on_enter_hyperlink)
  frame:SetScript("OnHyperlinkLeave", bom_on_leave_hyperlink)
end

--- EventHandler
--local eventFrame ---@type Control

---@param self Control
local function bom_gpiprivat_event_handler(self, event, ...)
  for i, Entry in pairs(self._GPIPRIVAT_events) do
    if Entry[1] == event then
      Entry[2](...)
    end
  end
end

---@param self Control
local function bom_gpiprivat_update_handler(self, ...)
  for i, Entry in pairs(self._GPIPRIVAT_updates) do
    Entry(...)
  end
end

--function BuffomatAddon:RegisterEvent(event, func)
--  if eventFrame == nil then
--    eventFrame = CreateFrame("Frame")
--  end
--
--  if eventFrame._GPIPRIVAT_events == nil then
--    eventFrame._GPIPRIVAT_events = {}
--    eventFrame:SetScript("OnEvent", bom_gpiprivat_event_handler)
--  end
--
--  tinsert(eventFrame._GPIPRIVAT_events, { event, func })
--  eventFrame:RegisterEvent(event)
--end

function Tool.OnUpdate(func)
  if eventFrame == nil then
    eventFrame = CreateFrame("Frame")
  end
  if eventFrame._GPIPRIVAT_updates == nil then
    eventFrame._GPIPRIVAT_updates = {}
    eventFrame:SetScript("OnUpdate", bom_gpiprivat_update_handler)
  end
  tinsert(eventFrame._GPIPRIVAT_updates, func)
end

-- move frame
local function bom_frame_drag_start(self)
  self:StartMoving()
end

local function bom_frame_drag_stop(self)
  self:StopMovingOrSizing()
  if self._GPIPRIVAT_MovingStopCallback then
    self._GPIPRIVAT_MovingStopCallback(self)
  end
end

function Tool.EnableMoving(frame, callback)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", bom_frame_drag_start)
  frame:SetScript("OnDragStop", bom_frame_drag_stop)
  frame._GPIPRIVAT_MovingStopCallback = callback
end

-- misc tools

local MyScanningTooltip ---@type Control

function Tool.ScanToolTip(what, ...)
  local TextList = {}
  if MyScanningTooltip == nil then
    MyScanningTooltip = CreateFrame("GameTooltip", TOCNAME .. "_MyScanningTooltip", nil, "GameTooltipTemplate") -- Tooltip name cannot be nil
    MyScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    -- Allow tooltip SetX() methods to dynamically add new lines based on these
    MyScanningTooltip:AddFontStrings(
            MyScanningTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
            MyScanningTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  MyScanningTooltip:ClearLines()
  MyScanningTooltip[what](MyScanningTooltip, ...)

  --print("do",TOCNAME.."_MyScanningTooltip")
  for i, region in ipairs({ MyScanningTooltip:GetRegions() }) do
    if region and region:GetObjectType() == "FontString" then
      local text = region:GetText()
      if text then
        tinsert(TextList, text)
      end
    end
  end
  return TextList
end

function Tool.CopyTable(from, to)
  -- "to" must be a table (possibly empty)
  to = to or {}
  for k, v in pairs(from) do
    if type(v) == "table" then
      to[k] = Tool.CopyTable(v)
    else
      to[k] = v
    end
  end
  return to
end

function Tool.GuildNameToIndex(name, searchOffline)
  name = string.lower(name)
  for i = 1, GetNumGuildMembers(searchOffline) do
    if string.lower(string.match((GetGuildRosterInfo(i)), "(.-)-")) == name then
      return i
    end
  end
end

function Tool.RunSlashCmd(cmd)
  if Tool._EditBox == nil then
    Tool._EditBox = CreateFrame("EditBox", "GPILIB_myEditBox_" .. TOCNAME, UIParent)
    Tool._EditBox.chatFrame = Tool._EditBox:GetParent();
    ChatEdit_OnLoad(Tool._EditBox);
    Tool._EditBox:Hide()
  end
  Tool._EditBox:SetText(cmd)
  ChatEdit_SendText(Tool._EditBox)
end

function Tool.RGBtoEscape(r, g, b, a)
  if type(r) == "table" then
    a = r.a
    g = r.g
    b = r.b
    r = r.r
  end

  r = r ~= nil and r <= 1 and r >= 0 and r or 1
  g = g ~= nil and g <= 1 and g >= 0 and g or 1
  b = b ~= nil and b <= 1 and b >= 0 and b or 1
  a = a ~= nil and a <= 1 and a >= 0 and a or 1
  return string.format("|c%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255)
end

function Tool.GetRaidIcon(name)
  local x = string.gsub(string.lower(name), "[%{%}]", "")
  return ICON_TAG_LIST[x] and Tool.RaidIcon[ICON_TAG_LIST[x]] or name
end

local TOO_FAR = 1000000

function Tool.UnitDistanceSquared(uId)
  --partly copied from DBM
  --    * Paul Emmerich (Tandanu @ EU-Aegwynn) (DBM-Core)
  --    * Martin Verges (Nitram @ EU-Azshara) (DBM-GUI)

  local range

  if UnitIsUnit(uId, "player") then
    range = 0
  else
    local distanceSquared, checkedDistance = UnitDistanceSquared(uId)

    if checkedDistance then
      range = distanceSquared
    elseif C_Map.GetBestMapForUnit(uId) ~= C_Map.GetBestMapForUnit("player") then
      range = TOO_FAR
    elseif IsItemInRange(8149, uId) then
      range = 64 -- 8 --Voodoo Charm
    elseif CheckInteractDistance(uId, 3) then
      range = 100 --10
    elseif CheckInteractDistance(uId, 2) then
      range = 121 --11
    elseif IsItemInRange(14530, uId) then
      range = 324 --18--Heavy Runecloth Bandage. (despite popular sites saying it's 15 yards, it's actually 18 yards verified by UnitDistanceSquared
    elseif IsItemInRange(21519, uId) then
      range = 529 --23--Item says 20, returns true until 23.
    elseif IsItemInRange(1180, uId) then
      range = 1089 --33--Scroll of Stamina
    elseif UnitInRange(uId) then
      range = 1849--43 item scheck of 34471 also good for 43
    else
      range = 10000
    end
  end
  return range
end

function Tool.Merge(t1, ...)
  for index = 1, select("#", ...) do
    for i, v in pairs(select(index, ...)) do
      t1[i] = v
    end
  end
  return t1
end

function Tool.iMerge(t1, ...)
  for index = 1, select("#", ...) do
    local var = select(index, ...)

    if type(var) == "table" then
      for i, v in ipairs(var) do
        if tContains(t1, v) == false then
          tinsert(t1, v)
        end
      end
    else
      tinsert(t1, var)
    end
  end
  return t1
end

---@param str string
---@return string
function Tool.stripChars(str)
  return string.gsub(str, "[%z\1-\127\194-\244][\128-\191]*", bom_special_letter_to_ascii)
end

---@param pattern string
---@param maximize boolean
function Tool.CreatePattern(pattern, maximize)
  pattern = string.gsub(pattern, "[%(%)%-%+%[%]]", "%%%1")

  if not maximize then
    pattern = string.gsub(pattern, "%%s", "(.-)")
  else
    pattern = string.gsub(pattern, "%%s", "(.+)")
  end

  pattern = string.gsub(pattern, "%%d", "%(%%d-%)")

  if not maximize then
    pattern = string.gsub(pattern, "%%%d%$s", "(.-)")
  else
    pattern = string.gsub(pattern, "%%%d%$s", "(.+)")
  end

  pattern = string.gsub(pattern, "%%%d$d", "%(%%d-%)")
  --pattern = string.gsub(pattern, "%[", "%|H%(%.%-%)%[")
  --pattern = string.gsub(pattern, "%]", "%]%|h")

  return pattern
end

function Tool.Combine(t, sep, first, last)
  if type(t) ~= "table" then
    return ""
  end
  sep = sep or " "
  first = first or 1
  last = last or #t

  local ret = ""
  for i = first, last do
    ret = ret .. sep .. tostring(t[i])
  end
  return string.sub(ret, string.len(sep) + 1)
end

function Tool.iSplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end

  local t = {}

  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    if tContains(t, str) == false then
      table.insert(t, tonumber(str))
    end
  end

  return t
end

function Tool.Split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end

  local t = {}

  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    if tContains(t, str) == false then
      table.insert(t, str)
    end
  end

  return t
end

-- Size 

local ResizeCursor ---@type Control

local SizingStop = function(self, button)
  self:GetParent():StopMovingOrSizing()

  if self.GPI_DoStop then
    self.GPI_DoStop(self:GetParent())
  end
end

local SizingStart = function(self, button)
  self:GetParent():StartSizing(self.GPI_SIZETYPE)
  if self.GPI_DoStart then
    self.GPI_DoStart(self:GetParent())
  end
end

---@type Control
local SizingEnter = function(self)
  if not (GetCursorInfo()) then
    ResizeCursor:Show()
    ResizeCursor.Texture:SetTexture(self.GPI_Cursor)
    ResizeCursor.Texture:SetRotation(math.rad(self.GPI_Rotation), 0.5, 0.5)
  end
end

local SizingLeave = function(self, button)
  ResizeCursor:Hide()
end

local sizecount = 0

local function CreateSizeBorder(frame, name, a1, x1, y1, a2, x2, y2, cursor, rot, OnStart, OnStop)
  local FrameSizeBorder ---@type Control
  sizecount = sizecount + 1
  FrameSizeBorder = CreateFrame("Frame", (frame:GetName() or TOCNAME .. sizecount) .. "_size_" .. name, frame)
  FrameSizeBorder:SetPoint("TOPLEFT", frame, a1, x1, y1)
  FrameSizeBorder:SetPoint("BOTTOMRIGHT", frame, a2, x2, y2)
  FrameSizeBorder.GPI_SIZETYPE = name
  FrameSizeBorder.GPI_Cursor = cursor
  FrameSizeBorder.GPI_Rotation = rot
  FrameSizeBorder.GPI_DoStart = OnStart
  FrameSizeBorder.GPI_DoStop = OnStop
  FrameSizeBorder:SetScript("OnMouseDown", SizingStart)
  FrameSizeBorder:SetScript("OnMouseUp", SizingStop)
  FrameSizeBorder:SetScript("OnEnter", SizingEnter)
  FrameSizeBorder:SetScript("OnLeave", SizingLeave)
  return FrameSizeBorder
end

local ResizeCursor_Update = function(self)
  local X, Y = GetCursorPosition()
  local Scale = self:GetEffectiveScale()
  self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", X / Scale, Y / Scale)
end

function Tool.EnableSize(frame, border, OnStart, OnStop)
  if not ResizeCursor then
    ResizeCursor = CreateFrame("Frame", nil, UIParent)
    ResizeCursor:Hide()
    ResizeCursor:SetWidth(24)
    ResizeCursor:SetHeight(24)
    ResizeCursor:SetFrameStrata("TOOLTIP")
    ResizeCursor.Texture = ResizeCursor:CreateTexture()
    ResizeCursor.Texture:SetAllPoints()
    ResizeCursor:SetScript("OnUpdate", ResizeCursor_Update)
  end
  border = border or 8

  frame:EnableMouse(true)
  frame:SetResizable(true)

  --path = "Interface\\AddOns\\" .. TOCNAME .. "\\Resize\\"

  CreateSizeBorder(frame, "BOTTOM", "BOTTOMLEFT", border, border, "BOTTOMRIGHT", -border, 0, "Interface\\CURSOR\\UI-Cursor-SizeLeft", 45, OnStart, OnStop)
  CreateSizeBorder(frame, "TOP", "TOPLEFT", border, 0, "TOPRIGHT", -border, -border, "Interface\\CURSOR\\UI-Cursor-SizeLeft", 45, OnStart, OnStop)
  CreateSizeBorder(frame, "LEFT", "TOPLEFT", 0, -border, "BOTTOMLEFT", border, border, "Interface\\CURSOR\\UI-Cursor-SizeRight", 45, OnStart, OnStop)
  CreateSizeBorder(frame, "RIGHT", "TOPRIGHT", -border, -border, "BOTTOMRIGHT", 0, border, "Interface\\CURSOR\\UI-Cursor-SizeRight", 45, OnStart, OnStop)

  CreateSizeBorder(frame, "TOPLEFT", "TOPLEFT", 0, 0, "TOPLEFT", border, -border, "Interface\\CURSOR\\UI-Cursor-SizeRight", 0, OnStart, OnStop)
  CreateSizeBorder(frame, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, "BOTTOMLEFT", border, border, "Interface\\CURSOR\\UI-Cursor-SizeLeft", 0, OnStart, OnStop)
  CreateSizeBorder(frame, "TOPRIGHT", "TOPRIGHT", 0, 0, "TOPRIGHT", -border, -border, "Interface\\CURSOR\\UI-Cursor-SizeLeft", 0, OnStart, OnStop)
  CreateSizeBorder(frame, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -border, border, "Interface\\CURSOR\\UI-Cursor-SizeRight", 0, OnStart, OnStop)
end

-- popup
local PopupDepth ---@type number|nil

local function PopupClick(self, arg1, arg2, checked)
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

local function PopupAddItem(self, text, disabled, value, arg1, arg2)
  local c = self._Frame._GPIPRIVAT_Items.count + 1
  self._Frame._GPIPRIVAT_Items.count = c

  if not self._Frame._GPIPRIVAT_Items[c] then
    self._Frame._GPIPRIVAT_Items[c] = {}
  end

  local t = self._Frame._GPIPRIVAT_Items[c] ---@type GPIMenuItem

  t.text = text or ""
  t.disabled = disabled or false
  t.value = value
  t.arg1 = arg1
  t.arg2 = arg2
  t.MenuDepth = PopupDepth
end

local function PopupAddSubMenu(self, text, value)
  if text ~= nil and text ~= "" then
    PopupAddItem(self, text, "MENU", value)
    PopupDepth = value
  else
    PopupDepth = nil
  end
end

local PopupLastWipeName

---@param self Control
local function PopupWipe(self, WipeName)
  self._Frame._GPIPRIVAT_Items.count = 0
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

local function PopupCreate(frame, level, menuList)
  if level == nil then
    return
  end

  local info = UIDropDownMenu_CreateInfo()

  for i = 1, frame._GPIPRIVAT_Items.count do
    local val = frame._GPIPRIVAT_Items[i]
    if val.MenuDepth == menuList then
      if val.disabled == "MENU" then
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
          info.arg2 = frame._GPIPRIVAT_TableCallback
        elseif type(val.value) == "function" then
          info.arg2 = val.arg2
        end
        info.func = PopupClick
        info.hasArrow = false
        info.menuList = nil
        --info.isNotRadio=true
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end
end

local function PopupShow(self, where, x, y)
  where = where or "cursor"
  if UIDROPDOWNMENU_OPEN_MENU ~= self._Frame then
    UIDropDownMenu_Initialize(self._Frame, PopupCreate, "MENU")
  end
  ToggleDropDownMenu(nil, nil, self._Frame, where, x, y)
  self._where = where
  self._x = x
  self._y = y
end

function Tool.CreatePopup(TableCallback)
  local popup = {}
  popup._Frame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")
  popup._Frame._GPIPRIVAT_TableCallback = TableCallback
  popup._Frame._GPIPRIVAT_Items = {}
  popup._Frame._GPIPRIVAT_Items.count = 0
  popup.AddItem = PopupAddItem
  popup.SubMenu = PopupAddSubMenu
  popup.Show = PopupShow
  popup.Wipe = PopupWipe
  return popup
end

-- TAB

local function bomSelectTab(self)
  if not self._gpi_combatlock or not InCombatLockdown() then
    local parent = self:GetParent()
    PanelTemplates_SetTab(parent, self:GetID())

    for i = 1, parent.numTabs do
      parent.Tabs[i].content:Hide()
    end

    self.content:Show()

    if parent.Tabs[self:GetID()].OnSelect then
      parent.Tabs[self:GetID()].OnSelect(self)
    end
  end
end

function Tool.TabHide(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id]:Hide()
  elseif not id and frame.Tabs then
    for i = 1, frame.numTabs do
      frame.Tabs[i]:Hide()
    end
  end
end

function Tool.TabShow(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id]:Show()
  elseif not id and frame.Tabs then
    for i = 1, frame.numTabs do
      frame.Tabs[i]:Show()
    end
  end
end

function Tool.SelectTab(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    bomSelectTab(frame.Tabs[id])
  end
end

function Tool.TabOnSelect(frame, id, func)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id].OnSelect = func
  end
end

function Tool.GetSelectedTab(frame)
  if frame.Tabs then
    for i = 1, frame.numTabs do
      if frame.Tabs[i].content:IsShown() then
        return i
      end
    end
  end
  return 0
end

---Adds a Tab to a frame (main window for example)
---@param frame Control | string - where to add a tab
---@param name string - tab text
---@param tabFrame Control | string - tab text
---@param combatlockdown boolean - accessible in combat or not
function Tool.AddTab(frame, name, tabFrame, combatlockdown)
  local frameName

  if type(frame) == "string" then
    frameName = frame
    frame = _G[frameName]
  else
    frameName = frame:GetName()
  end
  if type(tabFrame) == "string" then
    tabFrame = _G[tabFrame]
  end

  frame.numTabs = frame.numTabs and frame.numTabs + 1 or 1
  if frame.Tabs == nil then
    frame.Tabs = {}
  end

  frame.Tabs[frame.numTabs] = CreateFrame(
          "Button", frameName .. "Tab" .. frame.numTabs, frame,
          "CharacterFrameTabButtonTemplate")
  frame.Tabs[frame.numTabs]:SetID(frame.numTabs)
  frame.Tabs[frame.numTabs]:SetText(name)
  frame.Tabs[frame.numTabs]:SetScript("OnClick", bomSelectTab)
  frame.Tabs[frame.numTabs]._gpi_combatlock = combatlockdown
  frame.Tabs[frame.numTabs].content = tabFrame
  tabFrame:Hide()

  if frame.numTabs == 1 then
    frame.Tabs[frame.numTabs]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 4)
  else
    frame.Tabs[frame.numTabs]:SetPoint("TOPLEFT", frame.Tabs[frame.numTabs - 1], "TOPRIGHT", -14, 0)
  end

  bomSelectTab(frame.Tabs[frame.numTabs])
  bomSelectTab(frame.Tabs[1])
  return frame.numTabs
end


-- DataBroker
local bomDataBroker = false
function Tool.AddDataBroker(icon, onClick, onTooltipShow, text)
  if LibStub ~= nil and bomDataBroker ~= true then
    local Launcher = LibStub('LibDataBroker-1.1', true)
    if Launcher ~= nil then
      bomDataBroker = true
      Launcher:NewDataObject(TOCNAME, {
        type          = "launcher",
        icon          = icon,
        OnClick       = onClick,
        OnTooltipShow = onTooltipShow,
        tocname       = TOCNAME,
        label         = text or GetAddOnMetadata(TOCNAME, "Title"),
      })
    end
  end
end

-- Slashcommands

local slash, slashCmd
local function bom_slash_unpack(t, sep)
  local ret = ""
  if sep == nil then
    sep = ", "
  end
  for i = 1, #t do
    if i ~= 1 then
      ret = ret .. sep
    end
    ret = ret .. t[i]
  end
  return ret
end

function Tool.PrintSlashCommand(prefix, subSlash, p)
  p = p or print
  prefix = prefix or ""
  subSlash = subSlash or slash

  local colCmd = "|cFFFF9C00"

  for i, subcmd in ipairs(subSlash) do
    local words = (type(subcmd[1]) == "table") and "|r(" .. colCmd .. bom_slash_unpack(subcmd[1], "|r/" .. colCmd) .. "|r)" .. colCmd or subcmd[1]
    if words == "%" then
      words = "<value>"
    end

    if subcmd[2] ~= nil and subcmd[2] ~= "" then
      p(colCmd .. ((type(slashCmd) == "table") and slashCmd[1] or slashCmd) .. " " .. prefix .. words .. "|r: " .. subcmd[2])
    end
    if type(subcmd[3]) == "table" then

      Tool.PrintSlashCommand(prefix .. words .. " ", subcmd[3], p)
    end

  end
end

local function bom_do_slash(deep, msg, subSlash)
  for i, subcmd in ipairs(subSlash) do
    local ok = (type(subcmd[1]) == "table") and tContains(subcmd[1], msg[deep]) or
            (subcmd[1] == msg[deep] or (subcmd[1] == "" and msg[deep] == nil))

    if subcmd[1] == "%" then
      local para = Tool.iMerge({ unpack(subcmd, 4) }, { unpack(msg, deep) })
      return subcmd[3](unpack(para))
    end

    if ok then
      if type(subcmd[3]) == "function" then
        return subcmd[3](unpack(subcmd, 4))
      elseif type(subcmd[3]) == "table" then
        return bom_do_slash(deep + 1, msg, subcmd[3])
      end
    end
  end

  Tool.PrintSlashCommand(Tool.Combine(msg, " ", 1, deep - 1) .. " ", subSlash)

  return nil
end

local function bom_handle_slash_command(msg)
  if msg == "help" then
    local colCmd = "|cFFFF9C00"
    print("|cFFFF1C1C" .. GetAddOnMetadata(TOCNAME, "Title") .. " " .. GetAddOnMetadata(TOCNAME, "Version") .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
    print(GetAddOnMetadata(TOCNAME, "Notes"))
    if type(slashCmd) == "table" then
      print("SlashCommand:", colCmd, bom_slash_unpack(slashCmd, "|r, " .. colCmd), "|r")
    end

    Tool.PrintSlashCommand()
  else
    bom_do_slash(1, Tool.Split(msg, " "), slash)
  end
end

function Tool.SlashCommand(cmds, subcommand)
  slash = subcommand
  slashCmd = cmds
  if type(cmds) == "table" then
    for i, cmd in ipairs(cmds) do
      _G["SLASH_" .. TOCNAME .. i] = cmd
    end
  else
    _G["SLASH_" .. TOCNAME .. "1"] = cmds
  end

  SlashCmdList[TOCNAME] = bom_handle_slash_command
end

---- quick copy&past

local CopyPastFrame
local CopyPastSavedText
local CopyPastText

local function bom_create_copypaste()
  local frame

  if BOM.TBC then
    frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
  else
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetBackdrop({
      bgFile   = "Interface/DialogFrame/UI-DialogBox-Background",
      tile     = true,
      edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
      edgeSize = 32,
      insets   = {
        left   = 11,
        right  = 12,
        top    = 12,
        bottom = 11,
      },
    })
  end

  frame:SetFrameStrata("DIALOG")
  frame:SetSize(700, 450)
  frame:SetPoint("CENTER")
  frame:EnableMouse(true)
  frame:EnableKeyboard(true)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:SetMinResize(200, 200)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    CopyPastFrame:StartMoving()
  end)
  frame:SetScript("OnDragStop", function()
    CopyPastFrame:StopMovingOrSizing();
    CopyPastText:SetSize(CopyPastText:GetParent(scrollFrame):GetWidth(), 10)
  end)
  frame:SetScript("OnSizeChanged", function()
    if CopyPastText then
      CopyPastText:SetSize(CopyPastText:GetParent(scrollFrame):GetWidth(), 10)
    end
  end)

  Tool.EnableSize(frame)

  local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  button:SetWidth(128)
  button:SetPoint("BOTTOM", 0, 16)
  button:SetText("OK")
  button:SetScript("OnClick", function()
    CopyPastFrame:Hide()
  end)

  local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetSize(10, 10)
  scrollFrame:ClearAllPoints()
  scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
  scrollFrame:SetPoint("RIGHT", -40, 0)
  scrollFrame:SetPoint("BOTTOM", button, "TOP", 0, 10)

  scrollFrame:Show()

  local editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetMaxLetters(999999)
  editBox:SetSize(editBox:GetParent(scrollFrame):GetWidth(), 10)
  editBox:ClearAllPoints()
  --editBox:SetPoint("TOPLEFT",scrollFrame,"TOPLEFT")
  editBox:SetPoint("RIGHT", scrollFrame, "RIGHT")

  editBox:SetFont(ChatFontNormal:GetFont())
  editBox:SetAutoFocus(true)
  editBox:SetMultiLine(true)
  editBox:Show()
  editBox:SetScript("OnEscapePressed", function(self)
    CopyPastFrame:Hide()
  end)
  editBox:SetScript("OnEnterPressed", function(self)
    CopyPastFrame:Hide()
  end)
  editBox:SetScript("OnTextChanged", function(self)
    CopyPastText:SetText(CopyPastSavedText)
    CopyPastText:HighlightText()
  end)

  scrollFrame:SetScrollChild(editBox)

  CopyPastFrame = frame
  CopyPastTitle = title
  CopyPastText = editBox
  return frame
end

function Tool.CopyPast(Text)
  if CopyPastFrame == nil then
    bom_create_copypaste()
  end
  CopyPastText:SetText(Text)
  CopyPastText:HighlightText()
  CopyPastFrame:Show()
  CopyPastText:SetFocus()
  CopyPastSavedText = Text
end

---If maybe_label is nil, creates a text label under the parent. Calls position_fn
---on the label to set its position.
---@param maybe_label Control|nil - the existing label or nil
---@param parent Control - parent where the label is created
---@param position_fn function - applies function after creating the label
function bom_create_smalltext_label(maybe_label, parent, position_fn)
  if maybe_label == nil then
    maybe_label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  end
  position_fn(maybe_label)
  return maybe_label
end

---Add onenter/onleave scripts to show the tooltip with translation by key
---@param control Control
---@param translation_key string - the key from Languages.lua
function Tool.Tooltip(control, translation_key)
  control:SetScript("OnEnter", function()
    GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L[translation_key])
    GameTooltip:Show()
  end)
  control:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---Add onenter/onleave scripts to show the tooltip with TEXT
---@param control Control
---@param text string - the localized text to display
function Tool.TooltipText(control, text)
  control:SetScript("OnEnter", function()
    GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
    GameTooltip:AddLine(text)
    GameTooltip:Show()
  end)
  control:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---@param spellName string
local function bom_find_spellid(spellName)
  local i = 1;
  while true do
    local spellAndRank = My_GetSpellName(i, BOOKTYPE_SPELL);
    if (not spellAndRank) then
      break ;
    end
    if (spellName == spellAndRank) then
      --print at this point like "Fireball(Rank 13)"
      return i;
    end
    i = i + 1;
  end
  return nil;
end

---Add onenter/onleave scripts to show the tooltip with spell
---@param control Control
---@param link string The string in format "spell:<id>" or "item:<id>"
function Tool.TooltipLink(control, link)
  control:SetScript("OnEnter", function()
    local spellId = GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(link)
    GameTooltip:Show()
  end)
  control:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---@param text string
---@param fn function
function Tool.Profile(text, fn)
  local t_start = debugprofilestop()
  local result = fn()
  local t_end = debugprofilestop()

  local duration = t_end - t_start
  BOM.Dbg(text .. ": " .. tostring(duration))

  return result
end
