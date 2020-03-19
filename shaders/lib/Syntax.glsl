#if defined fsh
	#define varying in
#endif

#if defined vsh
	#define attribute in
	#define varying out
#endif

#define io inout

#define cbool  const bool
#define cbvec2 const bvec2
#define cbvec3 const bvec3
#define cbvec4 const bvec4

#define cuint  const uint
#define cuvec2 const uvec2
#define cuvec3 const uvec3
#define cuvec4 const uvec4

#define cint   const int
#define civec2 const ivec2
#define civec3 const ivec3
#define civec4 const ivec4

#define cfloat const float
#define cvec2  const vec2
#define cvec3  const vec3
#define cvec4  const vec4

#define timeNight   timeVector.y
#define saturate(x) clamp(x, 0.0, 1.0)