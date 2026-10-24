// Gemeinsame Definitionen für alle Szenen-Shader
#ifndef COMMON_HLSLI
#define COMMON_HLSLI

#define MAX_LIGHTS 16
#define PI 3.14159265

struct Light {
    float3 pos;    float range;
    float3 color;  float intensity;
    float3 dir;    float cosOuter;
    float cosInner; int type; int shadowIndex; float size;
    float volumetric; float shadowBias; float2 pad;
};

cbuffer FrameCB : register(b0) {
    row_major float4x4 view;
    row_major float4x4 proj;
    row_major float4x4 viewProj;
    row_major float4x4 invViewProj;
    row_major float4x4 shadowVP[2];
    float3 camPos;      float time;
    float2 screenSize;  float nearZ; float farZ;
    float3 ambientTop;  float envIntensity;
    float3 ambientBottom; int lightCount;
    float4 shadowParams[2];   // x = near, y = far, z = tan(halbe fov), w = Texelgröße
    float3 fogColor;    float fogDensity;
    float envMaxMip;    float frameIndex; float exposureHint; float pad0;
    Light lights[MAX_LIGHTS];
};

// Materialflags
#define F_ALBEDO     1
#define F_NORMAL     2
#define F_ORM        4
#define F_DETAIL     8
#define F_CARD       16
#define F_UNLIT      32
#define F_SKIN       64
#define F_FELT       128
#define F_GLASS      256
#define F_EMISSIVEMAP 512
#define F_NOENV      1024
#define F_UVRECT     2048
#define F_ALPHATEST  4096
#define F_ANISO      8192
#define F_TRIPLANAR  16384
#define F_TERRAIN    32768
#define F_WATER      65536

cbuffer ObjectCB : register(b1) {
    row_major float4x4 world;
    row_major float4x4 normalMat;
    float4 baseColor;
    float3 emissiveColor; float emissive;
    float roughness; float metallic; float normalStrength; float detailScale;
    float2 uvScale; float2 uvOffset;
    float4 uvRect;
    float4 tint;
    float4 glow;
    uint flags; float sheen; float clearcoat; float subsurface;
    float specular; float alphaCutoff; float detailStrength; float objPad;
};

float3 linearDepthToWorld(float2 uv, float linDepth) {
    // Rekonstruktion über invViewProj: Punkt auf near und far, dann entlang der Sicht
    float2 ndc = float2(uv.x * 2 - 1, 1 - uv.y * 2);
    float4 p = mul(invViewProj, float4(ndc, 1, 1));
    p.xyz /= p.w;
    float3 dir = p.xyz - camPos;
    // Skalierung so, dass Abstand entlang der Blickachse = linDepth
    float3 fwd = float3(view[2][0], view[2][1], view[2][2]);
    return camPos + dir * (linDepth / dot(dir, fwd));
}

float interleavedGradientNoise(float2 p) {
    return frac(52.9829189 * frac(dot(p, float2(0.06711056, 0.00583715))));
}

float luminance(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }

#endif
