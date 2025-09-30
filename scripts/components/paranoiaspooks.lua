local Spooks = require("IEspooks")

local function PickASpook(self)
    local isnight = TheWorld.state.isnight
    local isday = not TheWorld.state.isnight
    local isplayerindark = self.inst:IsInLight()
    local canplayerseeindark = CanEntitySeeInDark(self.inst)
    local isplayeronboat = self.inst:GetCurrentPlatform() ~= nil
    local isincombat = (GetTime() - self.lastfighttime < 6)

    local _node_id = TheWorld.Map:GetNodeIdAtPoint(self.inst.Transform:GetWorldPosition())
    local currentbiome = TheWorld.topology.ids[_node_id]

    -- local i = TheWorld.Map:GetNodeIdAtPoint(ThePlayer.Transform:GetWorldPosition()) print("Node (" .. tostring(i) .. "): " .. tostring(TheWorld.topology.ids[i]))
end

local function CheckAction(player)
    if player:HasTag("attack") then
        local target = player.replica.combat:GetTarget()
        if target and
        target:HasTag("_combat") and
        not ((target:HasTag("prey") and not target:HasTag("hostile")) or
        target:HasTag("bird") or
        target:HasTag("butterfly") or
        target:HasTag("shadow") or
        target:HasTag("shadowchesspiece") or
        target:HasTag("noepicmusic") or
        target:HasTag("thorny") or
        target:HasTag("smashable") or
        target:HasTag("wall") or
        target:HasTag("engineering") or
        target:HasTag("smoldering") or
        target:HasTag("veggie")) then
            if target:HasTag("shadowminion") or target:HasTag("abigail") then
                local follower = target.replica.follower
                if not (follower and follower:GetLeader() == player) then
                    self.lastfighttime = GetTime()
                end
            else
                self.lastfighttime = GetTime()
            end
        end
    end
end

local ParanoiaSpooks = Class(function(self, inst)
	self.inst = inst

    self.paranoia = 0
    self.paranoia_threshold = 3
    self.paranoia_sources = {  }

    self.spook_pending = false
    self.next_spook = nil

    self.lastfighttime = 0

    inst:ListenForEvent("performaction", CheckAction)
    
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
    -- if type == nil then -- We can run random spooks but they need to have default parameters
    --     type = IE.PARANOIA_SPOOK_TYPES[IE.PARANOIA_SPOOK_TYPES_KEYS[math.random(1, #IE.PARANOIA_SPOOK_TYPES_KEYS)]]
    --     data = {  }
    -- end

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
    end
end

function ParanoiaSpooks:OnUpdate(dt)
    if self.spook_pending then -- Do a spook next opportune time, don't add paranoia
        
        return
    end

    local sanity = self.inst.replica.sanity and self.inst.replica.sanity:GetPercent() or 1
    local paranoia_start = IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1]
    if sanity <= paranoia_start then
        self.paranoia_sources.sanity = 1 - sanity / paranoia_start
    end

    for source, amount in ipairs(self.paranoia_sources) do
        self.paranoia = self.paranoia + amount * dt
    end

    if self.paranoia_threshold <= self.paranoia then
        self.spook_pending = true
        self.next_spook = PickASpook(self)
    end
end

return ParanoiaSpooks