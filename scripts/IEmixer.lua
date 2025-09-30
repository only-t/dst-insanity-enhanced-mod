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
    [amb]      = 0.7,
    [cloud]    = 0.7,
    [music]    = 0.45,
    [voice]    = 0.7,
    [movement] = 0.7,
    [creature] = 0.7,
    [player]   = 0.7,
    [HUD]      = 0.7,
    [sfx]      = 0.7,
    [slurp]    = 0.7,
})

_G.TheMixer:AddNewMix("paranoia_stage4", 2, 4, {
    [amb]      = 0.5,
    [cloud]    = 0.5,
    [music]    = 0.25,
    [voice]    = 0.5,
    [movement] = 0.5,
    [creature] = 0.5,
    [player]   = 0.5,
    [HUD]      = 0.5,
    [sfx]      = 0.5,
    [slurp]    = 0.5,
})

_G.TheMixer:AddNewMix("paranoia_stage5", 2, 4, {
    [amb]      = 0.3,
    [cloud]    = 0.3,
    [music]    = 0.09,
    [voice]    = 0.3,
    [movement] = 0.3,
    [creature] = 0.3,
    [player]   = 0.3,
    [HUD]      = 0.3,
    [sfx]      = 0.4,
    [slurp]    = 0.3,
})