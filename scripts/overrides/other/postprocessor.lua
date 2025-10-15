AddModShadersInit(function()
    local pp_mt_index = _G.getmetatable(_G.PostProcessor).__index

    local old_pp_SetDistortionEnabled = pp_mt_index.SetDistortionEnabled
    pp_mt_index.SetDistortionEnabled = function(self, enabled, ...)
        old_pp_SetDistortionEnabled(self, false, ...) -- Don't allow any original distortions
    end

    local old_pp_SetColourCubeLerp = pp_mt_index.SetColourCubeLerp
    pp_mt_index.SetColourCubeLerp = function(self, index, lerp, ...)
        if index == 1 then
            old_pp_SetColourCubeLerp(self, index, 0, ...) -- Don't allow original desaturation
        else
            old_pp_SetColourCubeLerp(self, index, lerp, ...)
        end
    end
end)