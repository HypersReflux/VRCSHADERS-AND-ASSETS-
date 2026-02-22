Shader "Custom/VRChat/ProceduralHologram"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.1, 0.7, 1.0, 1.0)
        _RimColor ("Rim Color", Color) = (0.2, 1.0, 1.0, 1.0)
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.5
        _ScanlineDensity ("Scanline Density", Range(10, 300)) = 120
        _ScanlineSpeed ("Scanline Speed", Range(0, 4)) = 1.25
        _GlitchStrength ("Glitch Strength", Range(0, 0.2)) = 0.03
        _GlitchSpeed ("Glitch Speed", Range(0, 30)) = 12
        _Emission ("Emission", Range(0, 4)) = 1.3
        _Alpha ("Alpha", Range(0, 1)) = 0.85
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _BaseColor;
            fixed4 _RimColor;
            float _RimPower;
            float _ScanlineDensity;
            float _ScanlineSpeed;
            float _GlitchStrength;
            float _GlitchSpeed;
            float _Emission;
            float _Alpha;

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
            };

            float hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }

            v2f vert(appdata v)
            {
                v2f o;

                float3 world = mul(unity_ObjectToWorld, v.vertex).xyz;
                float glitchSeed = floor(world.y * 25 + _Time.y * _GlitchSpeed);
                float glitch = (hash(glitchSeed) - 0.5) * 2.0 * _GlitchStrength;
                world.x += glitch;

                o.pos = UnityWorldToClipPos(float4(world, 1.0));
                o.worldPos = world;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - world);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);
                float3 V = normalize(i.viewDir);

                float rim = pow(1.0 - saturate(dot(N, V)), _RimPower);

                float scan = sin((i.worldPos.y + _Time.y * _ScanlineSpeed) * _ScanlineDensity);
                scan = scan * 0.5 + 0.5;
                scan = smoothstep(0.35, 1.0, scan);

                float pulse = sin(_Time.y * 3.2 + i.worldPos.y * 8.0) * 0.5 + 0.5;
                float intensity = (scan * 0.65 + rim * 1.2 + pulse * 0.25) * _Emission;

                fixed3 color = _BaseColor.rgb + _RimColor.rgb * rim;
                color *= intensity;

                float alpha = saturate(_Alpha * (0.5 + rim + scan * 0.3));
                return fixed4(color, alpha);
            }
            ENDCG
        }
    }
}
