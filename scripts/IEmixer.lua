-- [[ Mixes ]]
local amb = "set_ambience/ambience"
local cloud = "set_ambience/cloud"
local music = "set_music/soundtrack"
local voice = "set_sfx/voice"
local movement ="set_sfx/movement"
local creature ="set_sfx/creature"
local player ="set_sfx/player"
local HUD ="set_sfx/HUD"
local sfx ="set_sfx/sfx"
local slurp ="set_sfx/everything_else_muted"

_G.TheMixer:AddNewMix("paranoia_stage3", 2, 4, {
    [amb]      = 0.6,
    [cloud]    = 0.6,
    [music]    = 0.45,
    [voice]    = 0.6,
    [movement] = 0.6,
    [creature] = 0.6,
    [player]   = 0.6,
    [HUD]      = 0.6,
    [sfx]      = 0.6,
    [slurp]    = 0.6,
})

_G.TheMixer:AddNewMix("paranoia_stage4", 2, 4, {
    [amb]      = 0.4,
    [cloud]    = 0.4,
    [music]    = 0.25,
    [voice]    = 0.4,
    [movement] = 0.4,
    [creature] = 0.4,
    [player]   = 0.4,
    [HUD]      = 0.4,
    [sfx]      = 0.4,
    [slurp]    = 0.4,
})

_G.TheMixer:AddNewMix("paranoia_stage5", 2, 4, {
    [amb]      = 0.2,
    [cloud]    = 0.2,
    [music]    = 0.08,
    [voice]    = 0.2,
    [movement] = 0.2,
    [creature] = 0.2,
    [player]   = 0.2,
    [HUD]      = 0.2,
    [sfx]      = 0.2,
    [slurp]    = 0.2,
})

_G.TheMixer:AddNewMix("suspense", 6, 5, {
    [amb]      = 0.0,
    [cloud]    = 0.0,
    [music]    = 0.0,
    [voice]    = 0.0,
    [movement] = 0.0,
    [creature] = 0.0,
    [player]   = 0.0,
    [HUD]      = 0.0,
    [sfx]      = 0.0,
    [slurp]    = 0.0,
})