const float sunAngularDiameter = radians(0.535);
const float sunAngularRadius   = 0.5 * sunAngularDiameter;
const vec3  sunLuminance       = vec3(1.0, 0.949, 0.937) * 1.6e9; // approximate
const vec3  sunIlluminance     = sunLuminance * coneAngleToSolidAngle(sunAngularRadius);

const float moonAngularDiameter = radians(0.528);
const float moonAngularRadius   = 0.5 * moonAngularDiameter;
const vec3  moonAlbedo          = vec3(0.136);
const vec3  moonLuminance       = moonAlbedo * sunIlluminance;
const vec3  moonIlluminance     = moonLuminance * coneAngleToSolidAngle(moonAngularRadius);
