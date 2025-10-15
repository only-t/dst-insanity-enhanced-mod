-- local SGwilson_client = require("stategraphs/SGwilson_client")
-- local old_wilson_idle_state = SGwilson_client.states["idle"]
-- if old_wilson_idle_state then
--     local old_wilson_idle_onenter = old_wilson_idle_state.onenter
--     old_wilson_idle_state.onenter = function(inst, ...)

--         if old_wilson_idle_onenter then
--             old_wilson_idle_onenter(inst, ...)
--         end

--         if inst.AnimState:IsCurrentAnimation("idle_sanity_pre") or inst.AnimState:IsCurrentAnimation("idle_sanity_loop") then
--             inst.AnimState:PlayAnimation("idle_loop")
--         end
--     end
-- else
--     _G.IE.modprint(_G.IE.WARN, "Tried overriding a state but it doesn't seem to exist!",
--                                "stategraph - SGwilson_client",
--                                "state - idle")
-- end