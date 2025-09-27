AddModShadersInit(function()
    _G.UniformVariables.PARANOIA_PARAMS1 = _G.PostProcessor:AddUniformVariable("PARANOIA_PARAMS1", 2)
    _G.UniformVariables.PARANOIA_PARAMS2 = _G.PostProcessor:AddUniformVariable("PARANOIA_PARAMS2", 2)

    _G.SamplerEffects.ParanoiaEffect = _G.PostProcessor:AddSamplerEffect(_G.resolvefilepath("shaders/pp_paranoiaeffect.ksh"), _G.SamplerSizes.Relative, 1.0, 1.0, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.PostProcessSampler)
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.ParanoiaEffect, _G.UniformVariables.SAMPLER_PARAMS)
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.ParanoiaEffect, _G.UniformVariables.PARANOIA_PARAMS1)

    _G.PostProcessorEffects.ParanoiaDistortions = _G.PostProcessor:AddPostProcessEffect(_G.resolvefilepath("shaders/pp_paranoiadistortions.ksh"))
    _G.PostProcessor:AddSampler(_G.PostProcessorEffects.ParanoiaDistortions, _G.SamplerEffectBase.Shader, _G.SamplerEffects.ParanoiaEffect)
    _G.PostProcessor:SetEffectUniformVariables(_G.PostProcessorEffects.ParanoiaDistortions, _G.UniformVariables.PARANOIA_PARAMS2)

    _G.PostProcessor:SetUniformVariable(_G.UniformVariables.PARANOIA_PARAMS1, 0, 0)
    _G.PostProcessor:SetUniformVariable(_G.UniformVariables.PARANOIA_PARAMS2, 0, 0)
end)

AddModShadersSortAndEnable(function()
    _G.PostProcessor:SetPostProcessEffectAfter(_G.PostProcessorEffects.ParanoiaDistortions, _G.PostProcessorEffects.Bloom)
    _G.PostProcessor:EnablePostProcessEffect(_G.PostProcessorEffects.ParanoiaDistortions, true)
end)