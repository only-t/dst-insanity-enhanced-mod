local assets = {
    Asset("ANIM", "anim/rocks.zip")
}

local function fn()
    local inst = CreateEntity()

    --[[ Non-networked entity ]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    if IE.DEV then
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("rocks")
        inst.AnimState:SetBuild("rocks")
        inst.AnimState:PlayAnimation("f1")
    end

    inst.sound = nil
    inst.volume = 1

    inst.Play = function(inst)
        if inst.sound ~= nil then
            inst.SoundEmitter:PlaySound(inst.sound, nil, inst.volume)
        end

        inst:Remove()
    end

    return inst
end

return Prefab("sfx_dummy", fn, assets)