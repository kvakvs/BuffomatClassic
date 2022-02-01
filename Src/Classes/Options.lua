local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

BOM.Class = BOM.Class or {}

---@class Options
---@field Btn table
---@field CBox table<string, Control> Checkboxes
---@field Color table
---@field CurrentPanel Control used when building the panel
---@field Edit table<string, Control> Controls
---@field Frames table<string, Control>
---@field Index table<number, string> Maps sequential control id to control names
---@field inLine boolean
---@field LineRelativ string|nil
---@field NextRelativ Control Used to anchor next control to it
---@field NextRelativX number Anchor offset X
---@field NextRelativY number Anchor offset Y
---@field oldNextRelativ Control Used to anchor next control to it
---@field oldNextRelativX number Anchor offset X
---@field oldNextRelativY number Anchor offset Y
---@field Panel table<string, Control>
---@field Prefix string the name prefix for controls: "BuffomatClassic_O_" .. <control name>
---@field RightSide Control
---@field scale number Options GUI scale
---@field Vars table<string, table<string, any>>

---@type Options
BOM.Class.Options = {}
BOM.Class.Options.__index = BOM.Class.Options

local CLASS_TAG = "options"
