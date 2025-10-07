local function TreeChoppingSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.TREECHOP

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.TREE_MUST_TAGS)

    local far_ents = {  }
    for i, ent in ipairs(ents) do
        if self.inst:GetDistanceSqToInst(ent) >= params.MIN_DIST_FROM_PLAYER * params.MIN_DIST_FROM_PLAYER then
            table.insert(far_ents, ent)
        end
    end
    
    if #far_ents <= 0 then return end

    local tree = far_ents[math.random(#far_ents)]

    if tree == nil then return end

    local chop_anim
    local old_anim
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

    if math.random() < params.CHOP_SFX_CHANCE then
        tree.SoundEmitter:PlaySound("paranoia/sfx/chop")
    end

    if math.random() < params.LEAF_SFX_CHANCE then
        tree.SoundEmitter:PlaySound("paranoia/sfx/leaf_rustle")
    end

    return tree
end

local function MiningSoundSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.MINING_SOUND

    local position
    local theta = math.random() * TWOPI
    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
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

    if position == nil then -- No ground in sight
        return
    end

    local sfx_dummy = SpawnPrefab("sfx_dummy")
    sfx_dummy.Transform:SetPosition(position.x, position.y, position.z)

    sfx_dummy.sound = "dontstarve/wilson/use_pick_rock"
    sfx_dummy.volume = params.VOLUME

    sfx_dummy:Play()

    return sfx_dummy
end

local function FootstepsSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS

    local position
    local theta = math.random() * TWOPI
    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
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

    if position == nil then -- No ground in sight
        return
    end

    local footsteps = SpawnPrefab("footsteps")

    local variation = params.VARIATIONS[math.random(1, #params.VARIATIONS)]
    footsteps.volume = variation.volume or 1
    footsteps.step_interval = variation.step_interval or 0.35
    footsteps.duration = variation.duration or 1.7
    footsteps.speed = variation.speed or 5

    footsteps.Transform:SetPosition(position.x, position.y, position.z)

    -- Keep perpendicular to the player
    local angle = footsteps:GetAngleToPoint(ppos.x, ppos.y, ppos.z) + 90 * (math.random() > 0.5 and -1 or 1)
    footsteps.Transform:SetRotation(angle)

    footsteps:Start()

    return footsteps
end

local function FootstepsRushSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS_RUSH

    local position
    local theta = math.random() * TWOPI
    local radius = params.DIST_FROM_PLAYER
    local ppos = self.inst:GetPosition()

    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local fpos = ppos + offset
        if TheWorld.Map:IsPassableAtPoint(fpos.x, fpos.y, fpos.z, false, true) then
            position = fpos
            break
        end

        theta = theta - TWOPI / steps
    end

    if position == nil then -- No ground in sight
        return
    end

    local footsteps = SpawnPrefab("footsteps")

    footsteps.volume = params.volume or 1
    footsteps.step_interval = params.step_interval or 0.35
    footsteps.duration = params.duration or 1.7
    footsteps.speed = params.speed or 5

    footsteps.Transform:SetPosition(position.x, position.y, position.z)

    -- Keep parallel to the player
    local angle = math.atan2(position.z - ppos.z, ppos.x - position.x) * RADIANS
    footsteps.Transform:SetRotation(angle)

    footsteps:Start()

    return footsteps
end

local function OceanSinkBirdSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.BIRDSINK

    local position = nil
    local theta = math.random() * TWOPI
    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local ppos = self.inst:GetPosition()

    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local offset_pos = ppos + offset
        if TheWorld.Map:IsOceanAtPoint(offset_pos.x, offset_pos.y, offset_pos.z, false) then
            position = offset_pos
            break
        end

        theta = theta - TWOPI / steps
    end

    if position == nil then -- No ocean in sight
        return
    end

    local bird = SpawnPrefab("birdsink")
    bird.Transform:SetPosition(position.x, position.y + 15, position.z)

    return bird
end

local function ScreechSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.SCREECH

    local position
    local theta = math.random() * TWOPI
    local radius = params.DIST_FROM_PLAYER
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

    if position == nil then -- No ground in sight
        return
    end

    local sfx_dummy = SpawnPrefab("sfx_dummy")
    sfx_dummy.Transform:SetPosition(position.x, position.y, position.z)

    sfx_dummy.sound = "scary_mod/stuff/screetch_scream"
    sfx_dummy.volume = params.VOLUME

    sfx_dummy:Play()

    if IE.DEV then -- Needs more testing
        if self.inst.components.paranoiamanager then
            self.inst.components.paranoiamanager:PushHeartbeatVolume(0, 0.5)

            self.inst:DoTaskInTime(2.5, function()
                self.inst.components.paranoiamanager:PushHeartbeatVolume(nil, 4) 
            end)
        end
    end

    return sfx_dummy
end

local function WhisperQuiet(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.WHISPER_QUIET

    local position
    local theta = math.random() * TWOPI
    local radius = params.DIST_FROM_PLAYER
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

    if position == nil then -- No ground in sight
        return
    end

    local quiet = SpawnPrefab("whisper_quiet")
    quiet.Transform:SetPosition(position.x, position.y, position.z)

    quiet.dissapear_distance_from_player = params.DISAPPEAR_DIST_SQ

    quiet:Appear()

    return quiet
end

local function WhisperLoud(self, data)
    local params = IE.PARANOIA_SPOOK_PARAMS.WHISPER_LOUD

    local position
    local theta = math.random() * TWOPI
    local radius = params.DIST_FROM_PLAYER
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

    if position == nil then -- No ground in sight
        return
    end

    local loud = SpawnPrefab("whisper_loud")
    loud.Transform:SetPosition(position.x, position.y, position.z)

    loud.dissapear_distance_from_player = params.DISAPPEAR_DIST_SQ

    loud:Appear()

    return loud
end

local function BerryBushRustleSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.BERRYBUSH_RUSTLE
    
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.BUSH_MUST_TAGS)

    local far_ents = {  }
    for i, ent in ipairs(ents) do
        if self.inst:GetDistanceSqToInst(ent) >= params.MIN_DIST_FROM_PLAYER * params.MIN_DIST_FROM_PLAYER then
            table.insert(far_ents, ent)
        end
    end
    
    if #far_ents <= 0 then return end

    local bush = far_ents[math.random(#far_ents)]

    if bush == nil then return end

    local rustle_anim
    local old_anim
    if bush.AnimState:IsCurrentAnimation("idle") then
        rustle_anim = "grow"
        old_anim = "idle"
    elseif bush.AnimState:IsCurrentAnimation("dead") then
        rustle_anim = "shake_dead"
        old_anim = "dead"
    else
        return -- None of the above are playing meaning we shouldn't interfere
    end

    bush.AnimState:PlayAnimation(rustle_anim)
    bush.AnimState:PushAnimation(old_anim, true)

    if bush.prefab == "berrybush" then
        local vfx = SpawnPrefab("green_leaves")
        vfx.Transform:SetPosition(bush.Transform:GetWorldPosition())
    else
        local sfx_dummy = SpawnPrefab("sfx_dummy") -- Since berry bushes don't have SoundEmitter, for SOME reason?
        sfx_dummy.Transform:SetPosition(bush.Transform:GetWorldPosition())

        sfx_dummy.sound = "dontstarve/wilson/harvest_berries"
        sfx_dummy.volume = 0.3

        sfx_dummy:Play()
    end

    return bush
end

local function OceanBubblesSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.OCEAN_BUBBLES

    local position = nil
    local theta = math.random() * TWOPI
    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local ppos = self.inst:GetPosition()

    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local offset_pos = ppos + offset
        if TheWorld.Map:IsOceanAtPoint(offset_pos.x, offset_pos.y, offset_pos.z, false) then
            position = offset_pos
            break
        end

        theta = theta - TWOPI / steps
    end

    if position == nil then -- No ocean in sight
        return
    end

    local bubbles = SpawnPrefab("spooky_bubbles")
    bubbles.Transform:SetPosition(position.x, position.y, position.z)
    bubbles.duration = params.DURATION
    bubbles.dissapear_distance_from_player = params.DISAPPEAR_DIST_SQ

    bubbles:Appear()

    return bubbles
end

return {
    TreeChoppingSpook = TreeChoppingSpook,
    FootstepsSpook = FootstepsSpook,
    FootstepsRushSpook = FootstepsRushSpook,
    OceanSinkBirdSpook = OceanSinkBirdSpook,
    ScreechSpook = ScreechSpook,
    WhisperQuiet = WhisperQuiet,
    WhisperLoud = WhisperLoud,
    MiningSoundSpook = MiningSoundSpook,
    BerryBushRustleSpook = BerryBushRustleSpook,
    OceanBubblesSpook = OceanBubblesSpook
}