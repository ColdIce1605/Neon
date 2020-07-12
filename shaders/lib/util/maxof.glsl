float maxof(vec2 v) { return max(v.x, v.y); }
float maxof(vec3 v) { return max(max(v.x, v.y), v.z); }
float maxof(vec4 v) { return max(max(v.x, v.y), max(v.z, v.w)); }
