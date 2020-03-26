#include "/lib/Utility/encoding.glsl"

  #define cRCP(type, name) const type name##RCP = 1.0 / name
  #define cin(type) const type
  #define rcp(x) ( 1.0 / x )

vec2 to2D(int index, const int total) {
    cRCP(float, total);
    return vec2(float(index) / total, vec2(index, total));
}
