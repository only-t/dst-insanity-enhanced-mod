local placeholder_assets = {
    Asset("ANIM", "anim/rocks.zip")
}

local birdsink_assets = {
    Asset("ANIM", "anim/puffin.zip"),
    Asset("ANIM", "anim/puffin_water.zip"),
    Asset("ANIM", "anim/puffin_build.zip"),
    Asset("SOUND", "sound/birds.fsb")
}

-- local ocean_shadow_assets = {
--     Asset("ANIM", "anim/ocean_shadow.zip")
-- }

local function footsteps_fn()
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

    local function TaskFn(inst)
        if GetTime() >= inst.starttime + inst.duration then
            inst:Remove()
            return
        end

        PlayFootstep(inst, inst.volume)

        inst.task = inst:DoTaskInTime(inst.step_interval, TaskFn)
    end

    inst.Start = function(inst)
        inst.starttime = GetTime()

        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end

        inst.task = inst:DoTaskInTime(inst.step_interval, TaskFn)

        if inst.speed ~= nil then
            inst.Physics:SetMotorVel(inst.speed, 0, 0)
        end
    end

    return inst
end

local function birdsink_fn()
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

    local function Sink(inst)
        local splash = SpawnPrefab("splash")
        splash.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst.AnimState:PlayAnimation("flap_pre")
        inst.AnimState:PushAnimation("flap_loop")
        inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/medium")
        inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
        inst.SoundEmitter:PlaySound(inst.sounds.chirp)
        inst:DoTaskInTime(0.5, function()
            local splash = SpawnPrefab("crab_king_waterspout")
            splash.Transform:SetScale(0.5, 0.5, 0.5)
            splash.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:Remove()
        end)
    end

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

local function sfx_dummy_fn()
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

local function whisper_quiet_fn()
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

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.donetalkingfn = function(inst)
        inst:RemoveComponent("updatelooper")
        ThePlayer:PushEvent("whispers_response")
        inst:DoTaskInTime(0, function()
            inst:Remove()
        end)
    end

    local voice = "paranoia/sfx/whispers_quiet_voice"
    local voice_volume = 0.25
    local offset = 5
    local fadein_duration = 1.3
    local time = 0
    local text_duration = 4

    local started = false

    inst.dissapear_distance_from_player = 4

    inst.Appear = function(inst)
        local script = STRINGS.IE.WHISPERS_QUIET[math.random(1, #STRINGS.IE.WHISPERS_QUIET)]
        inst.components.talker:Say(script, text_duration, true, true, true, { 1, 1, 1, 0 }) -- Will increase alpha in the update fn
        inst.SoundEmitter:PlaySound(voice, "whispers_LP", 0)
        started = true
        time = 0
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
        local player = ThePlayer or nil
        if player and inst:GetDistanceSqToInst(player) <= inst.dissapear_distance_from_player then
            inst.components.talker:ShutUp()
            return
        end

        if started then
            time = time + dt
            local t = math.min(time / fadein_duration, 1)
            inst.components.talker.widget.text:SetColour({ 1, 1, 1, 0.16 * t })
            inst.SoundEmitter:SetVolume("whispers_LP", voice_volume * t)

            inst.components.talker.widget:SetOffset(Vector3(-offset + math.random() * offset * 2, (-400 - offset) + math.random() * offset * 2, 0))
        end
    end)

    return inst
end

local function whisper_loud_fn()
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

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 0
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.donetalkingfn = function(inst)
        inst:RemoveComponent("updatelooper")
        ThePlayer:PushEvent("whispers_response")
        inst:DoTaskInTime(0, function()
            inst:Remove()
        end)
    end

    local function offset_curve(x)
        return 1 - math.sqrt(x / 1.2)
    end

    local function size_curve(x)
        if x <= 0.05 then
            return 0.5 + 10 * x
        else
            return 1 - math.pow(x / 1.2 - 0.05, 2)
        end
    end

    local voice = "paranoia/sfx/whispers_loud_voice"
    local time = 0
    local text_duration = 2
    local offset_duration = 1

    inst.dissapear_distance_from_player = 4

    inst.Appear = function(inst)
        local script = STRINGS.IE.WHISPERS_LOUD[math.random(1, #STRINGS.IE.WHISPERS_LOUD)]
        inst.components.talker:Say(script, text_duration, true, true, true, { 1, 1, 1, 0 }) -- Will increase alpha in the update fn
        inst.SoundEmitter:PlaySound(voice, "whispers_loud")
        time = 0
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
        local player = ThePlayer or nil
        if player and inst:GetDistanceSqToInst(player) <= inst.dissapear_distance_from_player then
            inst.components.talker:ShutUp()
            return
        end

        time = time + dt
        local size_t = math.min(time / text_duration, 1)
        local offset_t = math.min(time / offset_duration, 1)

        local offset = offset_curve(offset_t) * 60
        inst.components.talker.widget:SetOffset(Vector3(-offset + math.random() * offset * 2, (-400 - offset) + math.random() * offset * 2, 0))

        local fontsize = size_curve(size_t) * 40
        inst.components.talker.widget.text:SetSize(fontsize)

        local alpha = size_curve(size_t)
        inst.components.talker.widget.text:SetColour({ 1, 1, 1, alpha })
    end)

    return inst
end

local function spooky_bubbles_fn()
    local inst = CreateEntity()

    --[[ Non-networked entity ]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    if IE.DEV then -- This is not the actual bubbles vfx, it's only a spawner with a sound emitter
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("rocks")
        inst.AnimState:SetBuild("rocks")
        inst.AnimState:PlayAnimation("f1")
    end

    inst.duration = 14 -- How long this spook will stay visible
    inst.dissapear_distance_from_player = 16
    inst.period = 0.7
    inst._start_time = nil

    inst.Appear = function(inst)
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end

        inst._start_time = GetTime()

        if inst.SoundEmitter:PlayingSound("bubble_loop") then
            inst.SoundEmitter:KillSound("bubble_loop")
        end

        inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble_LP", "bubble_loop", 1)
        inst.SoundEmitter:SetParameter("bubble_loop", "intensity", 0.5)

        inst.task = inst:DoPeriodicTask(inst.period, function()
            if inst._start_time + inst.duration <= GetTime() then
                inst.task:Cancel()
                inst.task = nil
                inst.SoundEmitter:KillSound("bubble_loop")
                inst:DoTaskInTime(0.5, function()
                    inst:Remove()
                end)

                return
            end

            inst.task.period = inst.period + 0.3 * (GetTime() - inst._start_time) / inst.duration

            local fx = SpawnPrefab("crab_king_bubble"..tostring(math.random(1, 3)))
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end)
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
        local player = ThePlayer or nil
        if player and inst:GetDistanceSqToInst(player) <= inst.dissapear_distance_from_player then
            inst._start_time = inst._start_time - inst.duration -- Finish the task
        end
    end)

    return inst
end

-- local function ocean_shadow_fn()
--     local inst = CreateEntity()

--     --[[ Non-networked entity ]]
--     inst.entity:SetCanSleep(false)
--     inst.persists = false

--     inst.entity:AddTransform()
--     inst.entity:AddPhysics()
--     inst.entity:AddAnimState()
--     inst.entity:AddSoundEmitter()

--     --Initialize physics
-- 	inst.Physics:SetMass(1)
-- 	inst.Physics:SetFriction(0.1)
-- 	inst.Physics:SetDamping(0)
-- 	inst.Physics:SetRestitution(0.5)
-- 	inst.Physics:SetCollisionMask(COLLISION.WORLD)
-- 	inst.Physics:SetSphere(0.5)

--     inst.AnimState:SetBank("ocean_shadow")
--     inst.AnimState:SetBuild("ocean_shadow")
--     inst.AnimState:PlayAnimation("appear")

--     inst.Appear = function(inst)

--     end

--     return inst
-- end

return Prefab("footsteps", footsteps_fn, placeholder_assets),
       Prefab("birdsink", birdsink_fn, birdsink_assets),
       Prefab("sfx_dummy", sfx_dummy_fn, placeholder_assets),
       Prefab("whisper_quiet", whisper_quiet_fn, placeholder_assets),
       Prefab("whisper_loud", whisper_loud_fn, placeholder_assets),
       Prefab("spooky_bubbles", spooky_bubbles_fn, placeholder_assets)
    --    Prefab("ocean_shadow", ocean_shadow_fn, ocean_shadow_assets)