// converted from
// https://www.shadertoy.com/view/WlsSRs
// by user Shane 
// (amazing shadertoys https://www.shadertoy.com/user/Shane)

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D iChannel0 : hint_white;
uniform float specular: hint_range(0,1);
uniform float metallic: hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;

uniform vec3 uv2_offset;
varying vec3 P;

// IQ's signed box formula.
float sBox(vec2 p, vec2 b, float r){
  
  // Just outside lines.
  //p = max(abs(p) - b + r, 0.);
  //return length(p) - r;

  // Inside and outside lines.
  vec2 d = abs(p) - b + r;
  return min(max(d.x, d.y), 0.) + length(max(d, 0.)) - r;
}

// IQ's vec2 to float hash.
float hash21(vec2 p){  return fract(sin(dot(p, vec2(27.609, 57.583)))*43758.5453); }

// Custom box divide formula: I wrote this from scratch, and based it on various 
// techniques, but changed a lot of it to cut down on operations. I also went to
// some trouble to take a space and position preserving approach, which should make
// it much easier to work with. The routines I've come across don't do that. :)
//
// The idea is simple, in theory, and the solution was simple, but as usual, I had
// to make way too many mistakes to get there. Basically, you start in one of the
// corners of the grid square, produce a random number, then split space vertically 
// or horizontally, according to the random factor. For instance, if the random number
// is ".6," then split the space in a 60% to 40% ratio, update postions (depending
// which side of the line you're on), reduce the space dimensions accordingly, etc.
//
// Simple, right? It should have been. :D Anyway, it's done now, so feel free to
// use it for whatever you want.
//
vec3 boxDivide(in vec2 p) {
    
    
    // Scaling factor. If changing this, you may need to change a few settings
    // here and there to suit your needs.
    //const float sc = 1.5;
	const float sc = 1.00;
    p *= sc;
    
    
    // Basid grid tile ID. This will be further split into subtiles, which will
    // each have their own ID based on postion.
    vec2 ip = floor(p); 
   
    // If using the vertical offset option, update the position and ID accordingly.
    //#ifdef VERT_OFFSET
    if(mod(ip.x, 2.)>.5){
        p.y -= 1./2.;
        ip = floor(p);
    }
    //#endif
   
    p -= ip + .5; // The original grid tile's base local coordinates.
    
    
    //#ifdef SHOW_GRID
    //float grid = abs(max(abs(p.x), abs(p.y)) - .5) - .005;
    //#endif
    
    // Block dimension. Every time there's a random split, it'll be factored down
    // according to the random split factor.
    vec2 l = vec2(1, 1);  
    
    // The starting point, which represents the bottom left corner (or is it the top left corner?)
    // of the grid cell. With every split, it will be moved to the new split position.
    vec2 s = vec2(-.5);    
    
    // Split number.
    const int iNum = 8;

    
    //float r = hash21(ip);
    //float r2 = hash21(ip + .35);
    
    float count = 0.;
    
    
    // Create a box, divide it randomly, then do the same with the 
    // divided portions. Ad infinitum...
    for(int i=0; i<iNum; i++) {
 
        float r = hash21(ip + l + float(i)/float(iNum))*.3 + (1. - .3)/2.;
        // Forcing a vertical to horizontal split (and vice versa) every
        // iteration. It's not necessary, but I think it looks nicer.
        float r2 = mod(float(i), 2.)>.5? 0. : 1.;
        
        // Alternate, more randomized sequence.
        //float r2 = hash21(ip + 113.5 + l.yx + float(i)/float(iNum));
        // Alternate heuristic, for aesthetics purposes, to ensure at least one split.
        // If using this, be sure to uncomment the "count++" line below.
        //if(i==iNum-1 && count<1.5) r2 = 1.;
		//if(i==iNum-1 && count>float(iNum) - 2.5) r2 = 0.;
 
        
        // Alternate way to randomize things. How this is achieved is up to the user.
        //r = hash21(l + r + float(i)/float(iNum))*.3 + (1.-.3)/2.;
        //r2 = hash21(l.yx + r + r2 + float(i)/float(iNum));
        
         
        //r2 = mod(float(i), 2.)>.5? 0. : 1.;
        //if(r2<.5) { p = p.yx; l = l.yx; s = s.yx; }
        
        // If the second random number is above a certain threshold, split 
        // vertically. Otherwise, split horizontally.
        if(r2>.5){ 
            
            // Counter for heuristics above. Uncomment if using them.
            // count++;
            
            // This line splits the current cell down the middle, in accordance with
            // the random factor, "r," and the cell width "l.x." 
            if(p.x>s.x + l.x*r) {

                s.x += l.x*r; // Advance the position to the right of the split.
                l.x *= (1. - r); // Reduce the width by a factor of "1 - r."
            }
            else l.x *= r; // No need to advance position, but we need to reduce the width.
        
        }
        else {
            
              // This line splits the current cell horizontally, in accordance with
             // the random factor, "r," and the cell height "l.y." 
             if(p.y>s.y + l.y*r) {

                s.y += l.y*r; // Advance the position above (or below?) the split.
                l.y *= (1. - r); // Reduce the height by a factor of "1 - r."

             }
             else l.y *= r; // No need to advance position, but we need to reduce the height.
            
        }
        
        // There are many ways to vary the line width.
        // #ifdef VARIABLE_LINE_WIDTH
        //l *= 1. - r*.03;
        //l *= 1. - length(l)*.02;
        //l *= .986;
        //#endif

    }
    
    
    // Constructing the box itself: Actually, once you have the box coordinates, you can 
    // do whatever you want with them.
    //
    // Rounding factor: This depends on the look you're after. It could be a constant, 
    // or you could choose to have no rounding at all. After experimentingn, I decided 
    // to make the roundedness of the tile dependent on the minimum side length.
    float rf = min(l.x, l.y); 
    //float d = sBox(p - s - l/2., l/2., .08*sqrt(rf)) + .00*sc;
	float d = sBox(p - s - l/2., l/2., .05*sqrt(rf)) + -.000*sc;
    
   
    
    // Smoothing factor.
    //float sf = 1./iResolution.y*sc;
	float sf = 1./1024.0*sc;
    
    // Individual, position-based tile ID. Note that it'll read into the texture
    // at the correct position.
    vec2 id = ip + s + l/2.;
    
    // If using the vertical offset, the ID needs to follow suit.
    //#ifdef VERT_OFFSET
    if(mod(ip.x, 2.)>.5){
        id.y += .5;
    }
    //#endif
    
    
    
    // Using the ID to color the individual tile.
    
    
    // Textured version. Note that this is not an overlay -- Each tile has 
    // a uniform color.
    vec3 tx = texture(iChannel0, id/sc/1.5).xyz; tx *= tx;
    vec3 pCol = min(tx*2., 1.);
    
    // Original random colored version.
    //vec3 pCol = vec3(1, hash21(id), hash21(id*57. + .5));
    
    // 2D noise, etc.
    //float c =  n2D(id*2. + iTime);
    //vec3 pCol = min(vec3(c*.1 + .9, c + .05, c*c*.7), 1.); 

    
   
    
    vec3 col = vec3(.125);
    float sh = clamp(.5 - d*5./length(l), 0., 1.5);
    //col = mix(col, vec3(0), 1. - smoothstep(0., sf, d)); // Rounded pavers.
    col = mix(col, pCol, 1. - smoothstep(0., sf, d + .002*sc)); 
    //col = mix(col, vec3(0), 1. - smoothstep(0., sf, abs(d + .01*sc) - .001*sc)); 
    // More decoration, if so desired.
    //col = mix(col, mix(pCol*1.5, vec3(1), .35), 1. - smoothstep(0., sf, d + .005*sc)); 
    //col = mix(col, vec3(0), (1. - smoothstep(0., sf, d + .012*sc))*.9); 
    //col = mix(col, pCol*sh, 1. - smoothstep(0., sf, d + .016*sc)); 
 
    
    // Center, space preserving dots.
    
    // Just the center dot.
    //float d2 = length(p - s - l/2.) - min(.01, l.x*l.y)/sc;
    
    // Splitting space to produce four rivot-looking dots.
    //p = abs(p - s - l/2.) - l/2. + .035;
    //float d2 = length(p) - .01/sc;
    
    //col = mix(col, vec3(0), 1. - smoothstep(0., sf, d2)); // Rounded pavers.
    
    
    //#ifdef SHOW_GRID
    //col = mix(col, vec3(0), 1. - smoothstep(0., sf*2., grid - .005)); 
    //col = mix(col, vec3(1, .8, .2), 1. - smoothstep(0., sf, grid)); 
    //#endif
 
 
    
    return col;
    
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	P = VERTEX;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);

	ALBEDO = mix( vec3(0.18), vec3(0.25),boxDivide(P.xz*0.05)) * albedo_tex.rgb * albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular ;
}
