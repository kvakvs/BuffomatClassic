local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomLegacyOptionsModule
local legacyOptionsModule = BuffomatModule.DeclareModule("Ui/LegacyOptions") ---@type BomLegacyOptionsModule

BOM.legacyOptions = BOM.legacyOptions or {}
local Options = BOM.legacyOptions

---@class BomLegacyUiOptions
---@field Btn table
---@field CBox table<string, BomControl> Checkboxes
---@field Color table
---@field CurrentPanel BomControl used when building the panel
---@field Edit table<string, BomControl> Controls
---@field Frames table<string, BomControl>
---@field Index table<number, string> Maps sequential control id to control names
---@field inLine boolean
---@field LineRelativ string|nil
---@field NextRelativ BomControl Used to anchor next control to it
---@field NextRelativX number Anchor offset X
---@field NextRelativY number Anchor offset Y
---@field oldNextRelativ BomControl Used to anchor next control to it
---@field oldNextRelativX number Anchor offset X
---@field oldNextRelativY number Anchor offset Y
---@field Panel table<string, BomControl>
---@field Prefix string the name prefix for controls: "BuffomatClassic_O_" .. <control name>
---@field RightSide BomControl
---@field scale number Options GUI scale
---@field Vars table<string, table<string, any>>

local function options_check_button_right_click(self, button)
  if button == "RightButton" then
    self:Lib_GPI_rclick()
  end
end

function Options.Init(doOk, doCancel, doDefault)
  Options.Prefix = TOCNAME .. "O_"
  Options._DoOk = doOk
  Options._DoCancel = doCancel
  Options._DoDefault = doDefault

  Options.Panel = {}
  Options.Frames = {}
  Options.CBox = {}
  Options.Color = {}
  Options.Btn = {}
  Options.Edit = {}
  Options.Vars = {}
  Options.Index = {}

  Options.Frames.count = 0

  Options.scale = 1
end

function Options.DoOk(dblimit)
  for name, cbox in pairs(Options.CBox) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit)
    then
      Options.Vars[name .. "_db"][Options.Vars[name]] = cbox:GetChecked()
    end
  end

  for name, color in pairs(Options.Color) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit)
    then
      Options.Vars[name .. "_db"][Options.Vars[name]].r = color.ColR
      Options.Vars[name .. "_db"][Options.Vars[name]].g = color.ColG
      Options.Vars[name .. "_db"][Options.Vars[name]].b = color.ColB
      Options.Vars[name .. "_db"][Options.Vars[name]].a = color.ColA
    end
  end

  for name, edit in pairs(Options.Edit) do
    if (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      if Options.Vars[name .. "_onlynumbers"] then
        Options.Vars[name .. "_db"][Options.Vars[name]] = edit:GetNumber()
      else
        if Options.Vars[name .. "_suggestion"] and Options.Vars[name .. "_suggestion"] ~= "" then
          if edit:GetText() == Options.Vars[name .. "_suggestion"] then
            Options.Vars[name .. "_db"][Options.Vars[name]] = ""
          else
            Options.Vars[name .. "_db"][Options.Vars[name]] = edit:GetText()
          end
        else
          Options.Vars[name .. "_db"][Options.Vars[name]] = edit:GetText()
        end
      end
    end
  end
end

function Options.DoCancel(dblimit)
  for name, cbox in pairs(Options.CBox) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      cbox:SetChecked(Options.Vars[name .. "_db"][Options.Vars[name]])
    end
  end

  for name, color in pairs(Options.Color) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      color:GetNormalTexture():SetVertexColor(
              Options.Vars[name .. "_db"][Options.Vars[name]].r,
              Options.Vars[name .. "_db"][Options.Vars[name]].g,
              Options.Vars[name .. "_db"][Options.Vars[name]].b,
              Options.Vars[name .. "_db"][Options.Vars[name]].a
      )
      color.ColR = Options.Vars[name .. "_db"][Options.Vars[name]].r
      color.ColG = Options.Vars[name .. "_db"][Options.Vars[name]].g
      color.ColB = Options.Vars[name .. "_db"][Options.Vars[name]].b
      color.ColA = Options.Vars[name .. "_db"][Options.Vars[name]].a
    end
  end

  for name, edit in pairs(Options.Edit) do
    if (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      if Options.Vars[name .. "_onlynumbers"] then
        edit:SetNumber(Options.Vars[name .. "_db"][Options.Vars[name]])
      else
        edit:SetText(Options.Vars[name .. "_db"][Options.Vars[name]])
        Options.__EditBoxLostFocus(edit)
      end
    end
  end
end

function Options.DoDefault(dblimit)
  for name, cbox in pairs(Options.CBox) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      Options.Vars[name .. "_db"][Options.Vars[name]] = Options.Vars[name .. "_init"]
    end
  end

  for name, color in pairs(Options.Color) do
    if Options.Vars[name .. "_db"] ~= nil
            and Options.Vars[name] ~= nil
            and (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      Options.Vars[name .. "_db"][Options.Vars[name]].r = Options.Vars[name .. "_init"].r
      Options.Vars[name .. "_db"][Options.Vars[name]].g = Options.Vars[name .. "_init"].g
      Options.Vars[name .. "_db"][Options.Vars[name]].b = Options.Vars[name .. "_init"].b
      Options.Vars[name .. "_db"][Options.Vars[name]].a = Options.Vars[name .. "_init"].a

    end
  end

  for name, edit in pairs(Options.Edit) do
    if (dblimit == nil or Options.Vars[name .. "_db"] == dblimit) then
      Options.Vars[name .. "_db"][Options.Vars[name]] = Options.Vars[name .. "_init"]
    end
  end
  Options:DoCancel()
end

function Options.SetScale(x)
  Options.scale = x
end

function Options.AddPanel(Title, noheader, scrollable)
  local c = #Options.Panel + 1
  local FrameName = Options.Prefix .. "OptionFrame" .. c

  Options.RightSide = FrameName .. "_Title"

  Options.Panel[c] = CreateFrame("Frame", FrameName, UIParent)
  Options.Panel[c].name = Title
  if c == 1 then
    Options.Panel[c].okay = Options._DoOk
    Options.Panel[c].cancel = Options._DoCancel
    Options.Panel[c].refresh = Options._DoCancel
    Options.Panel[c].default = Options._DoDefault
  else
    Options.Panel[c].parent = Options.Panel[1].name
  end

  InterfaceOptions_AddCategory(Options.Panel[c])
  Options.CurrentPanel = Options.Panel[c]

  if scrollable then

    Options.Panel["scroll" .. c] = CreateFrame(
            "ScrollFrame",
            FrameName .. "Scroll",
            Options.CurrentPanel,
            "UIPanelScrollFrameTemplate")
    Options.Panel["scroll" .. c]:SetPoint("TOPLEFT", 0, -10)
    Options.Panel["scroll" .. c]:SetPoint("BOTTOMRIGHT", -30, 10)
    Options.Panel["scrollChild" .. c] = CreateFrame("Frame", FrameName .. "ScrollChild")
    Options.Panel["scroll" .. c]:SetScrollChild(Options.Panel["scrollChild" .. c])

    Options.Panel["scrollChild" .. c]:SetSize(Options.CurrentPanel:GetWidth() - 1, 100)
    Options.CurrentPanel = Options.Panel["scrollChild" .. c]
  end

  Options.Frames["title_" .. c] = Options.CurrentPanel:CreateFontString(
          FrameName .. "_Title", "OVERLAY", "GameFontNormalLarge")
  if noheader == true then
    Options.Frames["title_" .. c]:SetHeight(1)
  else
    Options.Frames["title_" .. c]:SetText(Title)
  end
  Options.Frames["title_" .. c]:SetPoint("TOPLEFT", 10, -10)
  Options.Frames["title_" .. c]:SetScale(Options.scale)

  Options.NextRelativ = FrameName .. "_Title"
  Options.NextRelativX = 25
  Options.NextRelativY = 0

  return Options.CurrentPanel
end

function Options.Indent(width)
  if width == nil then
    width = 10
  end
  Options.NextRelativX = Options.NextRelativX + width
end

function Options.InLine()
  Options.inLine = true
  Options.LineRelativ = nil
end

function Options.EndInLine()
  Options.inLine = false
  Options.LineRelativ = nil
end

function Options.SetRightSide(w)
  if Options.oldNextRelativ == nil then
    Options.oldNextRelativ = Options.NextRelativ
    Options.oldNextRelativX = Options.NextRelativX
    Options.oldNextRelativY = Options.NextRelativY
  end

  Options.NextRelativ = Options.RightSide
  Options.NextRelativX = (w or 310) / Options.scale
  Options.NextRelativY = 0
end

function Options.AnchorRightSide()
  Options.RightSide = Options.NextRelativ
end

function Options.EndRightSide()
  Options.NextRelativ = Options.oldNextRelativ
  Options.NextRelativX = Options.oldNextRelativX
  Options.NextRelativY = Options.oldNextRelativY
  Options.oldNextRelativ = nil
end

function Options.AddVersion(version)
  local i = "version_" .. #Options.Panel
  Options.Frames[i] = Options.CurrentPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  Options.Frames[i]:SetText(version)
  Options.Frames[i]:SetPoint("BOTTOMRIGHT", -10, 10)
  Options.Frames[i]:SetFont("Fonts\\FRIZQT__.TTF", 12)
  return Options.Frames[i]
end

function Options.AddCategory(Text)
  local c = Options.Frames.count + 1
  Options.Frames.count = c
  local CatName = Options.Prefix .. "Cat" .. c
  local cat_frame = Options.CurrentPanel:CreateFontString(
          CatName, "OVERLAY", "GameFontNormal")
  Options.Frames[CatName] = cat_frame

  Options.Frames[CatName]:SetText('|cffffffff' .. Text .. '|r')
  Options.Frames[CatName]:SetPoint(
          "TOPLEFT", Options.NextRelativ, "BOTTOMLEFT",
          Options.NextRelativX, Options.NextRelativY - 10)
  Options.Frames[CatName]:SetFontObject("GameFontNormalLarge")
  Options.Frames[CatName]:SetScale(Options.scale)
  Options.NextRelativ = CatName
  Options.NextRelativX = 0
  Options.NextRelativY = 0
  return Options.Frames[CatName]
end

function Options.EditCategory(cat, Text)
  local c = Options.Frames.count + 1
  cat:SetText('|cffffffff' .. Text .. '|r')
end

function Options.AddButton(Text, func)
  local c = Options.Frames.count + 1
  Options.Frames.count = c
  local ButtonName = Options.Prefix .. "BUTTON_" .. c
  local button = CreateFrame("Button", ButtonName, Options.CurrentPanel, "UIPanelButtonTemplate")
  Options.Btn[ButtonName] = button
  button:ClearAllPoints()

  if Options.inLine ~= true or Options.LineRelativ == nil then
    button:SetPoint(
            "TOPLEFT", Options.NextRelativ, "BOTTOMLEFT",
            Options.NextRelativX, Options.NextRelativY)
    Options.NextRelativ = ButtonName
    Options.LineRelativ = ButtonName
    Options.NextRelativX = 0
    Options.NextRelativY = 0
  else
    button:SetPoint("TOP", Options.LineRelativ, "TOP", 0, 0)
    button:SetPoint("LEFT", Options.LineRelativ .. "Text", "RIGHT", 10, 0)
    Options.LineRelativ = ButtonName
  end

  button:SetScale(Options.scale)
  button:SetScript("OnClick", func)
  button:SetText(Text)
  button:SetWidth(button:GetTextWidth() + 20)
  return button
end

local function CheckBox_OnRightClick(self, func)
  self.Lib_GPI_rclick = func
  self:SetScript("OnMouseDown", options_check_button_right_click)
end

function Options.AddCheckBox(DB, Var, Init, Text, width)
  local c = Options.Frames.count + 1
  Options.Frames.count = c
  local ButtonName = Options.Prefix .. "CBOX_" .. c

  if Init == nil then
    Init = false
  end

  Options.Index[c] = ButtonName

  Options.Vars[ButtonName] = Var
  Options.Vars[ButtonName .. "_init"] = Init
  Options.Vars[ButtonName .. "_db"] = DB

  if DB ~= nil and Var ~= nil then
    if DB[Var] == nil then
      DB[Var] = Init
    end
  end

  Options.CBox[ButtonName] = CreateFrame(
          "CheckButton",
          ButtonName,
          Options.CurrentPanel,
          "ChatConfigCheckButtonTemplate")

  local button = _G[ButtonName .. "Text"]
  button:SetText(Text)

  if width then
    button:SetWidth(width)
    button:SetNonSpaceWrap(false)
    button:SetMaxLines(1)
    Options.CBox[ButtonName]:SetHitRectInsets(0, -width, 0, 0)
  else
    Options.CBox[ButtonName]:SetHitRectInsets(
            0, -button:GetStringWidth() - 2,
            0, 0)
  end

  Options.CBox[ButtonName]:ClearAllPoints()

  if Options.inLine ~= true or Options.LineRelativ == nil then
    Options.CBox[ButtonName]:SetPoint(
            "TOPLEFT", Options.NextRelativ, "BOTTOMLEFT",
            Options.NextRelativX, Options.NextRelativY)
    Options.NextRelativ = ButtonName
    Options.LineRelativ = ButtonName
    Options.NextRelativX = 0
    Options.NextRelativY = 0
  else
    Options.CBox[ButtonName]:SetPoint(
            "TOP", Options.LineRelativ, "TOP", 0, 0)
    Options.CBox[ButtonName]:SetPoint(
            "LEFT", Options.LineRelativ .. "Text", "RIGHT", 10, 0)
    Options.LineRelativ = ButtonName
  end

  Options.CBox[ButtonName]:SetScale(Options.scale)

  if DB ~= nil and Var ~= nil then
    Options.CBox[ButtonName]:SetChecked(DB[Var])
  else
    Options.CBox[ButtonName]:Hide()
  end

  Options.CBox[ButtonName].OnRightClick = BOM.DoCheckBox_OnRightClick

  return Options.CBox[ButtonName]
end

function Options.AddColorButton(DB, Var, Init, Text, width)
  local c = Options.Frames.count + 1

  local textFrame = Options.AddText(Text, width)
  textFrame:SetTextColor(1, 1, 1)
  local h = textFrame:GetHeight()

  Options.Frames.count = c
  local ButtonName = Options.Prefix .. "COLOR_" .. c

  if Init == nil then
    Init = { r = 1, g = 1, b = 1, a = 1 }
  end

  Options.Index[c] = ButtonName

  Options.Vars[ButtonName] = Var
  Options.Vars[ButtonName .. "_init"] = Init
  Options.Vars[ButtonName .. "_db"] = DB

  if DB ~= nil and Var ~= nil then
    if DB[Var] == nil then
      DB[Var] = {
        r = Init.r,
        g = Init.g,
        b = Init.b,
        a = Init.a
      }
    end
  end

  Options.Color[ButtonName] = CreateFrame("Button", ButtonName, Options.CurrentPanel)

  local but = Options.Color[ButtonName]

  but:SetWidth(h)
  but:SetHeight(h)
  but.ColTex = but:CreateTexture(ButtonName .. "Background", "BACKGROUND")
  but.ColTex:SetPoint("CENTER")
  but.ColTex:SetWidth(h - 2)
  but.ColTex:SetHeight(h - 2)
  but.ColTex:SetColorTexture(1, 1, 1, 1)
  but:SetScript("OnEnter",
          function(self)
            _G[self:GetName() .. "Background"]:SetVertexColor(1.0, 0.82, 0.0)
          end
  )
  but:SetScript("OnLeave",
          function(self)
            _G[self:GetName() .. "Background"]:SetVertexColor(1.0, 1.0, 1.0)
          end
  )
  but:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")

  but:ClearAllPoints()

  but:SetPoint("TOPLEFT", Options.NextRelativ, "TOPRIGHT", 5, 0)

  but:SetScale(Options.scale)

  but:GetNormalTexture():SetVertexColor(DB[Var].r, DB[Var].g, DB[Var].b, DB[Var].a)
  but.ColR, but.ColG, but.ColB, but.ColA = DB[Var].r, DB[Var].g, DB[Var].b, DB[Var].a

  local function colorpicker_callback(previousValues)
    local newR, newG, newB, newA

    if previousValues then
      newR, newG, newB, newA = unpack(previousValues)
    else
      newA, newR, newG, newB = 1.0 - OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
    end
    but:GetNormalTexture():SetVertexColor(newR, newG, newB, newA)
    but.ColR, but.ColG, but.ColB, but.ColA = newR, newG, newB, newA
  end

  local function colorpicker_onclick(self)
    local r, g, b, a = but.ColR, but.ColG, but.ColB, but.ColA
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = true, 1.0 - a
    ColorPickerFrame.previousValues = { r, g, b, a }

    ColorPickerFrame.func = colorpicker_callback
    ColorPickerFrame.opacityFunc = colorpicker_callback
    ColorPickerFrame.cancelFunc = colorpicker_callback

    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
  end

  but:SetScript("OnClick", colorpicker_onclick)
  return but
end

function Options.EditCheckBox(toEdit, DB, Var, Init, Text, width)
  local ButtonName = toEdit:GetName()

  if Init == nil then
    Init = false
  end
  Options.Vars[ButtonName] = Var
  Options.Vars[ButtonName .. "_init"] = Init
  Options.Vars[ButtonName .. "_db"] = DB

  if DB ~= nil and Var ~= nil then
    if DB[Var] == nil then
      DB[Var] = Init
    end
  end

  local button = _G[ButtonName .. "Text"]
  button:SetText(Text)

  if width then
    button:SetWidth(width)
    button:SetNonSpaceWrap(false)
    button:SetMaxLines(1)
    Options.CBox[ButtonName]:SetHitRectInsets(0, -width, 0, 0)
  else
    Options.CBox[ButtonName]:SetHitRectInsets(0, -button:GetStringWidth() - 2, 0, 0)
  end

  if DB ~= nil and Var ~= nil then
    Options.CBox[ButtonName]:SetChecked(DB[Var])
    Options.CBox[ButtonName]:Show()
  else
    Options.CBox[ButtonName]:Hide()
  end
end

---AddText
---@param TXT string
---@param width number | nil
---@param centre boolean
function Options.AddText(TXT, width, centre)
  local textbox

  textbox = Options.CurrentPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  textbox:SetText(TXT)
  textbox:SetPoint("TOPLEFT", Options.NextRelativ, "BOTTOMLEFT", Options.NextRelativX, Options.NextRelativY - 2)
  textbox:SetScale(Options.scale)

  if width == nil or width == 0 then
    textbox:SetWidth(textbox:GetStringWidth())

  elseif width < 0 then
    if string.sub(Options.CurrentPanel:GetName(), -11) == "ScrollChild" then
      textbox:SetPoint("RIGHT", Options.CurrentPanel:GetParent():GetParent(), "RIGHT", width, 0)
    else
      textbox:SetPoint("RIGHT", width, 0)
    end
    if not centre then
      textbox:SetJustifyH("LEFT")
      textbox:SetJustifyV("TOP")
    end

  else
    textbox:SetWidth(width)
    if not centre then
      textbox:SetJustifyH("LEFT")
      textbox:SetJustifyV("TOP")
    end
  end

  Options.NextRelativ = textbox
  Options.NextRelativX = 0
  Options.NextRelativY = 0
  return textbox
end

function Options.EditText(textbox, TXT, width, centre)
  textbox:SetText(TXT)

  if width == nil or width == 0 then
    textbox:SetWidth(textbox:GetStringWidth())
  elseif width < 0 then
    textbox:SetPoint("RIGHT", width, 0)
    if not centre then
      textbox:SetJustifyH("LEFT")
      textbox:SetJustifyV("TOP")
    end
  else
    textbox:SetWidth(width)
    if not centre then
      textbox:SetJustifyH("LEFT")
      textbox:SetJustifyV("TOP")
    end
  end

end

function Options.__EditBoxTooltipShow(self)
  local name = self:GetName() .. "_tooltip"
  if self.GPI_Options and self.GPI_Options.Vars and self.GPI_Options.Vars[name] then
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
    GameTooltip:SetMinimumWidth(self:GetWidth())
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.GPI_Options.Vars[name], 0.9, 0.9, 0.9, true)
    GameTooltip:Show()
  end
end

function Options.__EditBoxTooltipHide(self)
  GameTooltip:Hide()
end

function Options.__EditBoxGetFocus(self)
  local name = self:GetName() .. "_suggestion"
  if self.GPI_Options and self.GPI_Options.Vars and self.GPI_Options.Vars[name] then
    if self:GetText() == self.GPI_Options.Vars[name] then
      self:SetText("")
      self:SetTextColor(1, 1, 1)
    end
  end
end

function Options.__EditBoxLostFocus(self)
  local name = self:GetName() .. "_suggestion"
  if self.GPI_Options and self.GPI_Options.Vars and self.GPI_Options.Vars[name] then
    if self:GetText() == "" then
      self:SetTextColor(0.6, 0.6, 0.6)
      self:SetText(self.GPI_Options.Vars[name])
      self:HighlightText(0, 0)
      self:SetCursorPosition(0)
    end
  end
end

function Options.__EditBoxOnEnterPressed(self)
  self:ClearFocus()
end

---AddEditBox
---@param DB table - some storage table where the values go
---@param Var string - name for control to create
---@param Init table - some initial value?
---@param TXTLeft string - some colored text (left side)
---@param width number | nil - width
---@param widthLeft number | nil - category frame width?
---@param onlynumbers boolean - numeric value only allowed
---@param tooltip string
---@param suggestion table
---@return BomControl
function Options.AddEditBox(DB, Var, Init, TXTLeft, width, widthLeft, onlynumbers,
                            tooltip, suggestion)
  if width == nil then
    width = 200
  end
  local c = Options.Frames.count + 1
  Options.Frames.count = c

  local ButtonName = Options.Prefix .. "Edit_" .. c .. Var
  local CatName = ButtonName .. "_Text"

  local cat_frame = Options.CurrentPanel:CreateFontString(
          CatName, "OVERLAY", "GameFontNormal")
  Options.Frames[CatName] = cat_frame

  cat_frame:SetText('|cffffffff' .. TXTLeft .. '|r')
  cat_frame:SetPoint("TOPLEFT", Options.NextRelativ, "BOTTOMLEFT",
          Options.NextRelativX, Options.NextRelativY - 2)
  cat_frame:SetScale(Options.scale)

  if widthLeft == nil or widthLeft == 0 then
    cat_frame:SetWidth(cat_frame:GetStringWidth())
  else
    cat_frame:SetWidth(widthLeft)
    cat_frame:SetJustifyH("LEFT")
    cat_frame:SetJustifyV("TOP")
  end

  Options.Vars[ButtonName] = Var
  Options.Vars[ButtonName .. "_db"] = DB
  Options.Vars[ButtonName .. "_init"] = Init
  Options.Vars[ButtonName .. "_onlynumbers"] = onlynumbers

  if DB[Var] == nil then
    DB[Var] = Init
  end

  local button = CreateFrame(
          "EditBox", ButtonName, Options.CurrentPanel, "InputBoxTemplate")
  Options.Edit[ButtonName] = button

  button:SetPoint("TOPLEFT", cat_frame, "TOPRIGHT", 5, 2)
  button:SetScale(Options.scale)
  button:SetWidth(width)
  button:SetHeight(20)

  button:SetScript("OnEnterPressed", Options.__EditBoxOnEnterPressed)

  button.GPI_Options = Options

  if onlynumbers then
    button:SetNumeric(true)
    button:SetNumber(DB[Var])
  else
    button:SetText(DB[Var])
  end

  button:SetCursorPosition(0)
  button:HighlightText(0, 0)
  button:SetAutoFocus(false)
  button:ClearFocus()
  if tooltip and tooltip ~= "" then
    button:SetScript("OnEnter", Options.__EditBoxTooltipShow)
    button:SetScript("onLeave", Options.__EditBoxTooltipHide)
    Options.Vars[ButtonName .. "_tooltip"] = tooltip
  end

  if suggestion and suggestion ~= "" then
    button:SetScript("OnEditFocusGained", Options.__EditBoxGetFocus)
    button:SetScript("OnEditFocusLost", Options.__EditBoxLostFocus)
    Options.Vars[ButtonName .. "_suggestion"] = suggestion
  end

  cat_frame:SetHeight(button:GetHeight() - 10)

  Options.NextRelativ = CatName
  Options.NextRelativX = 0
  Options.NextRelativY = -10

  return button
end

function Options.AddSpace(factor)
  Options.NextRelativY = Options.NextRelativY - 20 * (factor or 1)
end

function Options.Open(panel)
  if panel == nil or panel > #Options.Panel then
    panel = 1
  end
  InterfaceOptionsFrame_OpenToCategory(Options.Panel[#Options.Panel])
  InterfaceOptionsFrame_OpenToCategory(Options.Panel[#Options.Panel])
  InterfaceOptionsFrame_OpenToCategory(Options.Panel[panel])
end

