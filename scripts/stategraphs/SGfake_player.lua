local function DoRunSounds(inst)
    if inst.sg.mem.footsteps > 3 then
        IE.PlayParanoidFootstep(inst, 0.6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        IE.PlayParanoidFootstep(inst, 1, true)
    end
end

local events = {
    EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        if is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run_start")
        end
    end)
}

local states = {
    State({
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PushAnimation("idle_loop", true)
        end
    }),
    State({
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
			inst.sg.mem.footsteps = 0

            inst.components.locomotor:RunForward()

			inst.AnimState:PlayAnimation("run_pre")
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                IE.PlayParanoidFootstep(inst, nil, true)
            end)
        },

        events = {
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end)
        }
    }),
    State({
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.AnimState:PlayAnimation("run_loop", true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline = {
            TimeEvent(7 * FRAMES, function(inst)
                DoRunSounds(inst)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                DoRunSounds(inst)
            end)
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end
    }),
    State({
        name = "run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			inst.AnimState:PlayAnimation("run_pst")
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        }
    }),
    State({
        name = "chop_pre",
        tags = { "chopping" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("chop")
                end
            end)
        }
    }),
    State({
        name = "chop",
        tags = { "chopping", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline = {
            TimeEvent(2 * FRAMES, function(inst)
                inst:PushTargetWorkResponse() -- This plays the animation of working for the target entity e.g. tree hit
            end)
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        }
    }),
    State({
        name = "mine_start",
        tags = { "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end)
        }
    }),
    State({
        name = "mine",
        tags = { "mining", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickaxe_loop")
            inst.AnimState:PushAnimation("pickaxe_pst")
        end,

        timeline = {
            TimeEvent(7 * FRAMES, function(inst)
                inst:PushTargetWorkResponse() -- This plays the animation of working for the target entity e.g. tree hit
            end)
        },

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", true)
                end
            end)
        }
    })
}

return StateGraph("fake_player", states, events, "idle")