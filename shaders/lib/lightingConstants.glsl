// Sun luminance is close to the exact value that will result in an illuminance of 128000 lux with what I have set for the apparent size of the sun.
// I might have gottent the luminance wrong tough.
#define   LUMINANCE_SUN  6.61e6
#define ILLUMINANCE_SUN  128e3

// The moon should technically be a lot brighter, but I've dropped its albedo a lot to make it look better.
// Seriously, realistically it would have a luminance of 17408, which is way too bright when you consider its size.
#define   LUMINANCE_MOON 71.9168
#define ILLUMINANCE_MOON 0.32

#define LUMINANCE_STARS 100.0

// Will be replaced at some point
#define ILLUMINANCE_SKY  7e3

// This value needs a lot of tuning. It also should really be LUMINANCE_BLOCK, but I'll change that later.
#define ILLUMINANCE_BLOCK 50
