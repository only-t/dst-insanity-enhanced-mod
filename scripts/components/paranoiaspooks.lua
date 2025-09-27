local Spooks = require("IEspooks")

local ParanoiaSpooks = Class(function(self, inst)
	self.inst = inst

    self.paranoia = 0
    self.paranoia_sources = {  }
    
    self:Start()
end)

-- function ParanoiaSpooks:OnSave()
--     return {
        
--     }
-- end

-- function ParanoiaSpooks:OnLoad(data)
    
-- end

function ParanoiaSpooks:Start()
    self.inst:StartUpdatingComponent(self)
end

function ParanoiaSpooks:Stop()
    self.inst:StopUpdatingComponent(self)
end

function ParanoiaSpooks:Spook(type, data)
    if type == nil then -- We can run random spooks but they need to have default parameters
        type = IE.PARANOIA_SPOOK_TYPES[IE.PARANOIA_SPOOK_TYPES_KEYS[math.random(1, #IE.PARANOIA_SPOOK_TYPES_KEYS)]]
        data = {  }
    end

    if type == IE.PARANOIA_SPOOK_TYPES.TREECHOP then
        Spooks.TreeChoppingSpook(self, data)
    elseif type == IE.PARANOIA_SPOOK_TYPES.FOOTSTEPS then
        Spooks.FootstepsSpook(self, data)
    elseif type == IE.PARANOIA_SPOOK_TYPES.FOOTSTEPS_RUSH then
        Spooks.FootstepsRushSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.BIRDSINK then
        Spooks.OceanSinkBirdSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.SCREECH then
        Spooks.ScreechSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.WHISPER_QUIET then
        Spooks.WhisperQuiet(self, data)
    elseif type == IE.PARANOIA_SPOOK_TYPES.WHISPER_LOUD then
        Spooks.WhisperLoud(self, data)
    -- elseif type == IE.PARANOIA_SPOOK_TYPES.WHISPER_LOUD then
        -- Spooks.WhisperLoud(self, data)
    end
end

function ParanoiaSpooks:OnUpdate(dt)
    local sanity = self.inst.replica.sanity and self.inst.replica.sanity:GetPercent() or 1
    local paranoia_start = IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1]
    if sanity <= paranoia_start then
        self.paranoia_sources.sanity = 1 - sanity / paranoia_start
    end

    for source, amount in ipairs(self.paranoia_sources) do
        self.paranoia = self.paranoia + amount * dt
    end
end

return ParanoiaSpooks