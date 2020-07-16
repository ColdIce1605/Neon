#define PERSISTENT_TIME // If enabled, time-based effects are persistent across sessions. It is recommended that you disable this if the doDaylightCycle gamerule is set to false, as that will stop the timers required for persistent time.

/*
"global" time variables always count up smoothly, and if PERSISTENT_TIME is off, will be counting since the start of rendering, rather than being tied to the world time cycle.
"world" time variables are always tied to the world time cycle, but they do not neccesarily count up smoothly.

worldTime  - Time in ticks.
worldDay   - Time in days.

globalTime - Time in seconds.
*/

uniform int worldTime;
uniform int worldDay;

uniform float sunAngle;

#ifdef PERSISTENT_TIME
// TODO: Account for sunAngle not counting up linearly
float globalTime = (fract(sunAngle - 0.0345175) + mod(worldDay, 127)) * 12e2;
#else
uniform float frameTimeCounter;

float globalTime = frameTimeCounter;
#endif
