AddPlayerPostInit(function(inst)
    if not _G.TheNet:IsDedicated() then
        inst:DoTaskInTime(0, function() -- Waiting 1 tick to let replicas get created
            inst:AddComponent("paranoiamanager") -- Purely for tying new visuals to players sanity
            inst.components.paranoiamanager:Init()
            
            inst:AddComponent("paranoiaspooks")  -- Random spooks, tied to players sanity, doesn't require paranoiamanager
            inst.components.paranoiaspooks:Init()
        end)
    end
end)