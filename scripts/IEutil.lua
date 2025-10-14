if _G.IE.DEV then
    _G.IE.inspect = require("inspect")
end

_G.IE.OverrideListenForEventFn = function(inst, event, source, fn, fn_index)
    if inst == nil then
        -- modprint()
        return
    end

    source = source or inst

    if fn_index == nil or fn_index == 0 then
        fn_index = 1
    end

    local event_listeners = source.event_listeners[event]
    if event_listeners then
        local event_fns = event_listeners[inst]

        if event_fns == nil then
            -- modprint()
            return
        end

        if fn_index < 0 then
            fn_index = #event_fns + fn_index + 1
        end

        if fn_index < 1 then
            -- modprint()
            return
        end

        local old_fn = event_fns[fn_index]
        event_fns[fn_index] = function(...)
            fn(old_fn, ...)
        end
    else
        -- modprint()
    end

    local event_listening = inst.event_listening[event]
    if event_listening then
        local event_fns = event_listening[source]

        if event_fns == nil then
            -- modprint()
            return
        end

        if fn_index < 0 then
            fn_index = #event_fns + fn_index + 1
        end

        if fn_index < 1 then
            -- modprint()
            return
        end

        local old_fn = event_fns[fn_index]
        event_fns[fn_index] = function(...)
            fn(old_fn, ...)
        end
    else
        -- modprint()
    end
end