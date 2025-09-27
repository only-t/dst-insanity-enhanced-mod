local assets = {
    Asset("ANIM", "anim/puffin.zip"),
    Asset("ANIM", "anim/puffin_water.zip"),
    Asset("ANIM", "anim/puffin_build.zip"),
    Asset("SOUND", "sound/birds.fsb")
}

local function Sink(inst)
    local splash = SpawnPrefab("splash")
    splash.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.AnimState:PlayAnimation("flap_pre")
    inst.AnimState:PushAnimation("flap_loop")
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/medium")
    inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
    inst.SoundEmitter:PlaySound(inst.sounds.chirp)
    inst:DoTaskInTime(0.5, function()
        local splash = SpawnPrefab("splash")
        splash.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end)
end

local function fn()
    local inst = CreateEntity()

    --[[ Non-networked entity ]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()

    --Initialize physics
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(COLLISION.GROUND)
    inst.Physics:SetMass(1)
    inst.Physics:SetSphere(1)

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("puffin")
    inst.AnimState:SetBuild("puffin_build")
    inst.AnimState:PlayAnimation("idle")

    inst.DynamicShadow:SetSize(1, 0.75)
    inst.DynamicShadow:Enable(false)

    inst.sounds = {
        takeoff = "turnoftides/birds/takeoff_puffin",
        chirp = "turnoftides/birds/chirp_puffin",
        flyin = "dontstarve/birds/flyin"
    }

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGpuffin_sharkfood")

    inst.Land = function(inst)
        inst.DynamicShadow:Enable(true)
        inst.AnimState:SetBank("puffin_water")
            
        if inst.front_fx == nil then
            inst.front_fx = SpawnPrefab("float_fx_front")
            
            inst.front_fx.entity:SetParent(inst.entity)
            inst.front_fx.Transform:SetPosition(0, 0.07, 0)

            inst.front_fx.AnimState:PlayAnimation("idle_front_small", true)
        end

        if inst.back_fx == nil then
            inst.back_fx = SpawnPrefab("float_fx_back")

            inst.back_fx.entity:SetParent(inst.entity)
            inst.back_fx.Transform:SetPosition(0, 0.07, 0)

            inst.back_fx.AnimState:PlayAnimation("idle_back_small", true)
        end

        inst.AnimState:SetFloatParams(-0.05, 1.0, 1)

        local splash = SpawnPrefab("splash")
        splash.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:DoTaskInTime(2, Sink)
    end

    return inst
end

return Prefab("puffin_sharkfood", fn, assets)