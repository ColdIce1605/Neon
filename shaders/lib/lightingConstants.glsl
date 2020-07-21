// Sun luminance is close to the exact value that will result in an illuminance of 128000 lux with what I have set for the apparent size of the sun.
// I might have gotten the luminance wrong tough.
#define   LUMINANCE_SUN  6.61e6
#define ILLUMINANCE_SUN  128e3

// The moon should technically be a lot brighter, but I've dropped its albedo a lot to make it look better.
// Seriously, realistically it would have a luminance of 17408, which is way too bright when you consider its size.
#define   LUMINANCE_MOON 71.9168
#define ILLUMINANCE_MOON 0.32

#define LUMINANCE_STARS 100.0

// Will be replaced at some point
#define ILLUMINANCE_SKY  7e3

// This value needs a lot of tuning.
//The light of a candle is 13 lux, the question is how big is minecraft's torch compaired to a real life candle.
///A page on the lighting model of a Cemetery says that the torch there can do 100 lux or 1500 candelas 
// https://www.researchgate.net/figure/Torch-with-intensity-of-1500-candelas-providing-flame-lighting-of-approximately-100-lux_fig3_220955300
#define LUMINANCE_BLOCK 68
