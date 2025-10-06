local function WhisperRespond(inst)
    if inst.components.talker then
        local script = _G.STRINGS.IE.WHISPER_RESPONSES[math.random(1, #_G.STRINGS.IE.WHISPER_RESPONSES)]
        inst.components.talker:Say(script)
    end
end

AddPlayerPostInit(function(inst)
    if not _G.TheNet:IsDedicated() then
        inst:DoTaskInTime(0, function() -- Waiting 1 tick to let replicas get created
            inst:AddComponent("paranoiamanager") -- Purely for tying new visuals to player sanity
            inst:AddComponent("paranoiaspooks")  -- Random spooks, tied to players sanity, doesn't require paranoiamanager
        end)
        inst:ListenForEvent("whispers_response", WhisperRespond) -- This will only appear for the client, others will not see the response, oh well...
    end
end)