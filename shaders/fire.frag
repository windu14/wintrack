#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1; // Inner fire color
uniform vec3 uColor2; // Outer fire color
uniform float uIntensity;

out vec4 fragColor;

// Pseudo-random noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion
float fbm(vec2 st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 5; ++i) {
        v += a * noise(st);
        st = rot * st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    // Invert Y so 0 is at bottom for flame growth
    uv.y = 1.0 - uv.y;
    
    // Scale X to make it narrower
    vec2 q = uv;
    q.x *= 2.0;
    q.x -= 0.5;
    
    // Animate upward
    vec2 st = q * vec2(3.0, 2.0);
    st.y += uTime * 1.5;
    
    // Generate noise
    float n = fbm(st);
    
    // Create a teardrop shape for the flame based on intensity
    float flameShape = 1.0 - length(vec2(q.x * 2.0, uv.y - 0.2));
    flameShape = smoothstep(0.0, 1.0, flameShape * 1.5 * uIntensity);
    
    // Combine noise and shape
    float fire = n * flameShape;
    // Sharpen the flame core
    fire = smoothstep(0.1, 0.8, fire);
    
    // Colors
    vec3 col = mix(uColor2, uColor1, fire * 1.5);
    
    // Fade at bottom and edges
    float alpha = fire * smoothstep(0.0, 0.2, uv.y) * smoothstep(0.9, 0.6, uv.y);
    
    fragColor = vec4(col * alpha, alpha);
}
