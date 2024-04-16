local function OnSessionLoaded()
    modTable = Ext.Mod.GetMod("0c692104-c83f-48b8-9fcd-ca7e33be5098")
    print(string.format("Combat Extender v%s.%s.%s", modTable["Info"]["ModVersion"][1], modTable["Info"]["ModVersion"][2], modTable["Info"]["ModVersion"][3]))

    -- Define global variables
    Act = 1
    ConfigTable = {}
    CombatNPCS= {}
    CurrentCombat = ""
    HasPrinted = {}
    Loaded = false
    Party = {}
    Entities = {}
    EntityHealth = {}
    EntityHealthAdjustment = {}
    EntityResetState = {}
    PersistentVars = Mods["CombatExtender"].PersistentVars or {}
    PersistentVars["baseLevel"] = PersistentVars["baseLevel"] or {}

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

    function DebugPrint(...)
        if Ext.Debug.IsDeveloperMode() then
            print(...)
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
        local defaultConfigRaw = '{"Passives":[{"PassiveName":"CX_Barbarian_Boost","Act":{"1":{"Spells":["Throw_FrenziedThrow","Target_FrenziedStrike","Target_RecklessAttack"]},"2":{"ExtraPassives":["MindlessRage","FeralInstinct"]},"3":{"ExtraPassives":["BrutalCritical","RelentlessRage"]}}},{"PassiveName":"CX_Cleric_Boost","Act":{"1":{"Spells":["Projectile_GuidingBolt","Target_InflictWounds","Target_HealingWord","Shout_HealingWord_Mass"]},"2":{"Spells":["Shout_SpiritGuardians"],"ExtraPassives":["PotentSpellcasting"]},"3":{"Spells":["Target_FlameStrike","Target_Contagion"]}}},{"PassiveName":"CX_Fighter_Boost","Act":{"1":{"Spells":["Target_DistractingStrike","Target_PushingAttack","Target_FeintingAttack"],"ExtraPassives":["Riposte","FightingStyle_GreatWeaponFighting","FightingStyle_TwoWeaponFighting","FightingStyle_Protection","FightingStyle_Dueling"]},"3":{"Spells":["Zone_SweepingAttack"],"ExtraPassives":["Indomitable","ImprovedCombatSuperiority"]}}},{"PassiveName":"CX_Monk_Boost","Act":{"3":{"Spells":["Target_WaterWhip","Projectile_FangsOfTheFireSnake","Zone_Thunderwave_Monk","Target_FistOfUnbrokenAir"]}}},{"PassiveName":"CX_Paladin_Boost","Act":{"1":{"Spells":["Target_Smite_Thunderous","Target_Smite_Wrathful","Target_Smite_Searing","Target_Smite_Divine"],"ExtraPassives":["FightingStyle_GreatWeaponFighting","FightingStyle_TwoWeaponFighting","FightingStyle_Protection","FightingStyle_Dueling"]},"3":{"Spells":["Target_Smite_Blinding"],"ExtraPassives":["ImprovedDivineSmite"]}}},{"PassiveName":"CX_Ranger_Boost","Act":{"1":{"Spells":["Target_HuntersMark","Projectile_HailOfThorns"],"ExtraPassives":["FightingStyle_Archery"]},"2":{"Spells":["Target_MistyStep"],"ExtraPassives":["MultiattackDefense"]},"3":{"Spells":["Shout_HideInPlainSight","Target_Volley","Shout_Whirlwind"]}}},{"PassiveName":"CX_Rogue_Boost","Act":{"1":{"Spells":["Projectile_SneakAttack","Target_SneakAttack"],"ExtraPassives":["UncannyDodge"]},"2":{"ExtraPassives":["Evasion"]},"3":{"ExtraPassives":["ReliableTalent"]}}},{"PassiveName":"CX_Spells_L1","Spells":["Projectile_IceKnife","Projectile_MagicMissile","Projectile_RayOfSickness","Zone_Thunderwave","Projectile_ChromaticOrb"],"ExtraSpellSlots":["1","0","0","0","0","0"]},{"PassiveName":"CX_Spells_L2","Spells":["Projectile_AcidArrow","Projectile_ScorchingRay","Target_CloudOfDaggers","Zone_GustOfWind","Target_Shatter","Target_MistyStep"],"ExtraSpellSlots":["0","1","0","0","0","0"]},{"PassiveName":"CX_Spells_L3","Spells":["Projectile_Fireball","Target_CallLightning","Zone_LightningBolt"],"ExtraSpellSlots":["0","0","1","0","0","0"]},{"PassiveName":"CX_Spells_L4","Spells":["Target_Blight","Target_IceStorm"],"ExtraSpellSlots":["0","0","0","1","0","0"]},{"PassiveName":"CX_Spells_L5","Spells":["Target_Cloudkill","Zone_ConeOfCold"],"ExtraSpellSlots":["0","0","0","0","1","0"]},{"PassiveName":"CX_Spells_L6","Spells":["Projectile_Disintegrate","Target_CircleOfDeath","Projectile_ChainLightning","Zone_Sunbeam"],"ExtraSpellSlots":["0","0","0","0","0","1"]},{"PassiveName":"CX_Spells_L1C","Spells":["Target_FogCloud","Target_Grease"]},{"PassiveName":"CX_Spells_L2C","Spells":["Target_HoldPerson","Target_Silence"]},{"PassiveName":"CX_Spells_L3C","Spells":["Target_HypnoticPattern","Zone_Fear"]},{"PassiveName":"CX_Spells_L4C","Spells":["Target_Banishment"]},{"PassiveName":"CX_Spells_L5C","Spells":["Throw_Telekinesis","Target_DominatePerson"]},{"PassiveName":"CX_Spells_L6C","Spells":["Target_FleshToStone"]}],"Health":{"Allies":{},"Bosses":{"HealthMultiplier":0,"StaticBoost":0.1,"HealthPerLevel":0.02},"Enemies":{"HealthMultiplier":0,"StaticBoost":0.1,"HealthPerLevel":0.01}},"Damage":{"Allies":{},"Bosses":{"StaticDamageBoost":1,"DamagePerIncrement":1,"LevelIncrement":4},"Enemies":{"StaticDamageBoost":1,"DamagePerIncrement":1,"LevelIncrement":6}},"ArmourClass":{"Allies":{},"Bosses":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":4},"Enemies":{"StaticBoost":0,"BoostPerIncrement":1,"LevelIncrement":4}},"SpellSaveDC":{"Allies":{},"Bosses":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":8},"Enemies":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":8}},"AbilityPoints":{"Allies":{},"Bosses":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":4},"Enemies":{"StaticBoost":1,"BoostPerIncrement":1,"LevelIncrement":6}},"Movement":{"Allies":{},"Bosses":{"StaticBoost":3},"Enemies":{"StaticBoost":1}},"ExtraAction":{"Allies":{},"Bosses":{"Action":{"Additional":0},"BonusAction":{"Additional":0}},"Enemies":{"Action":{"Additional":0},"BonusAction":{"Additional":1}}},"Rolls":{"Allies":{},"Bosses":{"Attack":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4},"SavingThrow":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":4}},"Enemies":{"Attack":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":8},"SavingThrow":{"StaticRollBonus":1,"RollBonusPerIncrement":1,"LevelIncrement":8}}}}'

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
            print(string.format("INFO: Couldn't load: %%LOCALAPPDATA%%\\Larian Studios\\Baldur's Gate 3\\Script Extender\\%s. Applying default configuration", json or "CombatExtender.json"))

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

        -- Assign the result to the global ConfigTable
        ConfigTable = result

        -- Print the entire table for debugging only if HasPrinted is false
        if not HasPrinted["ConfigTable"] and Ext.Debug.IsDeveloperMode() then
            printTableAddress(ConfigTable)
            printTable(ConfigTable)
            HasPrinted["ConfigTable"] = true
        end
    end

    -- Call the readJsonFile function to read the JSON file and store the returned table in ConfigTable
    readJsonFile()

    ExcludedCharacters= {
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
        "S_DEN_ScoutCaptive_f5b5819f-1636-4f2e-82bb-709522cc399f"
    }

    Bosses= {
        "S_UND_TheDrowNere_06bf05c5-216b-4eaf-91f5-8f1dd3d57f30",
        "S_CRE_CrecheCaptain_5093da9b-237a-491f-9402-4f9da73c1565",
        "S_MOO_PrisonWarden_66b3e4c0-2f82-4c0a-9333-73a5194f88c7",
        "S_LOW_Lorroakan_a9d4b71d-b0ef-429e-8210-6dc8be986ee9",
        "S_GLO_Cazador_2f1880e6-1297-4ca3-a79c-9fabc7f179d3",
        "S_GLO_Gortash_b878a854-f790-4999-95c4-3f20f00f65ac",
        "S_LOW_Viconia_b1ea974d-96fb-47ca-b6d9-9c85fcb69313",
        "S_GLO_Monitor_f65becd6-5cd7-4c88-b85e-6dd06b60f7b8"
    }

    function CheckIfExcluded(guid)
        for _, v in ipairs(ExcludedCharacters) do
            if v == guid then
                return 1
            end
        end
        return 0
    end

    function IsTargetABoss(guid)
        if IsBoss(guid) == 1 then
            return 1
        end
        for _, v in ipairs(Bosses) do
            if v == guid then
                return 1
            end
        end
        return 0
    end

    function CheckIfParty(guid)
        if Party[guid] then
            return 1
        else
            return 0
        end
    end

  

    function IsPartyInCombat()
        for member, _ in pairs(Party) do
            if CombatGetGuidFor(member) ~= nil then
                return true
            end
        end
        return false
    end

    function GetPartyLevel()
        local hostCharacter = Osi.GetHostCharacter()
        local highestLevel = hostCharacter and GetLevel(hostCharacter) or 0
        for member, _ in pairs(Party) do
            local memberLevel = GetLevel(member)
            if memberLevel and memberLevel > highestLevel then
                highestLevel = memberLevel
            end
        end
        return highestLevel
    end

    function IsTargetAnEnemy(guid)
        for partyMemberGuid, _ in pairs(Party) do
            if IsEnemy(guid, partyMemberGuid) == 1 then
                return 1
            end
        end
        return 0
    end

    function IsPartySummon(guid)
        if IsTargetAnEnemy(guid) == 0 and IsSummon(guid) == 1 then
            if HasAppliedStatus(guid, "UNSUMMON_ABLE") == 1 or HasAppliedStatus(guid, "GUARDIAN_OF_FAITH_AURA") == 1 then
                local statuses = Ext.Entity.Get(guid).ServerCharacter.StatusManager.Statuses
                for _, status in pairs(statuses) do
                    local causeUuid = status.CauseGUID
                    for partyMemberGuid, _ in pairs(Party) do
                        -- Convert party member GUID to handle and back to UUID? for comparison
                        local partyMemberHandle = Ext.Entity.UuidToHandle(partyMemberGuid)
                        if partyMemberHandle then
                            local handle = Ext.Loca.GetTranslatedString(partyMemberHandle.DisplayName.NameKey.Handle.Handle)
                            local convertedPartyMemberGuid = Ext.Entity.HandleToUuid(partyMemberHandle)
                            --print(string.format("DEBUG: Converted party member GUID: %s to %s", partyMemberGuid, convertedPartyMemberGuid))
                            if causeUuid == convertedPartyMemberGuid then
                                print(string.format("DEBUG: Summon is from party member: %s, %s", handle, partyMemberGuid))
                                return 1
                            end
                        end
                    end
                end
                --print("DEBUG: Summon has required statuses but is not caused by a party member.")
            else
                print("DEBUG: Summon does not have the required statuses.")
            end
        end
        return 0
    end

    function GiveHPIncrease(guid, SkipCheck)
        local healthConfig

        if IsTargetABoss(guid) == 1 then
            healthConfig = ConfigTable["Health"]["Bosses"]
        elseif SkipCheck then
            healthConfig = ConfigTable["Health"]["Enemies"]
            if next(ConfigTable["Health"]["Allies"]) ~= nil then
                healthConfig = ConfigTable["Health"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["Health"]["Allies"]) == nil then
                return
            else
                healthConfig = ConfigTable["Health"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            healthConfig = ConfigTable["Health"]["Enemies"]
        end

        local healthMultiplier = tonumber(healthConfig["HealthMultiplier"])

        -- 0 equals level-based scaling
        if healthMultiplier == 0 then
            local playerLevel = GetPartyLevel()
            local staticBoost = tonumber(healthConfig["StaticBoost"])
            local healthPerLevel = tonumber(healthConfig["HealthPerLevel"])
            healthMultiplier = 1 + staticBoost + healthPerLevel * playerLevel
        elseif healthMultiplier == 1 then -- Check if the configuration is enabled for this type of character as 1 equals no change
            return
        end

        -- Get the character's current max health and the boost parameters
        local entity = Ext.Entity.Get(guid)
        local handle = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
        local currentMaxHealth = entity and entity.Health.MaxHp
        local boostsContainer = entity and entity.BoostsContainer
        local increaseMaxHPEntries
        if boostsContainer then
            for _, boostEntry in ipairs(boostsContainer.Boosts) do
                if boostEntry.Type == "IncreaseMaxHP" then
                    increaseMaxHPEntries = boostEntry.Boosts
                    break
                end
            end
        end
        local isBoosted = false
        local isReset = false
        local isProgressionBoosted = false
        local boostParams

        if not (currentMaxHealth and boostsContainer) then
            print(string.format("DEBUG: Invalid entity or missing properties for Target: %s.", guid))
            return
        end

        if handle == "Citizen" or handle == "Refugee" then
            --print(string.format("DEBUG: Invalid Target: %s, Name: %s", guid, handle))
            return
        end

        if increaseMaxHPEntries then
            for _, entry in ipairs(increaseMaxHPEntries) do
                if entry.BoostInfo.Cause.Cause == "combatextender" then
                    isBoosted = true -- Set flag to true if a combatextender boost is found
                    boostParams = tonumber(entry.BoostInfo.Params.Params)
                elseif entry.BoostInfo.Cause.Cause == "reset" then
                    isReset = true -- Set flag to true if a reset boost is found
                elseif entry.BoostInfo.Cause.Type == "Progression" then
                    isProgressionBoosted = true
                end
            end
        end

        -- Calculate healthToUse and store it in the EntityHealth table if it's not already there
        local healthOverrides = {
            ["S_WYR_SkeletalDragon_67770922-5e0a-40c5-b3f0-67e8eb50493a"] = 600, -- Ansur
            ["S_UND_KethericCity_AdamantineGolem_2a5997fc-5f2a-4a13-b309-bed16da3b255"] = 450, -- Grym
            ["S_END_MindBrain_f8bb04a3-22e5-41b0-aed7-5dcf852343d1"] = 450 -- Elder Brain
        }

        if not EntityHealth[guid] then
            local baseHealth
            local healthToUse

            -- Check if there is a health override for the entity in the configuration
            if ConfigTable.Overrides and ConfigTable.Overrides[guid] and ConfigTable.Overrides[guid].HealthOverride then
                healthToUse = ConfigTable.Overrides[guid].HealthOverride
            else
                local entity = Ext.Entity.Get(guid)
                if not (entity and entity.BaseHp and entity.BaseHp.Vitality) then -- Early return if the entity or BaseHp.Vitality is not available
                    return
                end

                baseHealth = math.floor(entity.BaseHp.Vitality * 1.3) -- 1.3 multiplier is default for Tactician

                if isProgressionBoosted and currentMaxHealth < 100 then
                    healthToUse = currentMaxHealth
                else
                    healthToUse = baseHealth
                end
            end

            EntityHealth[guid] = healthToUse
        end

        local healthToUse = EntityHealth[guid]
        local desiredMaxHealth = math.ceil(healthToUse * healthMultiplier)
        local hpIncrease = desiredMaxHealth - healthToUse
        --print(string.format("DEBUG: Target: %s, Name: %s, healthToUse: %s, currentMaxHealth: %s, desiredMaxHealth: %s", guid, handle, healthToUse, currentMaxHealth, desiredMaxHealth))
        --print(string.format("DEBUG: Target: %s, Name: %s, isBoosted: %s, isReset: %s, isProgressionBoosted: %s", guid, handle, isBoosted, isReset, isProgressionBoosted))

        local hpBoost
        if guid == "S_GLO_Monitor_f65becd6-5cd7-4c88-b85e-6dd06b60f7b8" then -- Raphael exception as the normal approach doesn't work on him
            if not IsPartyInCombat() then
                return -- Return early if not in combat
            else
                local entity = Ext.Entity.Get(guid)
                local currentMaxHealth = entity.Health.MaxHp
                local currentMaxTemporaryHp = entity.Health.MaxTemporaryHp
                local currentTotalHealth = currentMaxHealth + currentMaxTemporaryHp
                local desiredTotalHealth = math.ceil(currentMaxHealth * healthMultiplier)
                local temporaryHpIncrease = desiredTotalHealth - currentTotalHealth
                hpBoost = "TemporaryHP(" .. temporaryHpIncrease .. ")" -- If in combat, use TemporaryHP for Raphael
            end
        else
            hpBoost = "IncreaseMaxHP(" .. hpIncrease .. ")"
        end

        -- As MaxHp persists in the savefile, but the boost is ephemeral
        if currentMaxHealth == desiredMaxHealth and not isReset and not isBoosted and not IsPartyInCombat() then
            if not EntityResetState[guid] then
                AddBoosts(guid, "IncreaseMaxHP(0)", "reset", "1")
                DebugPrint(string.format("DEBUG: Reset to baseline: %s, Name: %s", guid, handle))
                EntityResetState[guid] = true
            end
        end

        -- Only add the health increase if the character hasn't been boosted already
        if not isBoosted then
            if currentMaxHealth > 10000 or currentMaxHealth <= 0 then -- To deal with -1 health as well as Shrines with 129998 health
                return
            end

            if currentMaxHealth == desiredMaxHealth then
                --print(string.format("DEBUG: Health already matches desired value for Target: %s, Name: %s, currentMaxHealth: %s, desiredMaxHealth: %s", guid, handle, currentMaxHealth, desiredMaxHealth))
                return
            end
            --print(string.format("DEBUG: NOT BOOSTED AND MISMATCH Target: %s, Name: %s, currentMaxHealth: %s, desiredMaxHealth: %s", guid, handle, currentMaxHealth, desiredMaxHealth))

            -- Essentially we do a soft reset here
            if currentMaxHealth > desiredMaxHealth then
                if EntityResetState[guid] then
                    return
                else
                    print(string.format("DEBUG: Resetting: %s, Name: %s, currentMaxHealth: %s, desired: %s", guid, handle, currentMaxHealth, desiredMaxHealth))
                    AddBoosts(guid, "IncreaseMaxHP(0)", "reset", "1")
                    EntityResetState[guid] = true
                    return
                end
            end

            AddBoosts(guid, hpBoost, "combatextender", "1")
            print(string.format("DEBUG: Boosting: %s, Name: %s, currentMaxHealth: %s, desired: %s, x: %s", guid, handle, currentMaxHealth, desiredMaxHealth, healthMultiplier))
        else
            -- Check if there is a mismatch between the current and recalculated maximum health
            if currentMaxHealth ~= desiredMaxHealth and IsDead(guid) == 0 then
                local offset = math.abs(currentMaxHealth - desiredMaxHealth)

                if offset == 1 then
                    return
                end

                if EntityHealthAdjustment[guid] and not IsPartyInCombat() then -- Check if the guid is already in the EntityHealthAdjustment table
                    --print(string.format("DEBUG: EntityHealthAdjustment exists for Target: %s, Name: %s", guid, handle))
                    return
                else
                    EntityHealthAdjustment[guid] = true -- Mark this guid as having had an adjustment attempt
                end

                if currentMaxHealth < desiredMaxHealth then
                    DebugPrint(string.format("DEBUG: Adjusting: %s, Name: %s, hpBoost: %s, currentMaxHealth: %s, desired: %s, x: %s", guid, handle, offset, currentMaxHealth, desiredMaxHealth, healthMultiplier))
                    AddBoosts(guid, "IncreaseMaxHP(" .. offset .. ")", "combatextender", "1")
                end
            --else
                --EntityHealthAdjustment[guid] = nil
                --print(string.format("DEBUG: Target: %s currentMaxHealth: %s desiredMaxHealth: %s", guid, currentMaxHealth, desiredMaxHealth))
            end
        end
    end

    -- Passive Check: Add additional spells, passives and perhaps more in the future. This builds upon the CX_NAME passive structure such as CX_Fighter_Boost.
    -- You can also use any other passive from the game, or from other mods
    function CheckPassive(guid)
        local currentAct = Act

        -- Iterate over the passives
        for _, passive in ipairs(ConfigTable["Passives"]) do
            -- Check if the target has the current passive
            if HasPassive(guid, passive["PassiveName"]) == 1 then
                print(string.format("DEBUG: Target has %s", passive["PassiveName"]))

                -- Initialize cumulative lists for spells and extra passives
                local cumulativeSpells = {}
                local cumulativeExtraPassives = {}

                -- Check if the passive has an "Act" structure
                if passive["Act"] then
                    -- Accumulate spells and extra passives up to the current act
                    for act = 1, currentAct do
                        local actConfig = passive["Act"][tostring(act)]
                        if actConfig then
                            if actConfig["Spells"] then
                                for _, spell in ipairs(actConfig["Spells"]) do
                                    table.insert(cumulativeSpells, spell)
                                end
                            end
                            if actConfig["ExtraPassives"] then
                                for _, extraPassive in ipairs(actConfig["ExtraPassives"]) do
                                    table.insert(cumulativeExtraPassives, extraPassive)
                                end
                            end
                        end
                    end
                else
                    -- Use the existing spells and extra passives from the old configuration
                    cumulativeSpells = passive["Spells"] or {}
                    cumulativeExtraPassives = passive["ExtraPassives"] or {}
                end

                -- Process cumulative spells
                if #cumulativeSpells > 0 then
                    print("DEBUG: Spells to add: " .. table.concat(cumulativeSpells, ", "))
                    for _, spell in ipairs(cumulativeSpells) do
                        if HasSpell(guid, spell) == 0 then
                            AddBoosts(guid, string.format("UnlockSpell(%s,AddChildren,d136c5d9-0ff0-43da-acce-a74a07f8d6bf,,)", spell), "", "")
                        else
                            print(string.format("DEBUG: Target already has spell %s", spell))
                        end
                    end
                else
                    print(string.format("DEBUG: No spells for %s. Spells array is empty.", passive["PassiveName"]))
                end

                -- Process cumulative extra passives
                if #cumulativeExtraPassives > 0 then
                    print("DEBUG: Passives to add: " .. table.concat(cumulativeExtraPassives, ", "))
                    for _, extraPassive in ipairs(cumulativeExtraPassives) do
                        if HasPassive(guid, extraPassive) == 0 then
                            AddPassive(guid, extraPassive)
                        else
                            print(string.format("DEBUG: Target already has passive %s", extraPassive))
                        end
                    end
                else
                    print(string.format("DEBUG: No extra passives for %s. ExtraPassives array is empty.", passive["PassiveName"]))
                end
            end
        end
    end

    function CheckOverride(guid)
        -- Check if "Overrides" exists and is not empty
        if ConfigTable.Overrides and next(ConfigTable["Overrides"]) ~= nil then
            local override = ConfigTable["Overrides"][guid]
            if override then
                if override["Spells"] then
                    --print("DEBUG: Spells to add: " .. table.concat(override["Spells"], ", "))
                    for _, spell in ipairs(override["Spells"]) do
                        if HasSpell(guid, spell) == 0 then
                            AddBoosts(guid, string.format("UnlockSpell(%s,AddChildren,d136c5d9-0ff0-43da-acce-a74a07f8d6bf,,)", spell), "", "")
                        else
                            --print(string.format("DEBUG: Target already has spell %s", spell))
                        end
                    end
                end

                if override["Passives"] then
                    --print("DEBUG: Passives to add: " .. table.concat(override["Passives"], ", "))
                    for _, extraPassive in ipairs(override["Passives"]) do
                        if HasPassive(guid, extraPassive) == 0 then
                            AddPassive(guid, extraPassive)
                        else
                            --print(string.format("DEBUG: Target already has passive %s", extraPassive))
                        end
                    end
                end
            end
        end
    end

    function GiveSpellSlots(guid)
        if not ConfigTable.Passives or next(ConfigTable["Passives"]) == nil then -- Check if ConfigTable is not nil
                print("DEBUG: Failed to load or parse JSON. Ending SpellSlot boost function execution.")
            return
        end

        -- Define the passives we are interested in
        local passives = {"CX_Spells_L1", "CX_Spells_L2", "CX_Spells_L3", "CX_Spells_L4", "CX_Spells_L5", "CX_Spells_L6"}

        -- Iterate over the passives
        for _, passive in ipairs(passives) do
            -- Check if the target has the current passive
            if HasPassive(guid, passive) == 1 then
                -- Iterate over the Passives array in the ConfigTable
                for _, config in ipairs(ConfigTable.Passives) do
                    -- Check if the PassiveName matches the current passive
                    if config["PassiveName"] == passive then
                        -- Access the "ExtraSpellSlots" key in the config
                        local extraSpellSlots = config["ExtraSpellSlots"]
                        -- Check if ExtraSpellSlots is a number or an array
                        if type(extraSpellSlots) == "number" then
                            -- Handle the old format (ExtraSpellSlots is a number)
                            local boost = string.format("ActionResource(SpellSlot,%s,%s)", extraSpellSlots, string.sub(passive, -1))
                            AddBoosts(guid, boost, "combatextender", "1")
                        elseif type(extraSpellSlots) == "table" then
                            -- Handle the new format (ExtraSpellSlots is an array of strings)
                            for level, slots in ipairs(extraSpellSlots) do
                                local numSlots = tonumber(slots)
                                if numSlots > 0 then
                                    local boost = string.format("ActionResource(SpellSlot,%s,%s)", numSlots, level)
                                    AddBoosts(guid, boost, "combatextender", "1")
                                end
                            end
                        else
                            print("DEBUG: ExtraSpellSlots is neither a number nor an array. Skipping passive: " .. passive)
                        end
                    end
                end
            end
        end
    end

    -- Generic Action Point Boost
    function GiveActionPointBoost(guid, actionType)
        local actionPointConfig

        if IsTargetABoss(guid) == 1 then
            actionPointConfig = ConfigTable["ExtraAction"]["Bosses"][actionType]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["ExtraAction"]["Allies"]) == nil or next(ConfigTable["ExtraAction"]["Allies"][actionType]) == nil then
                return
            else
                actionPointConfig = ConfigTable["ExtraAction"]["Allies"][actionType]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            actionPointConfig = ConfigTable["ExtraAction"]["Enemies"][actionType]
        end

        local additional = tonumber(actionPointConfig["Additional"])

        -- Check if the configuration is enabled for this type of character
        if additional == 0 then
            return
        end

        local actionResource = (actionType == "Action") and "ActionPoint" or "BonusActionPoint"
        local actionPoints = string.format("ActionResource(%s,%s,0)", actionResource, additional)
        AddBoosts(guid, actionPoints, "combatextender", "1")
    end

    -- Movement Bonus in meters
    function GiveMovementBoost(guid)
        local movementConfig

        if IsSummon(guid) == 1 then
            return
        end

        if guid == "S_UND_KethericCity_AdamantineGolem_2a5997fc-5f2a-4a13-b309-bed16da3b255" or "S_CRE_GuardianOfFaith_5144e2e8-fbd7-41b3-a6fb-f4cf5759cb95" then
            return
        end

        if IsTargetABoss(guid) == 1 then
            movementConfig = ConfigTable["Movement"]["Bosses"]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["Movement"]["Allies"]) == nil then
                return
            else
                movementConfig = ConfigTable["Movement"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            movementConfig = ConfigTable["Movement"]["Enemies"]
        end

        local staticBoost = tonumber(movementConfig["StaticBoost"])

        if staticBoost == 0 then
            return
        end

        local movement = "ActionResource(Movement," .. staticBoost .. ",0)"
        AddBoosts(guid, movement, "combatextender", "1")
    end

    -- Armour Class
    function GiveACBoost(guid)
        local armourClassConfig

        if IsTargetABoss(guid) == 1 then
            armourClassConfig = ConfigTable["ArmourClass"]["Bosses"]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["ArmourClass"]["Allies"]) == nil then
                return
            else
                armourClassConfig = ConfigTable["ArmourClass"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            armourClassConfig = ConfigTable["ArmourClass"]["Enemies"]
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
        AddBoosts(guid, ac, "combatextender", "1")
    end

    -- Spell Save Difficulty Class
    function GiveSpellSaveDCBoost(guid)
        if not ConfigTable.SpellSaveDC or next(ConfigTable["SpellSaveDC"]) == nil then
            DebugPrint("DEBUG: Failed to load or parse JSON. Ending SpellSaveDC boost function execution.")
            return
        end

        local spellSaveDCConfig

        if IsTargetABoss(guid) == 1 then
            spellSaveDCConfig = ConfigTable["SpellSaveDC"]["Bosses"]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["SpellSaveDC"]["Allies"]) == nil then
                return
            else
                spellSaveDCConfig = ConfigTable["SpellSaveDC"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            spellSaveDCConfig = ConfigTable["SpellSaveDC"]["Enemies"]
        end

        local staticBoost = tonumber(spellSaveDCConfig["StaticBoost"])
        local boostPerIncrement = tonumber(spellSaveDCConfig["BoostPerIncrement"])
        local levelIncrement = tonumber(spellSaveDCConfig["LevelIncrement"])

        if staticBoost == 0 and boostPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(guid)
        local totalBoost = staticBoost + boostPerIncrement * math.floor(levelMultiplier / levelIncrement)

        local ssdc = "SpellSaveDC(" .. totalBoost .. ")"
        AddBoosts(guid, ssdc, "combatextender", "1")
    end

    function GiveAbilityPointBoost(guid)
        if not ConfigTable.AbilityPoints or next(ConfigTable["AbilityPoints"]) == nil then
            DebugPrint("DEBUG: Failed to load or parse JSON. Ending AbilityPoint boost function execution.")
            return
        end

        local abilitiesCpp = Ext.Entity.Get(guid).Stats.Abilities
        local spellCastingAbility = Ext.Entity.Get(guid).Stats.SpellCastingAbility
        local abilityNames = {"Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"}
        local abilityBoostConfig = ConfigTable["AbilityPoints"]["Enemies"]

        -- Determine the entity type and corresponding boost amount from the configuration
        if IsTargetABoss(guid) == 1 then
            abilityBoostConfig = ConfigTable["AbilityPoints"]["Bosses"]
        elseif IsTargetAnEnemy(guid) == 0 then
            abilityBoostConfig = ConfigTable["AbilityPoints"]["Allies"]
            if next(abilityBoostConfig) == nil then
                return
            end
        end

        -- Check if the configuration has the new format
        local staticBoost = tonumber(abilityBoostConfig["StaticBoost"]) or 0
        local boostPerIncrement = tonumber(abilityBoostConfig["BoostPerIncrement"]) or 0
        local levelIncrement = tonumber(abilityBoostConfig["LevelIncrement"]) or 0

        -- If all new format values are 0, fall back to the old format
        if staticBoost == 0 and boostPerIncrement == 0 and levelIncrement == 0 then
            abilityBoostConfig = abilityBoostConfig["Additional"] or 0
        else
            -- Calculate the total boost based on the new format
            local levelMultiplier = GetLevel(guid)
            abilityBoostConfig = staticBoost + boostPerIncrement * math.floor(levelMultiplier / levelIncrement)
        end

        -- Convert C++ array to Lua table, ignoring the first value
        local abilities = {}
        for i = 2, #abilitiesCpp do
            abilities[abilityNames[i-1]] = abilitiesCpp[i]
        end

        -- Sort abilities by value to find the top two
        local sortedAbilities = {}
        for name, value in pairs(abilities) do
            table.insert(sortedAbilities, {name = name, value = value})
        end
        table.sort(sortedAbilities, function(a, b) return a.value > b.value end)

        -- Check if SpellCastingAbility is one of the top two
        local abilitiesToBoost = {}
        local spellCastingBoosted = false

        for i = 1, 2 do
            if sortedAbilities[i] then
                table.insert(abilitiesToBoost, sortedAbilities[i])
                if sortedAbilities[i].name == spellCastingAbility then
                    spellCastingBoosted = true
                end
            end
        end

        -- If SpellCastingAbility is not among the top two, add it to the list of abilities to boost
        if not spellCastingBoosted and spellCastingAbility ~= "None" then
            table.insert(abilitiesToBoost, {name = spellCastingAbility, value = abilities[spellCastingAbility]})
            --printTable(abilitiesToBoost)
        end

        -- Apply boost to the selected abilities
        for _, abilityInfo in ipairs(abilitiesToBoost) do
            local abilityName = abilityInfo.name
            local currentAbilityValue = abilities[abilityName] or abilityInfo.value
            local boostAmount = abilityBoostConfig
            local finalAbilityValue = currentAbilityValue + boostAmount

            -- Ensure the final ability value is an even number
            if finalAbilityValue % 2 ~= 0 then
                boostAmount = boostAmount + 1
            end

            local boostString = string.format("Ability(%s,%d)", abilityName, boostAmount)
            --print(string.format("DEBUG: Ability boost: %s %s", abilityName, boostAmount))
            AddBoosts(guid, boostString, "combatextender", "1")
        end
    end

    -- Roll Bonus
    function GiveRollBonus(guid, rollType)
        local rollBonusConfig

        if IsTargetABoss(guid) == 1 then
            rollBonusConfig = ConfigTable["Rolls"]["Bosses"][rollType]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["Rolls"]["Allies"]) == nil then
                return
            else
                rollBonusConfig = ConfigTable["Rolls"]["Allies"][rollType]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            rollBonusConfig = ConfigTable["Rolls"]["Enemies"][rollType]
        end

        local staticRollBonus = tonumber(rollBonusConfig["StaticRollBonus"])
        local rollBonusPerIncrement = tonumber(rollBonusConfig["RollBonusPerIncrement"])
        local levelIncrement = tonumber(rollBonusConfig["LevelIncrement"])

        if staticRollBonus == 0 and rollBonusPerIncrement == 0 and levelIncrement == 0 then
            return
        end

        local levelMultiplier = GetLevel(guid)
        local totalRollBonus = staticRollBonus + rollBonusPerIncrement * math.floor(levelMultiplier / levelIncrement)

        -- Retrieve the BoostsContainer for the entity
        local boostsContainer = Ext.Entity.Get(guid).BoostsContainer
        local rollBonusBoosts
        if boostsContainer then
            for _, boostEntry in ipairs(boostsContainer.Boosts) do
                if boostEntry.Type == "RollBonus" then
                    rollBonusBoosts = boostEntry.Boosts
                    break
                end
            end
        end
        -- Check for existing boosts and remove them if necessary
        if rollBonusBoosts then
            for _, boost in ipairs(rollBonusBoosts) do
                if boost.BoostInfo and boost.BoostInfo.Cause and boost.BoostInfo.Cause.Cause then
                    local cause = boost.BoostInfo.Cause.Cause
                    if cause:find("CX_" .. string.upper(rollType) .. "_") then
                        DebugPrint(string.format("DEBUG: Removing existing boost: %s", cause))
                        RemoveStatus(guid, cause, "")
                    end
                end
            end
        end

        if totalRollBonus >= 1 and totalRollBonus <= 10 then -- Apply status if totalRollBonus is within the specified range
            local status = "CX_" .. string.upper(rollType) .. "_" .. totalRollBonus
            ApplyStatus(guid, status, -1)
            --print(string.format("DEBUG: APPLY CX: %s", guid))

        elseif totalRollBonus >= 11 then -- As the boosts for working text ingame only go to 10
            local rollBonus = "RollBonus(" .. rollType .. "," .. totalRollBonus .. ")"
            AddBoosts(guid, rollBonus, "combatextender", "1")
            --print(string.format("DEBUG: APPLY ALT CX: %s", guid))
        end
    end

    -- Damage Boost (for each attack)
    function GiveDamageBoost(guid)
        local damageConfig

        if IsTargetABoss(guid) == 1 then
            damageConfig = ConfigTable["Damage"]["Bosses"]
        elseif IsTargetAnEnemy(guid) == 0 then
            if next(ConfigTable["Damage"]["Allies"]) == nil then
                return
            else
                damageConfig = ConfigTable["Damage"]["Allies"]
            end
        elseif IsTargetAnEnemy(guid) == 1 then
            damageConfig = ConfigTable["Damage"]["Enemies"]
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
        AddBoosts(guid, damageBonus, "combatextender", "1")
    end

    function GiveLevel(guid)
        local reset = false

        -- Check if "Level" configuration is empty
        if not ConfigTable.Level or next(ConfigTable["Level"]) == nil then
            if ConfigTable.Level == nil then
                if not HasPrinted["GiveLevel"] then
                    DebugPrint("DEBUG: Failed to load or parse JSON. Ending Level function execution.")
                    HasPrinted["GiveLevel"] = true
                end
                return
            else
                reset = true
            end
        end

        local baseLevel = PersistentVars["baseLevel"][guid] or GetLevel(guid)
        PersistentVars["baseLevel"][guid] = baseLevel

        if reset then
            local entity = Ext.Entity.Get(guid)
            local currentLevel = GetLevel(guid)
            if currentLevel ~= baseLevel then
                -- Directly set the AvailableLevel.Level and EocLevel.Level properties
                entity.AvailableLevel.Level = baseLevel
                entity.EocLevel.Level = baseLevel

                -- Explicitly replicate changes for AvailableLevel and EocLevel
                Ext.Entity.Get(guid):Replicate("AvailableLevel")
                Ext.Entity.Get(guid):Replicate("EocLevel")

                DebugPrint(string.format("DEBUG: Level of entity %s reset to base level %d", guid, baseLevel))
            end
            return
        end

        local currentAct = Act
        local entityType = "Characters"

        if IsTargetABoss(guid) == 1 then
            entityType = "Bosses"
        end

        -- Attempt to get the configuration for the current act and entity type
        local actConfig = ConfigTable["Level"][entityType]["Act"][tostring(currentAct)]
        if not actConfig then
            DebugPrint(string.format("DEBUG: No Level configuration found for entity %s in act %d", guid, currentAct))
            return
        end

        local playerLevel = GetPartyLevel()
        -- local maxLevel = actConfig["MaxLevel"] or playerLevel
        local maxLevel = actConfig["MaxLevel"]
        local offset = actConfig["Offset"] or 0
        local currentLevel = GetLevel(guid)
        local desiredLevel = playerLevel + offset

        if desiredLevel > maxLevel then -- Ensure new level does not exceed max level
            desiredLevel = maxLevel
        end

        -- Check if there's an actual change to be made
        if desiredLevel > currentLevel then
            SetLevel(guid, desiredLevel)
            DebugPrint(string.format("DEBUG: Level of entity %s set to %d", guid, desiredLevel))
        end
    end

    function GetNearbyCharacters(radius)
        local sourceEntity = Ext.Entity.Get(Osi.GetHostCharacter())
        local nearbyCharacters = {}
        if sourceEntity then
            local pos = sourceEntity.Transform.Transform.Translate
            for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("BaseHp")) do
                if entity.ServerCharacter ~= nil then
                    local target = entity.Transform.Transform.Translate
                    local distance = math.sqrt((pos[1] - target[1])^2 + (pos[2] - target[2])^2 + (pos[3] - target[3])^2)
                    if distance <= radius then
                        table.insert(nearbyCharacters, {
                            Entity = entity,
                            Guid = entity.Uuid.EntityUuid,
                            Name = entity.ServerCharacter.Template.Name,
                            Distance = distance,
                            Handle = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle),
                        })
                    end
                end
            end
        end

        table.sort(nearbyCharacters, function(a,b) return a.Distance < b.Distance end)
        return nearbyCharacters
    end

    function ProcessNearbyCharacters()
        local nearbyCharacters = GetNearbyCharacters(150)
        for _, character in ipairs(nearbyCharacters) do
            local guid = character.Name .. "_" .. character.Guid
            if IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and CheckIfExcluded(guid) == 0 then
                GiveHPIncrease(guid, true)
                GiveLevel(guid)
                CheckOverride(guid)
            end
        end
    end

    function ProcessExistingEntities()
        local count = 0
        for guid, entity in pairs(Entities) do
            --local handle = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
            if IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and CheckIfExcluded(guid) == 0 then
                --print(string.format("DEBUG: BOOSTING: %s, Name: %s", guid, handle))
                GiveHPIncrease(guid, true)
                count = count + 1
            end
        end
        print(string.format("INFO: Processed %s entities while loading", count))
    end

    -- Apply CX_APPLIED Boost which includes CX_APPLIED Passive to each processed character
    -- This should prevent multiple boosts being granted to the same character
    local CX_APPLIED = "CX_APPLIED"

    function CleanupEntities()
        local count = 0
        for guid, entity in pairs(Entities) do
            if IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and CheckIfExcluded(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 1 then
                local handle = ""
                if entity.DisplayName and entity.DisplayName.NameKey and entity.DisplayName.NameKey.Handle and entity.DisplayName.NameKey.Handle.Handle then
                    handle = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
                end
                DebugPrint(string.format("DEBUG: Cleanup Target: %s, Name: %s", guid, handle))

                -- Retrieve the BoostsContainer for the entity
                local boostsContainer = Ext.Entity.Get(guid).BoostsContainer
                if not boostsContainer then
                    DebugPrint(string.format("DEBUG: No BoostsContainer found for entity %s", guid))
                    goto continue
                end

                local boostTypes = {"AC", "Ability", "ActionResource", "DamageBonus", "RollBonus", "SpellSaveDC"}
                for _, boostEntry in ipairs(boostsContainer.Boosts) do
                    -- Directly check if the Type is in the list of interest
                    local isTypeOfInterest = false
                    for _, typeOfInterest in ipairs(boostTypes) do
                        if boostEntry.Type == typeOfInterest then
                            isTypeOfInterest = true
                            break
                        end
                    end

                    if isTypeOfInterest then
                        for _, boost in ipairs(boostEntry.Boosts) do
                            local boostInfo = boost.BoostInfo
                            if boostInfo and boostInfo.Cause and boostInfo.Cause.Cause then
                                local cause = boostInfo.Cause.Cause
                                if boostEntry.Type == "RollBonus" and cause and cause ~= "" and cause:find("CX_") then
                                    RemoveStatus(guid, cause, "")
                                    DebugPrint(string.format("DEBUG: Removed boost: boostType: %s, %s", boostEntry.Type, cause))
                                elseif boostEntry.Type ~= "RollBonus" and boostInfo.Cause.Cause == "combatextender" then
                                    local boostParams = boostInfo.Params.Params
                                    local boostRemovalString = string.format("%s(%s)", boostEntry.Type, boostParams)
                                    RemoveBoosts(guid, boostRemovalString, 0, "combatextender", "1")
                                    DebugPrint(string.format("DEBUG: Removed boost: boostType: %s, boostParams: %s", boostEntry.Type, boostParams))
                                end
                            end
                        end
                    end
                end
                RemoveStatus(guid, CX_APPLIED, "")
                count = count + 1
            end
            ::continue::
        end
        print(string.format("INFO: Processed %s entities after combat.", count))
    end

    -- Damage Listener
    Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function (defender, attackerOwner, attacker2, damageType, damageAmount, damageCause, storyActionID)
        --print(string.format("DEBUG: defender: %s, attackerOwner: %s, attacker2: %s, damageType: %s, damageAmount: %s, damageCause: %s", defender, attackerOwner, attacker2, damageType, tostring(damageAmount), damageCause))
        if IsCharacter(defender) == 1 then
            local defenderName = Ext.Loca.GetTranslatedString(Ext.Entity.UuidToHandle(defender).DisplayName.NameKey.Handle.Handle) or "Unknown"
            local attackerName = Ext.Loca.GetTranslatedString(Ext.Entity.UuidToHandle(attacker2).DisplayName.NameKey.Handle.Handle) or "Unknown"
            local attackerOwnerName = Ext.Loca.GetTranslatedString(Ext.Entity.UuidToHandle(attackerOwner).DisplayName.NameKey.Handle.Handle) or "Unknown"

            local cause = damageCause or "Unknown Cause"
            local damageType = damageType or "Unknown Damage Type"
            local amount = damageAmount or "Unknown Amount"

            -- Determine which attacker name to print
            local attackerToPrint = (attackerName ~= attackerOwnerName) and attackerOwnerName or attackerName
            print(string.format("DAMAGE: Defender: %s, Attacker: %s, Type: %s, Damage: %s, Cause: %s", defenderName, attackerToPrint, damageType, tostring(amount), cause))
        end
    end)

    -- Continuous Listener
    Ext.Entity.Subscribe("ActionResources", function (entity, _, _)
        if entity.Uuid and entity.Uuid.EntityUuid then
            local uuid = entity.Uuid.EntityUuid
            local name = entity.ServerCharacter.Template.Name
            local guid = name .. "_" .. uuid
            local handle = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)

            -- Check if the entity is not already in the Entities table
            if not Entities[guid] then
                Entities[guid] = entity
                if Loaded and IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and CheckIfExcluded(guid) == 0 and IsPartySummon(guid) == 0 and not IsPartyInCombat() then
                    DebugPrint(string.format("DEBUG: Listener Target: %s, Name: %s", guid, handle))
                    GiveHPIncrease(guid, true)
                end
            end
        else
            DebugPrint("DEBUG: entity.Uuid or entity.Uuid.EntityUuid is nil")
        end
    end)


    function StartCXTimer() -- Don't forget to restart on CombatEnded
        if not IsPartyInCombat() then
            Osi.TimerLaunch("cx", 6000)
            --print("DEBUG: Starting timer")
        else
            DebugPrint("DEBUG: Won't start timer, a party member is in combat")
        end
    end


    Ext.Osiris.RegisterListener("TimerFinished", 1, "before", CXTimerFinished)

    -- Combat Listener
    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(guid, combatid)
        -- Check if ConfigTable is loaded properly
        if not ConfigTable or next(ConfigTable) == nil then
            print("ERROR: Failed to load or parse JSON.")
            return
        end

        CurrentCombat = combatid
      

        -- TODO: Add HasActiveStatus as second check?
        if IsCharacter(guid) == 0 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 0 and CheckIfExcluded(guid) == 0 then
            local isEnemy = IsTargetAnEnemy(guid)
            if isEnemy == 1 then
                print("DEBUG: S_Enemy: " .. guid)
                -- GiveHPIncrease(guid) -- This does work for the orbs spawning before meeting Balthazar but causes issues for the Act 3 opening fight
                -- ApplyStatus(guid, CX_APPLIED, -1)
            end
        elseif IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 0 and CheckIfExcluded(guid) == 0 then
            table.insert(CombatNPCS, guid)

            local isEnemy = IsTargetAnEnemy(guid)
            local isBoss = IsTargetABoss(guid)

            if isEnemy == 1 and isBoss == 0 then
                print("DEBUG: Enemy: " .. guid)
            elseif isEnemy == 1 and isBoss == 1 then
                print("DEBUG: Boss: " .. guid)
            else
                print("DEBUG: Ally: " .. guid)
            end

            CheckPassive(guid)
            CheckOverride(guid)
            GiveSpellSlots(guid)
            GiveHPIncrease(guid, false)
            GiveRollBonus(guid, "Attack")
            GiveRollBonus(guid, "SavingThrow")
            GiveACBoost(guid)
            GiveSpellSaveDCBoost(guid)
            GiveAbilityPointBoost(guid)
            GiveDamageBoost(guid)
            GiveMovementBoost(guid)
            GiveActionPointBoost(guid, "Action")
            GiveActionPointBoost(guid, "BonusAction")
            ApplyStatus(guid, CX_APPLIED, -1)
        end
    end)

    -- Order: SessionLoaded - SavegameLoaded - LevelGameplayStarted - Fade in from loading screen
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function (levelName, isEditorMode)
        Loaded = true -- Game has now fully loaded

        -- Identify Act and set variable
        if levelName == "WLD_Main_A" or levelName == "CRE_Main_A" or levelName == "TUT_Avernus_C" then
            Act = 1
            print("INFO: Act set to 1 for level: " .. levelName)
        elseif levelName == "SCL_Main_A" then
            Act = 2
            print("INFO: Act set to 2 for level: " .. levelName)
        elseif levelName == "BGO_Main_A" or levelName == "CTY_Main_A" then
            Act = 3
            print("INFO: Act set to 3 for level: " .. levelName)
        else
            Act = 1
            print("DEBUG: Act is not set for level: " .. levelName)
        end

        -- Combat Save Loading: We re-apply the boosts to all nearby characters that have status CX_APPLIED, which persists in the savefile
        -- 50 meters is beyond the range at which characters join the ongoing combat
        local nearbyCharacters = GetNearbyCharacters(100)
        print("INFO: Number of nearby characters: " .. #nearbyCharacters)
        for _, character in ipairs(nearbyCharacters) do
            local guid = character.Name .. "_" .. character.Guid
            if IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and HasAppliedStatus(guid, CX_APPLIED) == 1 and CheckIfExcluded(guid) == 0 then
                local isEnemy = IsTargetAnEnemy(guid)
                local isBoss = IsTargetABoss(guid)

                if isEnemy == 1 and isBoss == 0 then
                    print(string.format("DEBUG: Enemy: %s, Name: %s", guid, character.Handle))
                elseif isEnemy == 1 and isBoss == 1 then
                    print(string.format("DEBUG: Boss: %s, Name: %s", guid, character.Handle))
                else
                    print(string.format("DEBUG: Ally: %s, Name: %s", guid, character.Handle))
                end
                CheckPassive(guid)
                CheckOverride(guid)
                GiveSpellSlots(guid)
                GiveHPIncrease(guid, false)
                GiveRollBonus(guid, "Attack")
                GiveRollBonus(guid, "SavingThrow")
                GiveACBoost(guid)
                GiveSpellSaveDCBoost(guid)
                --GiveAbilityPointBoost(guid)
                GiveDamageBoost(guid)
                GiveMovementBoost(guid)
                GiveActionPointBoost(guid, "Action")
                GiveActionPointBoost(guid, "BonusAction")
            else
                --print("DEBUG: Invalid: " .. guid .. ", Name: " .. character.Name)
            end
        end
    end)



end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
