Shader "Dove/reflection_planar"
{
    Properties
    {
        _ReflectionMap ("ReflectionTexture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "RenderPipeline"="UniversalPipeline" 
            "Queue"="Transparent+1"
        }
        LOD 100

        Pass
        {
            // Stencil {
            //     Ref 1
            //     Comp Equal
            // }

            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ReflectionMap_ST;
            CBUFFER_END
            
            TEXTURE2D(_ReflectionMap);
            SAMPLER(sampler_ReflectionMap);
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs inputs = GetVertexPositionInputs(v.vertex);
                o.vertex = inputs.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _ReflectionMap);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = _ReflectionMap.Sample(sampler_ReflectionMap, i.uv);
                col.w = 1;

                half depth = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, half2(1 - i.uv.x, i.uv.y));
                // Linear01Depth();
 
                return half4(depth, depth, depth, 1);
            }
            ENDHLSL
        }
    }
}
