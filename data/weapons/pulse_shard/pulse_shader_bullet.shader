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
uniform float alpha_falloff_gamma = 2.2;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	p = VERTEX;
}

float gamma(float i, float g) {
	return pow(i, 1.0/g);
}

float map(float value, float inMin, float inMax, float outMin, float outMax) {
  return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
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
	//ALPHA = albedo.a * albedo_tex.a * gamma(clamp(p.z + 0.5, 0.0, 1.0), alpha_falloff_gamma) * gamma(clamp( -p.z+0.5, 0.0, 1.0), alpha_falloff_gamma);
	ALPHA = albedo.a * albedo_tex.a 
		* gamma(clamp(map(p.z, 0.5, 0.0, 0.0, 1.0), 0.0, 1.0), alpha_falloff_gamma)
		* gamma(clamp(map(p.z, -0.5, 0.0, 0.0, 1.0), 0.0, 1.0), alpha_falloff_gamma);
}



