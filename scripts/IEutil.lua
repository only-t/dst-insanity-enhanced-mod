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

_G.IE.PlayParanoidFootstep = function(inst, volume, ispredicted)
    local soundemitter = inst.SoundEmitter
    if soundemitter then
        local platform = inst:GetCurrentPlatform()

        local tile = inst.components.locomotor and inst.components.locomotor:TempGroundTile() or nil
        local tileinfo = tile and _G.GetTileInfo(tile) or nil

        if platform then
            soundemitter:PlaySound("paranoia/sfx/footsteps/run_"..platform.walksound, nil, volume or 1, ispredicted)

            if platform.second_walk_sound then
                soundemitter:PlaySound("paranoia/sfx/footsteps/run_"..platform.second_walk_sound, nil, volume or 1, ispredicted)
            end
		else
			local soundpath

			if tileinfo == nil then
				tile, tileinfo = inst:GetCurrentTileType()
				if tile and tileinfo then
					local x, y, z = inst.Transform:GetWorldPosition()
					local oncreep = _G.TheWorld.GroundCreep:OnCreep(x, y, z)
					local onsnow = not tileinfo.nogroundoverlays and _G.TheWorld.state.snowlevel > 0.15
					local onmud = not tileinfo.nogroundoverlays and _G.TheWorld.state.wetness > 15

					if not oncreep and _G.RoadManager and _G.RoadManager:IsOnRoad(x, 0, z) then
						tile = _G.WORLD_TILES.ROAD
						tileinfo = _G.GetTileInfo(_G.WORLD_TILES.ROAD) or tileinfo
					end

					soundpath = (oncreep and "paranoia/sfx/footsteps/run_web") or
						        (onsnow and "paranoia/sfx/footsteps/"..string.split(tileinfo.snowsound, "/")[3]) or
						        (onmud and "paranoia/sfx/footsteps/"..string.split(tileinfo.mudsound, "/")[3]) or
						        nil
				end
			end

			if soundpath then
				soundemitter:PlaySound(soundpath, nil, volume or 1, ispredicted)
			elseif tileinfo then
				soundpath = "paranoia/sfx/footsteps/"..string.split(tileinfo.runsound, "/")[3]
                soundemitter:PlaySound(soundpath, nil, volume or 1, ispredicted)
			end
		end
    end
end