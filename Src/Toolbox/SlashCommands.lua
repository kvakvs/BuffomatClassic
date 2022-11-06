local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomSlashCommandsModule
local slashModule = {}
BomModuleManager.slashCommandsModule = slashModule

---@shape BomSlashCommand
---@field command string
---@field description string
---@field handler function|BomSlashCommand[]
---@field target string|nil

---@alias BomSlashCommandConfig BomSlashCommand[]

local slash, slashCmd
function slashModule:SlashUnpack(t, sep)
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

---@param prefix string
---@param subSlash BomSlashCommand[]
---@param p fun(text: string): void
function slashModule:PrintSlashCommand(prefix, subSlash, p)
  p = p or print
  prefix = prefix or ""
  subSlash = subSlash or slash

  local colCmd = "|cFFFF9C00"

  for i, subcmd in ipairs(subSlash) do
    local words = (type(subcmd[1]) == "table") and "|r(" .. colCmd
            .. slashModule:SlashUnpack(subcmd[1], "|r/" .. colCmd)
            .. "|r)" .. colCmd or subcmd[1]
    if words == "%" then
      words = "<value>"
    end

    if subcmd[2] ~= nil and subcmd[2] ~= "" then
      p(colCmd .. ((type(slashCmd) == "table") and slashCmd[1] or slashCmd) .. " " .. prefix .. words .. "|r: " .. subcmd[2])
    end

    if type(subcmd[3]) == "table" then
      slashModule:PrintSlashCommand(prefix .. words .. " ", subcmd[3], p)
    end
  end
end

---@param deep number
---@param msg string[]
---@param subSlash BomSlashCommand[]
function slashModule:DoSlash(deep, msg, subSlash)
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
        return slashModule:DoSlash(deep + 1, msg, subcmd[3])
      end
    end
  end

  slashModule:PrintSlashCommand(slashModule:Combine(msg, " ", 1, deep - 1) .. " ", subSlash)

  return nil
end

---@param msg string|nil
function slashModule.HandleSlashCommand(msg)
  if msg == "help" then
    local colCmd = "|cFFFF9C00"
    print("|cFFFF1C1C" .. GetAddOnMetadata(TOCNAME, "Title")
            .. " " .. GetAddOnMetadata(TOCNAME, "Version")
            .. " by " .. GetAddOnMetadata(TOCNAME, "Author"))
    print(GetAddOnMetadata(TOCNAME, "Notes"))
    if type(slashCmd) == "table" then
      print("SlashCommand:", colCmd, slashModule:SlashUnpack(slashCmd, "|r, " .. colCmd), "|r")
    end

    slashModule:PrintSlashCommand(nil)
  else
    slashModule:DoSlash(1, Tool.Split(msg, " "), slash)
  end
end

function slashModule:SlashCommand(cmds, subcommand)
  slash = subcommand
  slashCmd = cmds
  if type(cmds) == "table" then
    for i, cmd in ipairs(cmds) do
      _G["SLASH_" .. TOCNAME .. i] = cmd
    end
  else
    _G["SLASH_" .. TOCNAME .. "1"] = cmds
  end

  SlashCmdList[TOCNAME] = slashModule.HandleSlashCommand
end
