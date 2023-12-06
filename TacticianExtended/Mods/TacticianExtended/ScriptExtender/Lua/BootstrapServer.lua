local function OnSessionLoaded()
    print("Tactician Extended")

    -- Define configTable as a global variable
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

    function readJsonFile()
        -- Load the file and get its content
        local status, json = pcall(Ext.IO.LoadFile, "TacticianExtended.json")

        -- Check if the file was loaded successfully
        if not status or not json then
            print("INFO: Failed to load config file: " .. (json or "TacticianExtended.json"))
            return nil
        end

        -- Parse the JSON string into a Lua table
        local status, result = pcall(Ext.Json.Parse, json)

        -- Check if the JSON was parsed successfully
        if not status then
            print("Failed to parse JSON: " .. result) -- result contains the error message
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
        "S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"
    }
    function CheckIfExcluded(target)
        for i=#ExcludedCharacters,1,-1 do
            if (ExcludedCharacters[i] == target) then
                return 1
            end
        end
        return 0
    end

    Current_combat = ""
    Party = {}
    CombatNPCS= {}

    function CheckIfParty(target)
        for i = #Party,1,-1 do
            if (IsPartyMember(target,1) == 1) then
                return 1
            else return 0
            end
        end
    end

    -- Health Boost: Here a value of 1.5 means going from 50 -> 75 HP. And a value of 2 here means going from 50 -> 100 HP
    function GiveHPIncrease(target)
        local healthConfig

        if IsBoss(target) == 1 then
            healthConfig = configTable["Health"]["Bosses"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["Health"]["Allies"]) == nil then
                return
            else
                healthConfig = configTable["Health"]["Allies"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            healthConfig = configTable["Health"]["Enemies"]
        end

        local healthMultiplier = tonumber(healthConfig["HealthMultiplier"])

        -- Check if the configuration is enabled for this type of character as 1 equals no change
        if healthMultiplier == 1 then
            return
        end

        local maxHealth = Ext.Entity.Get(target).Health.MaxHp
        local desiredHealth = maxHealth * healthMultiplier
        local hpincrease = math.ceil(desiredHealth - maxHealth)

        local hpBoost = "IncreaseMaxHP(" .. hpincrease .. ")"
        AddBoosts(target, hpBoost, "1", "1")
    end

    -- Passive Check (To add extra spells)
    -- This builds upon the TX_NAME passives such as TX_Fighter_Boost
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
                --print("DEBUG: Target has " .. passive["PassiveName"] .. " guid: " .. guid) -- Verbose Debug
                print("DEBUG: Target has " .. passive["PassiveName"])

                -- Access the "Spells" key in the passive
                local spells = passive["Spells"]

                -- Check if spells is not nil
                if spells then
                    -- Check if spells is not empty
                    if #spells > 0 then
                        -- Uncomment for debug
                        --print("Boosting: " .. guid)
                        for _, spell in ipairs(spells) do
                            -- Uncomment for debug
                            --print("Spell: " .. spell)
                            AddSpell(guid, spell)
                        end
                    else
                        print("DEBUG: No spells for " .. passive["PassiveName"] .. ". Spells array is empty.")
                    end
                else
                    print("DEBUG: No spells for " .. passive["PassiveName"] .. ". Spells key is nil.")
                end
            --  Uncomment for debug
            --else
                --print("Target does not have " .. passive["PassiveName"] .. " guid: " .. guid)
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
        local passives = {"TX_Spells_L1", "TX_Spells_L2", "TX_Spells_L3", "TX_Spells_L4", "TX_Spells_L5", "TX_Spells_L6"}

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
                        AddBoosts(guid,"ActionResource(SpellSlot," .. extraSpellSlots .. "," .. level .. ")","","")
                    end
                end
            end
        end
    end

    -- Additional Action
    function GiveActionPointBoost(target)
        local actionPointConfig

        if IsBoss(target) == 1 then
            actionPointConfig = configTable["ExtraAction"]["Bosses"]["Action"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["ExtraAction"]["Allies"]) == nil or next(configTable["ExtraAction"]["Allies"]["Action"]) == nil then
                return
            else
                actionPointConfig = configTable["ExtraAction"]["Allies"]["Action"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            actionPointConfig = configTable["ExtraAction"]["Enemies"]["Action"]
        end

        local additional = tonumber(actionPointConfig["Additional"])

        -- Check if the configuration is enabled for this type of character
        if additional == 0 then
            return
        end

        local actionPoints = "ActionResource(ActionPoint," .. additional .. ",0)"
        AddBoosts(target, actionPoints, "1", "1")
    end

    -- Additional Bonus Action
    function GiveBonusActionPointBoost(target)
        local bonusActionPointConfig

        if IsBoss(target) == 1 then
            bonusActionPointConfig = configTable["ExtraAction"]["Bosses"]["BonusAction"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["ExtraAction"]["Allies"]) == nil or next(configTable["ExtraAction"]["Allies"]["BonusAction"]) == nil then
                return
            else
                bonusActionPointConfig = configTable["ExtraAction"]["Allies"]["BonusAction"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            bonusActionPointConfig = configTable["ExtraAction"]["Enemies"]["BonusAction"]
        end

        local additional = tonumber(bonusActionPointConfig["Additional"])

        -- Check if the configuration is enabled for this type of character
        if additional == 0 then
            return
        end

        local bonusActionPoints = "ActionResource(BonusActionPoint," .. additional .. ",0)"
        AddBoosts(target, bonusActionPoints, "1", "1")
    end

    -- Movement Bonus in meters
    function GiveMovementBoost(target)

        local excludeGUID = "S_UND_KethericCity_AdamantineGolem_2a5997fc-5f2a-4a13-b309-bed16da3b255" -- Grym GUID
        if target == excludeGUID then
            print("DEBUG: Grym is excluded from receiving a movement boost")
            return
        end

        local movementConfig

        if IsBoss(target) == 1 then
            movementConfig = configTable["Movement"]["Bosses"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["Movement"]["Allies"]) == nil then
                return
            else
                movementConfig = configTable["Movement"]["Allies"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            movementConfig = configTable["Movement"]["Enemies"]
        end

        local staticBoost = tonumber(movementConfig["StaticBoost"])

        -- Check if the configuration is enabled for this type of character
        if staticBoost == 0 then
            return
        end

        local movement = "ActionResource(Movement," .. staticBoost .. ",0)"
        AddBoosts(target, movement, "1", "1")
    end

    -- Armour Class
    function GiveACBoost(target)
        local armourClassConfig

        if IsBoss(target) == 1 then
            armourClassConfig = configTable["ArmourClass"]["Bosses"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["ArmourClass"]["Allies"]) == nil then
                return
            else
                armourClassConfig = configTable["ArmourClass"]["Allies"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            armourClassConfig = configTable["ArmourClass"]["Enemies"]
        end

        local staticBoost = tonumber(armourClassConfig["StaticBoost"])
        local boostPerIncrement = tonumber(armourClassConfig["BoostPerIncrement"])
        local levelIncrement = tonumber(armourClassConfig["LevelIncrement"])

        -- Check if the configuration is enabled for this type of character
        if staticBoost == 0 and boostPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(target)
        --local totalBoost = staticBoost + boostPerIncrement * math.floor(levelMultiplier / levelIncrement)
        local totalBoost = staticBoost + boostPerIncrement * math.floor((levelMultiplier - 1) / levelIncrement)

        local ac = "AC(" .. totalBoost .. ")"
        AddBoosts(target, ac, "", "")
    end

    -- Attack Roll
    function GiveAttackRollBonus(target)
        local rollBonusConfig

        if IsBoss(target) == 1 then
            rollBonusConfig = configTable["Rolls"]["Bosses"]["Attack"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["Rolls"]["Allies"]) == nil then
                return
            else
                rollBonusConfig = configTable["Rolls"]["Allies"]["Attack"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            rollBonusConfig = configTable["Rolls"]["Enemies"]["Attack"]
        end

        local staticRollBonus = tonumber(rollBonusConfig["StaticRollBonus"])
        local rollBonusPerIncrement = tonumber(rollBonusConfig["RollBonusPerIncrement"])
        local levelIncrement = tonumber(rollBonusConfig["LevelIncrement"])

        -- Check if the configuration is enabled for this type of character
        if staticRollBonus == 0 and rollBonusPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(target)
        --local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor(levelMultiplier / levelIncrement)
        local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor((levelMultiplier - 1) / levelIncrement)

        local attackRollBonus = "RollBonus(Attack," .. totalRollBonus .. ")"
        AddBoosts(target, attackRollBonus, "", "")
    end

    -- Saving Throw Rolls
    function GiveSavingThrowRollBonus(target)
        local rollBonusConfig

        if IsBoss(target) == 1 then
            rollBonusConfig = configTable["Rolls"]["Bosses"]["SavingThrow"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["Rolls"]["Allies"]) == nil then
                return
            else
                rollBonusConfig = configTable["Rolls"]["Allies"]["SavingThrow"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            rollBonusConfig = configTable["Rolls"]["Enemies"]["SavingThrow"]
        end

        local staticRollBonus = tonumber(rollBonusConfig["StaticRollBonus"])
        local rollBonusPerIncrement = tonumber(rollBonusConfig["RollBonusPerIncrement"])
        local levelIncrement = tonumber(rollBonusConfig["LevelIncrement"])

        -- Check if the configuration is enabled for this type of character
        if staticRollBonus == 0 and rollBonusPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(target)
        --local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor(levelMultiplier / levelIncrement)
        local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor((levelMultiplier - 1) / levelIncrement)

        local savingThrowRollBonus = "RollBonus(SavingThrow," .. totalRollBonus .. ")"
        AddBoosts(target, savingThrowRollBonus, "", "")
    end

    -- Damage Boost (for each attack)
    function GiveDamageBoost(target)
        local damageConfig

        if IsBoss(target) == 1 then
            damageConfig = configTable["Damage"]["Bosses"]
        elseif IsEnemy(target, GetHostCharacter()) == 0 then
            if next(configTable["Damage"]["Allies"]) == nil then
                return
            else
                damageConfig = configTable["Damage"]["Allies"]
            end
        elseif IsEnemy(target, GetHostCharacter()) == 1 then
            damageConfig = configTable["Damage"]["Enemies"]
        end

        local staticDamageBoost = tonumber(damageConfig["StaticDamageBoost"])
        local damagePerIncrement = tonumber(damageConfig["DamagePerIncrement"])
        local levelIncrement = tonumber(damageConfig["LevelIncrement"])

        -- Check if the configuration is enabled for this type of character
        if staticDamageBoost == 0 and damagePerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(target)
        local totalDamageBoost = staticDamageBoost + damagePerIncrement * math.floor(levelMultiplier / levelIncrement)

        local damageBonus = "DamageBonus(" .. totalDamageBoost .. ")"
        AddBoosts(target, damageBonus, "", "")
    end

    -- Combat Listener
    -- Apply TX_APPLIED Boost which includes TX_APPLIED Passive to each processed character
    -- This should prevent multiple boosts being granted to the same character
    local TX_APPLIED = "TX_APPLIED"

    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(guid, combatid)
        -- Check if configTable is loaded properly
        if not configTable or next(configTable) == nil then
            print("INFO: Failed to load or parse JSON.")
            return
        end

        Current_combat = combatid
        for k, d in ipairs(Osi.DB_PartyMembers:Get(nil)) do table.insert(Party, d[1]) end

        if IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, TX_APPLIED) == 0 and CheckIfExcluded(guid) == 0 then
            table.insert(CombatNPCS, guid)

            local isEnemy = IsEnemy(guid, GetHostCharacter())
            local isBoss = IsBoss(guid)

            if isEnemy == 1 and isBoss == 0 then
                print("DEBUG: Enemy: " .. guid)
            elseif isEnemy == 1 and isBoss == 1 then
                print("DEBUG: Boss: " .. guid)
            else
                print("DEBUG: Ally: " .. guid)
                return -- Not applying boosts to Allies
            end

            CheckPassive(guid)
            GiveSpellSlots(guid)
            GiveHPIncrease(guid)
            GiveAttackRollBonus(guid)
            GiveSavingThrowRollBonus(guid)
            GiveACBoost(guid)
            GiveDamageBoost(guid)
            GiveMovementBoost(guid)
            GiveActionPointBoost(guid)
            GiveBonusActionPointBoost(guid)
            ApplyStatus(guid, TX_APPLIED, -1)
        end
    end)

    Ext.Osiris.RegisterListener("CombatEnded",1,"after",function(combat)
        if (combat == Current_combat) then
            Party = {}
            CombatNPCS = {}
        end
    end)

end
 Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)