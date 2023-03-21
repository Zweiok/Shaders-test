Shader "Unlit/TestFrag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionRate("Distortion Rate", Range(1,50)) = 30
        _RotationSpeed("Rotation Speed", Range(0.0, 10.0)) = 3.0
        _DistortionColor("Distortion Color", Color) = (0,0,0,0)
        _DistorionOffset("Distortion Offset", Vector) = (0,0,0)
        _DistortSize("Distort Size", Range(0.001, 0.1)) = 0.05
        _DistortTransparencyMult("Distort Transparency Mulipier", Range(0.0, 1.0)) = 1
        [MaterialToggle] _EnableWholeTexture("Enable Whole Texture", Float) = 0
        [MaterialToggle] _EnableDistortion("Enable Distortion", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
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
            float _DistortionRate;
            float _RotationSpeed;
            float _DistortSize;
            fixed4 _DistortionColor;
            float2 _DistorionOffset;
            bool _EnableWholeTexture;
            bool _EnableDistortion;
            float _DistortTransparencyMult;

            v2f vert (appdata v)
            {
                v2f o;
               // v.vertex.y += sin(v.vertex.z + _Time.y);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float alpha = 1;
                fixed4 col = tex2D(_MainTex, i.uv);
                // sample the texture
                if (_EnableDistortion) 
                {
                    float2 uv = i.uv - 0.5;
                    float2 distort = uv + _DistorionOffset;
                    float distance = length(distort);
                    float interpolation = smoothstep(_DistortSize, _DistortSize / 15, distance);
                    distort *= interpolation * _DistortionRate;
                    float angle = _Time.y * _RotationSpeed;
                    float2x2 rotation =
                        float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));

                    distort = mul(rotation, distort);
                    i.uv += distort;

                    col = tex2D(_MainTex, i.uv);
                    col.rgb += _DistortionColor * interpolation;

                    if (interpolation <= 0)
                    {
                        alpha = 0;
                    }
                    else 
                    {
                        alpha = clamp(interpolation * 5, 0, 1);
                    }
                }
                

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return fixed4(col.r, col.g, col.b, alpha * _DistortTransparencyMult);
            }
            ENDCG
        }
    }
}
