local function WhisperRespond(inst)
    if inst.components.talker then
        local script = _G.STRINGS.IE.WHISPER_RESPONSES[math.random(1, #_G.STRINGS.IE.WHISPER_RESPONSES)]
        inst.components.talker:Say(script)
    end
end

AddPlayerPostInit(function(inst)
    if not _G.TheNet:IsDedicated() then
        inst:AddComponent("paranoiamanager") -- Purely for tying new visuals to player sanity
        inst:AddComponent("paranoiaspooks")  -- Random spooks, tied to players sanity, doesn't require paranoiamanager
        inst:ListenForEvent("whispers_response", WhisperRespond)
    end
end)