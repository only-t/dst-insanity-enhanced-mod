require("mathutil")

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

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.donetalkingfn = function(inst)
        inst:RemoveComponent("updatelooper")
        inst:DoTaskInTime(0, function()
            inst:Remove()
        end)
    end

    local offset = 5
    local fadein_duration = 1.3
    local time = 0
    local text_duration = 4

    local started = false

    inst.Appear = function(inst)
        local script = STRINGS.IE.WHISPERS_QUIET[math.random(1, #STRINGS.IE.WHISPERS_QUIET)]
        inst.components.talker:Say(script, text_duration, true, true, true, { 1, 1, 1, 0 }) -- Will increase alpha in the update fn
        started = true
        time = 0
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
        if started then
            time = time + dt
            local t = math.min(time / fadein_duration, 1)
            inst.components.talker.widget.text:SetColour({ 1, 1, 1, Lerp(0, 0.16, math.min(t, 1)) })

            inst.components.talker.widget:SetOffset(Vector3(-offset + math.random() * offset * 2, (-400 - offset) + math.random() * offset * 2, 0))
        end
    end)

    return inst
end

return Prefab("whisper_quiet", fn, assets)