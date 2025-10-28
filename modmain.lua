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
-- modimport("scripts/IEmodsettings")

-- [[ Mod strings ]]
modimport("scripts/IEstrings")

-- [[ Core Mod Script ]]
modimport("scripts/IEmain")

-- local UIAnim = require ("widgets/uianim")
-- local TEMPLATES = require("widgets/redux/templates")
-- local old_TEMPLATES_ModListItem = TEMPLATES.ModListItem
-- TEMPLATES.ModListItem = function(onclick_btn, onclick_checkbox, onclick_setfavorite, ...)
--     local opt = old_TEMPLATES_ModListItem(onclick_btn, onclick_checkbox, onclick_setfavorite, ...)

--     opt.anim_icon = opt:AddChild(UIAnim())
--     opt.anim_icon:Hide()

--     local old_opt_SetMod = opt.SetMod
--     opt.SetMod = function(self, modname, modinfo, ...)
--         old_opt_SetMod(self, modname, modinfo, ...)
    
--         if modinfo.anim_icon then
--             opt.image:Hide()

--             opt.anim_icon:GetAnimState():SetBank(modinfo.anim_icon_bank)
--             opt.anim_icon:GetAnimState():SetBuild(modinfo.anim_icon_build)
--             opt.anim_icon:GetAnimState():PushAnimation("idle", true)
--             opt.anim_icon:SetClickable(false)
--             opt.anim_icon:Show()
--         else
--             opt.image:Show()
            
--             opt.anim_icon:Hide()
--         end
--     end

--     return opt
-- end