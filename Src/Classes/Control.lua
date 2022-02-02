local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomControlModule
local controlModule = BuffomatModule.DeclareModule("Control") ---@type BomControlModule

BOM.Class = BOM.Class or {}

---@class GPIMenuItem
---@field text string
---@field disabled boolean
---@field value any
---@field arg1 any
---@field arg2 any
---@field MenuDepth number

---@type GPIMenuItem
BOM.Class.GPIMenuItem = {}
BOM.Class.GPIMenuItem.__index = BOM.Class.GPIMenuItem


---@class GPIMinimapButtonConfigData
---@field position number|nil
---@field distance number|nil
---@field visible boolean|nil
---@field lock boolean|nil
---@field lockDistance boolean|nil

---@type GPIMinimapButtonConfigData
BOM.Class.GPIMinimapButtonConfigData = {}
BOM.Class.GPIMinimapButtonConfigData.__index = BOM.Class.GPIMinimapButtonConfigData


---@class GPIMinimapButton
---@field icon table
---@field isMouseDown boolean
---@field isDraggingButton boolean
---@field db GPIMinimapButtonConfigData Config database which will persist between addon reloads
---@field Tooltip string
---@field onClick function

---@type GPIMinimapButton
BOM.Class.GPIMinimapButton = {}
BOM.Class.GPIMinimapButton.__index = BOM.Class.GPIMinimapButton


---@class BomControl A blizzard UI frame but may contain private fields used by internal library by GPI
---@field _privat_DB table Stores value when button is clicked
---@field _privat_Var string Variable name in the _privat_DB
---@field _privat_Set any Value to be set/reset to nil when the button is clicked, use nil to toggle a boolean
---@field _privat_OnClick function
---@field _privat_state boolean
---@field _privat_disabled boolean
---@field _privat_Text string
---
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

---@type BomControl
BOM.Class.Control = {}
BOM.Class.Control.__index = BOM.Class.Control

local CLASS_TAG = "ui_control"
