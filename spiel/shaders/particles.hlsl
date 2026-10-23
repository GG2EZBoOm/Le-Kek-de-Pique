// Weiche Partikel: Zigarrenrauch, Staub im Lichtkegel
#include "common.hlsli"

Texture2D texSmoke : register(t0);
Texture2D<float> texDepth : register(t1);
SamplerState sLinear : register(s1);

struct PIn {
    float3 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 params : TEXCOORD1;  // x = weich-Bereich, y = Lichtanteil, z = Flamme, w = additiv
};

struct POut {
    float4 pos : SV_Position;
    float3 wpos : WPOS;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 params : TEXCOORD1;
    float depth : DEPTH;
    float3 light : LIGHT;
};

POut VSMain(PIn i) {
    POut o;
    o.pos = mul(viewProj, float4(i.pos, 1));
    o.wpos = i.pos;
    o.uv = i.uv;
    o.color = i.color;
    o.params = i.params;
    float3 fwd = float3(view[2][0], view[2][1], view[2][2]);
    o.depth = dot(i.pos - camPos, fwd);
    // Beleuchtung pro Vertex (ohne Schatten)
    float3 lit = lerp(ambientBottom, ambientTop, 0.6) * 1.5;
    for (int li = 0; li < lightCount; ++li) {
        Light lt = lights[li];
        float3 Lv = lt.pos - i.pos;
        float dist = length(Lv);
        float3 L = Lv / dist;
        float att = saturate(1 - pow(dist / lt.range, 4));
        att = att * att / (dist * dist + 0.05);
        if (lt.type == 1) att *= smoothstep(lt.cosOuter, lt.cosInner, dot(-L, lt.dir));
        if (lt.type == 2) att = 1;
        lit += lt.color * lt.intensity * att * 0.25;
    }
    o.light = lit;
    return o;
}

float flameHash(float2 p) { return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453); }
float flameNoise(float2 p) {
    float2 a = floor(p), f = frac(p); f = f * f * (3 - 2 * f);
    return lerp(lerp(flameHash(a), flameHash(a + float2(1,0)), f.x),
                lerp(flameHash(a + float2(0,1)), flameHash(a + 1), f.x), f.y);
}

float4 PSMain(POut i) : SV_Target0 {
    float4 t = texSmoke.Sample(sLinear, i.uv);
    if (i.params.z > 0.5) {
        float h = 1 - i.uv.y;
        float2 flow = float2(i.uv.x * 5, h * 6 - time * 3) + i.wpos.xz * 0.17;
        float n = flameNoise(flow) * 0.65 + flameNoise(flow * 2.1) * 0.35;
        float bend = sin(h * 9 - time * 5 + i.wpos.z) * h * 0.09;
        float body = 1 - abs(i.uv.x - 0.5 + bend) / max(0.04, (1-h) * 0.43);
        float heat = saturate(body * 0.8 + n * 0.65 - h * 0.6);
        t.a = smoothstep(0.12, 0.43, heat) * smoothstep(0, 0.13, h) * (1-smoothstep(0.82, 1, h));
        t.rgb = lerp(float3(1,0.035,0.002), float3(1,0.72,0.12), smoothstep(0.3,0.9,heat));
    }
    float sceneDepth = texDepth.Load(int3(i.pos.xy, 0));
    float soft = saturate((sceneDepth - i.depth) / max(i.params.x, 1e-3));
    float nearFade = saturate((i.depth - 0.15) / 0.35);
    float a = t.a * i.color.a * soft * nearFade;
    float3 c = i.color.rgb * lerp(1.0.xxx, i.light, i.params.y) * t.rgb;
    if (i.params.w > 0.5) return float4(c * a, 0);  // additiv
    return float4(c * a, a);
}
