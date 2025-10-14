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
    [amb]      = 0.8,
    [cloud]    = 0.8,
    [music]    = 0.4,
    [voice]    = 0.8,
    [movement] = 0.8,
    [creature] = 0.8,
    [player]   = 0.8,
    [HUD]      = 0.8,
    [sfx]      = 0.8,
    [slurp]    = 0.8,
})

_G.TheMixer:AddNewMix("paranoia_stage4", 2, 4, {
    [amb]      = 0.65,
    [cloud]    = 0.65,
    [music]    = 0.25,
    [voice]    = 0.65,
    [movement] = 0.65,
    [creature] = 0.65,
    [player]   = 0.65,
    [HUD]      = 0.65,
    [sfx]      = 0.65,
    [slurp]    = 0.65,
})

_G.TheMixer:AddNewMix("paranoia_stage5", 2, 4, {
    [amb]      = 0.5,
    [cloud]    = 0.5,
    [music]    = 0.11,
    [voice]    = 0.5,
    [movement] = 0.5,
    [creature] = 0.5,
    [player]   = 0.5,
    [HUD]      = 0.5,
    [sfx]      = 0.55,
    [slurp]    = 0.5,
})