Shader "Unlit/Test" // путь для инспектора материала и имя шейдера
{
    // ShaderLab код
    Properties
    {
        // Свойствами можно манипулировать из Инспектора
        //                                          _ИмяСвойства ("отображаемое имя", тип) = изначальноеЗначение
        //                                                                       ..., Range(min, max)...                (0)
        //                                                                       ..., Float ...                         (0)
        //                                                                       ..., Int ...                           (0)
        //                                                                       ..., Color) = (R, G, B, A)             (0)
        //                                                                       ..., Vector) = (0, 0, 0, 1)            (0)
        //                                                                       ..., 2D) = изначальныйЦветТекстуры     (0)
        //                                                                       ..., Cube ...                          (0)
        //                                                                       ..., 3D ...                            (0)
        // [Toggle]                                                              ..., Float) = 0   <== имитирует boolean (1)
        // [KeywordEnum(StateOff, State01, etc...)]                              ..., Float) = 0   <== выпадающее меню со списком состояний (2)
        // [Enum(key1, value1, key2, value2, etc ...)]                           ..., Float) = 0   <== выпадающее меню со списком ключ-значение (3)
        // [PowerSlider(3.0)]                                                    ..., Range (0.01, 1)) = 0.08           (0)
        // [IntRange]                                                            ..., Range (0, 255)) = 100             (0)
        //
        // Разметка
        // [Space(10)]
        // [Header(Category name)]
        // Использование uniform в коде HLSL и CG может быть пропущенно. Так как ShaderLab делает это автоматический.
        
        // Пример:
        _Specular ("Specular", Range(0.0, 1.1)) = 0.3
        _Factor ("Color Factor", Float) = 0.3
        _Cid ("Color id", Int) = 2
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _VPos ("Vertex Position", Vector) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Reflection ("Reflection", Cube) = "black" {}
        _3DTexture ("3D Texture", 3D) = "white" {}
        [Header(Material properties drawers)]
        [Space(10)]
        [Toggle] _Enable ("Enable ?", Float) = 0
        [KeywordEnum(Off, Red, Blue)] _Options ("Color Options", Float) = 0
        [Enum(Off, 0, Front, 1, Back, 2)] _Face ("Face Culling", Float) = 0
        [PowerSlider(3.0)] _Brightness ("Brightness", Range(0.01, 1)) = 0.08 // чем отличается от _Specular?
        [IntRange] _Samples ("Samples", Range(0, 255)) = 100
    }
    SubShader // может быть несколько SubShader-ов будет выбран тот чье возможности наиболее подходят для текущего устройства. Например: IOS библиотека Metal
    {
        // SubShader настройки
        
        /* Как и когда исполняется SubShader. Если написать здесь, тогда будет наробать на все Pass  (4) */
        /* Tags                                                                                          */
        /* {                                                                                             */
        /*    "TagName1"="TagValue1"                                                                     */
        /*    "TagName2"="TagValue2"                                                                     */
        /* }                                                                                             */
        /*                                                                                               */
        /* Тег по умолчанию Geometry связан с камерой. Определяет в каком месте z буфера будет материал  */
        /* Возможные значения Background позади всех других материалов. Geometry значение по умолчани.   */
        /* AlphaTest мужду геометрией и прозрачными объектами. Transparent прозрачные объекты. Overlay UI*/
        Tags { "Queue"="Geometry" }    /*        по умолчанию в коде не пишется. Связан с камерой        */ 
        /* ??? replacement через скрипт замена шейдера */
        Tags { "RenderType"="Opaque" } /* Opaque по умолчанию                                            */
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        
        LOD 100
        Cull [_Face] // Команда для отображения поверхности полигона Off Back Front (3)
        // Blend [SourceFactor] [DestinationFactor] смешивание цветов, при прозрачности
        // Tags { "Queue"="Transparent" } Tags { "RenderType"="Transparent" } должны быть включены
        Blend SrcAlpha OneMinusSrcAlpha // Различные настройки
        ColorMask RGB // Исключение цветов R, G, B, GB, RA ... и т.д.
        //ZWrite Off выключить z-buffer для устранения z-fighting для прозрачных объектов
        //ZTest Less в каком порядке сортировать z-buffer
        //        Stencil  какие пиксели отображать, а какие нет. Часто используется для сосздания окон и зеркал.
        //        {
        //            Ref 2
        //            Comp NotEqual   
        //            Pass Keep
        //            ... много параметров
        //        }

        // Pass можно понимать как слой. То есть один pass накладывает цвета, потом свет и т.д.
        Pass // Каждый раз когда мы передаем все объекты попадающие в frustrum мы вызываем draw call. Количество Pass определяет кол-во draw call-ов.
        {
            // Cull можно написать здесь (3) аналогично Tags
            // Tags можно написать здесь, тогда будет действовать только на этот Pass (4)

            CGPROGRAM // или HLSLPROGRAM
            // Программа на языке HLSL или CG

            // Типы данных:
            // Числа с плавающей точкой
            // float - 32 bit. Позиция в мире, координаты текстур, сложные вычисления например с тригонометрией.
            // half - 16 bit. Вектор направления, позиция в пространстве объекта, и для плавного изменения цвета.
            // fixed - 11 bit. Простые операции. Например с цветами.
            //
            // float2 uv = float2(0.5, 0.5);
            // fixed4 color = float4(0.1, 0.5, 0.3, 1.0)
            //
            // float3x3 name = float 3x3
            // (
            //      1, 0, 0,
            //      0, 1, 0,
            //      0, 0, 1
            // );
            //
            // Другие данные
            // sampler2D - хранения текстур и UV. Связывает Texture2D и SamplerState в одну переменую. (5)
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            /*  Pragmas - включают определенные функции которые иначе были бы не распознаны компилятором              */
            /*   ShaderLab преобразует Toggle и KeywordEnum в константы. Все константы пишутся большими буквами.      */
            /*   Данный подход не повзоляет менять значение в runtime в билде.                                        */
            #pragma shader_feature _ENABLE_ON /* ON означает изначальное значение. Другие приставки не работают. (1)  */
            /* Можно менять в runtime, так как все варианты шейдера будут сохранены в билде. (2)                      */
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE /*                                          */
            /* Включить функцию v2f vert (appdata v) {}, для манипуляции с вершинами перед передачей в frag           */
            #pragma vertex vert /*                                                                                    */
            /* Включить функцию fixed4 frag (v2f i) : SV_Target {}, для манипуляции с цветами пикселей                */
            #pragma fragment frag /*                                                                                  */
            /* Директива, двойного назначения multi_compile позволяет вариативность шейдера.                          */
            /* _fog включает туман из настроик освещения Unity (Environment/Other).                                   */
            #pragma multi_compile_fog /*                                                                              */
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////

            #include "UnityCG.cginc" // Добавить функции или переменые из файла Windows: {unity install path}/Data/CGIncludes/UnityCG.cginc (6)

            // Составные типы данных:
            struct appdata // Стандартная структура vertex input
            {
                float4 vertex : POSITION; // vector[n] name : SEMANTIC[n];
                float2 uv : TEXCOORD0;    //                  семантика определяет как используется параметр

                float3 normal : NORMAL0;
                float3 tangent : TANGENT0;
                float3 vertColor: COLOR0;
            };

            struct v2f // Стандартная структура vertex output или v2f (vertex to fragment)
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1) //                             (6)
                float4 vertex : SV_POSITION;
                
                float3 binormalWorld : TEXCOORD2;
                float3 normalWorld : TEXCOORD3;
                float3 vertColor: COLOR0;
            };

            /* Связывание свойства с переменной (0)  */
            float _Specular; /*                      */
            float _Factor; /*                        */
            int _Cid; /*                             */
            float4 _Color; /*                        */
            float4 _VPos; /*                         */
            sampler2D _MainTex; /*                   */
            samplerCUBE _Reflection; /*              */
            sampler3D _3DTexture; /*                 */
            float _Brightness; /*                    */
            int _Samples; /*                         */
            ///////////////////////////////////////////
            
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //       (6)
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //            (6)
                UNITY_TRANSFER_FOG(o,o.vertex); //                  (6)
                return o;
            }

            //                , bool face : SV_IsFrontFace) определяет пиксель снаружи или внутри объекта. Работает если Cull Off
               fixed4 frag (v2f i) : SV_Target
            // half4 если HLSL       SV_Target (System Value Target) output который позволяет рендерить в промежуточный буффер (render target)
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv); // вместо _MainTex.Sample(sampler_MainTex, i.uv) (5)
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col); //                (6)
                
                #if _ENABLE_ON // (1)
                    return col * _Color;
                #else
                    #if _OPTIONS_OFF // (2)
                        return col;
                    #elif _OPTIONS_RED
                        return col * float4(1, 0, 0, 1);
                    #elif _OPTIONS_BLUE
                        return col * float4(0, 0, 1, 1);
                    #endif
                #endif
            }
            ENDCG // или ENDHLSL
        }
    }
    
    Fallback "Mobile/Unlit" // Если шейдер генерит ошибку, тогда будет отрабатывать другой шейдер.
}
