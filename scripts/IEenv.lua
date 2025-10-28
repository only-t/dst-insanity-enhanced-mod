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

    if print_type == _G[MOD_CODE].PRINT then
        print(_G[MOD_CODE].PRINT_PREFIX..mainline)
    elseif print_type == _G[MOD_CODE].WARN then
        print(_G[MOD_CODE].WARN_PREFIX..mainline)
    elseif print_type == _G[MOD_CODE].ERROR then
        print(_G[MOD_CODE].ERROR_PREFIX..mainline)
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
        modprint(_G[MOD_CODE].ERROR_PREFIX, mainline, ...)

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
    if _G[MOD_CODE].CURRENT_SETTINGS[setting_id] ~= nil then
        return _G[MOD_CODE].CURRENT_SETTINGS[setting_id]
    end

    modprint(_G[MOD_CODE].WARN, "Trying to get mod setting "..tostring(setting_id).." but it does not seem to exist.")
end

-- [[ Disable for live builds ]]
_G[MOD_CODE].DEV = true

-- [[ Universal Variables ]]
_G[MOD_CODE].PRINT = 0
_G[MOD_CODE].WARN = 1
_G[MOD_CODE].ERROR = 2
_G[MOD_CODE].PRINT_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - "
_G[MOD_CODE].WARN_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - WARNING! "
_G[MOD_CODE].ERROR_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - ERROR! "

_G[MOD_CODE].modprint = modprint
_G[MOD_CODE].modassert = modassert
_G[MOD_CODE].modsetpersistentdata = ModSetPersistentData
_G[MOD_CODE].modgetpersistentdata = ModGetPersistentData
_G[MOD_CODE].GetModSetting = GetModSetting


-- [[                                             ]] --
-- [[ Here is where mod specific env variables go ]] --
-- [[                                             ]] --

-- [[ Constants ]]
_G[MOD_CODE].PARANOIA_SPOOK_TYPES = {
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

_G[MOD_CODE].PARANOIA_SPOOK_TYPES_KEYS = {  }
for type, id in pairs(_G[MOD_CODE].PARANOIA_SPOOK_TYPES) do
    table.insert(_G[MOD_CODE].PARANOIA_SPOOK_TYPES_KEYS, type)
end

_G[MOD_CODE].PARANOIA_STAGES = {
    STAGE0 = 0, -- No paranoia
    STAGE1 = 1,
    STAGE2 = 2,
    STAGE3 = 3,
    STAGE4 = 4,
    STAGE5 = 5,
    STAGE6 = 6
}

_G[MOD_CODE].SHADER_PARAM_LIMITS = {
    SHARPNESS = 0.35,
    MONOCHROMACY = 0.55,
    DISTORION_RADIUS = 0.95,
    DISTORTION_STRENGTH = 14
}

-- [[ Mod Settings ]] -- Not to be confused with configuration_options.
                      -- These show up in Game Options and can be updated during gameplay.
local enableDisableOptions = {
    { text = _G.STRINGS.UI.OPTIONS.DISABLED, data = false },
    { text = _G.STRINGS.UI.OPTIONS.ENABLED,  data = true  }
}

_G[MOD_CODE].SETTING_TYPES = {
    SPINNER = "spinner",
    NUM_SPINNER = "num_spinner",
    LIST = "list",
    KEY_SELECT = "key_select"
}

_G[MOD_CODE].MOD_SETTINGS = {
    FILENAME = "IE_settings",
    TAB_NAME = "Paranoia",
    TOOLTIP = "Modify the mods settings",
    SETTINGS = {
        
    }
}

_G[MOD_CODE].CURRENT_SETTINGS = {  }

-- [[ Misc. Variables ]]

_G[MOD_CODE].PARANOIA_THRESHOLDS = {
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE1] = 0.60,
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE2] = 0.50,
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE3] = 0.40,
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE4] = 0.30,
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE5] = 0.20,
    [_G[MOD_CODE].PARANOIA_STAGES.STAGE6] = 0.15
}

_G[MOD_CODE].HEARTBEAT_START_STAGE = _G[MOD_CODE].PARANOIA_STAGES.STAGE3
_G[MOD_CODE].HEARTBEAT_MAX_VOLUME = 0.55
_G[MOD_CODE].HEARTBEAT_MIN_VOLUME = 0.1
_G[MOD_CODE].HEARTBEAT_MAX_COOLDOWN = 6
_G[MOD_CODE].HEARTBEAT_MIN_COOLDOWN = 2.5

_G[MOD_CODE].SHADER_MODE_TRANSITION_SPEED = 1

_G[MOD_CODE].IN_COMBAT_DURATION = 6
_G[MOD_CODE].BUSY_DURATION = 10
_G[MOD_CODE].PARANOIA_LOW_HEALTH_GAIN_START = 0.5
_G[MOD_CODE].PARANOIA_LOW_HEALTH_MAX_GAIN = 1
_G[MOD_CODE].PARANOIA_DARKNESS_GAIN = 1.67
_G[MOD_CODE].PARANOIA_PLAYER_GHOSTS_GAIN = 0.67
_G[MOD_CODE].PARANOIA_LONELINESS_DIST_SQ = 40 * 40
_G[MOD_CODE].PARANOIA_LONELINESS_GAIN = 0.5

_G[MOD_CODE].PARANOIA_SPOOK_COSTS = { -- Percentage of built up paranoia this spook will consume upon triggering
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

_G[MOD_CODE].PARANOIA_SPOOK_PARAMS = {
    TREECHOP = {
        MIN_DIST_FROM_PLAYER = 8,
        MAX_DIST_FROM_PLAYER = 20,
        TREE_MUST_TAGS = { "evergreens" },
        CHOP_SFX_CHANCE = 0.5,
        LEAF_SFX_CHANCE = 1
    },
    MINING_SOUND = {
        MIN_DIST_FROM_PLAYER = 10,
        MAX_DIST_FROM_PLAYER = 18,
        VOLUME = 0.3
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
        DISAPPEAR_DIST_SQ = 8 * 8
    },
    WHISPER_LOUD = {
        DIST_FROM_PLAYER = 14,
        DISAPPEAR_DIST_SQ = 8 * 8
    },
    BERRYBUSH_RUSTLE = {
        MIN_DIST_FROM_PLAYER = 8,
        MAX_DIST_FROM_PLAYER = 20,
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
            }
        },
        MIN_DIST_FROM_PLAYER = 24,
        MAX_DIST_FROM_PLAYER = 26,
        START_EROSION_DIST_FROM_PLAYER_SQ = 16 * 16
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

_G[MOD_CODE].PARANOIA_SPOOK_WEIGHTS = {
    TREECHOP = {
        forest = 1,
        cave = 1,

        night = 2,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 0.5,
        canseeindark = 3,

        isincombat = 0.67,
        isbusyworking = 4,

        biomes = {
            BGCrappyForest = 3,
            BGForest = 3,
            Forest = 3,
            ForestMole = 3,
            CrappyForest = 3,
            BGDeepForest = 4,
            CrappyDeepForest = 4,
            DeepForest = 4,
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
        cave = 3,
        
        night = 1,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 1,
        canseeindark = 1,

        isincombat = 0.67,
        isbusyworking = 4,

        biomes = {
            RockyPlains = 3,
            RockyHatchingGrounds = 3,
            BatsAndRocky = 3,
            BGRockyCave = 3,
            BGRockyCaveRoom = 3,
            WalrusHut_Rocky = 3,
            BGChessRocky = 3,
            BGRocky = 4,
            Rocky = 4,
            RockyBuzzards = 4,
            GenericRockyNoThreat = 3,
            MolesvilleRocky = 3,
            BGBadlands = 3,
            Badlands = 3,
            HoundyBadlands = 3,
            BuzzardyBadlands = 3,
            BGNoise = 2,
            CritterDen = 2,
            MoonbaseOne = 2,
            MoonIsland_Mine = 2,
            other = 1
        }
    },
    FOOTSTEPS = {
        forest = 1,
        cave = 1,

        night = 4,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 4,
        canseeindark = 1,

        isincombat = 0.5,
        isbusyworking = 2,

        biomes = {
            other = 1
        }
    },
    FOOTSTEPS_RUSH = {
        forest = 1,
        cave = 1,

        night = 5,
        day = 0.33,

        boat = -1,
        land = 1,

        isindark = 2,
        canseeindark = 0.5,

        isincombat = 1,
        isbusyworking = 3,

        biomes = {
            other = 1
        }
    },
    BIRDSINK = {
        forest = 1,
        cave = -1,

        night = 0.33,
        day = 1.5,

        boat = 1,
        land = 0.5,

        isindark = -1,
        canseeindark = 1,

        isincombat = 0.2,
        isbusyworking = 1,

        biomes = {
            other = 1
        }
    },
    SCREECH = {
        forest = 1,
        cave = -1,

        night = 3,
        day = -1,

        boat = -1,
        land = 1,

        isindark = 5,
        canseeindark = 2,

        isincombat = 0.5,
        isbusyworking = 1,

        biomes = {
            Forest = 3,
            ForestMole = 3,
            DeepForest = 4,
            Graveyard = 2,
            MoonbaseOne = 2,
            CrappyForest = 3,
            CrappyDeepForest = 4,
            other = 0.5
        }
    },
    WHISPER_QUIET = {
        forest = 1,
        cave = 0.67,

        night = 2,
        day = 1,

        boat = -1,
        land = 1,

        isindark = 4,
        canseeindark = 2,

        isincombat = 0.2,
        isbusyworking = 3,

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

        night = 2,
        day = 0,

        boat = -1,
        land = 0.5,

        isindark = 3,
        canseeindark = 1,

        isincombat = 0.5,
        isbusyworking = 2,

        biomes = {
            Forest = 2,
            ForestMole = 2,
            DeepForest = 3,
            CrappyForest = 2,
            CrappyDeepForest = 3,
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

        isindark = 0.5,
        canseeindark = 3,

        isincombat = 0.67,
        isbusyworking = 4,

        biomes = {
            other = 3
        }
    },
    OCEAN_BUBBLES = {
        forest = 1,
        cave = -1,

        night = 2,
        day = 2,

        boat = 3,
        land = -1,

        isindark = 1,
        canseeindark = 3,

        isincombat = 1,
        isbusyworking = 4,

        biomes = {
            other = 1
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
            other = 1
        }
    },
    FAKE_PLAYER = {
        forest = 1,
        cave = 1,

        night = 2,
        day = 3,

        boat = -1,
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