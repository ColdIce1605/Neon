//#define DEBUG
#define DEBUG_PROGRAM 0 // -1 = gbuffers. 0-15 = composite0-15. 16 = final [0 1 2 16]

#ifdef DEBUG
vec3 debugDisplay;

void debugShow(vec3 rgb) { debugDisplay = rgb; }

void debugExit() {
	#ifdef COMPOSITE
	#if COMPOSITE == DEBUG_PROGRAM
	composite.rgb = debugDisplay;
	#elif COMPOSITE > DEBUG_PROGRAM
	composite.rgb = texture(colortex4, fragCoord).rgb;
	#endif
	#endif

	#if defined FINAL && defined DEBUG
	#if DEBUG_PROGRAM == 16
	finalColor = debugDisplay;
	#else
	finalColor = texture(colortex4, fragCoord).rgb;
	#endif
	#endif
}
#else 
#define debugShow
#define debugExit()
#endif
