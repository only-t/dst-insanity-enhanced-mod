local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PushAnimation("idle", true)
        end
    },

    State{
        name = "glide",
		tags = { "idle", "flight" },

        onenter = function(inst)
			inst:AddTag("NOCLICK")
            inst:AddTag("NOBLOCK")

            if not inst.AnimState:IsCurrentAnimation("glide") then
                inst.AnimState:PlayAnimation("glide", true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
			inst.DynamicShadow:Enable(false)
        end,

        timeline = {
            TimeEvent(1 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.flyin)
            end)
        },

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
            end

            if y <= 0.1 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.AnimState:PlayAnimation("land")

                inst:Land()

                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("glide")
        end,

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
            inst:RemoveTag("NOBLOCK")
			inst.DynamicShadow:Enable(true)
		end
    }
}

return StateGraph("puffin_sharkfood", states, {  }, "glide")