// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Grass Geometry Complex Shader" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_GrassHeight("Grass Height", Float) = 0.25
		_GrassWidth("Grass Width", Float) = 0.25
		_AlphaClip("Alpha Clipping", Range(0,1)) = 0.25
		_WindStrength("Wind Strength", Float) = 0.25
		_WindSpeed("Wind Speed", Range(0,500)) = 1.0
		_Angle("Angle", Range(0,359)) = 0
	}
		SubShader
		{
			
			LOD 200

			Pass
			{
				Tags{ "LightMode" = "ForwardBase" "RenderType" = "Opaque" }
				CULL OFF

				CGPROGRAM
				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc" // for _LightColor0
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom


				// compile shader into multiple variants, with and without shadows
				// (we don't care about any lightmaps yet, so skip these variants)
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				// shadow helper functions and macros
				#include "AutoLight.cginc"
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
					fixed4 diff : COLOR0; // diffuse lighting color
					fixed3 ambient : COLOR1;
					SHADOW_COORDS(2) // put shadows data into TEXCOORD2
				};

				half _Glossiness;
				half _Metallic;
				fixed4 _Color;
				half _GrassHeight;
				half _GrassWidth;
				half _AlphaClip;
				half _WindStrength;
				half _WindSpeed;
				half _Angle;

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

				void buildQuad(inout TriangleStream<g2f> triStream, float3 points[4], float3 color, half nl, half3 worldNormal) 
				{
					g2f OUT;
					float3 faceNormal = cross(points[1] - points[0], points[2] - points[0]);
					for (int i = 0; i < 4; ++i) 
					{
						OUT.pos = UnityObjectToClipPos(points[i]);
						OUT.norm = faceNormal;
						OUT.diffuseColor = color;
						OUT.uv = float2(i % 2, (int)i / 2);
						OUT.diff = nl * _LightColor0;
						OUT.diff.rgb += ShadeSH9(half4(worldNormal, 1));
						OUT.ambient = ShadeSH9(half4(worldNormal, 1));
						TRANSFER_SHADOW(OUT);
						triStream.Append(OUT);
					}
					triStream.RestartStrip();
				}

				[maxvertexcount(24)]
				void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
				{
					float3 lightPosition = _WorldSpaceLightPos0;

					float3 perpendicular = float3(0,0,1);

					//float3 faceNormal = cross(perpendicular, IN[0].norm);
					
					half3 worldNormal = UnityObjectToWorldNormal(IN[0].norm);

					//float3 worldNormal = normalize(mul(unity_ObjectToWorld, faceNormal));

					half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
					

					// the point in the center of the lower part of the quad. Lower center point.
					float3 v0 = IN[0].pos.xyz;
					// the point in the center of the upper part of the quad. Upper center point.
					//float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;

					float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;

					float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x + v0.z), 0, cos(_Time.x * _WindSpeed + v0.x + v0.z));

					v1 += float3(0, sin(radians(_Angle)), cos(radians(_Angle)));
					v1 += wind * _WindStrength;
					
					float3 color = IN[0].color;

					float sin30 = 0.5f;
					float sin60 = 0.866f;

					float cos30 = sin60;
					float cos60 = sin30;

					//float lightStrength = max(dot(normalize(lightPosition), worldNormal), 0);

					g2f OUT;
					// *** Quad 1 ***	
					float3 quad1[4] = {
						v0 + perpendicular * 0.5 * _GrassWidth,
						v0 - perpendicular * 0.5 * _GrassWidth,
						v1 + perpendicular * 0.5 * _GrassWidth,
						v1 - perpendicular * 0.5 * _GrassWidth };

					buildQuad(triStream, quad1, color, nl, worldNormal);

					// *** Quad 2 ***
					float3 quad2[4] = {
						v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v0 - float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v1 + float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v1 - float3(sin60, 0, -cos60) * 0.5 * _GrassWidth };

					buildQuad(triStream, quad2, color, nl, worldNormal);

					// *** Quad 3 ***
					
					float3 quad3[4] = {
						v0 + float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v0 - float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v1 + float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v1 - float3(sin60, 0, cos60) * 0.5 * _GrassWidth };

					buildQuad(triStream, quad3, color, nl, worldNormal);

				}

				half4 frag(g2f IN) : COLOR
				{
					fixed4 c = tex2D(_MainTex, IN.uv);
					clip(c.a - _AlphaClip);
					// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
					fixed shadow = SHADOW_ATTENUATION(IN);
					// darken light's illumination with shadow, keep ambient intact
					fixed3 lighting = IN.diff * shadow + IN.ambient;
					c.rgb *= lighting;
					c *= IN.diff;
					return c;
				}
				ENDCG

			}

			Pass
			{
				Tags{ "LightMode" = "ShadowCaster" }
				CULL OFF

				CGPROGRAM
				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc" // for _LightColor0
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
				};


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
					return OUT;
				}

				void buildQuad(inout TriangleStream<g2f> triStream, float3 points[4], half nl, half3 worldNormal)
				{
					g2f OUT;
					float3 faceNormal = cross(points[1] - points[0], points[2] - points[0]);
					for (int i = 0; i < 4; ++i)
					{
						OUT.pos = UnityObjectToClipPos(points[i]);
						OUT.norm = faceNormal;
						OUT.uv = float2(i % 2, (int)i / 2);
						triStream.Append(OUT);
					}
					triStream.RestartStrip();
				}

				[maxvertexcount(24)]
				void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
				{
					float3 lightPosition = _WorldSpaceLightPos0;

					float3 perpendicular = float3(0,0,1);

					//float3 faceNormal = cross(perpendicular, IN[0].norm);

					half3 worldNormal = UnityObjectToWorldNormal(IN[0].norm);

					half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));

					// the point in the center of the lower part of the quad. Lower center point.
					float3 v0 = IN[0].pos.xyz;
					// the point in the center of the upper part of the quad. Upper center point.
					float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;

					float sin30 = 0.5f;
					float sin60 = 0.866f;

					float cos30 = sin60;
					float cos60 = sin30;

					//float lightStrength = max(dot(normalize(lightPosition), worldNormal), 0);

					g2f OUT;
					// *** Quad 1 ***	
					float3 quad1[4] = {
						v0 + perpendicular * 0.5 * _GrassWidth,
						v0 - perpendicular * 0.5 * _GrassWidth,
						v1 + perpendicular * 0.5 * _GrassWidth,
						v1 - perpendicular * 0.5 * _GrassWidth };

					buildQuad(triStream, quad1, nl, worldNormal);

					// *** Quad 2 ***
					float3 quad2[4] = {
						v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v0 - float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v1 + float3(sin60, 0, -cos60) * 0.5 * _GrassWidth,
						v1 - float3(sin60, 0, -cos60) * 0.5 * _GrassWidth };

					buildQuad(triStream, quad2, nl, worldNormal);

					// *** Quad 3 ***

					float3 quad3[4] = {
						v0 + float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v0 - float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v1 + float3(sin60, 0, cos60) * 0.5 * _GrassWidth,
						v1 - float3(sin60, 0, cos60) * 0.5 * _GrassWidth };

					buildQuad(triStream, quad3, nl, worldNormal);

				}

				half4 frag(g2f IN) : COLOR
				{
					fixed4 c = tex2D(_MainTex, IN.uv);
					clip(c.a - _AlphaClip);
					return c;
				}
					ENDCG
					
			}
		}
}
