---@shape BomLanguageChineseModule
local chineseModule = BomModuleManager.languageChineseModule ---@type BomLanguageChineseModule

---@return BomLocaleDict
function chineseModule:Translations()
  return {
    ["options.OptionsTitle"] = "Buffomat",

    ["options.general.group.AutoActions"] = "自动操作",
    ["options.general.group.Convenience"] = "便利性",
    ["options.general.group.General"] = "常规",
    ["options.general.group.Scan"] = "扫描",
    ["options.general.group.Buffing"] = "增益",

    ["options.short.ActivateBomOnSpiritTap"] = "在低于 % 的精神激活",
    ["options.short.ReputationTrinket"] = "警告:声望物品",
    ["options.short.AutoCrusaderAura"] = "提醒：十字军光环",
    ["options.short.AutoDismount"] = "自动离开坐骑",
    ["options.short.AutoDismountFlying"] = "自动离开飞行坐骑",
    ["options.short.AutoDisTravel"] = "自动离开旅行状态",
    ["options.short.AutoOpen"] = "自动打开 Buffomat",
    ["options.short.AutoStand"] = "自动站立",
    ["options.short.BuffTarget"] = "优先目标增益",
    ["options.short.Carrot"] = "装备物品的警告",
    ["options.short.DeathBlock"] = "如果有人死亡就暂停",
    ["options.short.DontUseConsumables"] = "不使用消耗品",
    ["options.short.InInstance"] = "在地下城/团本扫描",
    ["options.short.InPVP"] = "在战场扫描",
    ["options.short.InWorld"] = "在世界扫描",
    ["options.short.LockMinimapButton"] = "锁定小地图图标",
    ["options.short.LockMinimapButtonDistance"] = "锁定小地图图标距离",
    ["options.short.MainHand"] = "缺少主手附魔",
    ["options.short.NoGroupBuff"] = "不使用群体BUFF",
    ["options.short.OpenLootable"] = "打开可拾取的容器",
    ["options.short.PreventPVPTag"] = "防止PVP标志",
    ["options.short.ReplaceSingle"] = "替换单体增益",
    ["options.short.ResGhost"] = "尝试复活灵魂",
    ["options.short.SameZone"] = "扫描同一地区的成员",
    ["options.short.ScanInRestArea"] = "休息区时扫描",
    ["options.short.ScanInStealth"] = "隐身时扫描",
    ["options.short.ScanWhileMounted"] = "安装时扫描",
    ["options.short.SecondaryHand"] = "缺少副手附魔",
    ["options.short.SelfFirst"] = "永远自我",
    ["options.short.ShowMinimapButton"] = "显示小地图按钮",
    ["options.short.SlowerHardware"] = "减少扫描增益的频率",
    ["options.short.SomeoneIsDrinking"] = "隐藏'有人在喝酒'",
    ["options.short.UseProfiles"] = "使用配置文档",
    ["options.short.UseRank"] = "使用等级增益",

    ["options.long.ActivateBomOnSpiritTap"] = "如果牧师的'精神' 处于活跃状态且玩家法力低于 % ,则禁用",
    ["options.long.ReputationTrinket"] = "提醒更换银色黎明饰品",
    ["options.long.AutoCrusaderAura"] = "圣骑士: 骑乘时自动开启十字军光环",
    ["options.long.AutoDismount"] = "施法时自动取消地面坐骑",
    ["options.long.AutoDismountFlying"] = "施法时自动取消飞行坐骑 (小心摔死)",
    ["options.long.AutoDisTravel"] = "自动离开旅行状态 (在经典中不起作用)",
    ["options.long.AutoOpen"] = "有工作要做时自动显示 Buffomat (输入/bom)",
    ["options.long.AutoStand"] = "如果你在坐着的状态, Buffomat 会站起来",
    ["options.long.BuffTarget"] = "强制给当前目标施放增益",
    ["options.long.Carrot"] = "提醒取消装备的骑乘/飞行饰品",
    ["options.long.DeathBlock"] = "当有人死亡,不施放群体增益",
    ["options.long.DontUseConsumables"] = "仅通过 Shift, Ctrl 或 Alt 使用消耗品",
    ["options.long.GroupBuff"] = "一直施放群体BUFF(额外的材料成本)",
    ["options.long.InInstance"] = "在地下城和团本扫描增益",
    ["options.long.InPVP"] = "在战场扫描增益",
    ["options.long.InWorld"] = "在世界和城市扫描增益",
    ["options.long.LockMinimapButton"] = "锁定小地图图标位置",
    ["options.long.LockMinimapButtonDistance"] = "最小化小地图图标距离",
    ["options.long.MainHand"] = "主手缺少附魔,则发出警告",
    ["options.long.NoGroupBuff"] = "总是单体增益",
    ["options.long.OpenLootable"] = "开启背包内可拾取的物品",
    ["options.long.PreventPVPTag"] = "当你非PVP状态时跳过开启PVP的目标",
    ["options.long.ReplaceSingle"] = "将单体增益替换为群体增益",
    ["options.long.ResGhost"] = "尝试复活灵魂状态的",
    ["options.long.SameZone"] = "在同一地区扫描",
    ["options.long.ScanInRestArea"] = "在休息区(城市和旅店)扫描增益",
    ["options.long.ScanInStealth"] = "扫描增益(隐身的)",
    ["options.long.ScanWhileMounted"] = "安装时扫描",
    ["options.long.SecondaryHand"] = "副手缺少附魔,则发出警告",
    ["options.long.SelfFirst"] = "永远先给自己加BUFF",
    ["options.long.ShowClassicConsumables"] = "显示经典可能的消耗品",
    ["options.long.ShowMinimapButton"] = "显示小地图按钮",
    ["options.long.ShowTBCConsumables"] = "显示TBC可用的消耗品",
    ["options.long.SlowerHardware"] = "不太频繁的增益检查 (针对硬件不好/团队)",
    ["options.long.SomeoneIsDrinking"] = "隐藏'有人在喝酒' 的信息",
    ["options.long.UseProfiles"] = "使用配置文档",
    ["options.long.UseProfiles"] = "根据玩家个人/队伍/团队/战场使用配置文档",
    ["options.long.UseRank"] = "使用有等级的技能",

    ["task.target.Self"] = "自己", -- use instead of name when buffing self
    ["task.target.SelfOnly"] = "自己-Buff",
    ["task.type.RegularBuff"] = "Buff",
    ["task.type.GroupBuff"] = "团队-Buff ",
    ["task.type.Tracking"] = "追踪",
    ["task.type.Reminder"] = "提醒",
    ["task.type.Resurrect"] = "复活",
    ["task.type.MissingConsumable"] = "缺少材料",
    ["task.type.Consumable"] = "材料",
    ["task.hint.HoldShiftConsumable"] = "按住 Shift/Ctrl 和 Alt",
    TASK_BLESS_GROUP = "强效祝福",
    TASK_BLESS = "祝福",
    TASK_SUMMON = "召唤",
    TASK_CAST = "施放",
    ["task.type.Use"] = "使用",
    ["task.type.Consume"] = "消费",
    ["task.type.tbcHunterPetBuff"] = "对宠物使用",
    TASK_ACTIVATE = "启用",
    ["task.type.Unequip"] = "取下装备",
    ["task.error.range"] = "类别",
    ["reminder.reputationTrinket"] = "银色黎明徽记",
    ["reminder.ridingSpeedTrinket"] = "骑术/飞行速度饰品",
    ["task.hint.DontHaveItem"] = "不在背包",

    CHAT_MSG_PREFIX = "Buffomat: ",
    Buffomat = "Buffomat", -- addon title in the main window
    ResetWatchGroups = "重置为1-8队",
    FORMAT_BUFF_SINGLE = "%s %s",
    FORMAT_BUFF_SELF = "%s %s 对自己",
    FORMAT_BUFF_GROUP = "团队 %s %s",
    FORMAT_GROUP_NUM = "团%s",
    ["castButton.Next"] = "%s @ %s",
    --MsgNoSpell="Out of Range or Mana",
    ["castButton.inactive.Flying"] = "飞行:下坐骑禁用",
    ["castButton.inactive.Taxi"] = "坐骑上不检查",
    ["castButton.Busy"] = "繁忙中/角色",
    ["castButton.BusyChanneling"] = "繁忙中/聊天信息",
    ["castButton.NothingToDo"] = "无事可做",
    ["castButton.NoMacroSlots"] = "需要一个宏!",
    --MsgLocalRestart                             = "重载界面后才能更新设置 (/reload))",
    ["message.CancelBuff"] = "%s 取消增益 %s",
    ["message.BuffExpired"] = "%s 时间到了",
    ["message.ShowHideInCombat"] = "无法在战斗中显示/隐藏窗口",
    ["task.UseOrOpen"] = "使用/打开",
    MSG_MAINHAND_ENCHANT_MISSING = "主手缺少临时附魔",
    MSG_OFFHAND_ENCHANT_MISSING = "副手缺少临时附魔",
    InfoSomeoneIsDrinking = "1 在喝酒",
    InfoMultipleDrinking = "%d 在喝酒",

    InactiveReason_DeadMember = "队友死亡",
    ["castButton.inactive.IsDead"] = "你已死亡",
    ["castButton.inactive.InCombat"] = "你在战斗中",
    ["castButton.inactive.RestArea"] = "休息区禁用检查",
    ["castButton.inactive.IsStealth"] = "隐身禁用检查",
    ["castButton.inactive.PriestSpiritTap"] = "牧师的 <精神> 处于活跃状态",
    ["castButton.inactive.PvpZone"] = "战场禁用检查",
    ["castButton.inactive.Instance"] = "地下城禁用检查",
    ["castButton.inactive.OpenWorld"] = "野外禁用检查",
    ["castButton.inactive.Mounted"] = "坐骑上禁用检查",

    MsgDownGrade = "%s 的技能等级降级为 %s。请再补一次。",

    CRUSADER_AURA_COMMENT = "根据设置可以自动施放",

    HeaderRenew = "到时间前通知 (秒)",

    ["options.short.Time60"] = "时间 <=60 秒:",
    ["options.short.Time300"] = "时间 <=5 分:",
    ["options.short.Time600"] = "时间 <=10 分:",
    ["options.short.Time1800"] = "时间 <=30 分:",
    ["options.short.Time3600"] = "时间 <=60 分:",
    ["options.short.UIWindowScale"] = "UI 比例",
    ["options.short.MinBuff"] = "群体增益需达到多少人以上使用",
    ["options.short.MinBlessing"] = "强效祝福需达到多少人以上使用",

    ["options.long.Time60"] = "刷新增益的时间，如何剩余时间少于 <=60 秒 ",
    ["options.long.Time300"] = "刷新增益的时间，如何剩余时间少于 <=5 分",
    ["options.long.Time600"] = "刷新增益的时间，如何剩余时间少于 <=10 分",
    ["options.long.Time1800"] = "刷新增益的时间，如何剩余时间少于 <=30 分",
    ["options.long.Time3600"] = "刷新增益的时间，如何剩余时间少于 <=60 分",
    ["options.long.UIWindowScale"] = "UI 比例 (默认 1; 隐藏和显示Buffomat设置)",
    ["options.long.MinBuff"] = "群体增益使用需要缺失的数量",
    ["options.long.MinBlessing"] = "强效祝福使用需要缺失祝福的数量",

    TooltipSelfCastCheckbox_Self = "仅自己",
    TooltipSelfCastCheckbox_Party = "队伍/团队的Buff",
    TooltipEnableSpell = "添加这个 Buff 到列表内",
    TooltipEnableBuffCancel = "发现这个 Buff 就取消",
    FormatToggleTarget = "点击切换队伍: %s",
    FormatAllForceCastTargets = "强制施法: ",
    FormatForceCastNone = "强制施法列表",
    FormatAllExcludeTargets = "忽略: ",
    FormatExcludeNone = "忽略施法列表",
    TooltipForceCastOnTarget = "将当前团队/队伍目标添加到监控列表",
    TooltipExcludeTarget = "将当前团队/队伍目标添加到忽略列表",
    TooltipSelectTarget = "选择一个团队/队伍启用此选项",
    TooltipGroup = "在副本中检查 Buff %d",
    TooltipRaidGroupsSettings = "团队小组检查设置",
    MessageAddedForced = "强制 Buff ",
    MessageClearedForced = "取消强制 Buff",
    MessageAddedExcluded = "永不 Buff ",
    MessageClearedExcluded = "删除为",

    HintCancelThisBuff = "取消这个 Buff",
    HintCancelThisBuff_Combat = "战斗前",
    HintCancelThisBuff_Always = "一直",

    TooltipWhisperWhenExpired = "当BUFF过期时，对施放者密语提醒",
    ["tooltip.mainhand"] = "主手",
    ["tooltip.offhand"] = "副手",
    ShamanEnchantBlocked = "主手等待", -- TBC: Shown when shaman cannot enchant this hand because the other hand goes first
    PreventPVPTagBlocked = "目标开启 PvP", -- PreventPVPTag option enabled, player is non-PVP and target is PVP
    TooltipIncludesAllRanks = "所有这种类型的BUFF",
    TooltipSimilar = "任何类似的",
    TooltipSimilarFoods = "所有类型的食物",

    TabBuff = "Buff",
    TabDoNotBuff = "不要 Buff",
    TabBuffOnlySelf = "Buff 仅限自己", -- Shown when all raid groups are deselected
    TabSpells = "技能",
    --TabItems = "Items",
    --TabBehaviour = "Behaviour",

    ["popup.OpenBuffomat"] = "打开",
    BtnCancel = "取消",
    ["popup.QuickSettings"] = "快速设置",
    ["optionsMenu.Settings"] = "设置窗口",
    BtnSettingsSpells = "设置技能",
    BtnBuffs = "材料",
    ButtonCastBuff = "施放BUFF",
    ButtonBuffomatWindow = "显示/隐藏 Buffomat 窗口",

    Header_TRACKING = "追踪",
    --ActivateTracking              = "Activate tracking:", -- message when tracking is enabled
    Header_INFO = "信息",
    Header_CANCELBUFF = "取消 BUFF",
    Header_item = "材料",
    HeaderSupportedSpells = "支持的技能",
    HeaderWatchGroup = "团队中监控[队伍]",
    PanelAbout = "关于",
    HeaderInfo = "信息",
    HeaderUsage = "用法",
    HeaderSlashCommand = "可用命令",
    HeaderCredits = "Credits",
    HeaderCustomLocales = "本地化",
    ["header.Profiles"] = "简介",

    SlashSpellBook = "重新扫描技能书",
    SlashUpdate = "更新宏/列表",
    SlashClose = "取消 BOM 窗口",
    SlashReset = "重置 BOM 窗口",
    SlashOpen = "打开 BOM 窗口",
    SlashProfile = "将当前配置文件更改为 个人/队伍/团队/战场/自动",

    Tank = "坦克",
    Pet = "宠物",
    TooltipCastOnClass = "给职业施法",
    TooltipCastOnTank = "给坦克施法",
    TooltipCastOnPet = "给宠物施法",

    profile_solo = "个人",
    profile_group = "队伍",
    profile_raid = "团队",
    profile_battleground = "战场",
    profile_auto = "自动",

    AboutInfo = "耐力!智力!精神! - 这听起来很熟悉吗？ Buffomat 监控 "
            .. "扫描团队成员是否缺失BUFF,然后单击它就能给缺失BUFF的队友施放。当三 "
            .. "个或更多成员丢失同一个BUFF时,会使用群体BUFF "
            .. "插件的另一个功能是你提醒你启用'寻找草药'之类的追踪技能。插件同样可以用于复活技能 "
            .. "当你点击宏时,它将复活你身边的人-优先级最高为萨满,圣骑士和牧师。 ",

    AboutUsage = "你需要一个宏才能使用此插件。 主窗口有 "
            .. "两个标签'BUFF'和'技能'。 在'BUFF'下你会找到所有缺失的BUFF和一个施放按钮. "
            .. "在'技能'下,你可以设置那些技能应该被监控,是否 "
            .. "应该使用群体BUFF。选择是对你还是对所有队伍成员. "
            .. "选择哪个BUFF应该在哪个职业上使用。 你也可以忽略整个队伍 "
            .. "(例如在副本中,当你被分配给7队和8队上增益BUFF时)你也可以"
            .. "在这里选择,一个BUFF应该在当前目标上施放。例如 "
            .. "当德鲁伊点击主坦克,在'荆棘术'点击'-'（最后一个符号）- "
            .. "会变成十字准星,现在插件将记住你要把BUFF施放给主坦克。"
            .. "你有两个选项可以从缺失的BUFF列表中选择一个去施放BUFF。"
            .. "窗口中的法术按钮或插件的宏。 你可以在主窗口的'标题栏'上找到'M'按钮。"
            .. "|n重要提醒：插件只在脱战后起作用,因为暴雪 "
            .. "不允许在战斗中更改宏。"
            .. "另外,在战斗中也不允许打开或关闭主窗口！",

    AboutSlashCommand = "", --<value> can be true, 1, enable, false, 0, disable. If <value> is omitted, the current status switches.",

    TooltipMacroButton = "将此宏拖到您的动作条中来施放BUFF|您也可以在按键绑定 =>其他 中为宏添加快捷键 ",
    TooltipSettingsButton = "打开快速设置和配置文件存档",
    TooltipCloseButton = "隐藏 Buffomat 窗口,输入 /bom 重新打开或单击小地图按钮",
    TooltipCastButton = "从列表中施放法术。|n在战斗中不可用。|n可以通过宏来施放（在顶部）|n需要在按键绑定=>其他 中绑定快捷键",

    SpellLabel_TrackHumanoids = "Cat only - 覆盖跟踪草药和矿石",
  }

end