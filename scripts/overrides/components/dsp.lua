local paranoia_dsp = {
    [1] = { -- <60% sanity
        lowdsp = {
            ["set_music"] = 23000,
            ["set_ambience"] = 23000,
            ["set_sfx/set_ambience"] = 23000,
            ["set_sfx/movement"] = 23000,
            ["set_sfx/creature"] = 23000,
            ["set_sfx/player"] = 23000,
            ["set_sfx/voice"] = 23000,
            ["set_sfx/sfx"] = 23000,
            ["set_ambience/cloud"] = 23000
        },
        duration = 2
    },
    [2] = { -- <50% sanity
        lowdsp = {
            ["set_music"] = 21000,
            ["set_ambience"] = 21000,
            ["set_sfx/set_ambience"] = 21000,
            ["set_sfx/movement"] = 21000,
            ["set_sfx/creature"] = 21000,
            ["set_sfx/player"] = 21000,
            ["set_sfx/voice"] = 21000,
            ["set_sfx/sfx"] = 21000,
            ["set_ambience/cloud"] = 21000
        },
        duration = 2
    },
    [3] = { -- <40% sanity
        lowdsp = {
            ["set_music"] = 19000,
            ["set_ambience"] = 19000,
            ["set_sfx/set_ambience"] = 19000,
            ["set_sfx/movement"] = 19000,
            ["set_sfx/creature"] = 19000,
            ["set_sfx/player"] = 19000,
            ["set_sfx/voice"] = 19000,
            ["set_sfx/sfx"] = 19000,
            ["set_ambience/cloud"] = 19000
        },
        duration = 2
    },
    [4] = { -- <30% sanity
        lowdsp = {
            ["set_music"] = 16000,
            ["set_ambience"] = 16000,
            ["set_sfx/set_ambience"] = 16000,
            ["set_sfx/movement"] = 16000,
            ["set_sfx/creature"] = 16000,
            ["set_sfx/player"] = 16000,
            ["set_sfx/voice"] = 16000,
            ["set_sfx/sfx"] = 16000,
            ["set_ambience/cloud"] = 16000
        },
        duration = 2
    },
    [5] = { -- <20% sanity
        lowdsp = {
            ["set_music"] = 12000,
            ["set_ambience"] = 12000,
            ["set_sfx/set_ambience"] = 12000,
            ["set_sfx/movement"] = 12000,
            ["set_sfx/creature"] = 12000,
            ["set_sfx/player"] = 12000,
            ["set_sfx/voice"] = 12000,
            ["set_sfx/sfx"] = 12000,
            ["set_ambience/cloud"] = 12000
        },
        duration = 2
    },
    [6] = { -- <15% sanity, insane
        lowdsp = {
            ["set_music"] = 8000,
            ["set_ambience"] = 8000,
            ["set_sfx/set_ambience"] = 8000,
            ["set_sfx/movement"] = 8000,
            ["set_sfx/creature"] = 8000,
            ["set_sfx/player"] = 8000,
            ["set_sfx/voice"] = 8000,
            ["set_sfx/sfx"] = 8000,
            ["set_ambience/cloud"] = 8000
        },
        duration = 2
    }
}

local DSP = require("components/dsp")
local old_DSP_ctor = DSP._ctor
DSP._ctor = function(self, ...)
    local _activatedplayer = nil

    local function OnParanoiaStageChanged(inst, data)
        if data.oldstage ~= 0 then
            inst:PushEvent("popdsp", paranoia_dsp[data.oldstage])

            if data.oldstage == 3 then
                _G.TheMixer:PopMix("paranoia_stage3")
            end

            if data.oldstage == 4 then
                _G.TheMixer:PopMix("paranoia_stage4")
            end

            if data.oldstage >= 5 and data.newstage < 5 then
                _G.TheMixer:PopMix("paranoia_stage5")
            end
        end
        
        if data.newstage ~= 0 then
            inst:PushEvent("pushdsp", paranoia_dsp[data.newstage])

            if data.newstage == 3 then
                _G.TheMixer:PushMix("paranoia_stage3")
            elseif data.newstage == 4 then
                _G.TheMixer:PushMix("paranoia_stage4")
            elseif data.newstage >= 5 and data.oldstage < 5 then
                _G.TheMixer:PushMix("paranoia_stage5")
            end
        end
    end

    old_DSP_ctor(self, ...)

    _G.IE.OverrideListenForEventFn(self.inst, "playeractivated", nil, function(old_fn, inst, player, ...)
        if old_fn then
            old_fn(inst, player, ...)
        end

        player:DoTaskInTime(1, function() -- [TODO] Fix?
            if _activatedplayer == player then
                return
            elseif _activatedplayer and _activatedplayer.entity:IsValid() then
                if player.components.paranoiamanager then
                    inst:RemoveEventCallback("change_paranoia_stage", OnParanoiaStageChanged, player)
                end
            end
            _activatedplayer = player

            if player.components.paranoiamanager then
                inst:ListenForEvent("change_paranoia_stage", OnParanoiaStageChanged, player)
                OnParanoiaStageChanged(inst, { oldstage = _G.IE.PARANOIA_STAGES.STAGE0, newstage = player.components.paranoiamanager.current_stage })
            end
        end)
    end)

    _G.IE.OverrideListenForEventFn(self.inst, "playerdeactivated", nil, function(old_fn, inst, player, ...)
        if old_fn then
            old_fn(inst, player, ...)
        end

        if player.components.paranoiamanager then
            inst:RemoveEventCallback("change_paranoia_stage", OnParanoiaStageChanged, player)
        end
        
        if player == _activatedplayer then
            _activatedplayer = nil
        end
    end)
end