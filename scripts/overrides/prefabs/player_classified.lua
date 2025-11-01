local function OnGhostModeDirty(inst)
    if inst._parent and inst._parent.components.paranoiaspooks then
        if inst.isghostmode:value() then
            inst._parent.components.paranoiaspooks:_OnDeath()
        else
            inst._parent.components.paranoiaspooks:_OnRevive()
        end
    end
end

local function RegisterNetListeners(inst)
    inst:ListenForEvent("isghostmodedirty", OnGhostModeDirty)
end

AddPrefabPostInit("player_classified", function(inst)
    if not _G.TheNet:IsDedicated() then
        inst:DoStaticTaskInTime(0, RegisterNetListeners)
    end
end)