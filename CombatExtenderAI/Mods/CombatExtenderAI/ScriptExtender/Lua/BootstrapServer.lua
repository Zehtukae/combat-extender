local function OnSessionLoaded()
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function (levelName, isEditorMode)
        if levelName == "WLD_Main_A" then
            print("INFO: Activating CX AI archetype override")
            RequestSetBaseArchetype("S_UND_DuergarLoyalSergeant_0aeb5411-5f13-4263-acb0-87f0689de2e5", "duergar_melee") -- Sergeant Thrinn
            RequestSetBaseArchetype("S_UND_DuergarLoyalWry_dd93e23c-c62d-4927-9ea7-50e11621825e", "duergar_mage") -- Mind Master Dunnol
            RequestSetBaseArchetype("S_UND_DuergarLoyalGuard_02_cc942779-3d2d-4327-9704-c6c385c12c82", "duergar_ranged") -- Dalthar
            RequestSetBaseArchetype("S_UND_DuergarLoyalNervous_908f6096-360e-44dc-b2ff-63a7d32c015b", "duergar_ranged") -- Drar
            RequestSetBaseArchetype("S_UND_DuergarRebelBored_30fb7e6e-40d2-4e77-b5ea-887f8eb345c9", "duergar_ranged") -- Stone Guard Kur
            RequestSetBaseArchetype("S_UND_DuergarRaftCaptain_473ae3b0-d8e9-428d-9129-bbffe449b8ec", "duergar_melee") -- Corsair Greymon
            RequestSetBaseArchetype("S_UND_DuergarLoyalFocused_ccf9ef29-3d8e-4751-a7ae-203bec7352c3", "duergar_mage") -- Mind Master Fonmara
            RequestSetBaseArchetype("S_UND_DuergarRebelGreedy_379fd131-79ab-4588-a8f0-28cdb51546e3", "duergar_melee") -- Elder Brithvar
            RequestSetBaseArchetype("S_UND_DuergarRebelPatroller_01_0c7758f9-ed35-49cb-926c-8b24195ee978", "duergar_mage") -- Danna
            RequestSetBaseArchetype("S_UND_DuergarRebelPatroller_02_407307ff-6adb-488c-9576-534e2c158e29", "duergar_ranged") -- Mirthis
            RequestSetBaseArchetype("S_UND_DuergarRebel_AtPier_01_5ff28d97-e070-4805-a856-3112df670e1f", "duergar_melee") -- Stone Guard Orgarth
            RequestSetBaseArchetype("S_UND_DuergarRebel_AtPier_02_2dd2a840-35ff-4ed6-bf43-f9aae0e69c32", "duergar_mage") -- Morghal
            RequestSetBaseArchetype("S_UND_TheDrowNere_06bf05c5-216b-4eaf-91f5-8f1dd3d57f30", "duergar_mage") -- Nere
        end
    end)
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)