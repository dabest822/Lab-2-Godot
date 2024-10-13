shader_type canvas_item;

uniform bool is_left_side = true;
uniform vec4 sprite_region;  // (x, y, width, height) of the region in texture coordinates

void fragment() {
    // Convert UV to the sprite's local coordinates
    vec2 sprite_uv = (UV * sprite_region.zw + sprite_region.xy) / (sprite_region.zw);
    
    // Cut off based on which side we are showing
    if (is_left_side) {
        if (sprite_uv.x > 0.5) {
            discard;  // Hide right side
        }
    } else {
        if (sprite_uv.x <= 0.5) {
            discard;  // Hide left side
        }
    }
    
    // Apply the texture using the original UVs
    COLOR = texture(TEXTURE, UV);
}