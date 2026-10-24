// Vorwärts-PBR-Shader für alle Szenenobjekte
#include "common.hlsli"

Texture2D texAlbedo : register(t0);
Texture2D texNormal : register(t1);
Texture2D texORM : register(t2);
Texture2D texDetail : register(t3);
Texture2D texAlbedo2 : register(t4);
TextureCube texEnv : register(t5);
Texture2DArray<float> texShadow : register(t6);

SamplerState sAniso : register(s0);
SamplerState sLinearClamp : register(s1);
SamplerComparisonState sShadow : register(s2);
SamplerState sPoint : register(s3);

struct VSIn {
    float3 pos : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT;
};

struct VSOut {
    float4 pos : SV_Position;
    float3 wpos : WPOS;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    float3 opos : OPOS;
};

VSOut VSMain(VSIn i) {
    VSOut o;
    float4 wp = mul(world, float4(i.pos, 1));
    if (flags & F_WATER) {
        wp.y += .012 * sin(wp.x * 2.1 + time * 1.1) + .008 * sin(wp.z * 2.7 - time * 1.4);
    }
    o.wpos = wp.xyz;
    o.pos = mul(viewProj, wp);
    o.normal = normalize(mul((float3x3)normalMat, i.normal));
    o.tangent = float4(normalize(mul((float3x3)world, i.tangent.xyz)), i.tangent.w);
    o.uv = i.uv;
    o.opos = i.pos;
    return o;
}

// Schatten-Pass (nur Tiefe)
float4 VSShadow(VSIn i) : SV_Position {
    return mul(viewProj, mul(world, float4(i.pos, 1)));
}

// ---------------------------------------------------------------------------
static const float2 poisson[24] = {
    float2(-0.613392, 0.617481), float2(0.170019, -0.040254), float2(-0.299417, 0.791925), float2(0.645680, 0.493210),
    float2(-0.651784, 0.717887), float2(0.421003, 0.027070), float2(-0.817194, -0.271096), float2(-0.705374, -0.668203),
    float2(0.977050, -0.108615), float2(0.063326, 0.142369), float2(0.203528, 0.214331), float2(-0.667531, 0.326090),
    float2(-0.098422, -0.295755), float2(-0.885922, 0.215369), float2(0.566637, 0.605213), float2(0.039766, -0.396100),
    float2(0.751946, 0.453352), float2(0.078707, -0.715323), float2(-0.075838, -0.529344), float2(0.724479, -0.580798),
    float2(0.222999, -0.215125), float2(-0.467574, -0.405438), float2(-0.248268, -0.814753), float2(0.354411, -0.887570)};

float linearizeShadow(float d, float n, float f, bool ortho) { return ortho ? n + d * (f - n) : n * f / (f - d * (f - n)); }

float shadowFactor(int idx, float3 wpos, float3 N, float3 L, float2 screenPos, float lightSize, float biasTexels) {
    float4 params = shadowParams[idx];
    bool ortho = params.z < 0;  // Richtungslicht
    float NoL = saturate(dot(N, L));
    float extra = 0;
    if (biasTexels > 0) {
        // Versatz in Texeln der Schattenkarte am Empfänger (für grobe Karten über große Flächen)
        float4 sp0 = mul(shadowVP[idx], float4(wpos, 1));
        float texelW = (ortho ? -2 * params.z : 2 * max(sp0.w, 0.01) * params.z) * params.w;
        extra = texelW * biasTexels * (0.5 + 1.5 * (1 - NoL));
    }
    float3 biased = wpos + N * (0.004 + 0.01 * (1 - NoL) + extra);
    float4 sp = mul(shadowVP[idx], float4(biased, 1));
    if (sp.w <= 0) return 1;
    sp.xyz /= sp.w;
    float2 uv = sp.xy * float2(0.5, -0.5) + 0.5;
    if (any(uv < 0) || any(uv > 1)) return 1;
    float zRecv = linearizeShadow(sp.z, params.x, params.y, ortho);
    float texel = params.w;
    float frustumW = ortho ? -2 * params.z : 2 * zRecv * params.z;

    float ang = interleavedGradientNoise(screenPos + frameIndex * 7.0) * 6.2831;
    float2x2 rot = float2x2(cos(ang), -sin(ang), sin(ang), cos(ang));

    // Blocker-Suche
    float searchUV = clamp(lightSize * (ortho ? 8.0 : 0.6) / frustumW, texel * 2, 0.05);
    float blockerSum = 0, blockers = 0;
    [unroll] for (int k = 0; k < 12; ++k) {
        float2 o = mul(rot, poisson[k * 2]) * searchUV;
        float d = texShadow.SampleLevel(sPoint, float3(uv + o, idx), 0);
        if (d < sp.z) {
            blockerSum += linearizeShadow(d, params.x, params.y, ortho);
            blockers += 1;
        }
    }
    if (blockers < 0.5) return 1;
    float zBlock = blockerSum / blockers;
    float penumbra = lightSize * max(zRecv - zBlock, 0) / (ortho ? 1.0 : max(zBlock, 1e-3));
    float radius = clamp(penumbra / frustumW, texel * 1.5, texel * 48);
    float sum = 0;
    [unroll] for (int j = 0; j < 24; ++j) {
        float2 o = mul(rot, poisson[j]) * radius;
        sum += texShadow.SampleCmpLevelZero(sShadow, float3(uv + o, idx), sp.z);
    }
    return sum / 24.0;
}

float D_GGX(float NoH, float a) {
    float a2 = a * a;
    float d = NoH * NoH * (a2 - 1) + 1;
    return a2 / (PI * d * d);
}
float V_Smith(float NoV, float NoL, float a) {
    float a2 = a * a;
    float gv = NoL * sqrt(NoV * NoV * (1 - a2) + a2);
    float gl = NoV * sqrt(NoL * NoL * (1 - a2) + a2);
    return 0.5 / max(gv + gl, 1e-5);
}
float3 F_Schlick(float3 F0, float VoH) { return F0 + (1 - F0) * pow(1 - VoH, 5); }
float2 envBRDFApprox(float NoV, float rough) {
    const float4 c0 = float4(-1, -0.0275, -0.572, 0.022);
    const float4 c1 = float4(1, 0.0425, 1.04, -0.04);
    float4 r = rough * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    return float2(-1.04, 1.04) * a004 + r.zw;
}

float bayer4(float2 p) {
    int2 q = int2(p) & 3;
    const float m[16] = {0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5};
    return (m[q.y * 4 + q.x] + 0.5) / 16.0;
}

struct Surface {
    float3 albedo; float alpha; float3 N; float rough; float metal; float ao; float3 emissive;
};

float4 shade(VSOut i, bool frontFace, bool forEnv) {
    float2 uv = i.uv * uvScale + uvOffset;
    Surface s;
    s.albedo = baseColor.rgb * tint.rgb;
    s.alpha = baseColor.a * tint.a;
    s.rough = roughness;
    s.metal = metallic;
    s.ao = 1;
    // Leuchtbild (Neon, Nachtkulisse, Schild): nur das Bild leuchtet – kein gleichmäßiger Schleier über der Fläche
    s.emissive = ((flags & F_EMISSIVEMAP) ? 0 : emissiveColor * emissive) + glow.rgb;

    float3 Ng = normalize(i.normal);
    if (!frontFace) Ng = -Ng;
    float3 T = normalize(i.tangent.xyz - Ng * dot(Ng, i.tangent.xyz));
    float3 B = cross(Ng, T) * i.tangent.w;
    float3 N = Ng;
    float normalVar = 0;  // Rauheitszuschlag aus der Normal-Map (Toksvig)

    bool isCard = (flags & F_CARD) != 0;
    if (isCard) {
        if (i.uv.x < 1.5) {
            float2 cuv = uvRect.xy + i.uv * uvRect.zw;
            float4 c = texAlbedo.Sample(sAniso, cuv);
            s.albedo *= c.rgb;
        } else if (i.uv.x < 3.5) {
            float4 c = texAlbedo2.Sample(sAniso, i.uv - float2(2, 0));
            s.albedo *= c.rgb;
        } else {
            s.albedo *= float3(0.85, 0.83, 0.78);
        }
    } else {
        float2 auv = (flags & F_UVRECT) ? uvRect.xy + frac(uv) * uvRect.zw : uv;
        if (flags & F_UVRECT) auv = uvRect.xy + saturate(i.uv) * uvRect.zw;
        if (flags & F_TERRAIN) {
            // Gelände: Gras von oben, Fels dreiseitig projiziert (kein Verziehen an Steilhängen).
            // uv = absolute x/z der Landschaft, opos.y = absolute Höhe -> gleiche Koordinaten über alle Kacheln.
            float3 No = normalize(mul(transpose((float3x3)world), Ng));  // Normale im Kachelraum
            float2 py = uv;
            float2 px = float2(uv.y, i.opos.y * uvScale.x * 0.11);
            float2 pz = float2(uv.x, i.opos.y * uvScale.x * 0.11);
            float3 bw = pow(abs(No), 4);
            bw /= bw.x + bw.y + bw.z;
            float3 rock = texAlbedo2.Sample(sAniso, px).rgb * bw.x + texAlbedo2.Sample(sAniso, py).rgb * bw.y +
                          texAlbedo2.Sample(sAniso, pz).rgb * bw.z;
            // großflächige Farbschwankung und waagerechte Gesteinsschichten, damit Felswände nicht einförmig grau wirken
            float macro = texAlbedo2.Sample(sAniso, uv * 0.045 + 0.21).r * 1.6;
            float strata = sin(i.opos.y * 2.3 + macro * 3.0) * 0.07;
            rock *= 0.72 * (0.7 + 0.45 * macro) + strata;
            float3 grass = texAlbedo.Sample(sAniso, uv).rgb * baseColor.rgb;
            // Übergang nach Neigung, mit grobem Muster aufgelockert, damit keine Rasterkanten entstehen
            float breakup = texAlbedo2.Sample(sAniso, uv * 0.13 + 0.37).g - 0.45;
            float w = smoothstep(0.80, 0.64, No.y + breakup * 0.18);
            s.albedo = tint.rgb * lerp(grass, rock, w);
            s.rough = lerp(roughness, 0.78, w);
        } else if (flags & F_ALBEDO) {
            float4 c = texAlbedo.Sample(sAniso, auv);
            s.albedo *= c.rgb;
            if (flags & F_EMISSIVEMAP) s.emissive += c.rgb * c.a * emissive * emissiveColor;
            else s.alpha *= c.a;
        }
        if (flags & F_ORM) {
            float3 orm = texORM.Sample(sAniso, auv).rgb;
            s.ao = orm.r;
            s.rough *= orm.g;
            s.metal *= orm.b;
        }
        if (flags & F_NORMAL) {
            float3 tn = texNormal.Sample(sAniso, auv).xyz * 2 - 1;
            if (flags & F_WATER) {
                float3 a = texNormal.Sample(sAniso, auv + time * float2(.018, .011)).xyz * 2 - 1;
                float3 b = texNormal.Sample(sAniso, auv * 1.37 + time * float2(-.013, .016)).xyz * 2 - 1;
                tn = normalize(float3((a.xy + b.xy) * .55, a.z * b.z));
            }
            float tl = length(tn);
            normalVar = saturate((1 - tl) / max(tl, 1e-3)) * normalStrength;
            tn.xy *= normalStrength;
            N = normalize(T * tn.x + B * tn.y + Ng * tn.z);
        }
        if (flags & F_DETAIL) {
            float3 dn = texDetail.Sample(sAniso, uv * detailScale).xyz * 2 - 1;
            dn.xy *= detailStrength;
            N = normalize(N + T * dn.x + B * dn.y);
        }
    }
    if (flags & F_ALPHATEST) clip(s.alpha - alphaCutoff);
    if (tint.a < 0.999 && !(flags & F_GLASS)) clip(tint.a - bayer4(i.pos.xy));

    if (flags & F_UNLIT) return float4(s.albedo + s.emissive, s.alpha);

    float3 V = normalize(camPos - i.wpos);
    float NoV = max(dot(N, V), 1e-4);
    // Glanzlicht-Kantenglättung: ändert sich die Normale innerhalb eines Pixels stark (Lederporen, Kanten in der
    // Ferne), wird das Glanzlicht breiter, statt bei kleinster Kamerabewegung weiß aufzublitzen
    float3 dNx = ddx(N), dNy = ddy(N);
    float specVar = min(0.5 * (dot(dNx, dNx) + dot(dNy, dNy)) + normalVar, 0.3);
    float3 dGx = ddx(Ng), dGy = ddy(Ng);
    float coatVar = min(0.5 * (dot(dGx, dGx) + dot(dGy, dGy)), 0.18);
    float a0 = max(s.rough * s.rough, 0.002);
    float a = sqrt(a0 * a0 + specVar);
    float filteredRoughness = saturate(sqrt(a));
    const float coatA0 = 0.15 * 0.15;
    float coatA = sqrt(coatA0 * coatA0 + coatVar);
    float3 F0 = lerp(0.08 * specular.xxx, s.albedo, s.metal);
    float3 diffColor = s.albedo * (1 - s.metal);
    bool skin = (flags & F_SKIN) != 0;
    bool felt = (flags & F_FELT) != 0;

    float3 direct = 0;
    [loop] for (int li = 0; li < lightCount; ++li) {
        Light lt = lights[li];
        float3 Lv = lt.pos - i.wpos;
        float dist = length(Lv);
        float3 L = Lv / dist;
        float att = saturate(1 - pow(dist / lt.range, 4));
        att = att * att / (dist * dist + 0.01);
        if (lt.type == 2) {
            L = -lt.dir;
            att = 1;
        } else if (lt.type == 1) {
            float cd = dot(-L, lt.dir);
            att *= smoothstep(lt.cosOuter, lt.cosInner, cd);
        }
        if (att <= 1e-5) continue;
        float NoLraw = dot(N, L);
        float sh = 1;
        if (lt.shadowIndex >= 0 && (NoLraw > -0.3 || skin)) sh = shadowFactor(lt.shadowIndex, i.wpos, Ng, L, i.pos.xy, lt.size, lt.shadowBias);
        float3 radiance = lt.color * lt.intensity * att * sh;
        float NoL = saturate(NoLraw);
        float3 H = normalize(L + V);
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));
        float3 F = F_Schlick(F0, VoH);
        float3 spec = D_GGX(NoH, a) * V_Smith(NoV, NoL, a) * F;
        float3 diff = diffColor / PI;
        float diffTerm = NoL;
        if (skin) {
            float w = 0.45 * subsurface;
            diffTerm = saturate((NoLraw + w) / (1 + w));
            float3 sss = float3(0.5, 0.16, 0.08) * saturate(1 - abs(NoLraw)) * subsurface * 0.35;
            direct += radiance * diffColor * sss;
        }
        if (felt) {
            // Samtiger Glanz am Rand
            float sheenTerm = pow(1 - NoV, 3) * 0.6 + pow(saturate(1 - NoH), 2) * 0.15;
            direct += radiance * NoL * sqrt(s.albedo) * 0.45 * sheen * sheenTerm;
        }
        if (flags & F_ANISO) {
            // Haar: Kajiya-Kay mit zwei versetzten Glanzlichtern entlang der Strähnen (Bitangente)
            float3 strand = normalize(B);
            float t1 = dot(normalize(strand + Ng * 0.12), H);
            float t2 = dot(normalize(strand - Ng * 0.08), H);
            float s1 = pow(saturate(sqrt(1 - t1 * t1)), 90.0);
            float s2 = pow(saturate(sqrt(1 - t2 * t2)), 24.0);
            spec = (s1 * 0.07 + s2 * 0.05 * s.albedo * 3.0) * saturate(NoLraw * 0.5 + 0.5).xxx;
            diffTerm = saturate(NoLraw * 0.6 + 0.4) * 0.85;
        }
        float3 c = radiance * (diff * diffTerm * (1 - F) + spec * NoL);
        if (clearcoat > 0) {
            float NoLc = saturate(dot(Ng, L));
            float Dc = D_GGX(saturate(dot(Ng, H)), coatA);
            float Fc = 0.04 + 0.96 * pow(1 - VoH, 5);
            float Vc = 0.25 / max(VoH * VoH, 1e-3);
            c = c * (1 - Fc * clearcoat) + radiance * NoLc * Dc * Vc * Fc * clearcoat;
        }
        direct += c;
    }

    // Umgebung
    float3 R = reflect(-V, N);
    float3 ambDiff = lerp(ambientBottom, ambientTop, N.y * 0.5 + 0.5);
    float3 envSpec = 0;
    if (!forEnv && !(flags & F_NOENV)) {
        ambDiff += texEnv.SampleLevel(sLinearClamp, N, envMaxMip - 1).rgb * envIntensity * 0.6;
        envSpec = texEnv.SampleLevel(sLinearClamp, R, filteredRoughness * (envMaxMip - 1)).rgb * envIntensity;
    } else {
        envSpec = lerp(ambientBottom, ambientTop, R.y * 0.5 + 0.5) * 0.5;
    }
    float2 ab = envBRDFApprox(NoV, filteredRoughness);
    float3 specAmb = envSpec * (F0 * ab.x + ab.y);
    if (clearcoat > 0 && !forEnv && !(flags & F_NOENV)) {
        float coatNoV = saturate(dot(Ng, V));
        float Fc = 0.04 + 0.96 * pow(1 - coatNoV, 5);
        float coatMip = max(0.3, sqrt(coatA) * (envMaxMip - 1));
        specAmb += texEnv.SampleLevel(sLinearClamp, reflect(-V, Ng), coatMip).rgb * envIntensity * Fc * clearcoat;
    }
    float3 ambient = ambDiff * diffColor * s.ao + specAmb * s.ao;
    if (felt) ambient += ambDiff * s.albedo * sheen * pow(1 - NoV, 3) * 0.5;

    float3 color = direct + ambient + s.emissive;
    // Luftdunst im Freien: die Ferne verschwimmt zur Horizontfarbe
    if (fogDensity > 0) color = lerp(color, fogColor, 1 - exp(-fogDensity * length(camPos - i.wpos)));

    if (flags & F_GLASS) {
        float fres = 0.04 + 0.96 * pow(1 - NoV, 5);
        float alpha = saturate(s.alpha + fres * 0.35);
        return float4(color, alpha);
    }
    return float4(color, s.alpha);
}

float4 PSMain(VSOut i, bool ff : SV_IsFrontFace) : SV_Target0 {
    return shade(i, ff, false);
}

float4 PSEnv(VSOut i, bool ff : SV_IsFrontFace) : SV_Target0 {
    return shade(i, ff, true);
}
