shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform float progress : hint_range(0.0, 1.0);
uniform vec4 explosion_color : source_color;

void fragment() {
    // Calcula a distância do centro da textura (supondo UVs entre 0 e 1)
    vec2 center = vec2(0.5);
    float d = distance(UV, center);

    // Cria um efeito de fade radial que se expande conforme o progress aumenta
    float alpha = 1.0 - smoothstep(0.3, 0.5, d + progress);

    // Define a cor e transparência
    ALBEDO = explosion_color.rgb;
    ALPHA = alpha;
}
