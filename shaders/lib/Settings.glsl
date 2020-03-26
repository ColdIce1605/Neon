/*

const int colortex0Format = RGBA32F;

*/

const int shadowMapResolution = 4096;   //[1024 2048 4096 8192 16384]
const float shadowDistance = 128;       //[128 256 512 1024]
const float shadowMapBias = 0.85;
const int noiseTextureResolution = 256; //[128 256 512]
const float sunPathRotation = -20;      //[-10 -20 -30 -40]
const float night_red = 0.5;    //[0.2 0.3 0.4 0.5 0.6 0.7 0.8]
const float night_green = 0.5;  //[0.2 0.3 0.4 0.5 0.6 0.7 0.8]
const float night_blue = 0.5;   //[0.2 0.3 0.4 0.5 0.6 0.7 0.8]

float day_red = 1.0;   //[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
float day_green = 1.0; //[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
float day_blue = 1.0;  //[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]


//#define WHITEWORLD