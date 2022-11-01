local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomUiMinimapButtonModule
local uiMinimapButtonModule = {}
BomModuleManager.uiMinimapButtonModule = uiMinimapButtonModule

---@class BomMinimapButton
BOM.MinimapButton = BOM.MinimapButton or {} ---@type BomMinimapButton
local minimapButtonClass = BOM.MinimapButton

---Change minimap button texture position slightly
---@param button BomLegacyControl
local function minimap_button_texture_zoom(button)
  local deltaX, deltaY = 0, 0

  if not button.Lib_GPI_MinimapButton.isMouseDown then
    deltaX = 0.05
    deltaY = 0.05
  end

  button.Lib_GPI_MinimapButton.icon:SetTexCoord(deltaX, 1 - deltaX, deltaY, 1 - deltaY)
end

---Called when minimap button is dragged to update.
---@param button BomLegacyControl
local function minimap_button_drag_update(button)
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local w = ((Minimap:GetWidth() / 2) + 5)
  local scale = Minimap:GetEffectiveScale()
  px, py = px / scale, py / scale
  local dx, dy = px - mx, py - my
  local dist = math.sqrt(dx * dx + dy * dy) / w

  if button.Lib_GPI_MinimapButton.db.lockDistance then
    dist = 1
  else
    if dist < 1 then
      dist = 1
    elseif dist > 2 then
      dist = 2
    end
  end

  button.Lib_GPI_MinimapButton.db.distance = dist
  button.Lib_GPI_MinimapButton.db.position = math.deg(math.atan2(dy, dx)) % 360
  button.Lib_GPI_MinimapButton.UpdatePosition()
end

local function minimap_button_drag_start(button)
  button.Lib_GPI_MinimapButton.isMouseDown = true
  if button.Lib_GPI_MinimapButton.db.lock == false then
    button:LockHighlight()
    minimap_button_texture_zoom(button)
    button:SetScript("OnUpdate", minimap_button_drag_update)
    button.Lib_GPI_MinimapButton.isDraggingButton = true
  end
  GameTooltip:Hide()
end

local function minimap_button_drag_stop(button)
  button:SetScript("OnUpdate", nil)
  button.Lib_GPI_MinimapButton.isMouseDown = false
  minimap_button_texture_zoom(button)
  button:UnlockHighlight()
  button.Lib_GPI_MinimapButton.isDraggingButton = false
end

local function minimap_button_mouse_enter(button)
  if button.Lib_GPI_MinimapButton.isDraggingButton
          or not button.Lib_GPI_MinimapButton.Tooltip then
    return
  end

  GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", 0, 0)
  GameTooltip:AddLine(button.Lib_GPI_MinimapButton.Tooltip)
  GameTooltip:Show()
end

local function minimap_button_mouse_leave(button)
  GameTooltip:Hide()
end

local function minimap_button_click(button, b)
  GameTooltip:Hide()

  if button.Lib_GPI_MinimapButton.onClick then
    button.Lib_GPI_MinimapButton.onClick(button.Lib_GPI_MinimapButton, b)
  end
end

local function minimap_button_mouse_down(button)
  button.Lib_GPI_MinimapButton.isMouseDown = true
  minimap_button_texture_zoom(button)
end

local function minimap_button_mouse_up(button)
  button.Lib_GPI_MinimapButton.isMouseDown = false
  minimap_button_texture_zoom(button)
end

function minimapButtonClass.Init(Database, Texture, DoOnClick, Tooltip)
  minimapButtonClass.db = Database
  minimapButtonClass.onClick = DoOnClick
  minimapButtonClass.Tooltip = Tooltip
  minimapButtonClass.isMinimapButton = true

  local button = CreateFrame("Button", "Lib_GPI_Minimap_" .. TOCNAME, Minimap)

  minimapButtonClass.button = button
  button.Lib_GPI_MinimapButton = minimapButtonClass

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

  minimapButtonClass.icon = icon
  minimapButtonClass.isMouseDown = false
  minimapButtonClass.isDraggingButton = false

  button:SetScript("OnEnter", minimap_button_mouse_enter)
  button:SetScript("OnLeave", minimap_button_mouse_leave)

  button:SetScript("OnClick", minimap_button_click)

  button:SetScript("OnDragStart", minimap_button_drag_start)
  button:SetScript("OnDragStop", minimap_button_drag_stop)

  button:SetScript("OnMouseDown", minimap_button_mouse_down)
  button:SetScript("OnMouseUp", minimap_button_mouse_up)

  if minimapButtonClass.db.position == nil then
    minimapButtonClass.db.position = 225
  end
  if minimapButtonClass.db.distance == nil then
    minimapButtonClass.db.distance = 1
  end
  if minimapButtonClass.db.visible == nil then
    minimapButtonClass.db.visible = true
  end
  if minimapButtonClass.db.lock == nil then
    minimapButtonClass.db.lock = false
  end
  if minimapButtonClass.db.lockDistance == nil then
    minimapButtonClass.db.lockDistance = false
  end

  minimap_button_texture_zoom(button)
  minimapButtonClass.UpdatePosition()
end

local MinimapShapes = {
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

function minimapButtonClass.UpdatePosition()
  local w = ((Minimap:GetWidth() / 2) + 10) * minimapButtonClass.db.distance
  local h = ((Minimap:GetHeight() / 2) + 10) * minimapButtonClass.db.distance
  --local r=math.rad(MinimapButton.db.position)
  --MinimapButton.button:SetPoint("CENTER", Minimap, "CENTER", w * math.cos(r), h * math.sin(r))
  local rounding = 10
  local angle = math.rad(minimapButtonClass.db.position) -- determine position on your own
  local y = math.sin(angle)
  local x = math.cos(angle)
  local q = 1;

  if x < 0 then
    q = q + 1;        -- lower
  end

  if y > 0 then
    q = q + 2;        -- right
  end

  local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
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

  minimapButtonClass.button:SetPoint("CENTER", Minimap, "CENTER", x, y)

  if minimapButtonClass.db.visible then
    minimapButtonClass.Show()
  else
    minimapButtonClass.Hide()
  end
end

function minimapButtonClass.Show()
  minimapButtonClass.db.visible = true
  minimapButtonClass.button:SetParent(Minimap)
  minimapButtonClass.button:Show()
end

function minimapButtonClass.Hide()
  minimapButtonClass.db.visible = false
  minimapButtonClass.button:Hide()
  minimapButtonClass.button:SetParent(nil)
end

function minimapButtonClass.SetTexture(Texture)
  minimapButtonClass.icon:SetTexture(Texture)
  minimapButtonClass.icon:SetPoint("TOPLEFT", 7, -6)
  minimapButtonClass.icon:SetSize(17, 17)
end

function minimapButtonClass.SetTooltip(Text)
  minimapButtonClass.Tooltip = Text
end
