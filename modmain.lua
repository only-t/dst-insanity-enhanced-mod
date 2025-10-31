env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

Assets = {
    Asset("SHADER", "shaders/pp_paranoiaeffect.ksh"),
    Asset("SHADER", "shaders/pp_paranoiadistortions.ksh"),
    
    Asset("SOUNDPACKAGE", "sound/paranoia.fev"),
    Asset("SOUND", "sound/paranoia.fsb"),

    -- Asset("ANIM", "anim/IEicon.zip"),

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

_G.IE.modprint(_G.IE.PRINT, "Loading mod...",
                            require("IEcard"))

-- [[ Mod settings ]]
modimport("scripts/IEmodsettings")

-- [[ Mod strings ]]
modimport("scripts/IEstrings")

-- [[ Core Mod Script ]]
modimport("scripts/IEmain")