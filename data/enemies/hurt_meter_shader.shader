shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;

uniform float factor : hint_range(0,1);

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
varying vec3 P;

const float PI = 22.0/7.0;

uniform float value : hint_range(0,1);

float remap( float f, float start1, float stop1, float start2, float stop2){
	return start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1));
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	P = VERTEX;
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
	vec2 Pn = normalize(P.xz);
	
	// top bottom grads
	float a = albedo.a *
			albedo_tex.a *
			clamp(remap(P.y, 0.02, .099, 1.0, 0.0), 0.0, 1.0) *
			clamp(remap(P.y, -0.02, -.099, 1.0, 0.0), 0.0, 1.0);
	
	// atan2 abs and edge
	Pn.x = abs(Pn.x);
	float edge = clamp(remap(atan(Pn.x, Pn.y)-((1.0-factor)*PI), 0.0, 0.2, 0., 1.), 0., 1.);
	a = a * edge ;
	ALPHA = a ;
}



