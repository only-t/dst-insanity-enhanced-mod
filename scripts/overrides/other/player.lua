

AddPlayerPostInit(function(inst)
    if not _G.TheNet:IsDedicated() then
        inst:AddComponent("paranoiamanager") -- Purely for tying new visuals to player sanity
        inst:AddComponent("paranoiaspooks")  -- Random spooks, tied to players sanity, doesn't require paranoiamanager
    end
end)