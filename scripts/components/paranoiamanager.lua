require("mathutil")

-- local function OnEnterDark(self)
--     self.in_darkness = true
-- end

-- local function OnEnterLight(self)
--     self.in_darkness = false
-- end

-- local function OnNightVision(self, nightvision)
--     if nightvision then
--         self.darkness_immune = true
--     else
--         self.darkness_immune = false
--     end
-- end

-- Desmos:
-- -\frac{\cos\left(3x\pi\right)}{2}+0.5\left\{0\le x\le\frac{1}{3}\right\}
-- 1-\left(1.5x-0.5\right)^{2}\left\{\frac{1}{3}\le x\le1\right\}
local function DistortionCurve(x)
    if x < 0 or x > 1 then
        return 0
    end

    if x <= 1 / 3 then
        return -math.cos(3 * x * PI) / 2 + 0.5
    else
        return 1 - math.pow(1.5 * x - 0.5, 2)
    end
end

local function Transition(self, into, time) -- HOLY SHIT, it turned out sooo smoooth...
    self.transitioning_into = into
    self.is_transitioning = true
    self.transition_time = time
    self.transition_curtime = 0
    self.mode = into

    if self.mode == SANITY_MODE_INSANITY then
        local sanity = self.sanity and self.sanity:GetPercent() or 0
        local new_stage
        if sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE6] then
            new_stage = IE.PARANOIA_STAGES.STAGE6
        elseif sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE5] then
            new_stage = IE.PARANOIA_STAGES.STAGE5
        elseif sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE4] then
            new_stage = IE.PARANOIA_STAGES.STAGE4
        elseif sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE3] then
            new_stage = IE.PARANOIA_STAGES.STAGE3
        elseif sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE2] then
            new_stage = IE.PARANOIA_STAGES.STAGE2
        elseif sanity <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1] then
            new_stage = IE.PARANOIA_STAGES.STAGE1
        else
            new_stage = IE.PARANOIA_STAGES.STAGE0
        end

        self:ChangeParanoiaStage(new_stage)
    else
        self:ChangeParanoiaStage(IE.PARANOIA_STAGES.STAGE0)
    end
end

local function OnSanityDelta(inst, data)
    local self = inst.components.paranoiamanager
    if self.mode ~= data.sanitymode then
        Transition(self, data.sanitymode, IE.SHADER_MODE_TRANSITION_SPEED)
        return
    end

    if self.is_transitioning or data.sanitymode == SANITY_MODE_LUNACY then
        return
    end

    local new_stage
    if data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE6] then
        new_stage = IE.PARANOIA_STAGES.STAGE6
    elseif data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE5] then
        new_stage = IE.PARANOIA_STAGES.STAGE5
    elseif data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE4] then
        new_stage = IE.PARANOIA_STAGES.STAGE4
    elseif data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE3] then
        new_stage = IE.PARANOIA_STAGES.STAGE3
    elseif data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE2] then
        new_stage = IE.PARANOIA_STAGES.STAGE2
    elseif data.newpercent <= IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1] then
        new_stage = IE.PARANOIA_STAGES.STAGE1
    else
        new_stage = IE.PARANOIA_STAGES.STAGE0
    end

    self:ChangeParanoiaStage(new_stage)

    local strength = 1 - math.min(1, data.newpercent / IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1])
    local sharpness = IE.SHADER_PARAM_LIMITS.SHARPNESS * strength
    local monochromacy = IE.SHADER_PARAM_LIMITS.MONOCHROMACY * strength
    self:SetShaderColorParams(sharpness, monochromacy)
end

local ParanoiaManager = Class(function(self, inst)
    self.inst = inst

    if inst.replica.sanity == nil then
        IE.modprint(IE.WARN, "Trying to add ParanoiaManager but that entity doesn't have the Sanity replica!",
                             "inst - "..tostring(inst))
        inst:DoTaskInTime(0, function() -- Wait 1 tick to let the component get fully created
            inst:RemoveComponent("paranoiamanager") -- Then remove it
        end)

        return
    end

    self.sanity = inst.replica.sanity
    self.current_stage = IE.PARANOIA_STAGES.STAGE0

    -- Sanity mode transitioning
    self.mode = SANITY_MODE_INSANITY
    self.is_transitioning = false
    self.transitioning_into = nil
    self.transition_time = nil
    self.transition_curtime = nil

    -- Hearbeat
    self.do_heartbeat = true
    self.heartbeat_sfx = "paranoia/sfx/heartbeat"
    self.heartbeat_cooldown = 0
    self.heartbeat_cooldown_override = nil
    self.heartbeat_time = 0
    self.heartbeat_volume = 0
    self.volume_target = nil -- Used for custom heartbeat volume easing
    self.old_volume_target = nil -- Used for easing back into normal volume
    self.old_volume = nil
    self.volume_change_curtime = 0
    self.volume_change_duration = 4 -- In seconds
    self.volume_target_reached = nil

    -- Screen distortions
    self.distorting = false
    self.distortion_time = 2
    self.distortion_curtime = nil

    inst:StartUpdatingComponent(self)
end)

function ParanoiaManager:OnRemoveEntity()
    self:OnRemoveFromEntity()
end

function ParanoiaManager:OnRemoveFromEntity()
    self:ChangeParanoiaStage(0)

    self.inst:RemoveEventCallback("sanitydelta", OnSanityDelta)

    self:SetShaderDistortionParams(0, 0)
    self:SetShaderColorParams(0, 0)
    self:DisableShader()
end

function ParanoiaManager:Init()
    self.inst:ListenForEvent("sanitydelta", OnSanityDelta)
    OnSanityDelta(self.inst, { newpercent = self.sanity:GetPercent(), sanitymode = self.sanity:GetSanityMode() })

    self:EnableShader()
end

function ParanoiaManager:EnableShader()
    self.shader_enabled = true
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.ParanoiaDistortions, true)
end

function ParanoiaManager:DisableShader()
    self.shader_enabled = false
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.ParanoiaDistortions, false)
end

function ParanoiaManager:IsShaderEnabled()
    return self.shader_enabled
end

function ParanoiaManager:StopHeartbeat()
    self.do_heartbeat = false
end

function ParanoiaManager:ResumeHeartbeat()
    self.do_heartbeat = true
end

function ParanoiaManager:PushHeartbeatVolume(volume, change_speed)
    if volume ~= nil then
        self.old_volume_target = volume
    end

    if change_speed ~= nil then
        self.volume_change_duration = change_speed
    end
    
    self.volume_target = volume
    self.old_volume = self.heartbeat_volume

    self.volume_change_curtime = 0
    self.volume_target_reached = nil
end

function ParanoiaManager:OverrideHeartbeatCooldown(cooldown)
    self.heartbeat_cooldown_override = cooldown
end

function ParanoiaManager:DoHeartbeat(volume, nodistortion, ignoredeath)
    if not ignoredeath and self.inst.replica.health and (self.inst.replica.health:IsDead() or self.inst.replica.health:GetPercent() <= 0) then
        return -- Don't play the sound if the player is dead, duh...
    end

    self.inst.SoundEmitter:PlaySound(self.heartbeat_sfx, nil, volume)

    if not nodistortion then
        self:DistortEdges()
    end
end

function ParanoiaManager:DistortEdges()
    self.distorting = true
    self.distortion_curtime = 0
end

function ParanoiaManager:SetShaderColorParams(sharpness, monochromacy)
    if monochromacy == nil then
        PostProcessor:SetUniformVariable(UniformVariables.PARANOIA_PARAMS1, sharpness)
    elseif sharpness == nil then
        return
    end

    PostProcessor:SetUniformVariable(UniformVariables.PARANOIA_PARAMS1, sharpness, monochromacy)
end

function ParanoiaManager:SetShaderDistortionParams(distortion_radius, distortion_strength)
    if distortion_strength == nil then
        PostProcessor:SetUniformVariable(UniformVariables.PARANOIA_PARAMS2, distortion_radius)
    elseif distortion_radius == nil then
        return
    end

    PostProcessor:SetUniformVariable(UniformVariables.PARANOIA_PARAMS2, distortion_radius, distortion_strength)
end

function ParanoiaManager:ChangeParanoiaStage(new_stage)
    if self.current_stage ~= new_stage then
        self.inst:PushEvent("change_paranoia_stage", { newstage = new_stage, oldstage = self.current_stage })

        self.current_stage = new_stage
    end
end

function ParanoiaManager:OnUpdate(dt)
    if self.transition_time ~= nil and self.transitioning_into ~= nil then
        self.transition_curtime = self.transition_curtime + dt

        local strength = 1 - math.min(1, self.sanity:GetPercent() / IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1])
        local sharpness = IE.SHADER_PARAM_LIMITS.SHARPNESS * strength
        local monochromacy = IE.SHADER_PARAM_LIMITS.MONOCHROMACY * strength
        if self.transitioning_into == SANITY_MODE_LUNACY then -- Target is 0
            if self.transition_curtime >= self.transition_time then -- Finish shader transition
                self:SetShaderColorParams(0, 0)
                self:SetShaderDistortionParams(0, 0)

                self.transitioning_into = nil
                self.is_transitioning = false
                self.transition_time = nil
                self.transition_curtime = nil

                return
            end

            sharpness = Lerp(sharpness, 0, self.transition_curtime / self.transition_time)
            monochromacy = Lerp(sharpness, 0, self.transition_curtime / self.transition_time)
        elseif self.transitioning_into == SANITY_MODE_INSANITY then -- Target is whatever out sanity is at rn
            if self.transition_curtime >= self.transition_time then
                self:SetShaderColorParams(sharpness, monochromacy)

                self.transitioning_into = nil
                self.is_transitioning = false
                self.transition_time = nil
                self.transition_curtime = nil

                return
            end

            sharpness = Lerp(0, sharpness, self.transition_curtime)
            monochromacy = Lerp(0, monochromacy, self.transition_curtime)
        end

        self:SetShaderColorParams(sharpness, monochromacy)
    end

    if self.mode == SANITY_MODE_LUNACY then
        return
    end

    if self.do_heartbeat then
        local paranoia_lerp = 1 - math.min(1, self.sanity:GetPercent() / IE.PARANOIA_THRESHOLDS[IE.HEARTBEAT_START_STAGE])

        if self.volume_target ~= nil then
            if not self.volume_target_reached then
                self.volume_change_curtime = self.volume_change_curtime + dt

                local t = self.volume_change_curtime / self.volume_change_duration
                self.heartbeat_volume = Lerp(self.old_volume, self.volume_target, math.min(1, t))

                if t >= 1 then
                    self.heartbeat_volume = self.volume_target
                    self.volume_target_reached = true
                    self.volume_change_curtime = 0
                    self.old_volume = nil
                end
            end
        else
            if self.old_volume_target ~= nil then
                if self.current_stage < IE.HEARTBEAT_START_STAGE then
                    self.volume_change_curtime = self.volume_change_curtime + dt

                    local t = self.volume_change_curtime / self.volume_change_duration
                    self.heartbeat_volume = Lerp(self.old_volume_target, 0, math.min(1, t))

                    if t >= 1 then
                        self.heartbeat_volume = 0
                        self.volume_change_curtime = 0
                        self.old_volume_target = nil
                        self.volume_target_reached = nil
                    end
                else
                    local target_volume = Lerp(IE.HEARTBEAT_MIN_VOLUME, IE.HEARTBEAT_MAX_VOLUME, paranoia_lerp)

                    self.volume_change_curtime = self.volume_change_curtime + dt

                    local t = self.volume_change_curtime / self.volume_change_duration
                    self.heartbeat_volume = Lerp(self.old_volume_target, target_volume, math.min(1, t))

                    if t >= 1 then
                        self.heartbeat_volume = target_volume
                        self.volume_change_curtime = 0
                        self.old_volume_target = nil
                        self.volume_target_reached = nil
                    end
                end
            elseif self.current_stage >= IE.HEARTBEAT_START_STAGE then
                self.heartbeat_volume = Lerp(IE.HEARTBEAT_MIN_VOLUME, IE.HEARTBEAT_MAX_VOLUME, paranoia_lerp)
            end
        end

        if self.current_stage >= IE.HEARTBEAT_START_STAGE then
            self.heartbeat_cooldown = Lerp(IE.HEARTBEAT_MAX_COOLDOWN, IE.HEARTBEAT_MIN_COOLDOWN, paranoia_lerp)
        else
            self.heartbeat_cooldown = 0
        end

        if self.heartbeat_cooldown_override ~= nil then
            self.heartbeat_cooldown = self.heartbeat_cooldown_override
        end

        if self.heartbeat_cooldown > 0 and self.heartbeat_volume > 0 then
            self.heartbeat_time = self.heartbeat_time + dt

            if self.heartbeat_time >= self.heartbeat_cooldown then
                self:DoHeartbeat(self.heartbeat_volume)
                self.heartbeat_time = 0
            end
        end
    end

    if self.distorting then
        self.distortion_curtime = self.distortion_curtime + dt

        local strength = 1 - math.min(1, self.sanity:GetPercent() / IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE3])
        strength = strength * DistortionCurve(self.distortion_curtime / self.distortion_time)
        local distortion_radius = IE.SHADER_PARAM_LIMITS.DISTORION_RADIUS
        local distortion_strength = math.floor(IE.SHADER_PARAM_LIMITS.DISTORTION_STRENGTH * strength)

        self:SetShaderDistortionParams(distortion_radius, distortion_strength)

        if self.distortion_curtime >= self.distortion_time then
            self.distortion_curtime = 0
            self.distorting = false
        end
    end
end

return ParanoiaManager