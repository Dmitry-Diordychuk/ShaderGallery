Shader "Unlit/Chess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange]_Size ("Size", Range(1, 10)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Size;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv *= _Size;
                float2 fuv = frac(i.uv);
                if (step(fuv.x, 0.5) == step(fuv.y, 0.5))
                {
                    return float4(1, 1, 1, 1);
                }
                else
                {
                    return float4(0, 0, 0, 1);
                }
            }
            ENDCG
        }
    }
}
