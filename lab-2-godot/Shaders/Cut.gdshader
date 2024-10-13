shader_type canvas_item;

uniform bool is_left_side = true;

void fragment() {
    // Assume UV.x is between 0.0 and 1.0 representing the left and right halves
    if (is_left_side) {
        if (UV.x > 0.5) {
            discard;  // Hide right side
        }
    } else {
        if (UV.x <= 0.5) {
            discard;  // Hide left side
        }
    }

    // Apply the texture as usual
    COLOR = texture(TEXTURE, UV);
}
