// Weiche Partikel: Zigarrenrauch, Staub im Lichtkegel
#include "common.hlsli"

Texture2D texSmoke : register(t0);
Texture2D<float> texDepth : register(t1);
SamplerState sLinear : register(s1);

struct PIn {
    float3 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 params : TEXCOORD1;  // x = weich-Bereich, y = Lichtanteil, z = 0 Rauch / 1 Flamme / 2 Blase, w = additiv
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
    if (i.params.z > 1.5) {
        // Air/water boundary: mostly transparent centre, curved rim and two small reflections.
        float2 q = i.uv * 2 - 1;
        float r2 = dot(q,q);
        clip(1-r2);
        float z = sqrt(max(0,1-r2));
        float rim = pow(1-z,3);
        float glint = exp(-dot(q-float2(-.30,-.40),q-float2(-.30,-.40))*95);
        float lower = exp(-dot(q-float2(.26,.57),q-float2(.26,.57))*135);
        float edge = 1-smoothstep(.94,1,r2);
        t.rgb = lerp(float3(.17,.37,.40),float3(.71,.91,.96),rim*.8);
        t.rgb += glint*.85+lower*.24;
        t.a = (.035+rim*.60+glint*.65+lower*.22)*edge;
    } else if (i.params.z > 0.5) {
        float h = 1 - i.uv.y;
        float2 flow = float2(i.uv.x * 4.8, h * 4.1 - time * 1.65) + i.wpos.xz * .37;
        float curl = flameNoise(flow * .7 + 4.7) - .5;
        flow.x += curl * (h + .25) * 2;
        float n = flameNoise(flow) * .53 + flameNoise(flow * 2.07) * .29 + flameNoise(flow * 4.13) * .18;
        float width = .46 * pow(1-h, .65);
        float lateral = abs(i.uv.x - .5 + curl * h * .27);
        float body = 1 - lateral / max(.015, width);
        float heat = body * .64 + n * .72 - h * .64;
        // Aufsteigende, ausgefranste Zungen mit dunkleren Rändern statt identischer Lichtkegel.
        float fringe = smoothstep(.20, .36, heat);
        t.a = fringe * smoothstep(0,.11,h) * (1-smoothstep(.84,1,h));
        float core = smoothstep(.36,.83,heat) * (1-h*.5);
        t.rgb = lerp(float3(.75,.045,.003),float3(1,.56,.055),core);
        t.rgb = lerp(t.rgb,float3(1,.87,.42),smoothstep(.76,1,heat)*.8);
    }
    float sceneDepth = texDepth.Load(int3(i.pos.xy, 0));
    float soft = saturate((sceneDepth - i.depth) / max(i.params.x, 1e-3));
    float nearFade = saturate((i.depth - 0.15) / 0.35);
    float a = t.a * i.color.a * soft * nearFade;
    float3 c = i.color.rgb * lerp(1.0.xxx, i.light, i.params.y) * t.rgb;
    if (i.params.w > 0.5) return float4(c * a, 0);  // additiv
    return float4(c * a, a);
}
