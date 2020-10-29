//--// Settings

#include "/internalSettings.glsl"

//--// Uniforms

uniform float viewWidth, viewHeight;

uniform vec3 sunPosition;

//
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

//--// Shared Libraries

//--// Shared Functions

#if STAGE == STAGE_VERTEX
	//--// Vertex Outputs

	out vec2 screenCoord;
    out vec3 viewPos;

	//--// Vertex Functions

	void main() {
		screenCoord    = gl_Vertex.xy;
		gl_Position.xy = gl_Vertex.xy * 2.0 - 1.0;
		gl_Position.zw = vec2(1.0);
    vec4 screenPos = vec4(gl_Vertex.xy / vec2(viewWidth, viewHeight), gl_Vertex.z, 1.0);
        vec4 clipPos = screenPos * 2.0 - 1.0;
        vec4 tmp = gbufferProjectionInverse * clipPos;
        viewPos = (tmp / tmp.w).xyz;
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	in vec2 screenCoord;
    in vec3 viewPos;

	//--// Fragment Outputs

	/* DRAWBUFFERS:3 */

	layout (location = 0) out vec3 color;

	//--// Fragment Libraries

	#include "/lib/utility.glsl"
	#include "/lib/utility/colorspace.glsl"
	#include "/lib/utility/dithering.glsl"
	#include "/lib/utility/encoding.glsl"
	#include "/lib/utility/packing.glsl"
	#include "/lib/utility/spaceConversion.glsl"
	#include "/lib/utility/sphericalHarmonics.glsl"

	//--// Fragment Functions

#define PI 3.141592
#define iSteps 16
#define jSteps 8

vec2 rsi(vec3 r0, vec3 rd, float sr) {
    // ray-sphere intersection that assumes
    // the sphere is centered at the origin.
    // No intersection when result.x > result.y
    float a = dot(rd, rd);
    float b = 2.0 * dot(rd, r0);
    float c = dot(r0, r0) - (sr * sr);
    float d = (b*b) - 4.0*a*c;
    if (d < 0.0) return vec2(1e5,-1e5);
    return vec2(
        (-b - sqrt(d))/(2.0*a),
        (-b + sqrt(d))/(2.0*a)
    );
}

vec3 atmosphere(vec3 ray, vec3 r0, vec3 posSun, float iSun, float rPlanet, float rAtmos, vec3 kRlh, float kMie, float shRlh, float shMie, float g) {
    // Normalize the sun and view directions.
    posSun = normalize(posSun);
    posSun =  mat3(gbufferModelViewInverse) * posSun;
    ray = normalize(ray);

    // Calculate the step size of the primary ray.
    vec2 p = rsi(r0, ray, rAtmos);
    if (p.x > p.y) return vec3(0,0,0);
    p.y = min(p.y, rsi(r0, ray, rPlanet).x);
    float iStepSize = (p.y - p.x) / float(iSteps);

    // Initialize the primary ray time.
    float iTime = 0.0;

    // Initialize accumulators for Rayleigh and Mie scattering.
    vec3 totalRlh = vec3(0,0,0);
    vec3 totalMie = vec3(0,0,0);

    // Initialize optical depth accumulators for the primary ray.
    float iOdRlh = 0.0;
    float iOdMie = 0.0;

    // Calculate the Rayleigh and Mie phases.
    float mu = dot(ray, posSun);
    float mumu = mu * mu;
    float gg = g * g;
    float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
    float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

    // Sample the primary ray.
    for (int i = 0; i < iSteps; i++) {

        // Calculate the primary ray sample position.
        vec3 iPos = r0 + ray * (iTime + iStepSize * 0.5);

        // Calculate the height of the sample.
        float iHeight = length(iPos) - rPlanet;

        // Calculate the optical depth of the Rayleigh and Mie scattering for this step.
        float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
        float odStepMie = exp(-iHeight / shMie) * iStepSize;

        // Accumulate optical depth.
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;

        // Calculate the step size of the secondary ray.
        float jStepSize = rsi(iPos, posSun, rAtmos).y / float(jSteps);

        // Initialize the secondary ray time.
        float jTime = 0.0;

        // Initialize optical depth accumulators for the secondary ray.
        float jOdRlh = 0.0;
        float jOdMie = 0.0;

        // Sample the secondary ray.
        for (int j = 0; j < jSteps; j++) {

            // Calculate the secondary ray sample position.
            vec3 jPos = iPos + posSun * (jTime + jStepSize * 0.5);

            // Calculate the height of the sample.
            float jHeight = length(jPos) - rPlanet;

            // Accumulate the optical depth.
            jOdRlh += exp(-jHeight / shRlh) * jStepSize;
            jOdMie += exp(-jHeight / shMie) * jStepSize;

            // Increment the secondary ray time.
            jTime += jStepSize;
        }

        // Calculate attenuation.
        vec3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

        // Accumulate scattering.
        totalRlh += odStepRlh * attn;
        totalMie += odStepMie * attn;

        // Increment the primary ray time.
        iTime += iStepSize;

    }

    // Calculate and return the final color.
    return iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie);
}       

	void main() {

		vec4 gbufferTextureInfo = texture(colortex0, screenCoord);
		vec4 gbufferNormalId    = texture(colortex1, screenCoord);

        mat3 position;
		position[0] = vec3(screenCoord, texture(depthtex1, screenCoord).r);
		position[1] = screenSpaceToViewSpace(position[0], gbufferProjectionInverse);
		position[2] = mat3(gbufferModelViewInverse) * position[1] + gbufferModelViewInverse[3].xyz;

		//vec3 albedo = vec3(unpack2x8(gbufferTextureInfo.r), unpack2x8X(gbufferTextureInfo.g));
		    // albedo = srgbToLinear(albedo);
    vec3 sky_color = atmosphere(
        position[2],                    // normalized ray direction
        vec3(0,6372e3,0),               // ray origin
        sunPosition,                    // position of the sun
        22.0,                           // intensity of the sun
        6371e3,                         // radius of the planet in meters
        6471e3,                         // radius of the atmosphere in meters
        vec3(5.5e-6, 13.0e-6, 22.4e-6), // Rayleigh scattering coefficient
        21e-6,                          // Mie scattering coefficient
        8e3,                            // Rayleigh scale height
        1.2e3,                          // Mie scale height
        0.758                           // Mie preferred scattering direction
    );
            
        // Apply exposure.
            sky_color = 1.0 - exp(-sky_color);
            
            vec3 albedo = sky_color;
            //float sunRadius = 6.59e8;
            //float sunDist = 1.49e11;
            //float sunAngularRadius = sunRadius / sunDist;
            //vec3 viewDotSun = dot(, sunPosition)
            //sun = step(cos(sunAngularRadius), viewDotSun);

		vec3 normal = decodeNormal(gbufferNormalId.rg * 2.0 - 1.0);



		color  = albedo;
	}
#endif
