-- local SGwilson = require("stategraphs/SGwilson")
-- local old_wilson_idle_state = SGwilson.states["idle"]
-- if old_wilson_idle_state then
--     local old_wilson_idle_onenter = old_wilson_idle_state.onenter
--     old_wilson_idle_state.onenter = function(inst, ...)
--         local old_IsInsane = inst.components.sanity.IsInsane
--         inst.components.sanity.IsInsane = function() return false end -- Is this stupid? Is this cursed? maybe...

--         if old_wilson_idle_onenter then
--             old_wilson_idle_onenter(inst, ...)
--         end

--         inst.components.sanity.IsInsane = old_IsInsane
--     end
-- else
--     _G.IE.modprint(_G.IE.WARN, "Tried overriding a state but it doesn't seem to exist!",
--                                "stategraph - SGwilson",
--                                "state - idle")
-- end