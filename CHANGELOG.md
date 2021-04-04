# Changelog

## Buffomat Classic 1.9.6

- "Force cast" on target and "Exclude target". Target a member of your group and
  click Force or Exclude button. The setting is saved per character and is not
  reset when you leave raid. Force/exclude button tooltip shows current list of
  names.
- Added Argent Dawn strength food (Blessed Sunfruit)

## Buffomat Classic 1.9.3

- Improved tooltips on self/group buff switches. Inactive switches texture
  changed to gray circle "offline" texture.
- Added Naxxramas instance IDs from Lich King, for AD trinket reminders, seems
  to work in Classic too.
- Update timer is now 1.5 seconds instead of 0.1 seconds (might help Naxx lags)
- There is now group/single buff toggle conveniently placed next to the cast
  button, when you don't want to rebuff but just to refresh single buffs on
  people. This is the same option as in the quick settings menu and in the
  settings window.
- Internal code refactoring for the scan module.

## Buffomat Classic 1.9

- Internal code improvements, even though I constantly play with it and it shows
  no signs of problems, things will possibly be unstable for a moment.
- Menu popup is simpler now, options removed from the main Spells tab. Options
  submenu renamed to "Quick Options" and Options menu item renamed to "Options
  Window".
- Cancel auras now has text label and not just an empty row without any
  explanation. Can cancel int and spirit buffs.
- Added 2 more cancel buffs (int and spirit, useful for tanks in raids). Added
  agi elixir for cheapskates like me.
- Class-restrictions, limiting mana int and spirit buffs to mana classes,
  limiting agi, str and AP buffs to physical dmg classes - makes the list of
  consumables shorter.
- Resurrection targets are sorted to prefer priests, shamans and paladins first
- Multiple nice tooltips added reminding that keybind setting exists and that
  the macro button can be used.
- Buff tab now displays selected buff groups in tab text
- Watched groups are saved if the user is in raid (relogs and reloads do not
  lose the settings). Reset to watch all when user leaves the raid.
- Warriors can now have Battle Shout in watched buffs. Hunters now don't have
  all trackers enabled by default - choose yourself.
- Fonts made slightly bigger
- Green and red circles changed to more familiar checkboxes improving the UI
  overall feel.

## Buffomat Classic 1.83

- Forked and renamed abandoned addon to become "Buffomat Classic". Reuploading
  to Curse.

# Legacy Changelog from Buff'o'mat

## 1.83

- fix a bug with elixier count

## 1.82

- automatic cast tracking-spells

## 1.81

- add ranks for Touch of Weakness

## 1.80

- show item count (note for group buffs, it will count all variants (e.g.
  candles) and don't care about the rank of the spell)
- fix itemcache

## 1.76

- fix weapon-buff

## 1.75

- Support for Crippling Poison, Wound Poison, Instant Toxin, Instant Poison,
  Mind-numbing Poison, Deadly Poison, Elemental Sharpening Stone, Consecrated
  Sharpening Stone, Sharpening Stone, Weightstone, Blessed Wizard Oil, Brilliant
  Wizard Oil, Brilliant Mana Oil
- "preload" item-information.
- repair Mageblood Potion

## 1.74

- Fix Bug with weapon-enchantments
- Add Brilliant Mana Oil & Brilliant Wizard Oil

## 1.73

- more optimizations

## 1.72

- redesign spell-tab (config-section)
- cached-item-scan - should be much faster
- "slow-mode" - reduce refresh-rate, when the update of the list is slow.

## 1.71

- Bugfixes

## 1.70

- "wispher source-warlock when soul stone buff expired" should work without
  activate the info "soul stone"
- add a short delay after a loading screen
- TOC-Update

## 1.63

- New: Keybinding for the macro
- Alt-Key reset skip- and is resurrected-list
- add optional wispher source-warlock when soul stone buff expired
- soul-stone should remember last person who got a soulstone from the player

## 1.62

- split Mage Conjure Mana Ruby
- minor changes for resurrection

## 1.61

- fix stupid bug

## 1.60

- change refresh rate

## 1.54

- correct Buff-Food - SpellIds - should work now
- Option "Don't use consumables. Just inform." - when you hold shift/ctrl/alt it
  will use the consumables

## 1.53

- remove consumables from popup-menu (to large list)
- improve list in the spell-tab
- add mage ice barrier
- add priest Shadowform

## 1.52

- consumables are now in a submenu

## 1.51

- Support for Consumables Elixir of the Mongoose, Mageblood Potion, Elixir of
  Fortitude, Elixir of Superior Defense, Major Troll's Blood Potion, Gift of
  Arthas, Juju Power, Elixir of Giants, Juju Might, Winterfall Firewater,
  Greater Arcane Elixir, Elixir of Shadow Power, Elixir of Greater Firepower,
  Elixir of Frost Power, Juju Ember, Juju Chill, Crystal Ward, Crystal Spire,
  Grilled Squid, Smoked Desert Dumplings, Nightfin Soup, Runn Tum Tuber
  Surprise, Dirge's Kickin' Chimaerok Chops, Blessed Sunfruit Juice, Blessed
  Sunfruit, Kreeg's Stout Beatdown, Gordok Green Grog, Rumsey Rum Black Label,
  Greater Arcane Protection Potion, Greater Fire Protection Potion, Greater
  Frost Protection Potion, Greater Nature Protection Potion, Greater Shadow
  Protection Potion, Noggenfogger Elixir, Savory Deviate Delight

## 1.50

- bugfixes / release

## 1.46

- bugfixes

## 1.45

- option: Always buff self first
- targets and pets are now buffed at last

## 1.44

- resurrection ignores pets.
- profile-system - default off. Automatic switch between
  solo,group,raid,battleground. You can temporary force a profile for
  configuration (pop-menu)
- clears skip-list after combat

## 1.43

- option for pets in spells. Pets in Phase Shift are ignored

## 1.42

- Option to automatic open lootable items, ignores locked (default on)

## 1.41

- add: Mage Amplify Magic
- fix: Single-Buff on spezific group member - option was missing
- New: Option to select a Buff for Tanks (only in Raid, when tanks are set)
- Automatic Cancelling of "Blessing of Salvation / Greater Blessing of
  Salvation" - hidden when player is horde
- Remove Aspect of the Cheetah/Aspect of the Pack direct before a combat (
  default on) - hidden when player is not a hunter

## 1.40

- clarified option "Watch only when in same zone"
- "Targets" are now always in the same zone

## 1.35

- optional: Remove Aspect of the Cheetah/Aspect of the Pack direct before a
  combat (default on)

## 1.34

- some bugfixes

## 1.33

- fix downgrade-system and reactivate "use rank"
- Add: Priest Elune's Grace & Power Word: Shield
- Add: Dampen Magic
- Optional: Automatic Cancelling of "Power Word: Shield" and "Blessing of
  Salvation / Greater Blessing of Salvation"

## 1.32

- optional: Add current Target in List.
- new downgrade system. When a spell is rejected with a "player is to low"
  -errormessage, the next time buff'o'mat try to cast a lower version of the
  spell.

## 1.31

- List sorted by name
- correct maximum macro limit
- Blessings - it was possible, that to many manual single-Target will trigger a
  group buff.
- rework skip mechanic - should not stuck anymore
- New: Check for "Carrot on Stick"-Buff in dungeons

## 1.30

- release
- Better detection of the Soulstone CD.

## 1.26

- hide window, when combat starts
- Warlock: Demonic Sacrifice, Firestone, Healthstone, Soulstone
- Mage: Manastone
- Items: Remember, when a Soulstone exist and has no CD.

## 1.25

- optional: automatic dismount/stand up/remove travel form after
  casting-errorType Ghost/Druid-Travel form is only out of combat automatic
  removeable

## 1.24

- Repair Group-Buff-Detection / Error-Message

## 1.23

- add event/detect for weapon-enchantments
- repair Flametongue detection

## 1.22

- Support for temporary weapon-enchantments
- optional: warn if main/secondry hand weapon echantment is missing (default
  off)
- Shaman: support for Flametongue, Frostbrand, Windfury Weapon

## 1.21

- Optional: Infos for Soulstones, who eats and drinks (default off)
- Optional: Add Rank on spell-cast in the macro (default on)
- New Skip-Mechanic. When a Spell can't be casted, it will be skiped until every
  other spell is casted.
- Add Rockbiter Weapon and Lightning Shield from Shaman

## 1.20 -Russian update by Arrogant_Dreamer

## 1.12

- Option: Remember to (un)equip Argent Dawn Commission
- Option: Disable in World/Battleground/Instance

## 1.11

- Option: Number of missing blessing required to use a Greater Blessing

## 1.10

- Update TOC
- Option: Number of missing buffs required to use a group buff

## 1.03

- Nature's Grasp - CD-Detection
- Nature's Grasp - when inside the buff is visible in the list, but buff'o'mat
  will not cast it

## 1.02

- new option: Replace single buff with group buff (when more than 3)
- magier spell: Mana Shield
- druid spell: Nature's Grasp
- Paladin: More blessing and greater blessing

## 1.01

- set minimum width to 256 pixels
- add Shadowguard (troll-priest)

## 1.00

- fix Hunter and Feign Death (buff-time-reset)
- update Chinese translation by wellcat
- Russian translation from Arrogant_Dreamer
- detection of minmap-shape

## 0.96

- new option: "resurrect ghosts"
- Thanks to OlivBEL for the french translation
- new Option-Tab Localization
- some code-optimizations
- improved auto open/close
- Additional CD-Check for Fear Ward

## 0.95

- Tracking is now prio (because it doesn't cost mana)
- Always prio resurrections
- Rename Option to "Don't cast group buffs, when somebody is dead"
- fix bug with druid human tracking

## 0.94

- Always resurrect, even when group in raid is disabled
- Normal-Settings also in "spells"-tab
- disable Tab-Switch during combat
- some cosmetic changes

## 0.93

- Add "Set"-Button for setting the activ seal/aura/tracking
- Tooltip for "Supported Spells"
- Menu optimizations
- improved detection of buff duration/expirationTime of group/raid-members

## 0.92

- bugfix

## 0.91

- Fix: "Blessing of Wisdom" was linked with Blessing of Might
- Option "Rebuff when expired in x seconds"
- rework buff finding
- Add on SpellsTab "Watch group in raid"

## 0.90

- new TABs on main window
- Tab Buff - old "Main"-window
- Tab Spells - configuration of every spell Icons from left to right: on/off,
  all/self, on classes, Always on Person X (current target!)
  This settings are stored per character!
  Simple click on a icon to toogle!
- repair /cancelform for druids

## 0.80

- fix bug in blessing
- druid-buffs include a "/cancelform"
- add fearward

## 0.71

- Mage Armor-Spells use now "Seals"-Mechanik, only one can be active
- Aura - track only casted by player
- Add Paladin-Seals - default off

## 0.70

- new Tracking-Detection. Always want to cast the last active tracking.
- Track Humanoids (as cat) -> more tests needed!
- Paladin/Hunter/Druid -> more tests needed!

## 0.60

- update-check-Optimizations
- Reset "HasResurrection"-Check after combat
- new Message "somebody is dead"
- Group buff only, when everybody is in range
- Error-Message, when macro can't created
- Option "Only in same zone" - for example when in raid are persons without the
  prequest.
- Add druid-buff "Omen of Clarity"

## 0.50

- Repair hasResurrection detection - should not resurrect somebody which has
  already resurrected
- Option "Only buff self"
- Option "Ignore in raid group x"

## 0.40

- Chinese translation by wellcat
- add "Find Treasure" tracking spell
- fallback resurrection, try to resurrect a "ghost"-player
- Use now Rank and better spell-detection

## 0.30

- resurrection optimizations
- buff handling optimizations
- fix bug with mages
- bug fixes

## 0.20

- repair distance-check (list) / Sort order List
- Wait for SPELLS_CHANGED Event before scanning for spells
- party update only on special events
- Option "Don't use group buff"
- minimap-button indicates now missing buffs
- better combat - detection / indicates
- disable button while global cool-down
- disable button while casting
- disable button while combat
- many small changes and bug fixes

## 0.10

- first release
