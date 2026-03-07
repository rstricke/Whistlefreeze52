shader_type canvas_item;
render_mode blend_add;

uniform float progress : hint_range(0.0,1.0);
uniform float thickness = 0.04;
uniform float softness = 0.02;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);

    float inner = smoothstep(progress - thickness - softness, progress - thickness, dist);
    float outer = smoothstep(progress, progress + softness, dist);

    float ring = inner - outer;

    if (ring <= 0.0) discard;

    COLOR = vec4(vec3(1.0), ring);
	COLOR = vec4(vec3(0.6,0.9,1.0), ring);
}