local function OnSessionLoaded()
    print("Combat Extender Client")

    -- Update Loca
    Ext.Loca.UpdateTranslatedString("ha143856fg255bg49cbga1f4g6d318b04f0c2", "from Combat Extender") -- from Armour Class boost
    Ext.Loca.UpdateTranslatedString("h932c15e0gb870g440bg9409g748d8baa90e3", "Combat Extender") -- From (Spell) DC Bonus
    Ext.Loca.UpdateTranslatedString("ha1f5a262g20d6g44fegbf9fgcd9023a800ca", "Combat Extender") -- Damage Bonus
    end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)