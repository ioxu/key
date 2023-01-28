shader_type canvas_item;

uniform bool do_invert = false;

void fragment() {
	if (do_invert){
		COLOR.rgb = vec4(1.0, 1.0, 1.0, 1.0).rgb - texture(TEXTURE, UV).rgb;
	}else{
		COLOR = texture(TEXTURE, UV);
	}
}
