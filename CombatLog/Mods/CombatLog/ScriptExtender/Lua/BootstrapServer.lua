local function OnSessionLoaded()
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
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)