shader_type canvas_item;

uniform float split_offset : hint_range(-0.5, 0.5) = 0.0;

void fragment() {
    vec2 uv = UV;
    float midpoint = 0.5 + split_offset;
    
    if (uv.x <= midpoint) {
        discard;
    }
    
    COLOR = texture(TEXTURE, uv);
}