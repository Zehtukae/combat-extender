local function OnSessionLoaded()
    print("Combat Extender Client")

    -- Update Loca
    Ext.Loca.UpdateTranslatedString("ha143856fg255bg49cbga1f4g6d318b04f0c2", "from Combat Extender") -- from Armour Class boost
    Ext.Loca.UpdateTranslatedString("h9c232218g5080g4ccdga0afg8ecd8891b00c", "from Combat Extender") -- from Ability boost
    Ext.Loca.UpdateTranslatedString("h932c15e0gb870g440bg9409g748d8baa90e3", "Combat Extender") -- From (Spell) DC Bonus
    Ext.Loca.UpdateTranslatedString("ha1f5a262g20d6g44fegbf9fgcd9023a800ca", "Combat Extender") -- Damage Bonus
    Ext.Loca.UpdateTranslatedString("h427b53ccgf9dbg45b9gb081gf11c93739b85", "Cold Acuity") -- Thunderous Acuity
    Ext.Loca.UpdateTranslatedString("hd49505ddgcd93g4a25ga7edgdcea8965e792", "When the wearer deals Cold damage, they gain Arcane Acuity")
    Ext.Loca.UpdateTranslatedString("hd00e1377g1caeg4956g86dbgd5232fcc9068", "Hat of Cold Acuity") -- Hat of Storm Scion's Power
    Ext.Loca.UpdateTranslatedString("h2f198d16g3b45g44d2gb8d1gd8bd150ca02c", "Squire's Ring") -- Ring of Colour Spray
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)