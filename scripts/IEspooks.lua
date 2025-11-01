local function GetPointAwayFromInst(inst, radius, allowland, allowocean, allowvoid)
    local theta = math.random() * TWOPI
    local steps = 12
    for i = 1, steps do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local ox, oy, oz = (inst:GetPosition() + offset):Get()

        if TheWorld.Map:IsPassableAtPoint(ox, oy, oz, false, true) and allowland then
            return Vector3(ox, oy, oz)
        end

        if TheWorld.Map:IsOceanAtPoint(ox, oy, oz, false) and allowocean then
            return Vector3(ox, oy, oz)
        end

        if not TheWorld.Map:IsPassableAtPoint(ox, oy, oz, true, true) and allowvoid then
            return Vector3(ox, oy, oz)
        end

        theta = theta - TWOPI / steps
    end
end

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

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local sfx_dummy = SpawnPrefab("sfx_dummy")
    sfx_dummy.Transform:SetPosition(pos.x, pos.y, pos.z)

    sfx_dummy.sound = "dontstarve/wilson/use_pick_rock"
    sfx_dummy.volume = params.VOLUME

    sfx_dummy:Play()

    return sfx_dummy
end

local function FootstepsSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local footsteps = SpawnPrefab("footsteps")

    local variation = params.VARIATIONS[math.random(1, #params.VARIATIONS)]
    footsteps.volume = variation.volume or 1
    footsteps.step_interval = variation.step_interval or 0.35
    footsteps.duration = variation.duration or 1.7
    footsteps.speed = variation.speed or 5

    footsteps.Transform:SetPosition(pos.x, pos.y, pos.z)

    -- Keep perpendicular to the player
    local ppos = self.inst:GetPosition()
    local angle = footsteps:GetAngleToPoint(ppos.x, ppos.y, ppos.z) + 90 * (math.random() > 0.5 and -1 or 1)
    footsteps.Transform:SetRotation(angle)

    footsteps:Start()

    return footsteps
end

local function FootstepsRushSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS_RUSH

    local radius = params.DIST_FROM_PLAYER
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local footsteps = SpawnPrefab("footsteps")

    footsteps.volume = params.volume or 1
    footsteps.step_interval = params.step_interval or 0.35
    footsteps.duration = params.duration or 1.7
    footsteps.speed = params.speed or 5

    footsteps.Transform:SetPosition(pos.x, pos.y, pos.z)

    -- Keep parallel to the player
    local ppos = self.inst:GetPosition()
    local angle = math.atan2(pos.z - ppos.z, ppos.x - pos.x) * RADIANS
    footsteps.Transform:SetRotation(angle)

    footsteps:Start()

    return footsteps
end

local function OceanSinkBirdSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.BIRDSINK

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, false, true, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local bird = SpawnPrefab("birdsink")
    bird.Transform:SetPosition(pos.x, pos.y + 15, pos.z)

    return bird
end

local function ScreechSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.SCREECH

    local radius = params.DIST_FROM_PLAYER
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, true)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local sfx_dummy = SpawnPrefab("sfx_dummy")
    sfx_dummy.Transform:SetPosition(pos.x, pos.y, pos.z)

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

    local radius = params.DIST_FROM_PLAYER
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local quiet = SpawnPrefab("whisper_quiet")
    quiet.Transform:SetPosition(pos.x, pos.y, pos.z)

    quiet.disappear_distance_from_player = params.DISAPPEAR_DIST_SQ

    quiet:Appear()

    return quiet
end

local function WhisperLoud(self, data)
    local params = IE.PARANOIA_SPOOK_PARAMS.WHISPER_LOUD

    local radius = params.DIST_FROM_PLAYER
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local loud = SpawnPrefab("whisper_loud")
    loud.Transform:SetPosition(pos.x, pos.y, pos.z)

    loud.disappear_distance_from_player = params.DISAPPEAR_DIST_SQ

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

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, false, true, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local bubbles = SpawnPrefab("spooky_bubbles")
    bubbles.Transform:SetPosition(pos.x, pos.y, pos.z)
    bubbles.duration = params.DURATION
    bubbles.disappear_distance_from_player = params.DISAPPEAR_DIST_SQ

    bubbles:Appear()

    return bubbles
end

local function OceanFootstepsSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.OCEAN_FOOTSTEPS

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, false, true, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local footsteps = SpawnPrefab("footsteps")

    local variation = params.VARIATIONS[math.random(1, #params.VARIATIONS)]
    footsteps.volume = variation.volume or 1
    footsteps.step_interval = variation.step_interval or 0.35
    footsteps.duration = variation.duration or 1.7
    footsteps.speed = variation.speed or 5

    footsteps.Transform:SetPosition(pos.x, pos.y, pos.z)

    -- Keep perpendicular to the player
    local ppos = self.inst:GetPosition()
    local angle = footsteps:GetAngleToPoint(ppos.x, ppos.y, ppos.z) + 90 * (math.random() > 0.5 and -1 or 1)
    footsteps.Transform:SetRotation(angle)

    footsteps:Start()

    return footsteps
end

local function FakePlayerSpook(self) -- [TODO] Make this less ugly
    local params = IE.PARANOIA_SPOOK_PARAMS.FAKE_PLAYER

    local x, y, z = self.inst.Transform:GetWorldPosition()

    local action
    local rnd = math.random(1, 4)
    if rnd == 1 then
        action = "CHOPPING"
    elseif rnd == 2 then
        action = "MINING"
    elseif rnd == 3 then
        action = "WALKING"
    else
        action = "OBSERVING"
    end

    local target
    if params.ACTIONS[action].TARGET_TAGS ~= nil then
        local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.ACTIONS[action].TARGET_TAGS)

        local far_ents = {  }
        for i, ent in ipairs(ents) do
            if self.inst:GetDistanceSqToInst(ent) >= params.MIN_DIST_FROM_PLAYER * params.MIN_DIST_FROM_PLAYER then
                table.insert(far_ents, ent)
            end
        end

        if #far_ents <= 0 then return end

        target = far_ents[math.random(#far_ents)]
    else
        local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
        target = GetPointAwayFromInst(self.inst, radius, true, false, false)
    end

    if target == nil then -- Couldn't find a suitable origin point or target entity
        return
    end

    local fake_player = SpawnPrefab("fake_player")
    fake_player.runaway_distance_sq = params.RUN_AWAY_DIST_SQ
    if EntityScript.is_instance(target) then
        if IE.DEV then
            print("Chose an entity target!")
        end

        local theta = math.random() * PI2
        local radius = target:GetPhysicsRadius() + fake_player:GetPhysicsRadius()
        local position = target:GetPosition() + Vector3(math.cos(theta) * radius, 0, math.sin(theta) * radius)
        fake_player.Transform:SetPosition(position:Get())
        fake_player.action_target = target
        fake_player.action = action
    elseif Vector3.is_instance(target) then
        if IE.DEV then
            print("Chose a position target!")
        end

        fake_player.Transform:SetPosition(target:Get())

        if action == "WALKING" then
            fake_player.position_target = GetPointAwayFromInst(self.inst, 20, true, false, false)
        end
    end
    
    if params.ACTIONS[action].TOOL ~= nil then
        local tool
        if type(params.ACTIONS[action].TOOL) == "table" then
            tool = params.ACTIONS[action].TOOL[math.random(1, #params.ACTIONS[action].TOOL)]
        else
            tool = params.ACTIONS[action].TOOL
        end

        if IE.DEV then
            print("Chosen tool - "..tool)
        end

        if tool ~= "none" then
            fake_player.AnimState:Show("ARM_carry")
            fake_player.AnimState:Hide("ARM_normal")
            fake_player.AnimState:OverrideSymbol("swap_object", "swap_"..tool, "swap_"..tool)
            fake_player.action_tool = tool
        end
    else
        if IE.DEV then
            print("Chosen tool - none")
        end
    end

    fake_player:DoTaskInTime(1.5, fake_player.Start)

    return fake_player
end

local function FakeMobDeathSpook(self)
    local params = IE.PARANOIA_SPOOK_PARAMS.FAKE_MOB_DEATH

    local radius = math.random(params.MIN_DIST_FROM_PLAYER, params.MAX_DIST_FROM_PLAYER)
    local pos = GetPointAwayFromInst(self.inst, radius, true, false, false)

    if pos == nil then -- Couldn't find a suitable origin point
        return
    end

    local mobdata = params.MOBS[math.random(#params.MOBS)]
    local mob = SpawnPrefab("fake_mob")
    mob.start_erosion_dist = params.START_EROSION_DIST_FROM_PLAYER_SQ
    mob.timeout = params.EROSION_TIMEOUT
    mob:Setup(mobdata)
    mob.Transform:SetPosition(pos.x, pos.y, pos.z)
    mob:Die()

    return mob
end

-- local function ShadowSoundSpook(self)
--     local params = IE.PARANOIA_SPOOK_PARAMS.SHADOW_SOUND
--     local soundparams = params.SOUNDS[math.random(1, #params.SOUNDS)]

--     local radius = params.DIST_FROM_PLAYER
--     local pos = GetPointAwayFromInst(self.inst, radius, true, true, true)

--     if pos == nil then -- Couldn't find a suitable origin point, somehow?
--         return
--     end

--     local sfx_dummy = SpawnPrefab("sfx_dummy")
--     sfx_dummy.Transform:SetPosition(pos.x, pos.y, pos.z)

--     print("Chosen sound - "..soundparams.name)
--     print("    volume - "..tostring(soundparams.volume))
--     sfx_dummy.sound = soundparams.name
--     sfx_dummy.volume = soundparams.volume

--     sfx_dummy:Play()

--     return sfx_dummy
-- end

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
    OceanBubblesSpook = OceanBubblesSpook,
    OceanFootstepsSpook = OceanFootstepsSpook,
    FakePlayerSpook = FakePlayerSpook,
    FakeMobDeathSpook = FakeMobDeathSpook
    -- ShadowSoundSpook = ShadowSoundSpook,
    -- ShadySpook = ShadySpook,
    -- OceanShadowSpook = OceanShadowSpook,
}