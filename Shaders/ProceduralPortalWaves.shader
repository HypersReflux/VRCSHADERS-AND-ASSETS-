Shader "Custom/VRChat/ProceduralPortalWaves"
{
    Properties
    {
        _ColorA ("Color A", Color) = (0.05, 0.1, 1.0, 1.0)
        _ColorB ("Color B", Color) = (1.0, 0.0, 0.8, 1.0)
        _RingScale ("Ring Scale", Range(1, 20)) = 8
        _WaveSpeed ("Wave Speed", Range(0, 8)) = 2.2
        _SpiralStrength ("Spiral Strength", Range(0, 10)) = 4.0
        _FresnelPower ("Fresnel Power", Range(0.1, 8)) = 2.0
        _Emission ("Emission", Range(0, 8)) = 1.8
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 150

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _RingScale;
            float _WaveSpeed;
            float _SpiralStrength;
            float _FresnelPower;
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
                float3 viewDir : TEXCOORD2;
                float3 localPos : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
                o.localPos = v.vertex.xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 p = i.localPos.xz;
                float radius = length(p);
                float angle = atan2(p.y, p.x);

                float spiral = sin(angle * _SpiralStrength + _Time.y * _WaveSpeed * 1.4);
                float rings = sin(radius * _RingScale * 6.2831 - _Time.y * _WaveSpeed + spiral * 1.5);
                rings = rings * 0.5 + 0.5;

                float flow = sin((p.x + p.y) * 7.0 + _Time.y * _WaveSpeed * 0.7) * 0.5 + 0.5;
                float mask = smoothstep(1.0, 0.0, radius);

                float fresnel = pow(1.0 - saturate(dot(normalize(i.worldNormal), normalize(i.viewDir))), _FresnelPower);
                float mixVal = saturate(rings * 0.8 + flow * 0.2);

                fixed3 col = lerp(_ColorA.rgb, _ColorB.rgb, mixVal + fresnel * 0.25);
                col *= (0.4 + rings * 0.7 + fresnel * 0.8) * _Emission;
                col *= mask;

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
