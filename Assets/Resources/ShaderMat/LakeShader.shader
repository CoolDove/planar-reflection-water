Shader "Dove/lake"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (.3,.6,.8,1)
        _BaseColorB("BaseColorB", Color) = (.2,.4,.6,1)
        _Reflection("Reflection", float) = .6
        _ReflectionTex("ReflectionTex", 2D) = "white" {}
        _EdgePower("EdgePower", float) = 1
        _EdgeWidth("EdgeWidth", float) = 0
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalPipeline" 
            "Queue"="Transparent+1"
        }

        Pass
        {
            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }

            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "DShaderHelper/DCore.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos_cs : SV_POSITION;
                float4 pos_scr : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseTex_ST;
            CBUFFER_END

            float4 _BaseColor;
            float4 _BaseColorB;
            float _Reflection;
            float _EdgePower;
            float _EdgeWidth;
            DTEX(_ReflectionTex);
            DTEX(_CameraDepthTexture);

            v2f vert (appdata v)
            {
                VertexPositionInputs inputs = GetVertexPositionInputs(v.vertex);
                v2f o;
                o.pos_cs = inputs.positionCS;
                o.pos_scr = ComputeScreenPos(inputs.positionCS);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 scr_uv = half2(i.pos_scr.x/i.pos_scr.w, i.pos_scr.y/i.pos_scr.w);

                half4 base = _BaseColor;
                half4 reflec = DSAMPLE(_ReflectionTex, half2(1 - scr_uv.x, scr_uv.y));
                reflec.w = 1;

                float depth = DSAMPLE(_CameraDepthTexture, scr_uv);
                depth = LinearEyeDepth(depth, _ZBufferParams);
                float dis = abs(i.pos_scr.w - depth);
                dis = dis * _EdgePower + _EdgeWidth;
                dis = clamp(dis, 0, 1);

                half4 col = lerp(_BaseColor, _BaseColorB, dis);
                col = lerp(col, reflec, _Reflection);
                col.w = 1;
                return col;
            }
            ENDHLSL
        }
    }
}