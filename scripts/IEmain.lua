-- [[ Overrides ]]
local overrides = {
    components = {
        "ambientsound",
        "dynamicmusic",
        "dsp"
    },
    screens = {
        "playerhud"
    },
    stategraphs = {
        -- "SGwilson",
        -- "SGwilson_client"
    },
    prefabs = {

    },
    other = {
        "postprocessor",
        "player"
    }
}

for type, names in pairs(overrides) do
    for i, name in ipairs(names) do
        modimport("scripts/overrides/"..type.."/"..name)
    end
end

-- [[ Shaders ]]
modimport("scripts/IEshaders")

-- [[ Sound mixer ]]
modimport("scripts/IEmixer")