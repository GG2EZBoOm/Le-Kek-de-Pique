// Weiche Partikel: Zigarrenrauch, Staub im Lichtkegel
#include "common.hlsli"

Texture2D texSmoke : register(t0);
Texture2D<float> texDepth : register(t1);
SamplerState sLinear : register(s1);

struct PIn {
    float3 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 params : TEXCOORD1;  // x = weich-Bereich, y = Lichtanteil, z = Frame, w = additiv
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
        lit += lt.color * lt.intensity * att * 0.25;
    }
    o.light = lit;
    return o;
}

float4 PSMain(POut i) : SV_Target0 {
    float4 t = texSmoke.Sample(sLinear, i.uv);
    float sceneDepth = texDepth.Load(int3(i.pos.xy, 0));
    float soft = saturate((sceneDepth - i.depth) / max(i.params.x, 1e-3));
    float nearFade = saturate((i.depth - 0.15) / 0.35);
    float a = t.a * i.color.a * soft * nearFade;
    float3 c = i.color.rgb * lerp(1.0.xxx, i.light, i.params.y) * t.rgb;
    if (i.params.w > 0.5) return float4(c * a, 0);  // additiv
    return float4(c * a, a);
}
