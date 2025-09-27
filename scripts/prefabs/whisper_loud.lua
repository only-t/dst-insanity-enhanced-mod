local assets = {
    Asset("ANIM", "anim/rocks.zip")
}

local function curve(x)
    if x <= 0.1 then
        return 10 * x
    else
        return (0.3 + math.pow((x - 1) / 0.9, 6)) / 1.3
    end
end

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

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 20
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.donetalkingfn = function(inst)
        inst:RemoveComponent("updatelooper")
        inst:DoTaskInTime(0, function()
            inst:Remove()
        end)
    end

    local time = 0
    local text_duration = 2

    inst.Appear = function(inst)
        local script = STRINGS.IE.WHISPERS_LOUD[math.random(1, #STRINGS.IE.WHISPERS_LOUD)]
        inst.components.talker:Say(script, text_duration, true, true, true, { 1, 1, 1, 0 }) -- Will increase alpha in the update fn
        time = 0
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
        time = time + dt
        local t = math.min(time / text_duration, 1)
        t = curve(t)
        inst.components.talker.widget.text:SetColour({ 1, 1, 1, t })

        local offset = 32 * t
        inst.components.talker.widget:SetOffset(Vector3(-offset + math.random() * offset * 2, (-400 - offset) + math.random() * offset * 2, 0))

        local fontsize = 50 * t
        inst.components.talker.widget.text:SetSize(fontsize)
    end)

    return inst
end

return Prefab("whisper_loud", fn, assets)