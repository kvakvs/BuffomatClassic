---| Module contains code to update the already selected spells in tabs
local TOCNAME, BOM = ...
local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })

local SpellSettingsFrames = {}

---Filter all known spells through current player spellbook.
---Called below from BOM.UpdateSpellsTab()
local function create_spells_tab()
  local last
  local isHorde = (UnitFactionGroup("player")) == "Horde"

  if InCombatLockdown() then
    return
  end

  BOM.MyButtonHideAll()

  local dy = 0
  local section

  for i, spell in ipairs(BOM.SelectedSpells) do
    spell.frames = spell.frames or {}

    if spell.frames.info == nil then
      spell.frames.info = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child, spell.Icon, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end

    if spell.isBuff then
      spell.frames.info:SetTooltipLink("item:" .. spell.item)
    else
      spell.frames.info:SetTooltipLink("spell:" .. spell.singleId)
    end

    dy = 12

    if spell.isOwn and section ~= "isOwn" then
      section = "isOwn"
    elseif spell.isTracking and section ~= "isTracking" then
      section = "isTracking"
    elseif spell.isResurrection and section ~= "isResurrection" then
      section = "isResurrection"
    elseif spell.isSeal and section ~= "isSeal" then
      section = "isSeal"
    elseif spell.isAura and section ~= "isAura" then
      section = "isAura"
    elseif spell.isBlessing and section ~= "isBlessing" then
      section = "isBlessing"
    elseif spell.isInfo and section ~= "isInfo" then
      section = "isInfo"
    elseif spell.isBuff and section ~= "isBuff" then
      section = "isBuff"
    else
      dy = 2
    end

    if last then
      spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
    else
      spell.frames.info:SetPoint("TOPLEFT")
    end

    local l = spell.frames.info
    local dx = 7

    if spell.frames.Enable == nil then
      spell.frames.Enable = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, BOM.IconGreen, BOM.IconRed)
    end

    spell.frames.Enable:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")
    spell.frames.Enable:SetOnClick(BOM.MyButtonOnClick)
    spell.frames.Enable:SetTooltip(L.TTEnable)
    l = spell.frames.Enable
    dx = 7

    if BOM.SpellHasClasses(spell) then
      if spell.frames.SelfCast == nil then
        spell.frames.SelfCast = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, BOM.IconSelfCastOn, BOM.IconSelfCastOff)
      end

      spell.frames.SelfCast:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")
      spell.frames.SelfCast:SetOnClick(BOM.MyButtonOnClick)
      spell.frames.SelfCast:SetTooltip(L.TTSelfCast)

      l = spell.frames.SelfCast
      dx = 2

      for ci, class in ipairs(BOM.Tool.Classes) do
        if spell.frames[class] == nil then
          spell.frames[class] = BOM.CreateMyButton(
                  BomC_SpellTab_Scroll_Child, BOM.IconClasses, BOM.IconEmpty,
                  BOM.IconDisabled, BOM.IconClassesCoord[class])
        end

        spell.frames[class]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
        spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)
        spell.frames[class]:SetOnClick(BOM.DoBlessingOnClick)
        spell.frames[class]:SetTooltip(BOM.Tool.IconClass[class] .. " " .. BOM.Tool.ClassName[class])

        if (isHorde and class == "PALADIN") or (not isHorde and class == "SHAMAN") then
          spell.frames[class]:Hide()
        else
          l = spell.frames[class]
        end
      end

      if spell.frames["tank"] == nil then
        spell.frames["tank"] = BOM.CreateMyButton(
                BomC_SpellTab_Scroll_Child, BOM.IconTank, BOM.IconEmpty, BOM.IconDisabled,
                BOM.IconTankCoord)
      end

      spell.frames["tank"]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
      spell.frames["tank"]:SetOnClick(BOM.DoBlessingOnClick)
      spell.frames["tank"]:SetTooltip(L.Tank)
      l = spell.frames["tank"]

      if spell.frames["pet"] == nil then
        spell.frames["pet"] = BOM.CreateMyButton(
                BomC_SpellTab_Scroll_Child, BOM.IconPet, BOM.IconEmpty, BOM.IconDisabled,
                BOM.IconPetCoord)
      end

      spell.frames["pet"]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")
      spell.frames["pet"]:SetOnClick(BOM.DoBlessingOnClick)
      spell.frames["pet"]:SetTooltip(L.Pet)
      l = spell.frames["pet"]

      dx = 7

      if spell.frames.target == nil then
        spell.frames.target = BOM.CreateMyButton(
                BomC_SpellTab_Scroll_Child, BOM.IconTargetOn, BOM.IconTargetOff, BOM.IconDisabled)
      end

      spell.frames.target:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.target:SetOnClick(BOM.MyButtonOnClick)
      spell.frames.target:SetTooltip(L.TTTarget)

      l = spell.frames.target
      dx = 7

    end

    if (spell.isTracking or spell.isAura or spell.isSeal) and spell.needForm == nil then
      if spell.frames.Set == nil then
        spell.frames.Set = BOM.CreateMyButtonSecure(
                BomC_SpellTab_Scroll_Child, BOM.IconChecked, BOM.IconUnChecked)
      end

      spell.frames.Set:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.Set:SetSpell(spell.singleId)

      l = spell.frames.Set
      dx = 7
    end

    if spell.isInfo and spell.allowWhisper then
      if spell.frames.Whisper == nil then
        spell.frames.Whisper = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, BOM.IconWhisperOn, BOM.IconWhisperOff)
      end

      spell.frames.Whisper:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.Whisper:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Whisper")
      spell.frames.Whisper:SetOnClick(BOM.MyButtonOnClick)
      spell.frames.Whisper:SetTooltip(L.TTWhisper)
      l = spell.frames.Whisper
      dx = 2
    end

    if spell.isWeapon then
      if spell.frames.MainHand == nil then
        spell.frames.MainHand = BOM.CreateMyButton(
                BomC_SpellTab_Scroll_Child, BOM.IconMainHandOn, BOM.IconMainHandOff,
                BOM.IconDisabled, BOM.IconMainHandOnCoord)
      end

      spell.frames.MainHand:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
      spell.frames.MainHand:SetOnClick(BOM.MyButtonOnClick)
      spell.frames.MainHand:SetTooltip(L.TTMainHand)
      l = spell.frames.MainHand
      dx = 2

      if spell.frames.OffHand == nil then
        spell.frames.OffHand = BOM.CreateMyButton(
                BomC_SpellTab_Scroll_Child, BOM.IconSecondaryHandOn, BOM.IconSecondaryHandOff,
                BOM.IconDisabled, BOM.IconSecondaryHandOnCoord)
      end

      spell.frames.OffHand:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
      spell.frames.OffHand:SetOnClick(BOM.MyButtonOnClick)
      spell.frames.OffHand:SetTooltip(L.TTOffHand)
      l = spell.frames.OffHand
      dx = 2

    end

    if spell.frames.buff == nil then
      spell.frames.buff = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end

    if spell.isWeapon then
      spell.frames.buff:SetText((spell.single or "-") .. " (" .. L.TTAnyRank .. ")")
    else
      spell.frames.buff:SetText(spell.single or "-")
    end

    spell.frames.buff:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
    l = spell.frames.buff
    dx = 7

    spell.frames.info:Show()
    spell.frames.Enable:Show()

    if BOM.SpellHasClasses(spell) then
      spell.frames.SelfCast:Show()
      spell.frames.target:Show()

      for ci, class in ipairs(BOM.Tool.Classes) do
        if (isHorde and class == "PALADIN") or (not isHorde and class == "SHAMAN") then
          spell.frames[class]:Hide()
        else
          spell.frames[class]:Show()
        end
      end

      spell.frames["tank"]:Show()
      spell.frames["pet"]:Show()
    end

    if spell.frames.Set then
      spell.frames.Set:Show()
    end

    if spell.frames.buff then
      spell.frames.buff:Show()
    end

    if spell.frames.Whisper then
      spell.frames.Whisper:Show()
    end

    if spell.frames.MainHand then
      spell.frames.MainHand:Show()
    end

    if spell.frames.OffHand then
      spell.frames.OffHand:Show()
    end

    last = spell.frames.info
  end

  dy = 12

  for i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames = spell.frames or {}

    if spell.frames.info == nil then
      spell.frames.info = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, spell.Icon, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
      spell.frames.info:SetTooltipLink("spell:" .. spell.singleId)
    end

    if last then
      spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
    else
      spell.frames.info:SetPoint("TOPLEFT")
    end

    last = spell.frames.info

    if spell.frames.Enable == nil then
      spell.frames.Enable = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, BOM.IconBuffOn, BOM.IconBuffOff)
    end

    spell.frames.Enable:SetPoint("LEFT", spell.frames.info, "RIGHT", 7, 0)
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
    spell.frames.Enable:SetOnClick(BOM.MyButtonOnClick)
    spell.frames.Enable:SetTooltip(L.TTEnableBuff)

    if spell.OnlyCombat then
      if spell.frames.OnlyCombat == nil then
        spell.frames.OnlyCombat = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      end
      spell.frames.OnlyCombat:SetText("(" .. L.TTOnlyCombat .. ")")
      spell.frames.OnlyCombat:SetPoint("TOPLEFT", spell.frames.Enable, "TOPRIGHT", 7, -1)
    end

    spell.frames.info:Show()
    spell.frames.Enable:Show()
    if spell.frames.OnlyCombat then
      spell.frames.OnlyCombat:Show()
    end
    dy = 2
  end

  if last then

    if SpellSettingsFrames.Settings == nil then
      SpellSettingsFrames.Settings = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child, BOM.IconGear, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end

    SpellSettingsFrames.Settings:SetTooltip(L.BtnSettings)
    SpellSettingsFrames.Settings:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -12)

    last = SpellSettingsFrames.Settings
    local dx = 7
    local l = last

    if SpellSettingsFrames[0] == nil then
      SpellSettingsFrames[0] = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child, BOM.IconGroup, nil, nil, { 0.1, 0.9, 0.1, 0.9 })
    end
    SpellSettingsFrames[0]:SetTooltip(L.HeaderWatchGroup)
    SpellSettingsFrames[0]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)

    l = SpellSettingsFrames[0]
    dx = 7

    for i = 1, 8 do
      if SpellSettingsFrames[i] == nil then
        SpellSettingsFrames[i] = BOM.CreateMyButton(BomC_SpellTab_Scroll_Child, BOM.IconGroupItem, BOM.IconGroupNone)
      end

      SpellSettingsFrames[i]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
      SpellSettingsFrames[i]:SetVariable(BOM.WatchGroup, i)
      SpellSettingsFrames[i]:SetText(i)
      SpellSettingsFrames[i]:SetTooltip(string.format(L.TTGroup, i))
      SpellSettingsFrames[i]:SetOnClick(BOM.MyButtonOnClick)
      l = SpellSettingsFrames[i]
      dx = 2
    end

    last = SpellSettingsFrames[0]

    for i, set in ipairs(BOM.BehaviourSettings) do
      local key = set[1]

      if BOM["Icon" .. key .. "On"] then
        if SpellSettingsFrames[key] == nil then
          SpellSettingsFrames[key] = BOM.CreateMyButton(
                  BomC_SpellTab_Scroll_Child, BOM["Icon" .. key .. "On"], BOM["Icon" .. key .. "Off"],
                  nil, BOM["Icon" .. key .. "OnCoord"], BOM["Icon" .. key .. "OffCoord"])
        end

        SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -2)
        SpellSettingsFrames[key]:SetVariable(BOM.DB, key)
        SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
        SpellSettingsFrames[key]:SetOnClick(BOM.MyButtonOnClick)
        l = SpellSettingsFrames[key]
        dx = 2

        if SpellSettingsFrames[key .. "txt"] == nil then
          SpellSettingsFrames[key .. "txt"] = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end

        SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
        SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
        l = SpellSettingsFrames[key .. "txt"]
        dx = 7

        last = SpellSettingsFrames[key]
        dx = 0
      end
    end


    --last=SpellSettingsFrames.Settings
    --dx=SpellSettingsFrames.Settings:GetWidth()+7
    for i, set in ipairs(BOM.BehaviourSettings) do
      local key = set[1]

      if not BOM["Icon" .. key .. "On"] then
        if SpellSettingsFrames[key] == nil then
          SpellSettingsFrames[key] = BOM.CreateMyButton(
                  BomC_SpellTab_Scroll_Child, BOM.IconSettingOn, BOM.IconSettingOff, nil, nil, nil)
        end

        SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", dx, -2)
        SpellSettingsFrames[key]:SetVariable(BOM.DB, key)
        SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
        SpellSettingsFrames[key]:SetOnClick(BOM.MyButtonOnClick)
        l = SpellSettingsFrames[key]
        dx = 2

        if SpellSettingsFrames[key .. "txt"] == nil then
          SpellSettingsFrames[key .. "txt"] = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end
        SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
        SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
        l = SpellSettingsFrames[key .. "txt"]
        dx = 7

        last = SpellSettingsFrames[key]
        dx = 0
      end
    end

    SpellSettingsFrames.Settings:Show()

    for i = 0, 8 do
      SpellSettingsFrames[i]:Show()
    end

    for i, set in ipairs(BOM.BehaviourSettings) do
      if SpellSettingsFrames[set[1]] then
        SpellSettingsFrames[set[1]]:Show()
      end
      if SpellSettingsFrames[set[1] .. "txt"] then
        SpellSettingsFrames[set[1] .. "txt"]:Show()
      end
    end

    last = SpellSettingsFrames.Settings
  end
end

---UpdateTab - update spells in one of the spell tabs
---BOM.SelectedSpells: table - Spells which were selected for display in Scan function, their
---state will be displayed in a spell tab
function BOM.UpdateSpellsTab()
  -- InCombat Protection is checked by the caller (Update***Tab)
  if BOM.SelectedSpells == nil then
    return
  end

  if InCombatLockdown() then
    return
  end

  if not BOM.CreateSpellTab then
    create_spells_tab()
    BOM.CreateSpellTab = true
  end

  for i, spell in ipairs(BOM.SelectedSpells) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")

    if BOM.SpellHasClasses(spell) then
      spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")

      for ci, class in ipairs(BOM.Tool.Classes) do
        spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)

        if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
          spell.frames[class]:Disable()
        else
          spell.frames[class]:Enable()
        end
      end

      spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
      spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")

      if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        spell.frames["tank"]:Disable()
        spell.frames["pet"]:Disable()
      else
        spell.frames["tank"]:Enable()
        spell.frames["pet"]:Enable()
      end

      if BOM.lastTarget ~= nil then
        spell.frames.target:Enable()
        spell.frames.target:SetTooltip(L.TTTarget .. "|n" .. BOM.lastTarget)
        if spell.isBlessing then
          spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[BOM.BLESSINGID], BOM.lastTarget, spell.ConfigID)
        else
          spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget, BOM.lastTarget, true)
        end

      else
        spell.frames.target:Disable()
        spell.frames.target:SetTooltip(L.TTTarget .. "|n" .. L.TTSelectTarget)
        spell.frames.target:SetVariable()
      end
    end

    if spell.isInfo and spell.allowWhisper then
      spell.frames.Whisper:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Whisper")
    end

    if spell.isWeapon then
      spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
      spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
    end

    if (spell.isTracking or spell.isAura or spell.isSeal) and spell.needForm == nil then
      if (spell.isTracking and BOM.DBChar.LastTracking == spell.TrackingIcon) or
              (spell.isAura and spell.ConfigID == BOM.CurrentProfile.LastAura) or
              (spell.isSeal and spell.ConfigID == BOM.CurrentProfile.LastSeal) then
        spell.frames.Set:SetState(true)
      else
        spell.frames.Set:SetState(false)
      end
    end
  end

  for _i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
  end
end
