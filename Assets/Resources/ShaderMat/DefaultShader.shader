Shader "Dove/default"
{
    Properties
    {
        _BaseTex("BaseTex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline" 
            "Queue"="Geometry+1"
        }

        Pass
        {
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
                float3 posWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseTex_ST;
            CBUFFER_END
            
            TEXTURE2D(_BaseTex);
            SAMPLER(sampler_BaseTex);

            v2f vert (appdata v)
            {
                VertexPositionInputs inputs = GetVertexPositionInputs(v.vertex);
                v2f o;
                o.vertex = inputs.positionCS;
                o.posWS = inputs.positionWS;
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, i.uv);
                col.w *= i.posWS.y;
                // return half4(col.w, col.w, col.w, 1);
                return col;
            }
            ENDHLSL
        }
    }
}