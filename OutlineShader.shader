Shader "Custom/OutlineTestShader" {
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineWidth("Outline Width", Range(0.0, 0.74)) = 0.005
        _OutlineFill("Outline Fill", Range(0.0, 54.0)) = 0.0
    }

        SubShader{
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Cull Off
            Lighting Off
            ZWrite Off
            Blend One OneMinusSrcAlpha
            Cull Off
            Tags{ "Queue" = "Transparent" }

            Pass{
                CGPROGRAM
                #pragma vertex vertexFunc
                #pragma fragment fragmentFunc
                #include "UnityCG.cginc"

                sampler2D _MainTex;
                float _OutlineWidth;
                float _OutlineFill;

                struct v2f {
                    float4 pos : SV_POSITION;
                    half2 uv : TEXCOORD0;
                };

                v2f vertexFunc(appdata_base v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texcoord;
                    return o;
                }

                fixed4 _Color;
                float4 _MainTex_TexelSize;
                fixed4 _OutlineColor;

                fixed4 fragmentFunc(v2f i) : COLOR{
                    half4 c = tex2D(_MainTex, i.uv);
                    c.rgb *= c.a;
                    half4 outlineC = _OutlineColor;

                    float2 texel = _MainTex_TexelSize.xy;
                    float2 offset = _OutlineWidth * texel;
                    float4 sum = 0;

                    sum += tex2D(_MainTex, i.uv + float2(-offset.x, -offset.y));
                    sum += tex2D(_MainTex, i.uv + float2(offset.x, -offset.y));
                    sum += tex2D(_MainTex, i.uv + float2(-offset.x,  offset.y));
                    sum += tex2D(_MainTex, i.uv + float2(offset.x,  offset.y));

                    sum *= _OutlineColor.a * _OutlineFill;

                    outlineC.a *= ceil(sum.a);
                    outlineC.rgb *= outlineC.a;
                    return lerp(outlineC, c, c.a);
                }
                ENDCG
            }
        }
}
