#version 420

//--// Configuration //----------------------------------------------------------------------------------//

#include "/cfg/global.scfg"

#define COMPOSITE 5

const bool colortex4MipmapEnabled = true;

//--// Outputs //----------------------------------------------------------------------------------------//

/* DRAWBUFFERS:4 */

layout (location = 0) out vec4 composite;

//--// Inputs //-----------------------------------------------------------------------------------------//

in vec2 fragCoord;
in blank EyeDirectionVector;

//--// Uniforms //---------------------------------------------------------------------------------------//


uniform sampler2D colortex4;

uniform vec3 cameraPosition;


//--// Functions //--------------------------------------------------------------------------------------//

#include "/lib/debug.glsl"

#include "/lib/preprocess.glsl"
#include "/lib/lightingConstants.glsl"

#include "/lib/util/packing/normal.glsl"
#include "/lib/util/maxof.glsl"
#include "/lib/util/noise.glsl"

//--//

/*
Implementation:
We will have a ray object that starts at the player's position and the direction represents in which direction the camera is looking at, and a plane that represents the clouds, sort of like a "cloud plane"
Then we will do a ray-plane intersection to get where on the plane the ray intersects with it, and we will use the .xy coordinates of the intersection as coordinates for a perlin noise function which returns a 0 - 1 value, 0 meaning no clouds, 1 meaning completely covered with clouds
*/

struct Ray {
vec3 Origin;
vec3 Direction;
};

struct Plane {
    vec3 center;
    vec3 normal;
};

Ray WorldRay;
WorldRay.Origin = cameraPosition;
WorldRay.Direction = normalize(EyeDirectionVector); //We will calculate this in the vertex shader and pass it to the fragment shader as a varying
Plane CloudPlane;
CloudPlane.Position = vec3(cameraPosition.x, 256.0f, cameraPosition.z);
CloudPlane.Normal = vec3(0.0, 1.0, 0.0);
vec3 RayPlaneIntersection(vec3 PointRay, vec3 CloudPlane) {
return vec3(0.0);
}
vec3 Intersection = RayPlaneIntersection(Ray.WorldRay, Plane.CloudPlane); //Get intersection point
vec4 CloudCoverage = PerlinNoise(Intersection.xy); //Get cloud coverage

void main() {

}
