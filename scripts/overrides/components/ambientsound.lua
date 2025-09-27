local AmbientSound = require("components/ambientsound")
local old_AmbientSound_ctor = AmbientSound._ctor
AmbientSound._ctor = function(self, ...)
    old_AmbientSound_ctor(self, ...)

    local PARANOIA_SOUND = "paranoia/music/ambiance"
    local _paranoiaparam = 0

	self.inst.SoundEmitter:PlaySound(PARANOIA_SOUND, "PARANOIA", 0)

    local old_AmbientSound_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, ...)
        old_AmbientSound_OnUpdate(self, ...)

	    self.inst.SoundEmitter:SetParameter("SANITY", "sanity", 0) -- Never play insanity ambiance

        local player = _G.ThePlayer
        local sanity = player ~= nil and player.replica.sanity or nil
        local paranoiaparam = (sanity ~= nil and sanity:IsInsanityMode()) and (1 - sanity:GetPercent()) or 0
        if _paranoiaparam ~= paranoiaparam then
	        self.inst.SoundEmitter:SetParameter("PARANOIA", "paranoia", paranoiaparam)
            _paranoiaparam = paranoiaparam
        end
    end
end