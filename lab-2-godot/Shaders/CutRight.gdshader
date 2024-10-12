shader_type canvas_item;

void fragment() {
    // UV for the current fragment
    vec2 uv = UV;
    
    // Cut off the right half of the sprite
    if (uv.x > 0.5) {
        discard; // Ignore right side
    }
}
