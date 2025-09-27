local function TreeChoppingSpook(self, data)
    if data == nil then
        data = {  }
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, IE.PARANOIA_SPOOK_PARAMS.TREECHOP.MAX_DIST_FROM_PLAYER, { "evergreens" })

    local far_ents = {  }
    for i, ent in ipairs(ents) do
        if self.inst:GetDistanceSqToInst(ent) >= IE.PARANOIA_SPOOK_PARAMS.TREECHOP.MIN_DIST_FROM_PLAYER * IE.PARANOIA_SPOOK_PARAMS.TREECHOP.MIN_DIST_FROM_PLAYER then
            table.insert(far_ents, ent)
        end
    end
    
    if #far_ents <= 0 then return end

    local tree = far_ents[math.random(#far_ents)]

    if tree == nil then return end

    local chop_anim = "chop_short"
    local old_anim = "sway1_loop_short"
    if tree.AnimState:IsCurrentAnimation("sway2_loop_short") then
        chop_anim = "chop_short"
        old_anim = "sway2_loop_short"
    elseif tree.AnimState:IsCurrentAnimation("sway1_loop_normal") then
        chop_anim = "chop_normal"
        old_anim = "sway1_loop_normal"
    elseif tree.AnimState:IsCurrentAnimation("sway2_loop_normal") then
        chop_anim = "chop_normal"
        old_anim = "sway2_loop_normal"
    elseif tree.AnimState:IsCurrentAnimation("sway1_loop_tall") then
        chop_anim = "chop_tall"
        old_anim = "sway1_loop_tall"
    elseif tree.AnimState:IsCurrentAnimation("sway2_loop_tall") then
        chop_anim = "chop_tall"
        old_anim = "sway2_loop_tall"
    else
        return -- None of the above are playing meaning we shouldn't interfere
    end

    tree.AnimState:PlayAnimation(chop_anim)
    tree.AnimState:PushAnimation(old_anim, true)

    if data.play_axe_sound then
        tree.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree", "chop", 0.1)
    end

    return tree
end

local function FootstepsSpook(self, data)
    if data == nil then
        data = {  }
    end

    local position
    if data.pos ~= nil then
        position = data.pos
    else
        local theta = math.random() * TWOPI
        local radius = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS.MIN_DIST_FROM_PLAYER
        local ppos = self.inst:GetPosition()

        local steps = 12
        for i = 1, steps do
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local ox, oy, oz = (ppos + offset):Get()
            if TheWorld.Map:IsPassableAtPoint(ox, oy, oz, false, true) then
                position = Vector3(ox, oy, oz)
                break
            end

            theta = theta - TWOPI / steps
        end
    end

    if position == nil then -- No ground in sight
        return
    end

    local footsteps = SpawnPrefab("footstepsspook")
    if data.volume ~= nil then
        footsteps.volume = data.volume
    end

    if data.duration ~= nil then
        footsteps.duration = data.duration
    end

    if data.period ~= nil then
        footsteps.period = data.period
    end

    footsteps.Transform:SetPosition(position.x, position.y, position.z)

    if data.angle ~= nil then
        footsteps.Transform:SetRotation(data.angle)
    else
        -- Keep perpendicular to the player
        local px, py, pz = self.inst.Transform:GetWorldPosition()
        local angle = footsteps:GetAngleToPoint(px, py, pz) + 90 * (math.random() > 0.5 and -1 or 1)
        footsteps.Transform:SetRotation(angle)
    end

    if data.speed ~= nil then
        footsteps.speed = data.speed
    end

    footsteps:Start()

    return footsteps
end

local function FootstepsRushSpook(self) -- No data needed, it's a very specific FOOTSTEPS spook
    if not TheWorld.state.isnight then -- Should only happen at night
        return
    end

    local data = {
        duration = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS.FAST_STEPS.duration,
        period = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS.FAST_STEPS.period,
        speed = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS.FAST_STEPS.speed
    }

    local theta = math.random() * TWOPI
    local radius = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS.MIN_DIST_FROM_PLAYER + 6 -- Give it some more distance
    local ppos = self.inst:GetPosition()

    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local fpos = ppos + offset
        if TheWorld.Map:IsPassableAtPoint(fpos.x, fpos.y, fpos.z, false, true) then
            data.pos = fpos
            break
        end

        theta = theta - TWOPI / steps
    end

    if data.pos == nil then -- No ground in sight
        return
    end

    data.angle = math.atan2(data.pos.z - ppos.z, ppos.x - data.pos.x) * RADIANS

    return FootstepsSpook(self, data)
end

local function OceanSinkBirdSpook(self)
    if self.inst == nil or inst:GetCurrentPlatform() == nil then -- Should only happen at when on a boat
        return
    end

    local birdpos = nil
    local ppos = self.inst:GetPosition()

    local theta = math.random() * TWOPI
    local radius = math.random(IE.PARANOIA_SPOOK_PARAMS.BIRDSINK.MIN_DIST_FROM_PLAYER, IE.PARANOIA_SPOOK_PARAMS.BIRDSINK.MAX_DIST_FROM_PLAYER)
    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local offset_pos = ppos + offset
        if TheWorld.Map:IsOceanAtPoint(offset_pos.x, offset_pos.y, offset_pos.z, false) then
            birdpos = offset_pos
            break
        end

        theta = theta - TWOPI / steps
    end

    if birdpos == nil then -- No ocean in sight
        return
    end

    local bird = SpawnPrefab("puffin_sharkfood")
    bird.Transform:SetPosition(birdpos.x, birdpos.y + 15, birdpos.z)

    return bird
end

local function ScreechSpook(self)
    if not TheWorld.state.isnight then -- Should only happen at night
        return
    end

    local position

    local theta = math.random() * TWOPI
    local radius = IE.PARANOIA_SPOOK_PARAMS.SCREECH.MIN_DIST_FROM_PLAYER
    local pos = self.inst:GetPosition()

    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local ox, oy, oz = (pos + offset):Get()
        if TheWorld.Map:IsPassableAtPoint(ox, oy, oz, false, true) then
            position = Vector3(ox, oy, oz)
            break
        end

        theta = theta - TWOPI / steps
    end

    if position == nil then -- No ground in sight
        return
    end

    local sfx_dummy = SpawnPrefab("sfx_dummy")
    sfx_dummy.Transform:SetPosition(position.x, position.y, position.z)

    sfx_dummy.sound = "scary_mod/stuff/screetch_scream"
    sfx_dummy.volume = IE.PARANOIA_SPOOK_PARAMS.SCREECH.VOLUME

    sfx_dummy:Play()

    if self.inst.components.paranoiamanager then
        self.inst.components.paranoiamanager:PushHeartbeatVolume(0, 0.5) 

        self.inst:DoTaskInTime(2.5, function()
            self.inst.components.paranoiamanager:PushHeartbeatVolume(nil, 4) 
        end)
    end
end

local function WhisperQuiet(self, data)
    if data == nil then
        data = {  }
    end

    local position
    if data.pos ~= nil then
        position = data.pos
    else
        local theta = math.random() * TWOPI
        local radius = IE.PARANOIA_SPOOK_PARAMS.WHISPER_QUIET.MIN_DIST_FROM_PLAYER
        local ppos = self.inst:GetPosition()

        local steps = 12
        for i = 1, steps do
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local ox, oy, oz = (ppos + offset):Get()
            if TheWorld.Map:IsPassableAtPoint(ox, oy, oz, false, true) then
                position = Vector3(ox, oy, oz)
                break
            end

            theta = theta - TWOPI / steps
        end
    end

    if position == nil then -- No ground in sight
        return
    end

    local quiet = SpawnPrefab("whisper_quiet")
    quiet.Transform:SetPosition(position.x, position.y, position.z)

    quiet:Appear()

    return quiet
end

local function WhisperLoud(self, data)
    if data == nil then
        data = {  }
    end

    local position
    if data.pos ~= nil then
        position = data.pos
    else
        local theta = math.random() * TWOPI
        local radius = IE.PARANOIA_SPOOK_PARAMS.WHISPER_LOUD.MIN_DIST_FROM_PLAYER
        local ppos = self.inst:GetPosition()

        local steps = 12
        for i = 1, steps do
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local ox, oy, oz = (ppos + offset):Get()
            if TheWorld.Map:IsPassableAtPoint(ox, oy, oz, false, true) then
                position = Vector3(ox, oy, oz)
                break
            end

            theta = theta - TWOPI / steps
        end
    end

    if position == nil then -- No ground in sight
        return
    end

    local loud = SpawnPrefab("whisper_loud")
    loud.Transform:SetPosition(position.x, position.y, position.z)

    loud:Appear()

    return loud
end

local function func()
    -- body
end

return {
    TreeChoppingSpook = TreeChoppingSpook,
    FootstepsSpook = FootstepsSpook,
    FootstepsRushSpook = FootstepsRushSpook,
    OceanSinkBirdSpook = OceanSinkBirdSpook,
    ScreechSpook = ScreechSpook,
    WhisperQuiet = WhisperQuiet,
    WhisperLoud = WhisperLoud
}