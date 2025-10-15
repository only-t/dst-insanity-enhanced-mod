if _G.IE.DEV then
    _G.IE.inspect = require("inspect")
end

_G.IE.OverrideListenForEventFn = function(inst, event, source, fn, fn_index)
    if inst == nil then
        IE.modprint(IE.WARN, "Trying to override an event function but the entity is nil!",
                             "event - "..event)
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
            IE.modprint(IE.WARN, "Trying to override an event function but that entity doesn't listen for that event!",
                                 "event - "..event,
                                 "source - "..tostring(source))
            return
        end

        if fn_index < 0 then
            fn_index = #event_fns + fn_index + 1
        end

        if fn_index < 1 then
            IE.modprint(IE.WARN, "Trying to override an event function but the given function index is invalid!",
                                 "event - "..event,
                                 "source - "..tostring(source),
                                 "fn_index - "..tostring(fn_index),
                                 "#event_fns - "..tostring(#event_fns))
            return
        end

        local old_fn = event_fns[fn_index]
        event_fns[fn_index] = function(...)
            fn(old_fn, ...)
        end
    else
        IE.modprint(IE.WARN, "Trying to override an event function but that entity doesn't listen for that event!",
                             "event - "..event
                             "source - "..tostring(source))
    end

    local event_listening = inst.event_listening[event]
    if event_listening then
        local event_fns = event_listening[source]

        if event_fns == nil then
            IE.modprint(IE.WARN, "Trying to override an event function but that entity doesn't listen for that event!",
                                 "event - "..event,
                                 "source - "..tostring(source))
            return
        end

        if fn_index < 0 then
            fn_index = #event_fns + fn_index + 1
        end

        if fn_index < 1 then
            IE.modprint(IE.WARN, "Trying to override an event function but the given function index is invalid!",
                                 "event - "..event,
                                 "source - "..tostring(source),
                                 "fn_index - "..tostring(fn_index),
                                 "#event_fns - "..tostring(#event_fns))
            return
        end

        local old_fn = event_fns[fn_index]
        event_fns[fn_index] = function(...)
            fn(old_fn, ...)
        end
    else
        IE.modprint(IE.WARN, "Trying to override an event function but that entity doesn't listen for that event!",
                             "event - "..event
                             "source - "..tostring(source))
    end
end