# Baldur's Gate 3 Combat Extender
Adds extra abilities, spells and other buffs to enemies with easy user configuration. Whereas there are multiple combat mods, they tend to be (very) opiniated, outdated, abandoned or aren't really suitable for a serious campaign. This mod allows you to adjust combat difficulty while enabling you as player to easily adjust it to your needs.

## What does it do?
It [tags enemies](Source/Character.txt) based on archtypes using an override method. In turn these tags are used to dynamically add extra abilities, spells or passives. Besides tagged enemies it applies global boosts in the form of additional hitpoints, movement range or (bonus) actions.

For example Fighters get tagged with `CX_Fighter_Boost` in the [CombatExtender.json](Source/CombatExtender.json) file which is located in `%localappdata%\Larian Studios\Baldur's Gate 3\Script Extender` (Use WINKEY + R, then paste)
```
{
  "PassiveName": "CX_Fighter_Boost",
  "Spells": ["Target_DistractingStrike","Target_PushingAttack"],
  "ExtraPassives": ["FightingStyle_GreatWeaponFighting","FightingStyle_TwoWeaponFighting","FightingStyle_Protection"]
},
```
If you disagree with my default config, you can easily add, remove or customize entries. I am open to receive your suggestions for the "global" default config either here or on Nexus. Baldur's Gate is a large game with a lot of encounters, even though I have extensively tested this mod in my own MP sessions there can always be mistakes.

## What is your default config in English?
I highly recommend you read the excellent BG3 wiki for [Armour Class (AC)](https://bg3.wiki/wiki/Armour_Class), [Attack Rolls](https://bg3.wiki/wiki/Dice_rolls) and [Saving Throws](https://bg3.wiki/wiki/Saving_throws)

| Level | Boost (Armour Class (AC), Attack Roll, Saving Throw, Damage (per attack) |
|---|:---:|
| 1-3   | 1 |
| 4-7   | 2 |
| 8-11  | 3 |
| 12-15 | 4 |
| 16-19 | 5 |


| Type | Movement Boost (m) | Movement Boost (ft) |
|---|:--:|:---:|
| Ally  | 0 | 0 |
| Enemy | 3 | 10 |
| Boss  | 3 | 10 |

| Type | Health Boost |
|---|:--:|
| Ally  | 0% |
| Enemy | 10% |
| Boss  | 10% |

| Type | Extra Action | Extra Bonus Action |
|---|:--:|:--:|
| Ally  | 0 | 0 |
| Enemy | 0 | 1 |
| Boss  | 0 | 0 |




## Install
Grab the latest release from here, or from Nexus. The config `CombatExtender.json` can be easily adjusted to your liking and if you want to replace the default config with an easier to read one [copy paste this one](Source/CombatExtender.json).

