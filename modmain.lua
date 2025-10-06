env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

Assets = {
    Asset("SHADER", "shaders/pp_paranoiaeffect.ksh"),
    Asset("SHADER", "shaders/pp_paranoiadistortions.ksh"),
    
    Asset("SOUNDPACKAGE", "sound/paranoia.fev"),
    Asset("SOUND", "sound/paranoia.fsb"),

    -- Asset("ANIM", "anim/ocean_shadow.zip"),

    -- Sounds from the Screecher
    Asset("SOUNDPACKAGE", "sound/scary_mod.fev"),
    Asset("SOUND", "sound/scary_mod.fsb")
}

PrefabFiles = {
    "spooks"
}

-- [[ Mod environment ]]
modimport("scripts/IEenv")
modimport("scripts/IEutil")

-- [[ Mod settings ]]
modimport("scripts/IEmodsettings")

-- [[ Mod strings ]]
modimport("scripts/IEstrings")

-- [[ Core Mod Script ]]
modimport("scripts/IEmain")