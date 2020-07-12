#define PI    3.14159265358979323846
#define TAU   6.28318530717958647692
#define PHI   1.61803398874989484820
#define SQRT2 1.41421356237309504880

#define saturate(x) clamp(x, 0.0, 1.0)
#define max0(x)     max(x, 0.0)

#define textureRaw(samplr, coord) texelFetch(samplr, ivec2(coord * textureSize(samplr, 0)), 0)
