// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Grass Geometry Shader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_GrassHeight("Grass Height", Float) = 0.25
		_GrassWidth("Grass Width", Float) = 0.25
		_AlphaClip("Alpha Clipping", Range(0,1)) = 0.25

	}
		SubShader{
		Tags{ "LightMode" = "ForwardBase" "RenderType" = "Opaque" }
		LOD 200

		Pass
	{
		CULL OFF

		CGPROGRAM
#include "UnityCG.cginc" 
#pragma vertex vert
#pragma fragment frag
#pragma geometry geom

		// Use shader model 4.0 target, we need geometry shader support
#pragma target 4.0

		sampler2D _MainTex;

	struct v2g
	{
		float4 pos : SV_POSITION;
		float3 norm : NORMAL;
		float2 uv : TEXCOORD0;
		float3 color : TEXCOORD1;
	};

	struct g2f
	{
		float4 pos : SV_POSITION;
		float3 norm : NORMAL;
		float2 uv : TEXCOORD0;
		float3 diffuseColor : TEXCOORD1;
		//float3 specularColor : TEXCOORD2;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	half _GrassHeight;
	half _GrassWidth;
	half _AlphaClip;

	v2g vert(appdata_full v)
	{
		float3 v0 = v.vertex.xyz;

		v2g OUT;
		OUT.pos = v.vertex;
		OUT.norm = v.normal;
		OUT.uv = v.texcoord;
		OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;
		return OUT;
	}

	[maxvertexcount(4)]
	void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
	{
		float3 lightPosition = _WorldSpaceLightPos0;

		float3 perpendicular = float3(1,0,0);

		float3 faceNormal = cross(perpendicular, IN[0].norm);
		//float4 worldNormal = normalize(mul(unity_ObjectToWorld, faceNormal));

		// the point in the center of the lower part of the quad. Lower center point.
		float3 v0 = IN[0].pos.xyz;
		// the point in the center of the upper part of the quad. Upper center point.
		float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;
		
		float3 color = IN[0].color;

		//float lightStrength = max(dot(normalize(lightPosition), worldNormal), 0);

		g2f OUT;
		// the lower right
		OUT.pos = UnityObjectToClipPos(v0 + perpendicular * 0.5 * _GrassHeight);
		OUT.norm = faceNormal;
		OUT.diffuseColor = color; //* lightStrength;
		OUT.uv = float2(1, 0);
		triStream.Append(OUT);

		//the lower left
		OUT.pos = UnityObjectToClipPos(v0 - perpendicular * 0.5 * _GrassHeight);
		OUT.norm = faceNormal;
		OUT.diffuseColor = color; //* lightStrength;
		OUT.uv = float2(0, 0);
		triStream.Append(OUT);

		// the upper right
		OUT.pos = UnityObjectToClipPos(v1 + perpendicular * 0.5 * _GrassHeight);
		OUT.norm = faceNormal;
		OUT.diffuseColor = color; //* lightStrength;
		OUT.uv = float2(1, 1);
		triStream.Append(OUT);

		// the upper left
		OUT.pos = UnityObjectToClipPos(v1 - perpendicular * 0.5 * _GrassHeight);
		OUT.norm = faceNormal;
		OUT.diffuseColor = color;// *lightStrength;
		OUT.uv = float2(0, 1);
		triStream.Append(OUT);
	}

	half4 frag(g2f IN) : COLOR
	{
		fixed4 c = tex2D(_MainTex, IN.uv);
		clip(c.a - _AlphaClip);
		return c;// float4(IN.diffuseColor.rgb, 1.0);
	}
		ENDCG

	}
	}
}
