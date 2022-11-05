local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomControlModule
local controlModule = {}
BomModuleManager.controlModule = controlModule

---@class GPIMenuItem
---@field text string
---@field disabled boolean
---@field value any
---@field arg1 any
---@field arg2 any
---@field MenuDepth number
controlModule.GPIMenuItem = {}
controlModule.GPIMenuItem.__index = controlModule.GPIMenuItem


---@class GPIMinimapButtonConfigData
---@field position number|nil
---@field distance number|nil
---@field visible boolean|nil
---@field lock boolean|nil
---@field lockDistance boolean|nil
controlModule.GPIMinimapButtonConfigData = {}
controlModule.GPIMinimapButtonConfigData.__index = controlModule.GPIMinimapButtonConfigData


---@class GPIMinimapButton
---@field icon table
---@field isMouseDown boolean
---@field isDraggingButton boolean
---@field db GPIMinimapButtonConfigData Config database which will persist between addon reloads
---@field Tooltip string
---@field Init function
---@field onClick function
---@field UpdatePosition function
---@field SetTexture fun(texturePath: string)
controlModule.GPIMinimapButton = {
  --UpdatePosition = minimapButtonClass:UpdatePosition ???
}
controlModule.GPIMinimapButton.__index = controlModule.GPIMinimapButton


---@class BomControl A blizzard UI frame but may contain private fields used by internal library by Buffomat
---@field bomToolTipLink string Mouseover will show the link
---@field bomToolTipText string Mouseover will show the text
---@field bomReadVariable function Returns value which the button can modify, boolean for toggle buttons
---@field SetPoint fun(self: BomControl, point: string, relativeTo: BomControl, relativePoint: string, xOfs: number, yOfs: number)
---@field Hide fun(self: BomControl)
---@field ClearAllPoints fun(self: BomControl)
---@field SetParent fun(self: BomControl, parent: BomControl|nil)
---@field SetScript fun(self: BomControl, script: string, handler: function)
---@field Hide fun(self: BomControl)
---@field Show fun(self: BomControl)
---@field SetTextures fun(self: BomControl, sel: string|nil, unsel: string|nil, dis: string|nil, selCoord: number[]|nil, unselCoord: number[]|nil, disCoord: number[]|nil)
---@field SetText fun(self: BomControl, text: string)
---@field SetWidth fun(self: BomControl, width: number)
---@field SetHeight fun(self: BomControl, height: number)

---@class BomGPIControl: BomControl A blizzard UI frame but may contain private fields used by internal library by GPI
---@field _privat_DB table Stores value when button is clicked
---@field _privat_Var string Variable name in the _privat_DB
---@field _privat_Set any Value to be set/reset to nil when the button is clicked, use nil to toggle a boolean
---@field _privat_OnClick function
---@field _privat_state boolean
---@field _privat_disabled boolean
---@field _privat_Text string
---@field _privat_ToolTipLink string Mouseover will show the link
---@field _privat_ToolTipText string Mouseover will show the text
---@field _GPIPRIVAT_events table<string, function> Events
---@field _GPIPRIVAT_updates table<function> private field
---@field _GPIPRIVAT_MovingStopCallback any private field
---@field _GPIPRIVAT_TableCallback function
---@field _GPIPRIVAT_Items table<GPIMenuItem> Popup item list?
---@field _GPIPRIVAT_MovingStopCallback function
---@field GPI_Cursor any
---@field GPI_Rotation number Rotation in degrees
---@field GPI_DoStart boolean
---@field GPI_DoStop boolean
---@field GPI_SIZETYPE string
---@field Lib_GPI_MinimapButton GPIMinimapButton Stores extra values for minimap button control
---@field SetSpell fun(self: BomGPIControl, spell: BomSpellId)
---@field SetOnClick fun(self: BomGPIControl, func: function)
controlModule.Control = {}
controlModule.Control.__index = controlModule.Control

local CLASS_TAG = "ui_control"
