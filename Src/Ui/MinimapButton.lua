local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomUiMinimapButtonModule
local uiMinimapButtonModule = BomModuleManager.uiMinimapButtonModule ---@type BomUiMinimapButtonModule

---@shape BomMinimapButtonPlaceholder
---@field icon WowTexture
---@field isMouseDown boolean
---@field isDraggingButton boolean
---@field db GPIMinimapButtonConfigData Config database which will persist between addon reloads
---@field tooltip string
---@field isMinimapButton boolean
---@field button BomGPIControl
---@field OnClick function
---@field SetTexture fun(texturePath: string)
local minimapButtonClass = {}
minimapButtonClass.__index = minimapButtonClass

BOM.minimapButton = BOM.minimapButton or minimapButtonClass

---Change minimap button texture position slightly
---@param button BomGPIControl
local function minimap_button_texture_zoom(button)
  local deltaX, deltaY = 0, 0

  if not button.gpiMinimapButton.isMouseDown then
    deltaX = 0.05
    deltaY = 0.05
  end

  button.gpiMinimapButton.icon:SetTexCoord(deltaX, 1 - deltaX, deltaY, 1 - deltaY)
end

---Called when minimap button is dragged to update.
---@param button BomGPIControl
local function minimap_button_drag_update(button)
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local w = ((Minimap:GetWidth() / 2) + 5)
  local scale = Minimap:GetEffectiveScale()
  px, py = px / scale, py / scale
  local dx, dy = px - mx, py - my
  local dist = math.sqrt(dx * dx + dy * dy) / w

  if button.gpiMinimapButton.db.lockDistance then
    dist = 1
  else
    if dist < 1 then
      dist = 1
    elseif dist > 2 then
      dist = 2
    end
  end

  button.gpiMinimapButton.db.distance = dist
  button.gpiMinimapButton.db.position = math.deg(math.atan2(dy, dx)) % 360
  button.gpiMinimapButton:UpdatePosition()
end

local function minimap_button_drag_start(button)
  button.gpiMinimapButton.isMouseDown = true
  if button.gpiMinimapButton.db.lock == false then
    button:LockHighlight()
    minimap_button_texture_zoom(button)
    button:SetScript("OnUpdate", minimap_button_drag_update)
    button.gpiMinimapButton.isDraggingButton = true
  end
  GameTooltip:Hide()
end

local function minimap_button_drag_stop(button)
  button:SetScript("OnUpdate", nil)
  button.gpiMinimapButton.isMouseDown = false
  minimap_button_texture_zoom(button)
  button:UnlockHighlight()
  button.gpiMinimapButton.isDraggingButton = false
end

local function minimap_button_mouse_enter(button)
  if button.gpiMinimapButton.isDraggingButton
          or not button.gpiMinimapButton.Tooltip then
    return
  end

  GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", 0, 0)
  GameTooltip:AddLine(button.gpiMinimapButton.Tooltip)
  GameTooltip:Show()
end

local function minimap_button_mouse_leave(button)
  GameTooltip:Hide()
end

local function minimap_button_click(button, b)
  GameTooltip:Hide()

  if button.gpiMinimapButton.onClick then
    button.gpiMinimapButton.onClick(button.gpiMinimapButton, b)
  end
end

local function minimap_button_mouse_down(button)
  button.gpiMinimapButton.isMouseDown = true
  minimap_button_texture_zoom(button)
end

local function minimap_button_mouse_up(button)
  button.gpiMinimapButton.isMouseDown = false
  minimap_button_texture_zoom(button)
end

function minimapButtonClass:Init(Database, Texture, DoOnClick, Tooltip)
  self.db = Database
  self.OnClick = DoOnClick
  self.tooltip = Tooltip
  self.isMinimapButton = true

  local button = CreateFrame("Button", "Lib_GPI_Minimap_" .. TOCNAME, Minimap)

  self.button = button
  button.gpiMinimapButton = self

  button:SetFrameStrata("MEDIUM")
  button:SetSize(31, 31)
  button:SetFrameLevel(8)
  button:RegisterForClicks("anyUp")
  button:RegisterForDrag("LeftButton")
  button:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
  local overlay = button:CreateTexture(nil, "OVERLAY")
  overlay:SetSize(53, 53)
  overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
  overlay:SetPoint("TOPLEFT")
  local background = button:CreateTexture(nil, "BACKGROUND")
  background:SetSize(20, 20)
  background:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
  background:SetPoint("TOPLEFT", 7, -5)
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetSize(17, 17)
  icon:SetTexture(Texture)
  icon:SetPoint("TOPLEFT", 7, -6)

  self.icon = icon
  self.isMouseDown = false
  self.isDraggingButton = false

  button:SetScript("OnEnter", minimap_button_mouse_enter)
  button:SetScript("OnLeave", minimap_button_mouse_leave)

  button:SetScript("OnClick", minimap_button_click)

  button:SetScript("OnDragStart", minimap_button_drag_start)
  button:SetScript("OnDragStop", minimap_button_drag_stop)

  button:SetScript("OnMouseDown", minimap_button_mouse_down)
  button:SetScript("OnMouseUp", minimap_button_mouse_up)

  if self.db.position == nil then
    self.db.position = 225
  end
  if self.db.distance == nil then
    self.db.distance = 1
  end
  if self.db.visible == nil then
    self.db.visible = true
  end
  if self.db.lock == nil then
    self.db.lock = false
  end
  if self.db.lockDistance == nil then
    self.db.lockDistance = false
  end

  minimap_button_texture_zoom(button)
  self:UpdatePosition()
end

local MinimapShapes = --[[---@type {[string]: boolean[]}]] {
  -- quadrant booleans (same order as SetTexCoord)
  -- {upper-left, lower-left, upper-right, lower-right}
  -- true = rounded, false = squared
  ["ROUND"]                 = { true, true, true, true },
  ["SQUARE"]                = { false, false, false, false },
  ["CORNER-TOPLEFT"]        = { true, false, false, false },
  ["CORNER-TOPRIGHT"]       = { false, false, true, false },
  ["CORNER-BOTTOMLEFT"]     = { false, true, false, false },
  ["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
  ["SIDE-LEFT"]             = { true, true, false, false },
  ["SIDE-RIGHT"]            = { false, false, true, true },
  ["SIDE-TOP"]              = { true, false, true, false },
  ["SIDE-BOTTOM"]           = { false, true, false, true },
  ["TRICORNER-TOPLEFT"]     = { true, true, true, false },
  ["TRICORNER-TOPRIGHT"]    = { true, false, true, true },
  ["TRICORNER-BOTTOMLEFT"]  = { true, true, false, true },
  ["TRICORNER-BOTTOMRIGHT"] = { false, true, true, true },
}

function minimapButtonClass:UpdatePosition()
  local w = ((Minimap:GetWidth() / 2) + 10) * self.db.distance
  local h = ((Minimap:GetHeight() / 2) + 10) * self.db.distance
  --local r=math.rad(MinimapButton.db.position)
  --MinimapButton.button:SetPoint("CENTER", Minimap, "CENTER", w * math.cos(r), h * math.sin(r))
  local rounding = 10
  local angle = math.rad(self.db.position or 0) -- determine position on your own
  local y = math.sin(angle)
  local x = math.cos(angle)
  local q = 1;

  if x < 0 then
    q = q + 1;        -- lower
  end

  if y > 0 then
    q = q + 2;        -- right
  end

  local minimapShape = --[[---@type string]] (GetMinimapShape and GetMinimapShape() or "ROUND")
  local quadTable = MinimapShapes[minimapShape];

  if quadTable[q] then
    x = x * w;
    y = y * h;
  else
    local diagRadius = math.sqrt(2 * (w) ^ 2) - rounding
    x = math.max(-w, math.min(x * diagRadius, w))

    diagRadius = math.sqrt(2 * (h) ^ 2) - rounding
    y = math.max(-h, math.min(y * diagRadius, h))
  end

  self.button:SetPoint("CENTER", Minimap, "CENTER", x, y)

  if self.db.visible then
    self:Show()
  else
    self:Hide()
  end
end

function minimapButtonClass:Show()
  self.db.visible = true
  self.button:SetParent(Minimap)
  self.button:Show()
end

function minimapButtonClass:Hide()
  self.db.visible = false
  self.button:Hide()
  self.button:SetParent(nil)
end

---@param Texture string
function minimapButtonClass:SetTexture(Texture)
  self.icon:SetTexture(Texture, nil, nil)
  self.icon:SetPoint("TOPLEFT", 7, -6)
  self.icon:SetSize(17, 17)
end

function minimapButtonClass:SetTooltip(Text)
  self.tooltip = Text
end
