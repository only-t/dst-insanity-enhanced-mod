local assets = {
    Asset("ANIM", "anim/rocks.zip")
}

local function DoPlaySound(inst)
    PlayFootstep(inst, inst.volume)
end

local function TaskFn(inst)
    if GetTime() >= inst.starttime + inst.duration then
        inst:Remove()
        return
    end

    DoPlaySound(inst)

    inst.task = inst:DoTaskInTime(inst.period, TaskFn)
end

local function fn()
    local inst = CreateEntity()

    --[[ Non-networked entity ]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

	inst.entity:AddPhysics()
	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0.1)
	inst.Physics:SetDamping(0)
	inst.Physics:SetRestitution(0.5)
	inst.Physics:SetCollisionMask(COLLISION.WORLD)
	inst.Physics:SetSphere(0.5)

    if IE.DEV then
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("rocks")
        inst.AnimState:SetBuild("rocks")
        inst.AnimState:PlayAnimation("f1")
    end

    inst.task = nil

    inst.volume = 1
    inst.duration = 1   -- Default values
    inst.period = 0.3
    inst.speed = 5

    inst.Start = function(inst)
        inst.starttime = GetTime()

        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end

        inst.task = inst:DoTaskInTime(inst.period, TaskFn)

        if inst.speed ~= nil then
            inst.Physics:SetMotorVel(inst.speed, 0, 0)
        end
    end

    return inst
end

return Prefab("footstepsspook", fn, assets)