shader_type canvas_item;

uniform sampler2D my_texture;

void fragment() {
    vec4 tex_color = texture(my_texture, UV);
    COLOR = tex_color;
}
