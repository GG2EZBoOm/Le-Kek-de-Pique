// 2D-Oberfläche: abgerundete Rechtecke, Verläufe, SDF-Schrift, Bilder
cbuffer UICB : register(b0) {
    float2 screen;
    float2 uiPad;
};

Texture2D tex : register(t0);
SamplerState sLinear : register(s0);

struct VIn {
    float2 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 rect : TEXCOORD1;   // x,y = lokale Position relativ zur Mitte; z,w = halbe Größe
    float4 params : TEXCOORD2; // x = Modus, y = Radius, z = Rand/Weichheit, w = Rahmenbreite
};

struct VOut {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 rect : TEXCOORD1;
    float4 params : TEXCOORD2;
};

VOut VSMain(VIn i) {
    VOut o;
    o.pos = float4(i.pos.x / screen.x * 2 - 1, 1 - i.pos.y / screen.y * 2, 0, 1);
    o.uv = i.uv;
    o.color = i.color;
    o.rect = i.rect;
    o.params = i.params;
    return o;
}

float sdRoundBox(float2 p, float2 b, float r) {
    float2 q = abs(p) - b + r;
    return length(max(q, 0)) + min(max(q.x, q.y), 0) - r;
}

float4 PSMain(VOut i) : SV_Target0 {
    int mode = (int)i.params.x;
    if (mode == 0) {
        // Gefülltes abgerundetes Rechteck (optional nur Rahmen), z = Weichheit (Schatten)
        float d = sdRoundBox(i.rect.xy, i.rect.zw, i.params.y);
        float soft = max(i.params.z, 0.75);
        float a = 1 - smoothstep(-soft, soft, d);
        if (i.params.w > 0) {
            float inner = 1 - smoothstep(-soft, soft, d + i.params.w);
            a = a - inner;
        }
        return float4(i.color.rgb, i.color.a * a);
    }
    if (mode == 1) {
        // SDF-Text: y = Schärfe (Pixel je SDF-Einheit), z = Dicke-Offset, w = Weichheit
        float s = tex.Sample(sLinear, i.uv).r;
        float w = max(fwidth(s), 1e-4) * (0.7 + i.params.w);
        float a = smoothstep(0.5 - i.params.z - w, 0.5 - i.params.z + w, s);
        return float4(i.color.rgb, i.color.a * a);
    }
    if (mode == 2) {
        // Bild
        float4 t = tex.Sample(sLinear, i.uv);
        return t * i.color;
    }
    if (mode == 3) {
        // Bild mit abgerundeter Maske
        float4 t = tex.Sample(sLinear, i.uv);
        float d = sdRoundBox(i.rect.xy, i.rect.zw, i.params.y);
        float a = 1 - smoothstep(-0.75, 0.75, d);
        return float4(t.rgb * i.color.rgb, t.a * i.color.a * a);
    }
    if (mode == 4) {
        // Ring / Kreisbogen: rect.xy lokal, z = Radius, w = Dicke; params.y = Füllanteil 0..1
        float r = length(i.rect.xy);
        float d = abs(r - i.rect.z) - i.rect.w * 0.5;
        float a = 1 - smoothstep(-0.75, 0.75, d);
        float ang = atan2(i.rect.x, -i.rect.y) / 6.2831853 + 0.5;
        a *= step(ang, i.params.y);
        return float4(i.color.rgb, i.color.a * a);
    }
    return i.color;
}
