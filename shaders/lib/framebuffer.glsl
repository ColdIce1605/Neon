#include "/lib/Utility/Utilities.glsl"

/*!
 * \brief Holds a bunch of defines to give semantic names to all the framebuffer attachments
 */
/*
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D composite;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
*/ //TODO rename
struct Fragment {
    vec3 albedo;
    vec3 specular_color;
    vec3 normal;
    float roughness;
    float ao;
    float emission;
    bool is_metal;
    bool skip_lighting;
    bool is_sky;
    bool is_water;
};

#define METALLIC_BIT        0
#define SKIP_LIGHTING_BIT   1
#define SKY_BIT             2
#define WATER_BIT           3

//TODO redo
/*
void write_to_buffers(vec4 color, vec3 normal, float roughness, float ao, float metalness, float emission, bool skip_lighting, bool is_sky, bool is_water)  {
    gl_FragData[0] = color; 
    gl_FragData[5].r = Encode16(EncodeNormal(normal)); 
    gl_FragData[5].g = Encode16(vec2(roughness, ao));

    int masks = 0;
    masks |= (metalness > 0.5 ? 1 : 0)  << METALLIC_BIT;
    masks |= skip_lighting ? 1 : 0      << SKIP_LIGHTING_BIT;
    masks |= is_sky ? 1 : 0             << SKY_BIT;
    masks |= is_water ? 1 : 0           << WATER_BIT;
    gl_FragData[5].b = Encode16(vec2(emission, intBitsToFloat(masks & 0xFF)));
}

Fragment get_fragment(vec2 coord) {
    vec3 color_sample = texture2D(colortex0, coord).rgb;
    vec3 data_sample = texture2D(colortex5, coord).rgb;
    vec2 roughness_and_ao = Decode16(data_sample.g);
    vec2 emission_and_masks = Decode16(data_sample.b);
    int masks = floatBitsToInt(emission_and_masks.y);

    Fragment fragment;
    fragment.normal         = DecodeNormal(Decode16(data.x));
    fragment.roughness      = roughness_and_ao.x;
    fragment.ao             = roughness_and_ao.y;
    fragment.emission       = emission_and_masks.x;
    fragment.is_metal       = (masks & (1 << METALLIC_BIT)) > 0;
    fragment.skip_lighting  = (masks & (1 << SKIP_LIGHTING_BIT)) > 0;
    fragment.is_sky         = (masks & (1 << SKY_BIT)) > 0;
    fragment.is_water       = (masks & (1 << WATER_BIT)) > 0;

    if(fragment.is_metal) {
        fragment.albedo = vec3(0.02);
        fragment.specular_color = color_sample;
    } else {
        fragment.albedo = color_sample;
        fragment.specular_color = vec3(0.014);
    }

    return fragment;
}
*/