-- Defined this way to make reusing for different mods easier
local MOD_CODE = "IE"
local MOD_NAME = "Paranoia"

-- Good to define your entire environment in a special table.
-- Eliminates any potential mod incompatability with mods that use the same global names.
-- Unless they define a global of the same name as `MOD_CODE` i guess...
_G[MOD_CODE] = {
    MOD_CODE = MOD_CODE,
    MOD_NAME = MOD_NAME
}

local env = _G[MOD_CODE]

---
--- Created specifically to print lines with a clear source, that being, the mod.
--- Functionally, it's a simple print with a prefix which can be defined either as a `PRINT`, a `WARN` or an `ERROR`.
---
--- Any additional parameters after `mainline` will be printed with an indentation.
---@param print_type int
---@param mainline any
---@vararg any
---@return void
local function modprint(print_type, mainline, ...)
    if mainline == nil then
        return
    end

    mainline = tostring(mainline)

    if print_type == env.PRINT then
        print(env.PRINT_PREFIX..mainline)
    elseif print_type == env.WARN then
        print(env.WARN_PREFIX..mainline)
    elseif print_type == env.ERROR then
        print(env.ERROR_PREFIX..mainline)
    end

    for _, line in ipairs({...}) do
        print("    "..tostring(line))
    end

    print("")
end

---
--- A custom assert that prints the mods special error message with the `ERROR` prefix.
--- The assertion fails after all provided lines are printed, assuming `cond` is `false`.
---
--- Any additional parameters after `mainline` will be printed with an indentation.
---@param cond bool
---@param mainline any
---@vararg any
---@return void
local function modassert(cond, mainline, ...)
    if not cond then
        modprint(env.ERROR_PREFIX, mainline, ...)

        _G.error("Assertion failed!")
    end
end

---
--- Saves `data` as a persistent json string using `TheSim:SetPersistentString()`. The string is saved inside `filename`.
--- Currently only tested on client-sided mods.
---
--- `data` can be either a Lua table or a json string.
---
--- `cb` is an optional function that will run after a successful string save.
---@param filename string
---@param data table|str
---@param cb function
---@return void
local function ModSetPersistentData(filename, data, cb)
    if type(data) == "table" then
        data = _G.json.encode(data)
    elseif type(data) ~= "string" then
        modassert(false, "Failed to save persistent data!", "Data provided is neither a table nor a string!")
    end
    
    if cb == nil or type(cb) ~= "function" then
        _G.TheSim:SetPersistentString(filename, data, false)
        return
    end

    _G.TheSim:SetPersistentString(filename, data, false, cb)
end

---
--- Retrieves persistent data as a json string from `filename`.
--- Currently only tested on client-sided mods.
---
--- `cb` runs with 2 parameters: `success`, a boolean, and `data`, the json string. If `success` is `false` `data` is an empty string.
---@param filename string
---@param cb function
---@return void
local function ModGetPersistentData(filename, cb)
    modassert(type(cb) == "function", "Failed to load persistent data!", "cb needs to be a function!")
    _G.TheSim:GetPersistentString(filename, cb)
end

---
--- Retrieves current mod setting using `setting_id`. Will print a message if `setting_id` doesn't exist.
---@param setting_id string
---@return table
local function GetModSetting(setting_id)
    if env.CURRENT_SETTINGS[setting_id] ~= nil then
        return env.CURRENT_SETTINGS[setting_id]
    end

    modprint(env.WARN, "Trying to get mod setting "..tostring(setting_id).." but it does not seem to exist.")
end

-- [[ Disable for live builds ]]
env.DEV = true

-- [[ Universal Variables ]]
env.PRINT = 0
env.WARN = 1
env.ERROR = 2
env.PRINT_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - "
env.WARN_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - WARNING! "
env.ERROR_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - ERROR! "

env.modprint = modprint
env.modassert = modassert
env.ModSetPersistentData = ModSetPersistentData
env.ModGetPersistentData = ModGetPersistentData
env.GetModSetting = GetModSetting


-- [[                                             ]] --
-- [[ Here is where mod specific env variables go ]] --
-- [[                                             ]] --

-- [[ Constants ]]
env.PARANOIA_SPOOKS = {
    TREECHOP = 0,
    MINING_SOUND = 1,
    FOOTSTEPS = 2,
    FOOTSTEPS_RUSH = 3, -- Same as FOOTSTEPS but quickly rushes to the player
    BIRDSINK = 4,
    SCREECH = 5, -- Screecher's screech from the Screecher, a Klei mod which includes the screeching Screecher
    WHISPER_QUIET = 6,
    WHISPER_LOUD = 7,
    BERRYBUSH_RUSTLE = 8,
    OCEAN_BUBBLES = 9,
    OCEAN_FOOTSTEPS = 10,
    FAKE_PLAYER = 11,
    FAKE_MOB_DEATH = 12,
    -- SHADOW_SOUND = 13, -- An assortment of different spooky sounds
    -- SHADY = 14, -- He's just a chill guy :)))
    -- OCEAN_SHADOW = 15,
}

env.PARANOIA_STAGES = {
    STAGE0 = 0, -- No paranoia
    STAGE1 = 1,
    STAGE2 = 2,
    STAGE3 = 3,
    STAGE4 = 4,
    STAGE5 = 5,
    STAGE6 = 6
}

env.SHADER_PARAM_LIMITS = {
    SHARPNESS = 0.45,
    MONOCHROMACY = 0.65,
    DISTORION_RADIUS = 0.95,
    DISTORTION_STRENGTH = 18
}

-- [[ Mod Settings ]] -- Not to be confused with configuration_options.
                      -- These show up in Game Options and can be updated during gameplay.
local enableDisableOptions = {
    { text = _G.STRINGS.UI.OPTIONS.DISABLED, data = false },
    { text = _G.STRINGS.UI.OPTIONS.ENABLED,  data = true  }
}

env.SETTING_TYPES = {
    SPINNER = "spinner",
    NUM_SPINNER = "num_spinner",
    LIST = "list",
    KEY_SELECT = "key_select"
}

env.MIN_HEARTBEAT_INTENSITY = 0
env.MAX_HEARTBEAT_INTENSITY = 10
env.DEFAULT_HEARTBEAT_INTENSITY = 8

env.MIN_INSANITY_SHADER_INTENSITY = 0
env.MAX_INSANITY_SHADER_INTENSITY = 10
env.DEFAULT_INSANITY_SHADER_INTENSITY = 8

env.MIN_INSANITY_AMBIENCE_INTENSITY = 0
env.MAX_INSANITY_AMBIENCE_INTENSITY = 10
env.DEFAULT_INSANITY_AMBIENCE_INTENSITY = 5

env.MIN_SPOOK_INTENSITY = 1
env.MAX_SPOOK_INTENSITY = 10
env.DEFAULT_SPOOK_INTENSITY = 6

env.MOD_SETTINGS = {
    FILENAME = "IE_settings",
    TAB_NAME = "Paranoia",
    TOOLTIP = "Modify the mods settings",
    SETTINGS = {
        HEARTBEAT_INTENSITY = {
            ID = "IE_heartbeat_intensity",
            SPINNER_TITLE = "Heartbeat intensity:",
            TOOLTIP = "Modify the intensity of low sanity heartbeat.",
            COLUMN = 1,
            TYPE = env.SETTING_TYPES.NUM_SPINNER,
            VALUES = { env.MIN_HEARTBEAT_INTENSITY, env.MAX_HEARTBEAT_INTENSITY, 1 },
            DEFAULT = env.DEFAULT_HEARTBEAT_INTENSITY
        },
        INSANITY_SHADER_INTENSITY = {
            ID = "IE_insanity_shader_intensity",
            SPINNER_TITLE = "Shader intensity:",
            TOOLTIP = "Modify the intensity of low sanity shader.",
            COLUMN = 1,
            TYPE = env.SETTING_TYPES.NUM_SPINNER,
            VALUES = { env.MIN_INSANITY_SHADER_INTENSITY, env.MAX_INSANITY_SHADER_INTENSITY, 1 },
            DEFAULT = env.DEFAULT_INSANITY_SHADER_INTENSITY
        },
        INSANITY_AMBIENCE_INTENSITY = {
            ID = "IE_insanity_ambience_intensity",
            SPINNER_TITLE = "Ambience intensity:",
            TOOLTIP = "Modify the intensity of low sanity ambience.",
            COLUMN = 1,
            TYPE = env.SETTING_TYPES.NUM_SPINNER,
            VALUES = { env.MIN_INSANITY_AMBIENCE_INTENSITY, env.MAX_INSANITY_AMBIENCE_INTENSITY, 1 },
            DEFAULT = env.DEFAULT_INSANITY_AMBIENCE_INTENSITY
        },
        SPOOK_INTENSITY = {
            ID = "IE_spook_intensity",
            SPINNER_TITLE = "Spook intensity:",
            TOOLTIP = "Modify how often hallucinations should happen when low on sanity.",
            COLUMN = 1,
            TYPE = env.SETTING_TYPES.NUM_SPINNER,
            VALUES = { env.MIN_SPOOK_INTENSITY, env.MAX_SPOOK_INTENSITY, 1 },
            DEFAULT = env.DEFAULT_SPOOK_INTENSITY
        }
    }
}

env.CURRENT_SETTINGS = {  }

env.ApplySettings = function()
    if _G.ThePlayer ~= nil then
        if _G.ThePlayer.components.paranoiaspooks then
            _G.ThePlayer.components.paranoiaspooks.spook_intensity = env.CURRENT_SETTINGS[env.MOD_SETTINGS.SETTINGS.SPOOK_INTENSITY.ID]
        end

        if _G.ThePlayer.components.paranoiamanager then
            local strength = 1 - math.min(1, _G.ThePlayer.replica.sanity:GetPercent() / env.PARANOIA_THRESHOLDS[env.PARANOIA_STAGES.STAGE1])
            local sharpness = env.SHADER_PARAM_LIMITS.SHARPNESS * strength
            local monochromacy = env.SHADER_PARAM_LIMITS.MONOCHROMACY * strength
            _G.ThePlayer.components.paranoiamanager:SetShaderColorParams(sharpness, monochromacy)
        end
    end
end

-- [[ Misc. Variables ]]

env.PARANOIA_THRESHOLDS = {
    [env.PARANOIA_STAGES.STAGE1] = 0.60,
    [env.PARANOIA_STAGES.STAGE2] = 0.50,
    [env.PARANOIA_STAGES.STAGE3] = 0.40,
    [env.PARANOIA_STAGES.STAGE4] = 0.30,
    [env.PARANOIA_STAGES.STAGE5] = 0.20,
    [env.PARANOIA_STAGES.STAGE6] = 0.15
}

env.HEARTBEAT_START_STAGE = env.PARANOIA_STAGES.STAGE3
env.HEARTBEAT_MAX_VOLUME = 0.55
env.HEARTBEAT_MIN_VOLUME = 0.1
env.HEARTBEAT_MAX_COOLDOWN = 6
env.HEARTBEAT_MIN_COOLDOWN = 2.5

env.SHADER_MODE_TRANSITION_SPEED = 1

env.IN_COMBAT_DURATION = 6
env.BUSY_DURATION = 10

env.PARANOIA_DROPOFF = 1

env.PARANOIA_SOURCES = {
    SANITY = {
        START_THRESHOLD = env.PARANOIA_THRESHOLDS[env.PARANOIA_STAGES.STAGE1],
        GAIN_ADDITIVE = 1
    },
    LOW_HEALTH = {
        START_THRESHOLD = 0.5,
        GAIN_MULTIPLICATIVE = 2,
        GAIN_ADDITIVE = 0.5
    },
    DARKNESS = {
        GAIN_MULTIPLICATIVE = 2,
        GAIN_ADDITIVE = 1.67
    },
    PLAYER_GHOSTS = {
        GAIN_ADDITIVE = 0.67
    },
    LONELINESS = {
        START_DIST_FROM_OTHERS_SQ = 40 * 40,
        GAIN_ADDITIVE = 0.5
    },
    CAVING = {
        GAIN_ADDITIVE = 0.5
    }
}

env.PARANOIA_SPOOK_COSTS = { -- Percentage of built up paranoia this spook will consume upon triggering
    TREECHOP = 0.5,
    MINING_SOUND = 0.5,
    FOOTSTEPS = 0.75,
    FOOTSTEPS_RUSH = 1,
    BIRDSINK = 0.5,
    SCREECH = 1,
    WHISPER_QUIET = 0.5,
    WHISPER_LOUD = 1,
    BERRYBUSH_RUSTLE = 0.5,
    OCEAN_BUBBLES = 0.5,
    OCEAN_FOOTSTEPS = 0.75,
    FAKE_PLAYER = 1,
    FAKE_MOB_DEATH = 1
}

env.PARANOIA_SPOOK_PARAMS = {
    TREECHOP = {
        MIN_DIST_FROM_PLAYER = 10,
        MAX_DIST_FROM_PLAYER = 24,
        TREE_MUST_TAGS = { "evergreens" }
    },
    MINING_SOUND = {
        MIN_DIST_FROM_PLAYER = 8,
        MAX_DIST_FROM_PLAYER = 18,
        VOLUME = 0.4
    },
    FOOTSTEPS = {
        VARIATIONS = {
            {
                step_interval = 0.15,
                duration = 0.9,
                speed = 15
            },
            {
                step_interval = 0.35,
                duration = 1.7,
                speed = 5
            },
            {
                step_interval = 0.6,
                duration = 3,
                speed = 5
            }
        },
        MIN_DIST_FROM_PLAYER = 12,
        MAX_DIST_FROM_PLAYER = 15
    },
    FOOTSTEPS_RUSH = {
        step_interval = 0.15,
        duration = 0.9,
        speed = 15,
        DIST_FROM_PLAYER = 20
    },
    BIRDSINK = {
        MIN_DIST_FROM_PLAYER = 12,
        MAX_DIST_FROM_PLAYER = 20
    },
    SCREECH = {
        DIST_FROM_PLAYER = 20,
        VOLUME = 0.25
    },
    WHISPER_QUIET = {
        DIST_FROM_PLAYER = 14,
        DISAPPEAR_DIST_SQ = 10 * 10
    },
    WHISPER_LOUD = {
        DIST_FROM_PLAYER = 14,
        DISAPPEAR_DIST_SQ = 10 * 10
    },
    BERRYBUSH_RUSTLE = {
        MIN_DIST_FROM_PLAYER = 10,
        MAX_DIST_FROM_PLAYER = 24,
        BUSH_MUST_TAGS = { "bush" }
    },
    OCEAN_BUBBLES = {
        MIN_DIST_FROM_PLAYER = 10,
        MAX_DIST_FROM_PLAYER = 20,
        DURATION = 14,
        DISAPPEAR_DIST_SQ = 4 * 4
    },
    OCEAN_FOOTSTEPS = {
        VARIATIONS = {
            {
                step_interval = 0.15,
                duration = 0.9,
                speed = 15
            },
            {
                step_interval = 0.35,
                duration = 1.7,
                speed = 5
            },
            {
                step_interval = 0.6,
                duration = 3,
                speed = 5
            }
        },
        MIN_DIST_FROM_PLAYER = 14,
        MAX_DIST_FROM_PLAYER = 18
    },
    FAKE_PLAYER = {
        ACTIONS = {
            CHOPPING = {
                TARGET_TAGS = { "evergreens" },
                TOOL = {
                    "axe",
                    "goldenaxe",
                    "multitool_axe_pickaxe"
                }
            },
            MINING = {
                TARGET_TAGS = { "boulder" },
                TOOL = {
                    "pickaxe",
                    "goldenpickaxe",
                    "multitool_axe_pickaxe"
                }
            },
            WALKING = {
                TOOL = {
                    "pickaxe",
                    "goldenpickaxe",
                    "axe",
                    "goldenaxe",
                    "multitool_axe_pickaxe",
                    "spear",
                    "none"
                }
            },
            OBSERVING = {
                TOOL = {
                    "pickaxe",
                    "goldenpickaxe",
                    "axe",
                    "goldenaxe",
                    "multitool_axe_pickaxe",
                    "spear",
                    "none"
                }
            }
        },
        MIN_DIST_FROM_PLAYER = 24,
        MAX_DIST_FROM_PLAYER = 26,
        RUN_AWAY_DIST_SQ = 12 * 12,
    },
    FAKE_MOB_DEATH = {
        MOBS = {
            {
                num_faces = 4,
                bank = "bearger",
                build = "bearger_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
                    inst:DoTaskInTime(6 * _G.FRAMES, function()
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/death")
                    end)
                    inst:DoTaskInTime(46 * _G.FRAMES, function()
                        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
                    end)
                end
            },
            {
                num_faces = 4,
                bank = "deerclops",
                build = "deerclops_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/death")
                    inst:DoTaskInTime(48 * _G.FRAMES, function()
                        if _G.TheWorld.state.snowlevel > 0.02 then
                            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
                        else
                            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
                        end
                    end)
                end
            },
            {
                num_faces = 4,
                bank = "goosemoose",
                build = "goosemoose_build",
                idleanim = "idle",
                deathanim = "death",
                death_fn = function(inst)
			        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/death")
                end
            },
            {
                num_faces = 6,
                bank = "warg",
                build = "warg_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
			        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/death")
                end
            },
            {
                num_faces = 4,
                bank = "pigman",
                build = "pig_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
			        inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
                end
            },
            {
                num_faces = 6,
                bank = "koalefant",
                build = "koalefant_summer_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
			        inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/yell")
                end
            },
            {
                num_faces = 6,
                bank = "koalefant",
                build = "koalefant_winter_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
			        inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/yell")
                end
            },
            {
                num_faces = 4,
                bank = "leif",
                build = "leif_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/forest/treeFall")
                end
            },
            {
                num_faces = 4,
                bank = "leif",
                build = "leif_lumpy_build",
                idleanim = "idle_loop",
                deathanim = "death",
                death_fn = function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/forest/treeFall")
                end
            },
            {
                num_faces = 4,
                bank = "spider_queen",
                build = "spider_queen_build",
                idleanim = "idle",
                deathanim = "death",
                death_fn = function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
                end
            },
            {
                num_faces = 4,
                bank = "mole",
                build = "mole_build",
                idleanim = "idle_under",
                deathanim = "death",
                death_fn = function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
                end
            }
        },
        MIN_DIST_FROM_PLAYER = 38,
        MAX_DIST_FROM_PLAYER = 48,
        START_EROSION_DIST_FROM_PLAYER_SQ = 16 * 16,
        EROSION_TIMEOUT = 10
    }
    -- SHADOW_SOUND = {
    --     DIST_FROM_PLAYER = 12,
    --     SOUNDS = {
    --         {
    --             name = "dontstarve/sanity/knight/attack_1",
    --             volume = 1
    --         },
    --         {
    --             name = "dontstarve/sanity/knight/attack_2",
    --             volume = 1
    --         },
    --         {
    --             name = "dontstarve/sanity/knight/attack_3",
    --             volume = 1
    --         },
    --         {
    --             name = "dontstarve/sanity/knight/dissappear",
    --             volume = 0.4
    --         },
    --         -- {
    --         --     name = "dontstarve/sanity/knight/hit_response" -- Could be good for a suspense payoff sfx
    --         -- },
    --         {
    --             name = "dontstarve/sanity/creature3/movement_pst",
    --             volume = 1
    --         },
    --         {
    --             name = "dontstarve/sanity/creature1/dissappear",
    --             volume = 0.4
    --         },
    --         {
    --             name = "dontstarve/sanity/bishop/dissappear",
    --             volume = 1
    --         },
    --         {
    --             name = "dontstarve/sanity/bishop/taunt",
    --             volume = 1
    --         }
    --     }
    -- },
    -- SHADY = {
    --     MIN_DIST_FROM_PLAYER = 12,
    --     MAX_DIST_FROM_PLAYER = 20
    -- },
    -- OCEAN_SHADOW = {

    -- }
}

env.PARANOIA_SPOOK_WEIGHTS = {
    TREECHOP = {
        forest = 1,
        cave = 1,

        night = 2,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 0.5,
        canseeindark = 3,

        isincombat = 0.33,
        isbusyworking = 6,

        biomes = {
            BGCrappyForest = 5,
            BGForest = 5,
            Forest = 5,
            ForestMole = 5,
            CrappyForest = 5,
            BGDeepForest = 6,
            CrappyDeepForest = 6,
            DeepForest = 6,
            BurntForest = 2,
            CritterDen = 2,
            SpiderForest = 2,
            Graveyard = 2,
            MoonbaseOne = 2,
            BGNoise = 2,
            CritterDen = 2,
            other = 1
        }
    },
    MINING_SOUND = {
        forest = 1,
        cave = 5,
        
        night = 1,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 1,
        canseeindark = 1,

        isincombat = 0.33,
        isbusyworking = 4,

        biomes = {
            RockyPlains = 5,
            RockyHatchingGrounds = 5,
            BatsAndRocky = 5,
            BGRockyCave = 5,
            BGRockyCaveRoom = 5,
            WalrusHut_Rocky = 5,
            BGChessRocky = 5,
            BGRocky = 6,
            Rocky = 6,
            RockyBuzzards = 6,
            GenericRockyNoThreat = 5,
            MolesvilleRocky = 5,
            BGBadlands = 5,
            Badlands = 5,
            HoundyBadlands = 5,
            BuzzardyBadlands = 5,
            BGNoise = 2,
            CritterDen = 3,
            MoonbaseOne = 3,
            MoonIsland_Mine = 3,
            other = 1
        }
    },
    FOOTSTEPS = {
        forest = 1,
        cave = 1,

        night = 6,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 9,
        canseeindark = 1,

        isincombat = 0.5,
        isbusyworking = 4,

        biomes = {
            other = 2
        }
    },
    FOOTSTEPS_RUSH = {
        forest = 1,
        cave = 1,

        night = 6,
        day = 0.33,

        boat = -1,
        land = 1,

        isindark = 10,
        canseeindark = 2,

        isincombat = 0.67,
        isbusyworking = 2,

        biomes = {
            other = 2
        }
    },
    BIRDSINK = {
        forest = 1,
        cave = -1,

        night = 1,
        day = 1.5,

        boat = 4,
        land = 0.25,

        isindark = -1,
        canseeindark = 3,

        isincombat = 0.2,
        isbusyworking = 4,

        biomes = {
            other = 2
        }
    },
    SCREECH = {
        forest = 1,
        cave = -1,

        night = 6,
        day = -1,

        boat = -1,
        land = 1,

        isindark = 6,
        canseeindark = 2,

        isincombat = 0.2,
        isbusyworking = 6,

        biomes = {
            Forest = 5,
            ForestMole = 5,
            DeepForest = 6,
            Graveyard = 3,
            MoonbaseOne = 3,
            CrappyForest = 5,
            CrappyDeepForest = 6,
            other = 0
        }
    },
    WHISPER_QUIET = {
        forest = 1,
        cave = 1,

        night = 3,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 5,
        canseeindark = 2,

        isincombat = 0.2,
        isbusyworking = 4,

        biomes = {
            Forest = 3,
            ForestMole = 3,
            DeepForest = 4,
            Graveyard = 2,
            MoonbaseOne = 2,
            CrappyForest = 3,
            CrappyDeepForest = 4,
            other = 1
        }
    },
    WHISPER_LOUD = {
        forest = 1,
        cave = 1,

        night = 3,
        day = 0,

        boat = -1,
        land = 0.5,

        isindark = 5,
        canseeindark = 0.5,

        isincombat = 0.5,
        isbusyworking = 3,

        biomes = {
            Forest = 2,
            ForestMole = 2,
            DeepForest = 4,
            CrappyForest = 2,
            CrappyDeepForest = 4,
            other = 1
        }
    },
    BERRYBUSH_RUSTLE = {
        forest = 1,
        cave = 1,

        night = 2,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 0,
        canseeindark = 4,

        isincombat = 0.67,
        isbusyworking = 4,

        biomes = {
            other = 4
        }
    },
    OCEAN_BUBBLES = {
        forest = 1,
        cave = -1,

        night = 2,
        day = 1,

        boat = 5,
        land = -1,

        isindark = 1,
        canseeindark = 5,

        isincombat = 1,
        isbusyworking = 4,

        biomes = {
            other = 2
        }
    },
    OCEAN_FOOTSTEPS = {
        forest = 1,
        cave = -1,

        night = 3,
        day = 2,

        boat = 3,
        land = -1,

        isindark = 1,
        canseeindark = 3,

        isincombat = 0.5,
        isbusyworking = 4,

        biomes = {
            other = 2
        }
    },
    FAKE_PLAYER = {
        forest = 1,
        cave = 1,

        night = 2,
        day = 4,

        boat = 1,
        land = 2,

        isindark = 1,
        canseeindark = 4,

        isincombat = 1,
        isbusyworking = 2,

        biomes = {
            other = 2
        }
    },
    FAKE_MOB_DEATH = {
        forest = 1,
        cave = 1,

        night = 1,
        day = 3,

        boat = -1,
        land = 3,

        isindark = 1,
        canseeindark = 4,

        isincombat = 2,
        isbusyworking = 3,

        biomes = {
            other = 3
        }
    }
    -- SHADOW_SOUND = {

    -- },
    -- SHADY = {
    --     forest = 1,
    --     cave = 1,

    --     night = 4,
    --     day = 2,

    --     boat = 1,
    --     land = 3,

    --     isindark = 1,
    --     canseeindark = 5,

    --     isincombat = 1,
    --     isbusyworking = 4,

    --     biomes = {
    --         other = 1
    --     }
    -- },
    -- OCEAN_SHADOW = {
    --     forest = 1,
    --     cave = -1,

    --     night = 2,
    --     day = 3,

    --     boat = 3,
    --     land = -1,

    --     isindark = 2,
    --     canseeindark = 5,

    --     isincombat = 0.5,
    --     isbusyworking = 3,

    --     biomes = {
    --         other = 1
    --     }
    -- }
}