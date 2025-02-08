---@alias WowTexCoord number[]

---@class WowTexture
---@field GetTexCoord fun(self: WowTexture): WowTexCoord
---@field GetTexture fun(self: WowTexture): string
---@field SetAllPoints function
---@field SetBlendMode fun(self: WowTexture, blendMode: string)
---@field SetColorTexture fun(self: WowTexture, r: number, g: number, b: number, a: number)
---@field SetDesaturated fun(self: WowTexture, desaturated: boolean)
---@field SetRotation fun(self: WowTexture, rotation: number, point: number[])|fun(self: WowTexture, rotation: number)
---@field SetTexCoord fun(self: WowTexture, coord: WowTexCoord)
---@field SetTexture fun(self: WowTexture, texturePath: string|nil, a: nil, filterQuality: nil)
---@field SetPoint fun(self: WowTexture, point: string, x: number, y: number)
---@field SetSize fun(self: WowTexture, width: number, height: number)
---@field SetVertexColor fun(self: WowTexture, r: number, g: number, b: number, a: number)

---@class WowControl A blizzard UI frame but may contain private fields used by internal library by Buffomat
---@field bomReadVariable function Returns value which the button can modify, boolean for toggle buttons
---@field bomToolTipLink string Mouseover will show the link
---@field bomToolTipText string Mouseover will show the text
---@field ClearAllPoints fun(self: WowControl)
---@field CreateFontString fun(self: WowControl, name: string|nil, layer: string|nil, inherits: string|nil): WowFontString
---@field CreateTexture fun(self: WowControl): WowTexture
---@field Disable fun(self: WowControl)
---@field Enable fun(self: WowControl)
---@field EnableMouse fun(self: WowControl, enable: boolean)
---@field SetUserPlaced fun(self: WowControl, enable: boolean)
---@field GetHeight fun(self: WowControl): number
---@field GetLeft fun(self: WowControl): number
---@field GetParent fun(self: WowControl): WowControl
---@field GetTop fun(self: WowControl): number
---@field GetWidth fun(self: WowControl): number
---@field Hide fun(self: WowControl)
---@field IsEnabled fun(self: WowControl): boolean
---@field IsVisible fun(self: WowControl): boolean
---@field RegisterForDrag fun(self: WowControl, button: string)
---@field SetAlpha fun(self: WowControl, a: number)
---@field SetAttribute function
---@field SetFrameStrata fun(self: WowControl, strata: string)
---@field SetHeight fun(self: WowControl, height: number)
---@field SetMinResize function
---@field SetOwner fun(self: WowControl, owner: WowControl, anchor: string)
---@field SetParent fun(self: WowControl, parent: WowControl|nil)
---@field SetPoint function # fun(self: WowControl, point: string, relativeTo: WowControl|nil, relativePoint: string, xOfs: number, yOfs: number)|fun(self: WowControl, point: string, x: number, y: number)
---@field SetScale function
---@field SetSize function(self: WowControl, width: number, height: number)
---@field SetMovable function
---@field SetScript fun(self: WowControl, script: string, handler: function)
---@field SetState fun(self: WowControl, state: any) GPI control handler but is here for simpler code where controls are mixed in same container
---@field SetText fun(self: WowControl, text: string)
---@field SetTextures fun(self: WowControl, sel: string|nil, unsel: string|nil, dis: string|nil, selCoord: number[]|nil, unselCoord: number[]|nil, disCoord: number[]|nil)
---@field SetWidth fun(self: WowControl, width: number)
---@field Show fun(self: WowControl)
---@field StartSizing fun(self: WowControl, sizingType: string)
---@field StartMoving fun(self: WowControl)
---@field StopMovingOrSizing fun(self: WowControl)

---@class WowFontString: WowControl
---@field SetFontObject function

---@class WowUIErrorsFrame: WowControl
---@field Clear function

---@class WowChatFrame: WowControl
---@field editBox WowControl
---@field AddMessage function
---@field Clear function
---@field SetFading function
---@field SetFontObject function
---@field SetJustifyH function
---@field SetHyperlinksEnabled function
---@field SetMaxLines function

---@class WowInputBox: WowControl
---@field SetAutoFocus function
---@field SetTextColor function
---@field ClearFocus function

---@class WowGameTooltip: WowControl
---@field AddLine fun(self: WowGameTooltip, m: string)
---@field SetHyperlink fun(self: WowGameTooltip, m: string)

---@param s string
---@param msg string
---@param lang string|nil
---@param name string
function SendChatMessage(s, msg, lang, name)
end

---@class C_Minimap
---@field GetNumTrackingTypes fun(...): number
---@field GetTrackingInfo fun(i: number): string, string, boolean, string, number, WowSpellId
---@field SetTracking fun(...)
C_Minimap = {}

---@param a string
---@param b string
function GetAddOnMetadata(a, b)
end

---@param name string
---@param x WowControl|string|nil
---@param parent WowControl
---@param template string|nil
---@return WowControl
function CreateFrame(name, x, parent, template)
  return --[[---@type WowControl]] {}
end

---@param t WowControl
---@param n number
function PanelTemplates_TabResize(t, n)
end

---@param name string
function PickupMacro(name)
end

---@return boolean
function CursorHasItem()
  return false
end