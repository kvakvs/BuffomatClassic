local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomToolboxModule
---@field IconClass table<string, string> Class icon strings indexed by class name
---@field IconClassBig table<string, string> Class icon strings indexed by class name
---@field RaidIconNames table<string, number>
---@field RaidIcon string[]
---@field Classes string[]
---@field ClassName string[] Localized class names (male)
---@field ClassColor table<string, table> Localized class colors
---@field NameToClass table<string, string> Reverse class name lookup
---@field _EditBox BomGPIControlEditBox
local toolboxModule = BomModuleManager.toolboxModule ---@type BomToolboxModule

local _t = BomModuleManager.languagesModule
local constModule = BomModuleManager.constModule

---@class BomGPIControlEditBox: BomGPIControl
---@field chatFrame BomControl

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
  local part = toolboxModule:Split(link, ":")
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

function toolboxModule:EnableHyperlink(frame)
  frame:SetHyperlinksEnabled(true);
  frame:SetScript("OnHyperlinkEnter", bom_on_enter_hyperlink)
  frame:SetScript("OnHyperlinkLeave", bom_on_leave_hyperlink)
end

--- EventHandler
--local eventFrame ---@type Control

---@param self BomGPIControl
---@deprecated
local function bom_gpiprivat_event_handler(self, event, ...)
  for key, callback in pairs(self._GPIPRIVAT_events) do
    if key == event then
      callback(...)
    end
  end
end

---@param self BomGPIControl
function toolboxModule.gpiprivat_update_handler(self, ...)
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

function toolboxModule:OnUpdate(func)
  if eventFrame == nil then
    eventFrame = CreateFrame("Frame")
  end
  if eventFrame._GPIPRIVAT_updates == nil then
    eventFrame._GPIPRIVAT_updates = {}
    eventFrame:SetScript("OnUpdate", self.gpiprivat_update_handler)
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

function toolboxModule:EnableMoving(frame, callback)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", bom_frame_drag_start)
  frame:SetScript("OnDragStop", bom_frame_drag_stop)
  frame._GPIPRIVAT_MovingStopCallback = callback
end

-- misc tools
local myScanningTooltip ---@type BomTooltipControl

function toolboxModule:ScanToolTip(what, ...)
  local TextList = {}
  if myScanningTooltip == nil then
    myScanningTooltip = CreateFrame("GameTooltip", TOCNAME .. "_MyScanningTooltip", nil, "GameTooltipTemplate") -- Tooltip name cannot be nil
    myScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    -- Allow tooltip SetX() methods to dynamically add new lines based on these
    myScanningTooltip:AddFontStrings(
            myScanningTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
            myScanningTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  myScanningTooltip:ClearLines()
  myScanningTooltip[what](myScanningTooltip, ...)

  --print("do",TOCNAME.."_MyScanningTooltip")
  for i, region in ipairs({ myScanningTooltip:GetRegions() }) do
    if region and region:GetObjectType() == "FontString" then
      local text = region:GetText()
      if text then
        tinsert(TextList, text)
      end
    end
  end
  return TextList
end

function toolboxModule:CopyTable(from, to)
  -- "to" must be a table (possibly empty)
  to = to or {}
  for k, v in pairs(from) do
    if type(v) == "table" then
      to[k] = self:CopyTable(v, nil)
    else
      to[k] = v
    end
  end
  return to
end

---@deprecated
function toolboxModule:GuildNameToIndex(name, searchOffline)
  name = string.lower(name)
  for i = 1, GetNumGuildMembers(searchOffline) do
    if string.lower(string.match((GetGuildRosterInfo(i)), "(.-)-")) == name then
      return i
    end
  end
end

---@deprecated
function toolboxModule:RunSlashCmd(cmd)
  if self._EditBox == nil then
    self._EditBox = CreateFrame("EditBox", "GPILIB_myEditBox_" .. TOCNAME, UIParent)
    self._EditBox.chatFrame = self._EditBox:GetParent()
    ChatEdit_OnLoad(self._EditBox);
    self._EditBox:Hide()
  end
  self._EditBox:SetText(cmd)
  ChatEdit_SendText(toolboxModule._EditBox)
end

---@deprecated
function toolboxModule:RGBtoEscape(r, g, b, a)
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

---@deprecated
function toolboxModule:GetRaidIcon(name)
  local x = string.gsub(string.lower(name), "[%{%}]", "")
  return ICON_TAG_LIST[x] and constModule.RAID_ICON[ICON_TAG_LIST[x]] or name
end

local TOO_FAR = 1000011 -- special value to find out that the range error originates from this module

---@param uId string Unit to check distance from the player
function toolboxModule:UnitDistanceSquared(uId)
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

---@deprecated
function toolboxModule:Merge(t1, ...)
  for index = 1, select("#", ...) do
    for i, v in pairs(select(index, ...)) do
      t1[i] = v
    end
  end
  return t1
end

---@deprecated
function toolboxModule:iMerge(t1, ...)
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

---@deprecated
---@param str string
---@return string
function toolboxModule:stripChars(str)
  return string.gsub(str, "[%z\1-\127\194-\244][\128-\191]*", bom_special_letter_to_ascii)
end

---@deprecated
---@param pattern string
---@param maximize boolean
function toolboxModule:CreatePattern(pattern, maximize)
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

---@param t table
---@param sep string
---@param first number
---@param last number
function toolboxModule:Combine(t, sep, first, last)
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

function toolboxModule:iSplit(inputstr, sep)
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

---@return string[]
function toolboxModule:Split(inputstr, sep)
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

local ResizeCursor ---@type BomGPIControl

---@param self BomGPIControl
local function SizingStop(self, button)
  self:GetParent():StopMovingOrSizing()

  if self.GPI_DoStop then
    self.GPI_DoStop(self:GetParent())
  end
end

---@param self BomGPIControl
local function SizingStart(self, button)
  self:GetParent():StartSizing(self.GPI_SIZETYPE)
  if self.GPI_DoStart then
    self.GPI_DoStart(self:GetParent())
  end
end

---@param self BomGPIControl
local function SizingEnter(self)
  if not (GetCursorInfo()) then
    ResizeCursor:Show()
    ResizeCursor.Texture:SetTexture(self.gpiCursor, nil, nil)
    ResizeCursor.Texture:SetRotation(math.rad(self.gpiRotation), 0.5, 0.5)
  end
end

---@param self BomGPIControl
local function SizingLeave(self, button)
  ResizeCursor:Hide()
end

local sizecount = 0

local function CreateSizeBorder(frame, name, a1, x1, y1, a2, x2, y2, cursor, rot, OnStart, OnStop)
  local FrameSizeBorder ---@type BomGPIControl
  sizecount = sizecount + 1
  FrameSizeBorder = CreateFrame("Frame", (frame:GetName() or TOCNAME .. sizecount) .. "_size_" .. name, frame)
  FrameSizeBorder:SetPoint("TOPLEFT", frame, a1, x1, y1)
  FrameSizeBorder:SetPoint("BOTTOMRIGHT", frame, a2, x2, y2)
  FrameSizeBorder.GPI_SIZETYPE = name
  FrameSizeBorder.gpiCursor = cursor
  FrameSizeBorder.gpiRotation = rot
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

function toolboxModule:EnableSize(frame, border, OnStart, OnStop)
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

-- TAB

---@param self BomGPIControl
local function bomSelectTab(self)
  if not self.gpiCombatLock or not InCombatLockdown() then
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

function toolboxModule:TabHide(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id]:Hide()
  elseif not id and frame.Tabs then
    for i = 1, frame.numTabs do
      frame.Tabs[i]:Hide()
    end
  end
end

function toolboxModule:TabShow(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id]:Show()
  elseif not id and frame.Tabs then
    for i = 1, frame.numTabs do
      frame.Tabs[i]:Show()
    end
  end
end

function toolboxModule:SelectTab(frame, id)
  if id and frame.Tabs and frame.Tabs[id] then
    bomSelectTab(frame.Tabs[id])
  end
end

function toolboxModule:TabOnSelect(frame, id, func)
  if id and frame.Tabs and frame.Tabs[id] then
    frame.Tabs[id].OnSelect = func
  end
end

function toolboxModule:GetSelectedTab(frame)
  if frame.Tabs then
    for i = 1, frame.numTabs do
      if frame.Tabs[i].content:IsShown() then
        return i
      end
    end
  end
  return 0
end

---@class BomGPIControlFrame: BomGPIControl
---@field numTabs number
---@field Tabs BomGPIControlTab[]
---@field GetName fun(self: BomGPIControlFrame): string

---@class BomGPIControlTab: BomGPIControl
---@field SetID fun(self: BomGPIControlTab, id: number): void
---@field content BomGPIControlTab

---Adds a Tab to a frame (main window for example)
---@param frame BomGPIControlFrame | string Where to add a tab; or a global name of a frame
---@param name string Tab text
---@param tabFrame BomGPIControlTab | string - tab text
---@param combatlockdown boolean - accessible in combat or not
function toolboxModule:AddTab(frame, name, tabFrame, combatlockdown)
  local frameName ---@type string

  if type(frame) == "string" then
    frameName = --[[---@type string]] frame
    frame = _G[frameName]
  else
    frameName = frame:GetName()
  end

  if type(tabFrame) == "string" then
    tabFrame = _G[tabFrame]
  end

  local frameControl = --[[---@type BomGPIControlFrame]] frame
  local tabFrameControl = --[[---@type BomGPIControlTab]] tabFrame

  frameControl.numTabs = frameControl.numTabs and frameControl.numTabs + 1 or 1

  if frameControl.Tabs == nil then
    frameControl.Tabs = {}
  end

  frameControl.Tabs[frameControl.numTabs] = CreateFrame(
          "Button", frameName .. "Tab" .. frameControl.numTabs, frame,
          "CharacterFrameTabButtonTemplate")
  frameControl.Tabs[frameControl.numTabs]:SetID(frameControl.numTabs)
  frameControl.Tabs[frameControl.numTabs]:SetText(name)
  frameControl.Tabs[frameControl.numTabs]:SetScript("OnClick", bomSelectTab)
  frameControl.Tabs[frameControl.numTabs].gpiCombatLock = combatlockdown
  frameControl.Tabs[frameControl.numTabs].content = tabFrameControl
  tabFrameControl:Hide()

  if frameControl.numTabs == 1 then
    frameControl.Tabs[frameControl.numTabs]:SetPoint(
            "TOPLEFT", frameControl, "BOTTOMLEFT",
            5, 4)
  else
    frameControl.Tabs[frameControl.numTabs]:SetPoint(
            "TOPLEFT", frameControl.Tabs[frameControl.numTabs - 1], "TOPRIGHT",
            -14, 0)
  end

  bomSelectTab(frameControl.Tabs[frameControl.numTabs])
  bomSelectTab(frameControl.Tabs[1])
  return frameControl.numTabs
end


-- DataBroker
local bomDataBroker = false
function toolboxModule:AddDataBroker(icon, onClick, onTooltipShow, text)
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

---- quick copy&past

local CopyPastFrame
local CopyPastSavedText
local CopyPastText

local function bom_create_copypaste()
  local frame

  if BOM.isTBC then
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

  toolboxModule:EnableSize(frame, nil, nil, nil)

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

function toolboxModule:CopyPast(Text)
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
---@param maybeLabel BomGPIControl|nil the existing label or nil
---@param parent BomGPIControl parent where the label is created
---@param positionFn function applies function after creating the label
---@return BomGPIControl
function toolboxModule:CreateSmalltextLabel(maybeLabel, parent, positionFn)
  if maybeLabel == nil then
    maybeLabel = --[[---@type BomGPIControl]] parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  end
  positionFn(maybeLabel)
  return --[[---@not nil]] maybeLabel
end

---Add onenter/onleave scripts to show the tooltip with translation by key
---This works when the tooltip is set too early before translations are loaded.
---@param control BomGPIControl
---@param translationKey string The key to translation
function toolboxModule:TooltipWithTranslationKey(control, translationKey)
  control:SetScript("OnEnter", function()
    GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
    GameTooltip:AddLine(_t(translationKey))
    GameTooltip:Show()
  end)
  control:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---Add onenter/onleave scripts to show the tooltip with translation by key
---@param control BomGPIControl
---@param text string The translated text
function toolboxModule:Tooltip(control, text)
  control:SetScript("OnEnter", function()
    GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
    GameTooltip:AddLine(text)
    GameTooltip:Show()
  end)
  control:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

---Add onenter/onleave scripts to show the tooltip with TEXT
---@param control BomControl
---@param text string - the localized text to display
function toolboxModule:TooltipText(control, text)
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
---@param control BomControl
---@param link string The string in format "spell:<id>" or "item:<id>"
function toolboxModule:TooltipLink(control, link)
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
function toolboxModule:Profile(text, fn)
  local t_start = debugprofilestop()
  local result = fn()
  local t_end = debugprofilestop()

  local duration = t_end - t_start
  --BOM.Dbg(text .. ": " .. tostring(duration))

  return result
end
