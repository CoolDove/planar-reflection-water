#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#define DTEX(x) TEXTURE2D(x); SAMPLER(sampler_##x)
#define DSAMPLE(x, uv) x.Sample(sampler_##x, uv)
