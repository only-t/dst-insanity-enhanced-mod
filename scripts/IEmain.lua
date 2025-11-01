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
        -- "SGwilson", -- [TODO]
        -- "SGwilson_client"
    },
    prefabs = {
        "player_classified"
    },
    other = {
        "postprocessor",
        "player"
    }
}

for type, names in pairs(overrides) do
    for _, name in ipairs(names) do
        _G.IE.modprint(_G.IE.PRINT, "Overriding...",
                                    "filepath - ".."scripts/overrides/"..type.."/"..name)
        modimport("scripts/overrides/"..type.."/"..name)
    end
end

-- [[ Shaders ]]
modimport("scripts/IEshaders")

-- [[ Sound mixer ]]
modimport("scripts/IEmixer")