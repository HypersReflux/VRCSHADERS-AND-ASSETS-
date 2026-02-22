Shader "Custom/VRChat/ProceduralLavaTriplanar"
{
    Properties
    {
        _ColdColor ("Cold Rock Color", Color) = (0.08, 0.08, 0.09, 1)
        _HotColor ("Hot Lava Color", Color) = (1.0, 0.35, 0.0, 1)
        _GlowColor ("Glow Color", Color) = (1.0, 0.8, 0.2, 1)
        _NoiseScale ("Noise Scale", Range(0.2, 20)) = 4.5
        _FlowSpeed ("Flow Speed", Range(0, 5)) = 0.75
        _CrackWidth ("Crack Width", Range(0.01, 0.8)) = 0.24
        _Emission ("Emission", Range(0, 8)) = 2.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _ColdColor;
            fixed4 _HotColor;
            fixed4 _GlowColor;
            float _NoiseScale;
            float _FlowSpeed;
            float _CrackWidth;
            float _Emission;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            float hash31(float3 p)
            {
                p = frac(p * 0.1031);
                p += dot(p, p.yzx + 19.19);
                return frac((p.x + p.y) * p.z);
            }

            float valueNoise(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);

                float n000 = hash31(i + float3(0,0,0));
                float n100 = hash31(i + float3(1,0,0));
                float n010 = hash31(i + float3(0,1,0));
                float n110 = hash31(i + float3(1,1,0));
                float n001 = hash31(i + float3(0,0,1));
                float n101 = hash31(i + float3(1,0,1));
                float n011 = hash31(i + float3(0,1,1));
                float n111 = hash31(i + float3(1,1,1));

                float nx00 = lerp(n000, n100, f.x);
                float nx10 = lerp(n010, n110, f.x);
                float nx01 = lerp(n001, n101, f.x);
                float nx11 = lerp(n011, n111, f.x);
                float nxy0 = lerp(nx00, nx10, f.y);
                float nxy1 = lerp(nx01, nx11, f.y);
                return lerp(nxy0, nxy1, f.z);
            }

            float fbm(float3 p)
            {
                float v = 0.0;
                float a = 0.5;
                for (int j = 0; j < 4; j++)
                {
                    v += valueNoise(p) * a;
                    p *= 2.03;
                    a *= 0.5;
                }
                return v;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 n = normalize(abs(i.worldNormal));
                n /= max(dot(n, 1.0), 1e-4);

                float t = _Time.y * _FlowSpeed;
                float3 p = i.worldPos * _NoiseScale;

                float nx = fbm(float3(p.y, p.z, t));
                float ny = fbm(float3(p.x, p.z, t + 11.3));
                float nz = fbm(float3(p.x, p.y, t + 23.7));
                float noise = nx * n.x + ny * n.y + nz * n.z;

                float cracks = smoothstep(_CrackWidth, _CrackWidth + 0.08, noise);
                float lava = 1.0 - cracks;

                float shimmer = sin((noise + t * 2.0) * 20.0) * 0.5 + 0.5;
                lava *= 0.7 + shimmer * 0.3;

                fixed3 baseCol = lerp(_HotColor.rgb, _ColdColor.rgb, cracks);
                fixed3 emissive = (_HotColor.rgb * 0.6 + _GlowColor.rgb * 0.8) * lava * _Emission;

                return fixed4(baseCol + emissive, 1.0);
            }
            ENDCG
        }
    }
}
