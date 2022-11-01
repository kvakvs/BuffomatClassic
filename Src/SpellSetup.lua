local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local itemCacheModule = BomModuleManager.itemCacheModule

---@class BomSpellSetupModule
local spellSetupModule = {}
BomModuleManager.spellSetupModule = spellSetupModule

local toolboxModule = BomModuleManager.toolboxModule
local profileModule = BomModuleManager.profileModule

---@deprecated
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

---Flag set to true when custom spells and cancel-spells were imported from the config
local bomBuffsImportedFromConfig = false

---Formats a spell icon + spell name as a link
-- TODO: Move to SpellDef class
---@param spellInfo BomSpellCacheElement spell info from the cache via BOM.GetSpellInfo
function spellSetupModule:FormatSpellLink(spellInfo)
  if spellInfo == nil then
    return "NIL SPELL"
  end
  if spellInfo.spellId == nil then
    return "NIL SPELLID"
  end

  return "|Hspell:" .. spellInfo.spellId
          .. "|h|r |cff71d5ff"
          .. BOM.FormatTexture(spellInfo.icon)
          .. spellInfo.name
          .. "|r|h"
end

function spellSetupModule:Setup_MaybeAddCustomSpells()
  if bomBuffsImportedFromConfig then
    return
  end

  bomBuffsImportedFromConfig = true

  for x, entry in ipairs(buffomatModule.shared.CustomSpells) do
    tinsert(BOM.AllBuffomatBuffs, toolboxModule:CopyTable(entry))
  end

  for x, entry in ipairs(buffomatModule.shared.CustomCancelBuff) do
    tinsert(BOM.CancelBuffs, toolboxModule:CopyTable(entry))
  end
end

function spellSetupModule:Setup_ResetCaches()
  BOM.SelectedSpells = {} ---@type table<number, BomBuffDefinition>
  BOM.cancelForm = {}
  BOM.AllSpellIds = {}
  BOM.SpellIdtoConfig = {}
  BOM.SpellIdIsSingle = {}
  BOM.ConfigToSpell = {} ---@type table<number, BomBuffDefinition>

  buffomatModule.shared.Cache = buffomatModule.shared.Cache or {}
  buffomatModule.shared.Cache.Item2 = buffomatModule.shared.Cache.Item2 or {}
end

function spellSetupModule:Setup_CancelBuffs()
  for i, spell in ipairs(BOM.CancelBuffs) do
    -- save "buffId"
    --spell.buffId = spell.buffId or spell.singleId

    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.buffId
      end
    end

    -- GetSpellNames and set default duration
    local spell_info = BOM.GetSpellInfo(spell.singleId)

    spell.singleText = spell_info.name
    spell_info.rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = self:FormatSpellLink(spell_info)
    spell.spellIcon = spell_info.icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for j, profil in ipairs(profileModule.ALL_PROFILES) do
      if buffomatModule.character[profil].CancelBuff[spell.buffId] == nil then
        buffomatModule.character[profil].CancelBuff[spell.buffId] = {}
        buffomatModule.character[profil].CancelBuff[spell.buffId].Enable = spell.default or false
      end
    end
  end
end

---@param spell BomBuffDefinition
---@param add boolean
function spellSetupModule:Setup_EachSpell_Consumable(add, spell)
  -- call results are cached if they are successful, should not be a performance hit
  local item_info = BOM.GetItemInfo(spell.item)

  if not spell.isScanned and item_info then
    if (not item_info
            or not item_info.itemName
            or not item_info.itemLink
            or not item_info.itemIcon) and buffomatModule.shared.Cache.Item2[spell.item]
    then
      item_info = buffomatModule.shared.Cache.Item2[spell.item]

    elseif (not item_info
            or not item_info.itemName
            or not item_info.itemLink
            or not item_info.itemIcon) and itemCacheModule.cache[spell.item]
    then
      item_info = itemCacheModule.cache[spell.item]
    end

    if item_info
            and item_info.itemName
            and item_info.itemLink
            and item_info.itemIcon then
      add = true
      spell.singleText = item_info.itemName
      spell.singleLink = BOM.FormatTexture(item_info.itemIcon) .. item_info.itemLink
      spell.Icon = item_info.itemIcon
      spell.isScanned = true

      buffomatModule.shared.Cache.Item2[spell.item] = item_info
    else
      --BOM:Print("Item not found! Spell=" .. tostring(spell.singleId)
      --      .. " Item=" .. tostring(spell.item))

      -- Go delayed fetch
      local item = Item:CreateFromItemID(spell.item)
      item:ContinueOnItemLoad(function()
        local name = item:GetItemName()
        local link = item:GetItemLink()
        local icon = item:GetItemIcon()
        buffomatModule.shared.Cache.Item2[spell.item] = { itemName = name,
                                                    itemLink = link,
                                                    itemIcon = icon }
      end)
    end
  else
    add = true
  end

  if spell.items == nil then
    spell.items = { spell.item }
  end

  return add
end

---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_CacheUpdate(spell)
  -- get highest rank and store SpellID=buffId
  if spell.singleFamily then
    for sindex, sID in ipairs(spell.singleFamily) do
      BOM.SpellIdtoConfig[sID] = spell.buffId
      BOM.SpellIdIsSingle[sID] = true
      BOM.ConfigToSpell[sID] = spell

      if IsSpellKnown(sID) then
        spell.singleId = sID
      end
    end
  end

  if spell.singleId then
    BOM.SpellIdtoConfig[spell.singleId] = spell.buffId
    BOM.SpellIdIsSingle[spell.singleId] = true
    BOM.ConfigToSpell[spell.singleId] = spell
  end

  if spell.groupFamily then
    for sindex, sID in ipairs(spell.groupFamily) do
      BOM.SpellIdtoConfig[sID] = spell.buffId
      BOM.ConfigToSpell[sID] = spell

      if IsSpellKnown(sID) then
        spell.groupId = sID
      end
    end
  end

  if spell.groupId then
    BOM.SpellIdtoConfig[spell.groupId] = spell.buffId
    BOM.ConfigToSpell[spell.groupId] = spell
  end
end

---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_SetupNonConsumable(spell)
  -- Load spell info and save some good fields for later use
  local spellInfo = BOM.GetSpellInfo(spell.singleId)

  if spellInfo ~= nil then
    spell.singleText = spellInfo.name
    spellInfo.rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = self:FormatSpellLink(spellInfo)
    spell.spellIcon = spellInfo.icon

    if spell.type == "tracking" then
      spell.trackingIconId = spellInfo.icon
      spell.trackingSpellName = spellInfo.name
    end

    if not spell.isInfo
            and not spell.isConsumable
            and spell.singleDuration
            and buffomatModule.shared.Duration[spellInfo.name] == nil
            and IsSpellKnown(spell.singleId) then
      buffomatModule.shared.Duration[spellInfo.name] = spell.singleDuration
    end
  end -- spell info returned success
end

---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_SetupGroupBuff(spell)
  local spellInfo = BOM.GetSpellInfo(spell.groupId)

  if spellInfo ~= nil then
    spell.groupText = spellInfo.name
    spellInfo.rank = GetSpellSubtext(spell.groupId) or ""
    spell.groupLink = self:FormatSpellLink(spellInfo)

    if spell.groupDuration
            and buffomatModule.shared.Duration[spellInfo.name] == nil
            and IsSpellKnown(spell.groupId)
    then
      buffomatModule.shared.Duration[spellInfo.name] = spell.groupDuration
    end
  end
end

---Adds a spell to the palette of spells to configure and use, for each profile
---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_Add(spell)
  tinsert(BOM.SelectedSpells, spell)
  BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily, spell.groupFamily,
          spell.singleId, spell.groupId)

  if spell.cancelForm then
    BOM.Tool.iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily,
            spell.singleId, spell.groupId)
  end

  --setDefaultValues!
  for j, eachProfile in ipairs(profileModule.ALL_PROFILES) do
    ---@type BomBuffDefinition
    local profileSpell = buffomatModule.character[eachProfile].Spell[spell.buffId]

    if profileSpell == nil then
      buffomatModule.character[eachProfile].Spell[spell.buffId] = {}
      profileSpell = buffomatModule.character[eachProfile].Spell[spell.buffId]

      profileSpell.Class = profileSpell.Class or {}
      profileSpell.ForcedTarget = profileSpell.ForcedTarget or {}
      profileSpell.ExcludedTarget = profileSpell.ExcludedTarget or {}
      profileSpell.Enable = spell.default or false

      if spell:HasClasses() then
        local SelfCast = true
        profileSpell.SelfCast = false

        for ci, class in ipairs(BOM.Tool.Classes) do
          profileSpell.Class[class] = tContains(spell.targetClasses, class)
          SelfCast = profileSpell.Class[class] and false or SelfCast
        end

        profileSpell.ForcedTarget = {}
        profileSpell.ExcludedTarget = {}
        profileSpell.SelfCast = SelfCast
      end
    else
      profileSpell.Class = profileSpell.Class or {}
      profileSpell.ForcedTarget = profileSpell.ForcedTarget or {}
      profileSpell.ExcludedTarget = profileSpell.ExcludedTarget or {}
    end

  end -- for all profile names
end

---For each spell known to Buffomat check whether the player can use it and the
---category where it will go. Build mapping tables to quickly find spells
---@param buff BomBuffDefinition
function spellSetupModule:Setup_EachBuff(buff)
  buff.SkipList = {}
  BOM.ConfigToSpell[buff.buffId] = buff

  self:Setup_EachSpell_CacheUpdate(buff)

  -- GetSpellNames and set default duration
  if buff.singleId and not buff.isConsumable then
    self:Setup_EachSpell_SetupNonConsumable(buff)
  end

  if buff.groupId then
    self:Setup_EachSpell_SetupGroupBuff(buff)
  end

  -- has Spell? Manacost?
  local add = false

  -- Add single buffs which are known
  if IsSpellKnown(buff.singleId) then
    add = true
    buff.singleMana = 0
    local cost = GetSpellPowerCost(buff.singleText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          buff.singleMana = cost[j].cost or 0
        end
      end
    end
  end

  -- Add group buffs which are known
  if buff.groupText and IsSpellKnown(buff.groupId) then
    add = true
    buff.groupMana = 0
    local cost = GetSpellPowerCost(buff.groupText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          buff.groupMana = cost[j].cost or 0
        end
      end
    end
  end

  if buff.isConsumable then
    add = self:Setup_EachSpell_Consumable(add, buff)
  end

  if buff.isInfo then
    add = true
  end

  if add then
    self:Setup_EachSpell_Add(buff)
  end -- if spell is OK to be added
end

---Scan all spells known to Buffomat and see if they are available to the player
function spellSetupModule:SetupAvailableSpells()
  for i, profil in ipairs(profileModule.ALL_PROFILES) do
    buffomatModule.character[profil].Spell = buffomatModule.character[profil].Spell or {}
    buffomatModule.character[profil].CancelBuff = buffomatModule.character[profil].CancelBuff or {}
    buffomatModule.character[profil].Spell[constModule.BLESSING_ID] = buffomatModule.character[profil].Spell[constModule.BLESSING_ID] or {}
  end

  self:Setup_MaybeAddCustomSpells()

  --Spells selected for the current class/settings/profile etc
  self:Setup_ResetCaches()

  if BOM.ArgentumDawn.Link == nil
          or BOM.Carrot.Link == nil then
    do
      BOM.ArgentumDawn.Link = self:FormatSpellLink(BOM.GetSpellInfo(BOM.ArgentumDawn.spell))
      BOM.Carrot.Link = self:FormatSpellLink(BOM.GetSpellInfo(BOM.Carrot.spell))
    end
  end

  self:Setup_CancelBuffs()

  ---@param buff BomBuffDefinition
  for _i, buff in ipairs(BOM.AllBuffomatBuffs) do
    self:Setup_EachBuff(buff)
  end -- for all BOM-supported spells
end
