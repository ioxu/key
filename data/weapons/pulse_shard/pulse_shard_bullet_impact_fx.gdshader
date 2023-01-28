shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_emission : hint_default_black;
uniform vec4 emission : source_color;
uniform float emission_energy;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
//uniform float PI = 3.1415926535897932384626433832795;
uniform float time_offset;

uniform float cone_amount : hint_range(0, 1);

uniform float shader_time : hint_range(0, 1);

uniform sampler2D noise_texture : hint_default_black;

float remap( float f, float start1, float stop1, float start2, float stop2){
	return start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1));
}

float gamma(float i, float g) {
	return pow(i, 1.0/g);
}

float map(float value, float inMin, float inMax, float outMin, float outMax) {
  return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

float bias(float t, float b){
	return ( t / ((((1.0/b) - 2.0) *(1.0 - t)) + 1.0 ));
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX.z +=  -1.0 * length(vec2(VERTEX.x, VERTEX.y)) * cone_amount * 2.0 ;
}

float fcontrast(float f, float contrast, float pivot){
	return clamp((f - pivot) * contrast + pivot, 0.0, 1.0);
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
	
	float edge_time = map(shader_time, 0.0, 1.0, 0.15, 0.45);
	float edge_fade = clamp(map(length(UV - vec2(0.5, 0.5)), edge_time, edge_time-0.04, 0.0, 1.0), 0.0, 1.0);
	
	float inner_time = map(shader_time, 0.0, 1.0, 0.0, 0.5);
	float inner_fade = clamp(map(length(UV - vec2(0.5, 0.5)), inner_time, inner_time-0.1, 1.0, 0.0), 0.0, 1.0);
	
	float time = TIME + time_offset;
	float conic_grad_u = ( atan( UV.x-0.5, UV.y-0.5 ) + PI ) / (PI*2.0) *1.2; 
	float conic_grad_v = length(vec2(UV.x-0.5, UV.y-0.5)) * 0.65;
	vec2 conic_uvs = vec2(conic_grad_u *0.5 + time *0.00, conic_grad_v* 0.5 + (time * -3.0) );
	float noise_tex = texture(noise_texture, conic_uvs * vec2( 2.0, 0.3 ) ).r;
	float contrast_pivot_time = map(bias(shader_time, 0.75), 0.0, 1.0, 0.0, 0.65);
	//ALPHA = fcontrast(noise_tex, 100.0, contrast_pivot_time);//edge_fade * inner_fade;
	ALPHA = albedo.a * albedo_tex.a * edge_fade * inner_fade * fcontrast(noise_tex, 100.0, contrast_pivot_time);
	//float final_a = albedo.a * albedo_tex.a * edge_fade * inner_fade * fcontrast(noise_tex, 100.0, contrast_pivot_time);
}
