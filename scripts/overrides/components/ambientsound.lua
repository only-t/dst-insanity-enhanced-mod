require("mathutil")

local AmbientSound = require("components/ambientsound")
local old_AmbientSound_ctor = AmbientSound._ctor
AmbientSound._ctor = function(self, ...)
    old_AmbientSound_ctor(self, ...)

    local PARANOIA_SOUND = "paranoia/ambience/void"
    local _paranoiaparam = 0

    local old_volume = nil
    local old_volume_target = nil
    local volume_target = nil
    local volume_target_reached = false
    local volume_change_duration = nil
    local volume_change_curtime = 0

	self.inst.SoundEmitter:PlaySound(PARANOIA_SOUND, "paranoia_amb")
    self.inst.SoundEmitter:SetParameter("paranoia_amb", "PARANOIA", 0)

    local old_AmbientSound_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, dt, ...)
        old_AmbientSound_OnUpdate(self, dt, ...)

	    self.inst.SoundEmitter:SetParameter("SANITY", "sanity", 0) -- Never play insanity ambience
        
        if volume_target ~= nil then
            if not volume_target_reached then
                volume_change_curtime = volume_change_curtime + dt

                local t = volume_change_curtime / volume_change_duration
                _paranoiaparam = _G.Lerp(old_volume, volume_target, math.min(1, t))

                if t >= 1 then
                    _paranoiaparam = volume_target
                    volume_target_reached = true
                    volume_change_curtime = 0
                    old_volume = nil
                end
            end
        else
            if old_volume_target ~= nil then
                local player = _G.ThePlayer
                local sanity = player ~= nil and player.replica.sanity or nil
                local sanity_percent = (sanity ~= nil and sanity:IsInsanityMode()) and sanity:GetPercent() or 1
                local paranoiaparam = (1 - math.min(1, sanity_percent / _G.IE.PARANOIA_THRESHOLDS[_G.IE.PARANOIA_STAGES.STAGE1])) * _G.IE.CURRENT_SETTINGS[_G.IE.MOD_SETTINGS.SETTINGS.INSANITY_AMBIENCE_INTENSITY.ID] / 10
                volume_change_curtime = volume_change_curtime + dt

                local t = volume_change_curtime / volume_change_duration
                _paranoiaparam = _G.Lerp(old_volume_target, paranoiaparam, math.min(1, t))

                if t >= 1 then
                    _paranoiaparam = paranoiaparam
                    volume_change_curtime = 0
                    old_volume_target = nil
                    volume_target_reached = nil
                end
            else
                local player = _G.ThePlayer
                local sanity = player ~= nil and player.replica.sanity or nil
                local sanity_percent = (sanity ~= nil and sanity:IsInsanityMode()) and sanity:GetPercent() or 1
                _paranoiaparam = (1 - math.min(1, sanity_percent / _G.IE.PARANOIA_THRESHOLDS[_G.IE.PARANOIA_STAGES.STAGE1])) * _G.IE.CURRENT_SETTINGS[_G.IE.MOD_SETTINGS.SETTINGS.INSANITY_AMBIENCE_INTENSITY.ID] / 10
            end
        end

        self.inst.SoundEmitter:SetParameter("paranoia_amb", "PARANOIA", _paranoiaparam)
    end

    self.PushParanoiaVolume = function(self, volume, change_speed)
        old_volume = _paranoiaparam
        old_volume_target = volume_target
        volume_target_reached = false
        volume_target = volume
        volume_change_curtime = 0
        volume_change_duration = change_speed
    end
end