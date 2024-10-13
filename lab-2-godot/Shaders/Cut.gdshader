shader_type canvas_item;

uniform bool is_left_side = true;
uniform float split_offset = 0.0;  // Offset to adjust the split midpoint
uniform vec4 sprite_rect = vec4(0.0, 0.0, 1.0, 1.0);  // x, y, width, height in UV space

void fragment() {
    // Remap UV to account for sprite rect
    vec2 remapped_uv = (UV - sprite_rect.xy) / sprite_rect.zw;
    
    // Calculate the midpoint with an optional offset
    float midpoint = 0.5 + split_offset;
    
    // Determine which part to discard based on the calculated midpoint
    if (is_left_side) {
        if (remapped_uv.x > midpoint) {
            discard;  // Discard the right side if this is the left half
        }
    } else {
        if (remapped_uv.x <= midpoint) {
            discard;  // Discard the left side if this is the right half
        }
    }
    
    // Apply the actual texture to the remaining part
    COLOR = texture(TEXTURE, UV);  // Note: Use original UV here, not remapped
    
    // Debug: Visualize the remapped UV
    // COLOR = vec4(remapped_uv, 0.0, 1.0);
}