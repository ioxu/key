shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx,cull_back;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
varying vec3 p;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	p = VERTEX;
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	EMISSION = (emission.rgb+emission_tex)*emission_energy;
	ALPHA = albedo.a * albedo_tex.a * clamp(p.z + 0.5, 0.0, 1.0) * clamp( -p.z+0.5, 0.0, 1.0);
}



float map(float value, float inMin, float inMax, float outMin, float outMax) {
  return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}