Shader "Unlit/Circle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Center", Vector) = (0, 0, 0, 1)
        _Radius ("Radius", Float) = 0.5
        _Smooth ("Smooth", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

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
            float2 _Center;
            float _Radius;
            float _Smooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float circle(float2 p, float2 center, float radius, float smooth)
            {
                float c = length(p - center);
                return smoothstep(c - smooth, c + smooth, radius);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float c = circle(i.uv, _Center, _Radius, _Smooth);
                return float4(c.xxx, 1);
            }
            ENDCG
        }
    }
}
