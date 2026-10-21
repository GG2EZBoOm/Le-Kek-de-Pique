// Nachbearbeitung: Tiefe, Volumetrik, Bloom, Tiefenschärfe, Tonemapping
#include "common.hlsli"

cbuffer PostCB : register(b2) {
    float4 p0;
    float2 texel; float2 srcSize;
    float exposure; float bloomIntensity; float bloomThreshold; float bloomKnee;
    float vignette; float grain; float chromAb; float saturation;
    float contrast; float dofFocus; float dofRange; float dofMaxRadius;
    float volIntensity; float smokeDensity; float smokeScale; float dofEnabled;
    float3 liftColor; float fade;
    float3 gainColor; float baseFog;
    float maxVolDist; float sharpen; float letterbox; float postPad;
};

Texture2D tex0 : register(t0);
Texture2D tex1 : register(t1);
Texture2D tex2 : register(t2);
Texture2D tex3 : register(t3);
#ifdef DEPTH_SINGLE
Texture2D<float> texDepthMS : register(t4);
#define LOAD_DEPTH(p) texDepthMS.Load(int3(p, 0))
#else
Texture2DMS<float> texDepthMS : register(t4);
#define LOAD_DEPTH(p) texDepthMS.Load(p, 0)
#endif
Texture2DArray<float> texShadow : register(t5);
Texture3D<float> texNoise : register(t6);

SamplerState sLinearClamp : register(s1);
SamplerComparisonState sShadow : register(s2);
SamplerState sPoint : register(s3);
SamplerState sLinearWrap : register(s4);

struct FSOut {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
};

FSOut VSFullscreen(uint id : SV_VertexID) {
    FSOut o;
    float2 uv = float2((id << 1) & 2, id & 2);
    o.uv = uv;
    o.pos = float4(uv * float2(2, -2) + float2(-1, 1), 0, 1);
    return o;
}

// --- Tiefe auflösen ----------------------------------------------------------
float PSResolveDepth(FSOut i) : SV_Target0 {
    float d = LOAD_DEPTH(int2(i.pos.xy));
    if (d >= 1.0) return farZ;
    return nearZ * farZ / (farZ - d * (farZ - nearZ));
}

// --- Volumetrisches Licht ------------------------------------------------------
float phaseHG(float c, float g) {
    float g2 = g * g;
    return (1 - g2) / (4 * PI * pow(1 + g2 - 2 * g * c, 1.5));
}

float smokeField(float3 p) {
    float3 q = p * smokeScale + float3(time * 0.013, -time * 0.02, time * 0.009);
    float n = texNoise.SampleLevel(sLinearWrap, q, 0) * 0.65 + texNoise.SampleLevel(sLinearWrap, q * 2.7 + 3.1, 0) * 0.35;
    n = saturate((n - 0.38) * 2.2);
    // mehr Rauch knapp unter der Lampe / über dem Tisch
    float h = saturate(1 - abs(p.y - 1.55) / 1.1);
    return n * (0.35 + 0.65 * h);
}

struct VolOut {
    float4 scatter : SV_Target0;
    float depth : SV_Target1;
};

VolOut PSVolumetric(FSOut i) {
    VolOut o;
    // Tiefe aus 2x2 Block: Minimum für stabile Kanten
    float2 fuv = i.uv;
    float d = tex0.SampleLevel(sPoint, fuv, 0).r;
    o.depth = d;
    float dist = min(d, maxVolDist);
    float3 endP = linearDepthToWorld(fuv, dist);
    float3 ro = camPos;
    float3 rd = endP - ro;
    float len = length(rd);
    rd /= len;
    const int STEPS = 48;
    float stepLen = len / STEPS;
    float jitter = interleavedGradientNoise(i.pos.xy + frac(frameIndex * 0.618) * 113.0);
    float T = 1;
    float3 inscatter = 0;
    [loop] for (int s = 0; s < STEPS; ++s) {
        float3 p = ro + rd * ((s + jitter) * stepLen);
        float dens = baseFog + smokeDensity * smokeField(p);
        float3 lightAcc = 0;
        [loop] for (int li = 0; li < lightCount; ++li) {
            Light lt = lights[li];
            if (lt.volumetric <= 0 || lt.type == 2) continue;
            float3 Lv = lt.pos - p;
            float dl = length(Lv);
            float3 L = Lv / dl;
            float att = saturate(1 - pow(dl / lt.range, 4));
            att = att * att / (dl * dl + 0.05);
            if (lt.type == 1) att *= smoothstep(lt.cosOuter, lt.cosInner, dot(-L, lt.dir));
            if (att <= 1e-5) continue;
            float vis = 1;
            if (lt.shadowIndex >= 0) {
                float4 sp = mul(shadowVP[lt.shadowIndex], float4(p, 1));
                sp.xyz /= sp.w;
                float2 suv = sp.xy * float2(0.5, -0.5) + 0.5;
                if (all(suv > 0) && all(suv < 1) && sp.w > 0)
                    vis = texShadow.SampleCmpLevelZero(sShadow, float3(suv, lt.shadowIndex), sp.z);
            }
            lightAcc += lt.color * lt.intensity * att * vis * phaseHG(dot(rd, -L), 0.45) * lt.volumetric;
        }
        float stepT = exp(-dens * stepLen);
        inscatter += T * lightAcc * dens * stepLen;
        T *= stepT;
    }
    o.scatter = float4(inscatter * volIntensity, T);
    return o;
}

// Bilateraler Weichzeichner (Richtung in p0.xy, tex0 = Volumetrik, tex1 = Halbtiefe)
float4 PSBilateral(FSOut i) : SV_Target0 {
    float dc = tex1.SampleLevel(sPoint, i.uv, 0).r;
    float4 sum = 0;
    float wsum = 0;
    [unroll] for (int k = -4; k <= 4; ++k) {
        float2 uv = i.uv + p0.xy * texel * k;
        float4 v = tex0.SampleLevel(sPoint, uv, 0);
        float d = tex1.SampleLevel(sPoint, uv, 0).r;
        float w = exp(-k * k / 8.0) * exp(-abs(d - dc) / max(dc * 0.05, 0.02));
        sum += v * w;
        wsum += w;
    }
    return sum / max(wsum, 1e-4);
}

// Volumetrik + Nebel auf die Szene anwenden (tex0 = Szene, tex1 = Volumetrik halb, tex2 = Tiefe voll, tex3 = Halbtiefe)
float4 PSApplyFog(FSOut i) : SV_Target0 {
    float3 scene = tex0.SampleLevel(sPoint, i.uv, 0).rgb;
    float d = tex2.SampleLevel(sPoint, i.uv, 0).r;
    // Gemeinsamer bilateraler Upsampler
    float2 hs = srcSize * 0.5;
    float2 base = i.uv * hs - 0.5;
    float2 f = frac(base);
    float2 b0 = (floor(base) + 0.5) / hs;
    float4 acc = 0;
    float wsum = 0;
    [unroll] for (int y = 0; y < 2; ++y)
        [unroll] for (int x = 0; x < 2; ++x) {
            float2 uv = b0 + float2(x, y) / hs;
            float4 v = tex1.SampleLevel(sPoint, uv, 0);
            float hd = tex3.SampleLevel(sPoint, uv, 0).r;
            float bw = (x ? f.x : 1 - f.x) * (y ? f.y : 1 - f.y);
            float w = bw * exp(-abs(hd - d) / max(d * 0.04, 0.01)) + 1e-4;
            acc += v * w;
            wsum += w;
        }
    float4 vol = acc / wsum;
    float3 c = scene * vol.a + vol.rgb;
    return float4(c, 1);
}

// --- Bloom --------------------------------------------------------------------
float3 downsample13(Texture2D t, float2 uv, float2 tx) {
    float3 a = t.SampleLevel(sLinearClamp, uv + tx * float2(-2, -2), 0).rgb;
    float3 b = t.SampleLevel(sLinearClamp, uv + tx * float2(0, -2), 0).rgb;
    float3 c = t.SampleLevel(sLinearClamp, uv + tx * float2(2, -2), 0).rgb;
    float3 d = t.SampleLevel(sLinearClamp, uv + tx * float2(-2, 0), 0).rgb;
    float3 e = t.SampleLevel(sLinearClamp, uv, 0).rgb;
    float3 f = t.SampleLevel(sLinearClamp, uv + tx * float2(2, 0), 0).rgb;
    float3 g = t.SampleLevel(sLinearClamp, uv + tx * float2(-2, 2), 0).rgb;
    float3 h = t.SampleLevel(sLinearClamp, uv + tx * float2(0, 2), 0).rgb;
    float3 ii = t.SampleLevel(sLinearClamp, uv + tx * float2(2, 2), 0).rgb;
    float3 j = t.SampleLevel(sLinearClamp, uv + tx * float2(-1, -1), 0).rgb;
    float3 k = t.SampleLevel(sLinearClamp, uv + tx * float2(1, -1), 0).rgb;
    float3 l = t.SampleLevel(sLinearClamp, uv + tx * float2(-1, 1), 0).rgb;
    float3 m = t.SampleLevel(sLinearClamp, uv + tx * float2(1, 1), 0).rgb;
    float3 r = e * 0.125 + (a + c + g + ii) * 0.03125 + (b + d + f + h) * 0.0625 + (j + k + l + m) * 0.125;
    return r;
}

float3 karisW(float3 c, float w) { return c * (w / (1 + max(c.r, max(c.g, c.b)))); }
float karisN(float3 c, float w) { return w / (1 + max(c.r, max(c.g, c.b))); }

float4 PSBloomPrefilter(FSOut i) : SV_Target0 {
    float2 uv = i.uv, tx = texel;
    float3 sum = 0;
    float wsum = 0;
    [unroll] for (int y = -2; y <= 2; y += 2)
        [unroll] for (int x = -2; x <= 2; x += 2) {
            float w = (x == 0 && y == 0) ? 0.125 : ((x == 0 || y == 0) ? 0.0625 : 0.03125);
            float3 s = tex0.SampleLevel(sLinearClamp, uv + tx * float2(x, y), 0).rgb;
            sum += karisW(s, w);
            wsum += karisN(s, w);
        }
    [unroll] for (int k = 0; k < 4; ++k) {
        float2 o = float2(k & 1 ? 1 : -1, k & 2 ? 1 : -1);
        float3 s = tex0.SampleLevel(sLinearClamp, uv + tx * o, 0).rgb;
        sum += karisW(s, 0.125);
        wsum += karisN(s, 0.125);
    }
    float3 c = sum / max(wsum, 1e-4);
    c = min(c, 60.0);
    float br = max(c.r, max(c.g, c.b));
    float soft = clamp(br - bloomThreshold + bloomKnee, 0, 2 * bloomKnee);
    soft = soft * soft / (4 * bloomKnee + 1e-4);
    float contrib = max(soft, br - bloomThreshold) / max(br, 1e-4);
    return float4(c * contrib, 1);
}

float4 PSBloomDown(FSOut i) : SV_Target0 {
    return float4(downsample13(tex0, i.uv, texel), 1);
}

float4 PSBloomUp(FSOut i) : SV_Target0 {
    float2 tx = texel * p0.x;
    float3 s = tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(-1, -1), 0).rgb;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(0, -1), 0).rgb * 2;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(1, -1), 0).rgb;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(-1, 0), 0).rgb * 2;
    s += tex0.SampleLevel(sLinearClamp, i.uv, 0).rgb * 4;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(1, 0), 0).rgb * 2;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(-1, 1), 0).rgb;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(0, 1), 0).rgb * 2;
    s += tex0.SampleLevel(sLinearClamp, i.uv + tx * float2(1, 1), 0).rgb;
    return float4(s / 16.0 * p0.y, 1);
}

// --- Tiefenschärfe --------------------------------------------------------------
float cocOf(float depth) {
    float c = (depth - dofFocus) / dofRange;
    return clamp(c, -1, 1) * dofMaxRadius;
}

float4 PSDofPrefilter(FSOut i) : SV_Target0 {
    float3 c = tex0.SampleLevel(sLinearClamp, i.uv, 0).rgb;
    float d0 = tex1.SampleLevel(sPoint, i.uv + texel * float2(-0.25, -0.25), 0).r;
    float d1 = tex1.SampleLevel(sPoint, i.uv + texel * float2(0.25, 0.25), 0).r;
    float coc = cocOf(min(d0, d1));
    return float4(c, coc);
}

float4 PSDofBlur(FSOut i) : SV_Target0 {
    float4 center = tex0.SampleLevel(sPoint, i.uv, 0);
    float3 acc = center.rgb;
    float wsum = 1;
    const float GA = 2.39996323;
    const int N = 56;
    [loop] for (int k = 1; k < N; ++k) {
        float r = sqrt((float)k / N) * dofMaxRadius;
        float a = k * GA;
        float2 o = float2(cos(a), sin(a)) * r;
        float4 s = tex0.SampleLevel(sLinearClamp, i.uv + o * texel, 0);
        float sc = abs(s.a);
        // Probe zählt, wenn ihr Unschärfekreis diesen Pixel erreicht
        float w = saturate(sc - r + 1.0);
        // Vordergrund darf über scharfen Hintergrund bluten, Hintergrund nicht über Vordergrund
        if (s.a > 0 && center.a < s.a - 2) w *= saturate(abs(center.a) / max(sc, 1e-3) + 0.2);
        acc += s.rgb * w;
        wsum += w;
    }
    return float4(acc / wsum, abs(center.a));
}

// --- Abschluss ------------------------------------------------------------------
float3 acesFitted(float3 v) {
    const float3x3 ACESIn = {0.59719, 0.35458, 0.04823, 0.07600, 0.90834, 0.01566, 0.02840, 0.13383, 0.83777};
    const float3x3 ACESOut = {1.60475, -0.53108, -0.07367, -0.10208, 1.10813, -0.00605, -0.00327, -0.07276, 1.07602};
    v = mul(ACESIn, v);
    float3 a = v * (v + 0.0245786) - 0.000090537;
    float3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    v = a / b;
    return saturate(mul(ACESOut, v));
}

float hash12(float2 p) {
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

// tex0 = HDR (mit Nebel), tex1 = Bloom, tex2 = DoF, tex3 = Tiefe voll
float4 PSComposite(FSOut i) : SV_Target0 {
    float2 uv = i.uv;
    float2 dc = uv - 0.5;
    float r2 = dot(dc, dc);
    float2 caOff = dc * r2 * chromAb;
    float3 col;
    col.r = tex0.SampleLevel(sLinearClamp, uv - caOff, 0).r;
    col.g = tex0.SampleLevel(sLinearClamp, uv, 0).g;
    col.b = tex0.SampleLevel(sLinearClamp, uv + caOff, 0).b;

    if (sharpen > 0) {
        float3 n = tex0.SampleLevel(sLinearClamp, uv + float2(texel.x, 0), 0).rgb + tex0.SampleLevel(sLinearClamp, uv - float2(texel.x, 0), 0).rgb +
                   tex0.SampleLevel(sLinearClamp, uv + float2(0, texel.y), 0).rgb + tex0.SampleLevel(sLinearClamp, uv - float2(0, texel.y), 0).rgb;
        col = max(col + (col - n * 0.25) * sharpen, 0);
    }

    if (dofEnabled > 0.5) {
        float d = tex3.SampleLevel(sPoint, uv, 0).r;
        float coc = abs(cocOf(d));
        float4 dof = tex2.SampleLevel(sLinearClamp, uv, 0);
        float blend = smoothstep(0.6, 2.5, max(coc, dof.a * 0.8));
        col = lerp(col, dof.rgb, blend);
    }
    col += tex1.SampleLevel(sLinearClamp, uv, 0).rgb * bloomIntensity;
    col *= exposure;
    col = acesFitted(col);
    // Farbkorrektur: Schatten/Lichter tönen
    float l = luminance(col);
    col = lerp(l.xxx, col, saturation);
    col = saturate((col - 0.5) * contrast + 0.5);
    col = col * lerp(liftColor, gainColor, smoothstep(0.0, 0.6, l));
    // Vignette
    float vig = 1 - vignette * smoothstep(0.15, 0.85, r2 * 2.2);
    col *= vig;
    // Körnung
    float n = hash12(i.pos.xy + frac(time * 13.37) * 1000) - 0.5;
    col += n * grain * (0.4 + 0.6 * (1 - l));
    // Letterbox (Kino-Kamera)
    float lb = letterbox * 0.12;
    if (uv.y < lb || uv.y > 1 - lb) col = 0;
    col *= 1 - fade;
    // Dithering gegen Banding
    col += (hash12(i.pos.xy * 1.7) - 0.5) / 255.0;
    return float4(max(col, 0), 1);
}

// Einfaches Kopieren (Skalierung)
float4 PSCopy(FSOut i) : SV_Target0 {
    return tex0.SampleLevel(sLinearClamp, i.uv, 0);
}
