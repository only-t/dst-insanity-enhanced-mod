local AmbientSound = require("components/ambientsound")
local old_AmbientSound_ctor = AmbientSound._ctor
AmbientSound._ctor = function(self, ...)
    old_AmbientSound_ctor(self, ...)

    local PARANOIA_SOUND = "paranoia/ambience/void"
    local _paranoiaparam = 0

	self.inst.SoundEmitter:PlaySound(PARANOIA_SOUND, "paranoia_amb")
    self.inst.SoundEmitter:SetParameter("paranoia_amb", "PARANOIA", 0)

    local old_AmbientSound_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, ...)
        old_AmbientSound_OnUpdate(self, ...)

	    self.inst.SoundEmitter:SetParameter("SANITY", "sanity", 0) -- Never play insanity ambience

        local player = _G.ThePlayer
        local sanity = player ~= nil and player.replica.sanity or nil
        local sanity_percent = (sanity ~= nil and sanity:IsInsanityMode()) and sanity:GetPercent() or 1
        local paranoiaparam = (1 - math.min(1, sanity_percent / _G.IE.PARANOIA_THRESHOLDS[_G.IE.PARANOIA_STAGES.STAGE1])) * 0.65

        if _paranoiaparam ~= paranoiaparam then
	        self.inst.SoundEmitter:SetParameter("paranoia_amb", "PARANOIA", paranoiaparam)
            _paranoiaparam = paranoiaparam
        end
    end

    self.PushParanoiaVolume = function(self)

    end
end