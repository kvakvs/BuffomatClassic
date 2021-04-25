---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Control
BOM.Class.Control = {}
BOM.Class.Control.__index = BOM.Class.Control

local CLASS_TAG = "ui_control"
