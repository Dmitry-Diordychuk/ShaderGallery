Shader "Unlit/NormalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
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
                float3 normal : NORMAL;    // Нормаль объекта.                                                          (0)
                float4 tangent : TANGENT; // Касательная объекта.
                //                           Они находятся в пространстве объекта их нужно перегнать в мировые кординаты
                //                           потом пространство касательных.
                // binormal юнити выбрасывает, так как мы всегда можем вычислить этот вектор через normal и tangent,
                // но направление записывается в tangent.w. По этой причине tangent float4
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_normal : TEXCOORD1;
                float3 normal_world : TEXCOORD2; // нормаль записывается в TEXCOORD,
                                           // так как frag не работает с такой семантикой как NORMAL                    (0)
                float3 tangent_world : TEXCOORD3; // тоже самое с TANGENT и NORMAL
                float3 binormal_world : TEXCOORD4; //TEXCOORD[ID] важно устанавливай разный ID. Иначе операции будут накладываться на дубликаты.
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap); // add tilling and offset
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz; // Переведем в мировые normal и tangent
                o.tangent_world = normalize(mul(unity_ObjectToWorld, v.tangent)).xyz;
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w); // Вычислим binormal
                
                return o;
            }

            // Unity хранит нормали следующим образом:
            // NORMALx = 2Alpha - 1; NORMALy = 2Green - 1; NORMALz = sqrt(1 - NORMALx^2 - NORMALy^2);
            // Последняя формула вытикает из нормализованости нормалей. Нас интересует только положительный корень
            // уравнения, так как нормали проходят вдоль +z.
            float3 DXTCompression (float4 normal_map)
            {
            #if defined (UNITY_NO_DXT5nm) 
                return normalMap.rgb * 2 - 1; // Если карта нормалей не сжималась.
            #else
                float3 normal_col = float3 (normal_map.a * 2.0 - 1.0, normal_map.g * 2.0 - 1.0, 0);
                normal_col.b = sqrt(1 - (pow(normal_col.r, 2) + pow(normal_col.g, 2)));
                return normal_col;
            #endif
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                fixed3 normal_compressed = DXTCompression(normal_map); // UnpackNormal(normal_map);
                float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world,
                    i.binormal_world,
                    i.normal_world
                );
                
                fixed3 normal_color = normalize(mul(normal_compressed, TBN_matrix)); // Повернет нормали правильно к текущей проскости
                return float4(normal_color, 1);
            }
            ENDCG
        }
    }
}
