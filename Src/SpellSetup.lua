local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSpellSetupModule
local spellSetupModule = BuffomatModule.New("SpellSetup") ---@type BomSpellSetupModule

local constModule = BuffomatModule.Import("Const") ---@type BomConstModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule

local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

---Flag set to true when custom spells and cancel-spells were imported from the config
local bomSpellsImportedFromConfig = false

---Formats a spell icon + spell name as a link
-- TODO: Move to SpellDef class
---@param spellInfo BomSpellCacheElement spell info from the cache via BOM.GetSpellInfo
local function bomFormatSpellLink(spellInfo)
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

local function bomSetup_MaybeAddCustomSpells()
  if bomSpellsImportedFromConfig then
    return
  end

  bomSpellsImportedFromConfig = true

  for x, entry in ipairs(BomSharedState.CustomSpells) do
    tinsert(BOM.AllBuffomatSpells, BOM.Tool.CopyTable(entry))
  end

  for x, entry in ipairs(BomSharedState.CustomCancelBuff) do
    tinsert(BOM.CancelBuffs, BOM.Tool.CopyTable(entry))
  end
end

local function bomSetup_ResetCaches()
  BOM.SelectedSpells = {}
  BOM.cancelForm = {}
  BOM.AllSpellIds = {}
  BOM.SpellIdtoConfig = {}
  BOM.SpellIdIsSingle = {}
  BOM.ConfigToSpell = {}

  BOM.SharedState.Cache = BOM.SharedState.Cache or {}
  BOM.SharedState.Cache.Item2 = BOM.SharedState.Cache.Item2 or {}
end

local function bomSetup_CancelBuffs()
  for i, spell in ipairs(BOM.CancelBuffs) do
    -- save "ConfigID"
    --spell.ConfigID = spell.ConfigID or spell.singleId

    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
      end
    end

    -- GetSpellNames and set default duration
    local spell_info = BOM.GetSpellInfo(spell.singleId)

    spell.singleText = spell_info.name
    spell_info.rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = bomFormatSpellLink(spell_info)
    spell.spellIcon = spell_info.icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for j, profil in ipairs(BOM.ALL_PROFILES) do
      if BOM.CharacterState[profil].CancelBuff[spell.ConfigID] == nil then
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID] = {}
        BOM.CharacterState[profil].CancelBuff[spell.ConfigID].Enable = spell.default or false
      end
    end
  end
end

---@param spell BomSpellDef
---@param add boolean
local function bomSetup_EachSpell_Consumable(add, spell)
  -- call results are cached if they are successful, should not be a performance hit
  local item_info = BOM.GetItemInfo(spell.item)

  if not spell.isScanned and item_info then
    if (not item_info
            or not item_info.itemName
            or not item_info.itemLink
            or not item_info.itemIcon) and BOM.SharedState.Cache.Item2[spell.item]
    then
      item_info = BOM.SharedState.Cache.Item2[spell.item]

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

      BOM.SharedState.Cache.Item2[spell.item] = item_info
    else
      --BOM:Print("Item not found! Spell=" .. tostring(spell.singleId)
      --      .. " Item=" .. tostring(spell.item))

      -- Go delayed fetch
      local item = Item:CreateFromItemID(spell.item)
      item:ContinueOnItemLoad(function()
        local name = item:GetItemName()
        local link = item:GetItemLink()
        local icon = item:GetItemIcon()
        BOM.SharedState.Cache.Item2[spell.item] = { itemName = name,
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

local function bomSetup_EachSpell_CacheUpdate(spell)
  -- get highest rank and store SpellID=ConfigID
  if spell.singleFamily then
    for sindex, sID in ipairs(spell.singleFamily) do
      BOM.SpellIdtoConfig[sID] = spell.ConfigID
      BOM.SpellIdIsSingle[sID] = true
      BOM.ConfigToSpell[sID] = spell

      if IsSpellKnown(sID) then
        spell.singleId = sID
      end
    end
  end

  if spell.singleId then
    BOM.SpellIdtoConfig[spell.singleId] = spell.ConfigID
    BOM.SpellIdIsSingle[spell.singleId] = true
    BOM.ConfigToSpell[spell.singleId] = spell
  end

  if spell.groupFamily then
    for sindex, sID in ipairs(spell.groupFamily) do
      BOM.SpellIdtoConfig[sID] = spell.ConfigID
      BOM.ConfigToSpell[sID] = spell

      if IsSpellKnown(sID) then
        spell.groupId = sID
      end
    end
  end

  if spell.groupId then
    BOM.SpellIdtoConfig[spell.groupId] = spell.ConfigID
    BOM.ConfigToSpell[spell.groupId] = spell
  end
end

---@param spell BomSpellDef
local function bomSetup_EachSpell_SetupNonConsumable(spell)
  -- Load spell info and save some good fields for later use
  local spellInfo = BOM.GetSpellInfo(spell.singleId)

  if spellInfo ~= nil then
    spell.singleText = spellInfo.name
    spellInfo.rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = bomFormatSpellLink(spellInfo)
    spell.spellIcon = spellInfo.icon

    if spell.type == "tracking" then
      spell.trackingIconId = spellInfo.icon
      spell.trackingSpellName = spellInfo.name
    end

    if not spell.isInfo
            and not spell.isConsumable
            and spell.singleDuration
            and BOM.SharedState.Duration[spellInfo.name] == nil
            and IsSpellKnown(spell.singleId) then
      BOM.SharedState.Duration[spellInfo.name] = spell.singleDuration
    end
  end -- spell info returned success
end

---@param spell BomSpellDef
local function bomSetup_EachSpell_SetupGroupBuff(spell)
  local spellInfo = BOM.GetSpellInfo(spell.groupId)

  if spellInfo ~= nil then
    spell.groupText = spellInfo.name
    spellInfo.rank = GetSpellSubtext(spell.groupId) or ""
    spell.groupLink = bomFormatSpellLink(spellInfo)

    if spell.groupDuration
            and BOM.SharedState.Duration[spellInfo.name] == nil
            and IsSpellKnown(spell.groupId)
    then
      BOM.SharedState.Duration[spellInfo.name] = spell.groupDuration
    end
  end
end

---Adds a spell to the palette of spells to configure and use, for each profile
---@param spell BomSpellDef
local function bomSetup_EachSpell_Add(spell)
  tinsert(BOM.SelectedSpells, spell)
  BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily, spell.groupFamily,
          spell.singleId, spell.groupId)

  if spell.cancelForm then
    BOM.Tool.iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily,
            spell.singleId, spell.groupId)
  end

  --setDefaultValues!
  for j, eachProfile in ipairs(BOM.ALL_PROFILES) do
    ---@type BomSpellDef
    local profileSpell = BOM.CharacterState[eachProfile].Spell[spell.ConfigID]

    if profileSpell == nil then
      BOM.CharacterState[eachProfile].Spell[spell.ConfigID] = {}
      profileSpell = BOM.CharacterState[eachProfile].Spell[spell.ConfigID]

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
---@param spell BomSpellDef
local function bomSetup_EachSpell(spell)
  spell.SkipList = {}
  BOM.ConfigToSpell[spell.ConfigID] = spell

  bomSetup_EachSpell_CacheUpdate(spell)

  -- GetSpellNames and set default duration
  if spell.singleId and not spell.isConsumable then
    bomSetup_EachSpell_SetupNonConsumable(spell)
  end

  if spell.groupId then
    bomSetup_EachSpell_SetupGroupBuff(spell)
  end

  -- has Spell? Manacost?
  local add = false

  -- Add single buffs which are known
  if IsSpellKnown(spell.singleId) then
    add = true
    spell.singleMana = 0
    local cost = GetSpellPowerCost(spell.singleText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          spell.singleMana = cost[j].cost or 0
        end
      end
    end
  end

  -- Add group buffs which are known
  if spell.groupText and IsSpellKnown(spell.groupId) then
    add = true
    spell.groupMana = 0
    local cost = GetSpellPowerCost(spell.groupText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          spell.groupMana = cost[j].cost or 0
        end
      end
    end
  end

  if spell.isConsumable then
    add = bomSetup_EachSpell_Consumable(add, spell)
  end

  if spell.isInfo then
    add = true
  end

  if add then
    bomSetup_EachSpell_Add(spell)
  end -- if spell is OK to be added
end

---Scan all spells known to Buffomat and see if they are available to the player
function spellSetupModule:SetupAvailableSpells()
  for i, profil in ipairs(BOM.ALL_PROFILES) do
    BOM.CharacterState[profil].Spell = BOM.CharacterState[profil].Spell or {}
    BOM.CharacterState[profil].CancelBuff = BOM.CharacterState[profil].CancelBuff or {}
    BOM.CharacterState[profil].Spell[constModule.BLESSING_ID] = BOM.CharacterState[profil].Spell[constModule.BLESSING_ID] or {}
  end

  bomSetup_MaybeAddCustomSpells()

  --Spells selected for the current class/settings/profile etc
  bomSetup_ResetCaches()

  if BOM.ArgentumDawn.Link == nil
          or BOM.Carrot.Link == nil then
    do
      BOM.ArgentumDawn.Link = bomFormatSpellLink(BOM.GetSpellInfo(BOM.ArgentumDawn.spell))
      BOM.Carrot.Link = bomFormatSpellLink(BOM.GetSpellInfo(BOM.Carrot.spell))
    end
  end

  bomSetup_CancelBuffs()

  ---@param spell BomSpellDef
  for i, spell in ipairs(BOM.AllBuffomatSpells) do
    bomSetup_EachSpell(spell)
  end -- for all BOM-supported spells
end
