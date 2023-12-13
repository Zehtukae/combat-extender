local function OnSessionLoaded()
    print("Combat Extender")

    -- Define global variables
    configTable = {}
    hasPrinted = false

    function printTableAddress(t)
        for k, v in pairs(t) do
            print(k, v)
        end
    end

    function printTable(tbl, indent)
        if not indent then indent = 0 end

        for k, v in pairs(tbl) do
            formatting = string.rep("  ", indent) .. k .. ": "

            if type(v) == "table" then
                print(formatting)
                printTable(v, indent+1)
            else
                print(formatting .. tostring(v))
            end
        end
    end

    -- Without JSON beautify in SE this will have to do
    function beautifyJson(json)
        local result = ""
        local indent = 0
        local inString = false
        local currentChar = ""

        for i = 1, #json do
            currentChar = json:sub(i, i)

            if currentChar == '"' and json:sub(i - 1, i - 1) ~= "\\" then
                inString = not inString
            end

            if inString then
                result = result .. currentChar
            else
                if currentChar == "{" or currentChar == "[" then
                    indent = indent + 2
                    result = result .. currentChar .. "\n" .. string.rep(" ", indent)
                elseif currentChar == "}" or currentChar == "]" then
                    indent = indent - 2
                    result = result .. "\n" .. string.rep(" ", indent) .. currentChar
                elseif currentChar == "," then
                    result = result .. currentChar .. "\n" .. string.rep(" ", indent)
                else
                    result = result .. currentChar
                end
            end
        end
        return result
    end

    function writeDefaultConfig()
        -- Define the default configuration
        local defaultConfigRaw = '{"Passives":[{"PassiveName":"CX_Barbarian_Boost","Spells":["Throw_FrenziedThrow","Target_RecklessAttack"]},{"PassiveName":"CX_Cleric_Boost","Spells":["Projectile_GuidingBolt","Target_InflictWounds"]},{"PassiveName":"CX_Fighter_Boost","Spells":["Target_DistractingStrike","Target_PushingAttack"]},{"PassiveName":"CX_Paladin_Boost","Spells":["Target_Smite_Thunderous"]},{"PassiveName":"CX_Ranger_Boost","Spells":["Target_HuntersMark"]},{"PassiveName":"CX_Rogue_Boost","Spells":["Projectile_SneakAttack","Target_SneakAttack"]},{"PassiveName":"CX_Spells_L1","Spells":["Projectile_IceKnife","Projectile_MagicMissile","Projectile_RayOfSickness","Zone_Thunderwave"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L2","Spells":["Projectile_AcidArrow","Projectile_ScorchingRay","Target_CloudOfDaggers","Zone_GustOfWind","Target_Shatter","Target_MistyStep"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L3","Spells":["Projectile_Fireball","Target_CallLightning","Zone_LightningBolt"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L4","Spells":["Target_Blight","Target_IceStorm"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L5","Spells":["Target_Cloudkill","Zone_ConeOfCold"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L6","Spells":["Projectile_Disintegrate","Target_CircleOfDeath","Projectile_ChainLightning","Zone_Sunbeam"],"ExtraSpellSlots":1},{"PassiveName":"CX_Spells_L1C","Spells":["Target_FogCloud","Target_Grease"]},{"PassiveName":"CX_Spells_L2C","Spells":["Target_HoldPerson","Target_Silence"]},{"PassiveName":"CX_Spells_L3C","Spells":["Target_HypnoticPattern","Zone_Fear"]},{"PassiveName":"CX_Spells_L4C","Spells":["Target_Banishment"]},{"PassiveName":"CX_Spells_L5C","Spells":["Throw_Telekinesis","Target_DominatePerson"]},{"PassiveName":"CX_Spells_L6C","Spells":["Target_FleshToStone"]}],"Health":{"Allies":{},"Bosses":{"HealthMultiplier":1.1},"Enemies":{"HealthMultiplier":1.1}},"Damage":{"Allies":{},"Bosses":{"StaticDamageBoost":1,"DamagePerIncrement":1,"LevelIncrement":4},"Enemies":{"StaticDamageBoost":1,"DamagePerIncrement":1,"LevelIncrement":4}},"ArmourClass":{"Allies":{},"Bosses":{"StaticBoost":2,"BoostPerIncrement":1,"LevelIncrement":4},"Enemies":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":4}},"Movement":{"Allies":{},"Bosses":{"StaticBoost":3},"Enemies":{"StaticBoost":3}},"ExtraAction":{"Allies":{},"Bosses":{"Action":{"Additional":0},"BonusAction":{"Additional":0}},"Enemies":{"Action":{"Additional":0},"BonusAction":{"Additional":1}}},"Rolls":{"Allies":{},"Bosses":{"Attack":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4},"SavingThrow":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4}},"Enemies":{"Attack":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4},"SavingThrow":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4}}}}'

        -- Beautify the JSON string
        local defaultConfig = beautifyJson(defaultConfigRaw)

        -- Write the default configuration to the file
        Ext.IO.SaveFile("CombatExtender.json", defaultConfig)
    end

    function readJsonFile()
        -- Load the file and get its content
        local status, json = pcall(Ext.IO.LoadFile, "CombatExtender.json")

        -- Check if the file was loaded successfully
        if not status or not json then
            print(string.format("INFO: Couldn't load: %%LOCALAPPDATA%%\\Larian Studios\\Baldur's Gate 3\\Script Extender\\%s Applying default", json or "CombatExtender.json"))

            -- If the file is not present or fails to load, write the default config file
            writeDefaultConfig()

            -- Try to load the file again after writing the default config
            status, json = pcall(Ext.IO.LoadFile, "CombatExtender.json")

            -- If the file still fails to load, return nil
            if not status or not json then
                print("ERROR: Failed to load config file after writing default config")
                return nil
            end
        end

        -- Parse the JSON string into a Lua table
        local status, result = pcall(Ext.Json.Parse, json)

        -- Check if the JSON was parsed successfully
        if not status then
            print(string.format("ERROR: Failed to parse JSON: %s", result)) -- result contains the error message
            return nil
        end

        -- Assign the result to the global configTable
        configTable = result

        -- Print the entire table for debugging only if hasPrinted is false
        if not hasPrinted and Ext.Debug.IsDeveloperMode() then
            printTableAddress(configTable)
            printTable(configTable)
            hasPrinted = true
        end
    end

    -- Call the readJsonFile function to read the JSON file and store the returned table in configTable
    readJsonFile()

    ExcludedCharacters=
    {
        "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323",
        "S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b",
        "S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255",
        "S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604",
        "S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a",
        "S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c",
        "S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12",
        "S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba",
        "S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679",
        "S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d",
        "S_UND_KethericCity_AdamantineGolem_2a5997fc-5f2a-4a13-b309-bed16da3b255"
    }
    function CheckIfExcluded(guid)
        for i=#ExcludedCharacters,1,-1 do
            if (ExcludedCharacters[i] == guid) then
                return 1
            end
        end
        return 0
    end

    Current_combat = ""
    Party = {}
    CombatNPCS= {}

    function CheckIfParty(guid)
        for i = #Party,1,-1 do
            if (IsPartyMember(guid,1) == 1) then
                return 1
            else return 0
            end
        end
    end

    -- Health Boost: Here a value of 1.5 means going from 50 -> 75 HP. And a value of 2 here means going from 50 -> 100 HP
    function GiveHPIncrease(guid)
        local healthConfig

        if IsBoss(guid) == 1 then
            healthConfig = configTable["Health"]["Bosses"]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["Health"]["Allies"]) == nil then
                return
            else
                healthConfig = configTable["Health"]["Allies"]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            healthConfig = configTable["Health"]["Enemies"]
        end

        local healthMultiplier = tonumber(healthConfig["HealthMultiplier"])

        if healthMultiplier == 1 then -- Check if the configuration is enabled for this type of character as 1 equals no change
            return
        end

        local maxHealth = Ext.Entity.Get(guid).Health.MaxHp
        local desiredHealth = math.ceil(maxHealth * healthMultiplier)
        local hpincrease = desiredHealth - maxHealth

        local hpBoost
        if guid == "S_GLO_Monitor_f65becd6-5cd7-4c88-b85e-6dd06b60f7b8" then -- Raphael exception as the normal approach doesn't work on him
            hpBoost = "TemporaryHP(" .. hpincrease .. ")"
        else
            hpBoost = "IncreaseMaxHP(" .. hpincrease .. ")"
        end
        AddBoosts(guid, hpBoost, "1", "1")
    end

    -- Passive Check (To add extra spells)
    -- This builds upon the CX_NAME passives such as CX_Fighter_Boost
    -- You can also use any other passive from the game, or from other mods
    function CheckPassive(guid)
        -- Check if configTable is not nil
        if not configTable.Passives or next(configTable["Passives"]) == nil then
            if Ext.Debug.IsDeveloperMode() then
                print("DEBUG: Failed to load or parse JSON. Ending passive function execution.")
            end
            return
        end

        -- Iterate over the passives
        for _, passive in ipairs(configTable["Passives"]) do

            -- Check if the target has the current passive
            if HasPassive(guid, passive["PassiveName"]) == 1 then
                print(string.format("DEBUG: Target has %s", passive["PassiveName"]))

                -- Access the "Spells" key in the passive
                local spells = passive["Spells"]

                -- Check if spells is not nil
                if spells then
                    -- Check if spells is not empty
                    if #spells > 0 then
                        for _, spell in ipairs(spells) do
                            AddSpell(guid, spell)
                        end
                    else
                        print(string.format("DEBUG: No spells for %s. Spells array is empty.", passive["PassiveName"]))
                    end
                else
                    print(string.format("DEBUG: No spells for %s. Spells key is nil.", passive["PassiveName"]))
                end
            --  Uncomment for debug
            --else
                --print(string.format("DEBUG: Target does not have %s", passive["PassiveName"]))
            end
        end
    end

    function GiveSpellSlots(guid)
        -- Check if configTable is not nil
        if not configTable.Passives or next(configTable["Passives"]) == nil then
            if Ext.Debug.IsDeveloperMode() then
                print("DEBUG: Failed to load or parse JSON. Ending SpellSlot boost function execution.")
            end
            return
        end

        -- Define the passives we are interested in
        local passives = {"CX_Spells_L1", "CX_Spells_L2", "CX_Spells_L3", "CX_Spells_L4", "CX_Spells_L5", "CX_Spells_L6"}

        -- Iterate over the passives
        for _, passive in ipairs(passives) do
            -- Check if the target has the current passive
            if HasPassive(guid, passive) == 1 then
                -- Iterate over the Passives array in the configTable
                for _, config in ipairs(configTable.Passives) do
                    -- Check if the PassiveName matches the current passive
                    if config["PassiveName"] == passive then
                        -- Access the "ExtraSpellSlots" key in the config
                        local extraSpellSlots = config["ExtraSpellSlots"]
                        -- print ("DEBUG: extraSpellSlots: " .. extraSpellSlots)

                        -- Extract the level from the passive name
                        local level = string.sub(passive, -1)
                        -- print ("DEBUG: Level value: " .. level)

                        local boost = string.format("ActionResource(SpellSlot,%s,%s)", extraSpellSlots, level)
                        AddBoosts(guid, boost, "", "")
                    end
                end
            end
        end
    end

    -- Generic Action Point Boost
    function GiveActionPointBoost(guid, actionType)
        local actionPointConfig

        if IsBoss(guid) == 1 then
            actionPointConfig = configTable["ExtraAction"]["Bosses"][actionType]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["ExtraAction"]["Allies"]) == nil or next(configTable["ExtraAction"]["Allies"][actionType]) == nil then
                return
            else
                actionPointConfig = configTable["ExtraAction"]["Allies"][actionType]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            actionPointConfig = configTable["ExtraAction"]["Enemies"][actionType]
        end

        local additional = tonumber(actionPointConfig["Additional"])

        -- Check if the configuration is enabled for this type of character
        if additional == 0 then
            return
        end

        local actionResource = (actionType == "Action") and "ActionPoint" or "BonusActionPoint"
        local actionPoints = string.format("ActionResource(%s,%s,0)", actionResource, additional)
        AddBoosts(guid, actionPoints, "1", "1")
    end

    -- Movement Bonus in meters
    function GiveMovementBoost(guid)
        local movementConfig

        if IsBoss(guid) == 1 then
            movementConfig = configTable["Movement"]["Bosses"]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["Movement"]["Allies"]) == nil then
                return
            else
                movementConfig = configTable["Movement"]["Allies"]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            movementConfig = configTable["Movement"]["Enemies"]
        end

        local staticBoost = tonumber(movementConfig["StaticBoost"])

        if staticBoost == 0 then
            return
        end

        local movement = "ActionResource(Movement," .. staticBoost .. ",0)"
        AddBoosts(guid, movement, "1", "1")
    end

    -- Armour Class
    function GiveACBoost(guid)
        local armourClassConfig

        if IsBoss(guid) == 1 then
            armourClassConfig = configTable["ArmourClass"]["Bosses"]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["ArmourClass"]["Allies"]) == nil then
                return
            else
                armourClassConfig = configTable["ArmourClass"]["Allies"]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            armourClassConfig = configTable["ArmourClass"]["Enemies"]
        end

        local staticBoost = tonumber(armourClassConfig["StaticBoost"])
        local boostPerIncrement = tonumber(armourClassConfig["BoostPerIncrement"])
        local levelIncrement = tonumber(armourClassConfig["LevelIncrement"])

        if staticBoost == 0 and boostPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(guid)
        local totalBoost = staticBoost + boostPerIncrement * math.floor(levelMultiplier / levelIncrement)

        local ac = "AC(" .. totalBoost .. ")"
        AddBoosts(guid, ac, "", "")
    end

    -- Re-use function for similar use case
    function GiveRollBonus(guid, rollType)
        local rollBonusConfig

        if IsBoss(guid) == 1 then
            rollBonusConfig = configTable["Rolls"]["Bosses"][rollType]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["Rolls"]["Allies"]) == nil then
                return
            else
                rollBonusConfig = configTable["Rolls"]["Allies"][rollType]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            rollBonusConfig = configTable["Rolls"]["Enemies"][rollType]
        end

        local staticRollBonus = tonumber(rollBonusConfig["StaticRollBonus"])
        local rollBonusPerIncrement = tonumber(rollBonusConfig["RollBonusPerIncrement"])
        local levelIncrement = tonumber(rollBonusConfig["LevelIncrement"])

        if staticRollBonus == 0 and rollBonusPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(guid)
        local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor(levelMultiplier / levelIncrement)

        local rollBonus = "RollBonus(" .. rollType .. "," .. totalRollBonus .. ")"
        AddBoosts(guid, rollBonus, "", "")
    end

    -- Damage Boost (for each attack)
    function GiveDamageBoost(guid)
        local damageConfig

        if IsBoss(guid) == 1 then
            damageConfig = configTable["Damage"]["Bosses"]
        elseif IsEnemy(guid, GetHostCharacter()) == 0 then
            if next(configTable["Damage"]["Allies"]) == nil then
                return
            else
                damageConfig = configTable["Damage"]["Allies"]
            end
        elseif IsEnemy(guid, GetHostCharacter()) == 1 then
            damageConfig = configTable["Damage"]["Enemies"]
        end

        local staticDamageBoost = tonumber(damageConfig["StaticDamageBoost"])
        local damagePerIncrement = tonumber(damageConfig["DamagePerIncrement"])
        local levelIncrement = tonumber(damageConfig["LevelIncrement"])

        if staticDamageBoost == 0 and damagePerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(guid)
        local totalDamageBoost = staticDamageBoost + damagePerIncrement * math.floor(levelMultiplier / levelIncrement)

        local damageBonus = "DamageBonus(" .. totalDamageBoost .. ")"
        AddBoosts(guid, damageBonus, "", "")
    end

    -- Apply CX_APPLIED Boost which includes CX_APPLIED Passive to each processed character
    -- This should prevent multiple boosts being granted to the same character
    local CX_APPLIED = "CX_APPLIED"

    -- Combat Listener
    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(guid, combatid)
        -- Check if configTable is loaded properly
        if not configTable or next(configTable) == nil then
            print("INFO: Failed to load or parse JSON.")
            return
        end

        Current_combat = combatid
        for k, d in ipairs(Osi.DB_PartyMembers:Get(nil)) do table.insert(Party, d[1]) end

        -- Not everything we face is a character, thankfully this is pretty rare.
        if IsCharacter(guid) == 0 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 0 and CheckIfExcluded(guid) == 0 then
            local isEnemy = IsEnemy(guid, GetHostCharacter())
            if isEnemy == 1 then
                print("DEBUG: S_Enemy: " .. guid)
                GiveHPIncrease(guid)
                ApplyStatus(guid, CX_APPLIED, -1)
            end
        elseif IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 0 and CheckIfExcluded(guid) == 0 then
            table.insert(CombatNPCS, guid)

            local isEnemy = IsEnemy(guid, GetHostCharacter())
            local isBoss = IsBoss(guid)

            if isEnemy == 1 and isBoss == 0 then
                print("DEBUG: Enemy: " .. guid)
            elseif isEnemy == 1 and isBoss == 1 then
                print("DEBUG: Boss: " .. guid)
            else
                print("DEBUG: Ally: " .. guid)
            end

            CheckPassive(guid)
            GiveSpellSlots(guid)
            GiveHPIncrease(guid)
            GiveRollBonus(guid, "Attack")
            GiveRollBonus(guid, "SavingThrow")
            GiveACBoost(guid)
            GiveDamageBoost(guid)
            GiveMovementBoost(guid)
            GiveActionPointBoost(guid, "Action")
            GiveActionPointBoost(guid, "BonusAction")
            ApplyStatus(guid, CX_APPLIED, -1)
        end
    end)

    Ext.Osiris.RegisterListener("CombatEnded", 1, "after", function(combat)
        if (combat == Current_combat) then
            Party = {}
            CombatNPCS = {}
        end
    end)

end
 Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)