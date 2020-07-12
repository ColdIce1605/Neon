float minof(vec2 v) { return min(v.x, v.y); }
float minof(vec3 v) { return min(min(v.x, v.y), v.z); }
float minof(vec4 v) { return min(min(v.x, v.y), min(v.z, v.w)); }
