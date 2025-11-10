local function TreechopConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.TREECHOP

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.TREE_MUST_TAGS)

    if #ents > 0 then
        if #ents > 20 then
            chance = 0.6
        else
            chance = 0.03 * #ents
        end
    else
        return 0 -- Don't allow the spook to happen if the player is not near a tree
    end

    if player.replica.inventory ~= nil then
        local handitem = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if handitem ~= nil and handitem:HasTag("tool") then
            chance = chance + 0.1
        end
    end
    
    return chance
end

local function MiningSoundConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.MINING_SOUND

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, { "boulder" })

    if #ents > 0 then
        if #ents > 20 then
            chance = 0.6
        else
            chance = 0.03 * #ents
        end
    else
        return 0.15
    end

    if player.replica.inventory ~= nil then
        local handitem = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if handitem ~= nil and handitem:HasTag("tool") then
            chance = chance + 0.1
        end
    end
    
    return chance
end

local function FootstepsConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS

    local chance = 0

    if not player.components.locomotor:WantsToMoveForward() then
        chance = chance + 0.15
    end

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, { "_locomotor" })
    if #ents <= 1 then
        chance = chance + 0.2
    end

    if not TheWorld.state.iscaveday then
        chance = chance + 0.3
    end

    return chance
end

local function FootstepsRushConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.FOOTSTEPS_RUSH

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local campfires = TheSim:FindEntities(x, y, z, 12, { "campfire" })
    if #campfires >= 1 then
        chance = chance + 0.2
    end

    if not TheWorld.state.iscaveday then
        chance = chance + 0.15
    end

    if TheWorld.state.isnight then
        chance = chance + 0.25
    end

    return chance
end

local function BirdSinkConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.BIRDSINK

    local chance = 0

    local x, y = TheWorld.Map:GetTileCoordsAtPoint(player.Transform:GetWorldPosition())
    local half_radius = params.MAX_DIST_FROM_PLAYER / TILE_SCALE

    for x1 = -half_radius, half_radius do
        for y1 = -half_radius, half_radius do
            if TileGroupManager:IsImpassableTile(TheWorld.Map:GetTile(x + x1, y + y1)) then
                chance = chance + 0.75 * (1 / math.pow(half_radius + half_radius, 2))
            end
        end
    end

    if player:GetCurrentPlatform() ~= nil then
        chance = chance + 0.1
    end

    return chance
end

local function ScreechConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.SCREECH

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local campfires = TheSim:FindEntities(x, y, z, 12, { "campfire" })
    if #campfires >= 1 then
        chance = chance + 0.2
    end

    if TheWorld.state.isnight then
        chance = chance * 0.8 + 0.45
    elseif TheWorld.state.iscaveday then
        return 0
    else
        chance = chance + 0.1
    end

    return chance
end

local function WhisperQuietConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.WHISPER_QUIET

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.DIST_FROM_PLAYER + 8, nil, { "FX", "DECOR", "INLIMBO", "NOCLICK" })

    if #ents > 0 then
        if #ents > 20 then
            chance = 0.6
        else
            chance = 0.03 * #ents
        end
    end

    if TheWorld.state.iscaveday then
        chance = chance * 0.65
    elseif TheWorld.state.isnight then
        chance = chance * 1.6
    end

    return math.min(chance, 1)
end

local function WhisperLoudConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.WHISPER_LOUD

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.DIST_FROM_PLAYER + 8, nil, { "FX", "DECOR", "INLIMBO", "NOCLICK" })

    if #ents > 0 then
        if #ents > 20 then
            chance = 0.8
        else
            chance = 0.04 * #ents
        end
    end

    return chance
end

local function BerryBushRustleConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.BERRYBUSH_RUSTLE

    local chance = 0

    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.BUSH_MUST_TAGS)

    if #ents > 0 then
        if #ents > 12 then
            chance = 0.6
        else
            chance = 0.03 * #ents
        end
    else
        return 0 -- Don't allow the spook to happen if the player is not near a berry bush
    end

    return chance
end

local function OceanBubblesConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.OCEAN_BUBBLES

    local chance = 0

    local x, y = TheWorld.Map:GetTileCoordsAtPoint(player.Transform:GetWorldPosition())
    local half_radius = params.MAX_DIST_FROM_PLAYER / TILE_SCALE

    for x1 = -half_radius, half_radius do
        for y1 = -half_radius, half_radius do
            if TileGroupManager:IsImpassableTile(TheWorld.Map:GetTile(x + x1, y + y1)) then
                chance = chance + 1 / math.pow(half_radius + half_radius, 2)
            end
        end
    end

    if player:GetCurrentPlatform() == nil then
        return 0
    end

    return chance
end

local function OceanFootstepsConditions(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.OCEAN_FOOTSTEPS

    local chance = 0

    local x, y = TheWorld.Map:GetTileCoordsAtPoint(player.Transform:GetWorldPosition())
    local half_radius = params.MAX_DIST_FROM_PLAYER / TILE_SCALE

    for x1 = -half_radius, half_radius do
        for y1 = -half_radius, half_radius do
            if TileGroupManager:IsImpassableTile(TheWorld.Map:GetTile(x + x1, y + y1)) then
                chance = chance + 0.8 * (1 / math.pow(half_radius + half_radius, 2))
            end
        end
    end

    return chance
end

local function FakePlayerConditions()
    local params = IE.PARANOIA_SPOOK_PARAMS.FAKE_PLAYER

    local chance = 0

    chance = 1

    return chance
end

local function FakeMobDeathConditions()
    local params = IE.PARANOIA_SPOOK_PARAMS.FAKE_MOB_DEATH

    local chance = 0

    chance = 1

    return chance
end

return {
    TREECHOP = TreechopConditions,
    MINING_SOUND = MiningSoundConditions,
    FOOTSTEPS = FootstepsConditions,
    FOOTSTEPS_RUSH = FootstepsRushConditions,
    BIRDSINK = BirdSinkConditions,
    SCREECH = ScreechConditions,
    WHISPER_QUIET = WhisperQuietConditions,
    WHISPER_LOUD = WhisperLoudConditions,
    BERRYBUSH_RUSTLE = BerryBushRustleConditions,
    OCEAN_BUBBLES = OceanBubblesConditions,
    OCEAN_FOOTSTEPS = OceanFootstepsConditions,
    FAKE_PLAYER = FakePlayerConditions,
    FAKE_MOB_DEATH = FakeMobDeathConditions,
}