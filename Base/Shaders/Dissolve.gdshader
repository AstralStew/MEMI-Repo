shader_type canvas_item;
uniform sampler2D target_texture;
uniform float weight: hint_range(0, 1);
const float epsilon = 0.01f;

// NOTE -> Necessary to fix MODULATE not working on parent???
varying vec4 v_vertex_color;
// Called for every vertex the material is visible on.
void vertex() {
	v_vertex_color = COLOR;
}

// Called for every pixel the material is visible on.
void fragment() {
    vec4 color_a = texture(TEXTURE, UV);
    vec4 color_b = texture(target_texture, UV);
	
    if (abs(color_a.a) < epsilon) {
    	COLOR = v_vertex_color * mix(vec4(color_b.r,color_b.g,color_b.b,0.0), color_b, weight);
	} else if (abs(color_b.a) < epsilon) {
		COLOR = v_vertex_color * mix(color_a, vec4(color_b.a,color_b.a,color_b.a,0.0), weight);
	} else {                
    	COLOR = v_vertex_color * mix(color_a, color_b, weight);
    }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
