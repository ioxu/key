shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;

uniform vec3 uv2_offset;
varying vec3 p;

uniform float line_sharp = 40.0;
uniform float line_width = 0.025;
uniform vec4 line_color : source_color;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	p = VERTEX;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb;
	float xma = smoothstep(1.0, 0.0, (mod(p.x + line_width , 1.0) - 0.5) * line_sharp  );
	float xmb = smoothstep(0.0, 1.0, (mod(p.x - line_width, 1.0) - 0.5) * line_sharp );
	float yma = smoothstep(1.0, 0.0, (mod(p.z + line_width , 1.0) - 0.5) * line_sharp  );
	float ymb = smoothstep(0.0, 1.0, (mod(p.z - line_width, 1.0) - 0.5) * line_sharp );

	xma = max(max(xma, xmb), max(yma, ymb));
	ALBEDO = mix(line_color.rgb, vec3(1.0, 1.0, 1.0), xma) * albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
