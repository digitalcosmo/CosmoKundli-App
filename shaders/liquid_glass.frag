#version 460 core
#include <flutter/runtime_effect.glsl>

// Liquid-glass lens for floating surfaces (dock, sheets).
// u_size  : size of the filter input texture (set by the engine)
// u_rect  : x, y, w, h of the glass in texture pixels
// u_radius: corner radius in pixels
// u_depth : how far content bends at the rim, in pixels
uniform vec2 u_size;
uniform vec4 u_rect;
uniform float u_radius;
uniform float u_depth;
uniform sampler2D u_input;

out vec4 frag_color;

float sdRoundRect(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + vec2(r);
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  bool local = abs(u_size.x - u_rect.z) < 4.0 && abs(u_size.y - u_rect.w) < 4.0;
  vec2 origin = local ? vec2(0.0) : u_rect.xy;
  vec2 c = origin + u_rect.zw * 0.5;
  vec2 p = frag - c;
  float d = sdRoundRect(p, u_rect.zw * 0.5, u_radius); // <0 inside
  // Refraction only in a band near the rim: content is pulled inward, like a
  // thick glass edge, and stays undistorted in the middle.
  float band = clamp(1.0 + d / max(u_depth * 2.2, 1.0), 0.0, 1.0);
  float bend = band * band * u_depth;
  vec2 dir = normalize(p + vec2(0.0001));
  vec2 uv = (frag - dir * bend) / u_size;
  // slight chromatic split at the very edge
  float ca = band * band * 1.2 / u_size.x;
  vec4 col;
  col.r = texture(u_input, uv + vec2(ca, 0.0)).r;
  col.g = texture(u_input, uv).g;
  col.b = texture(u_input, uv - vec2(ca, 0.0)).b;
  col.a = 1.0;
  // specular sheen along the top edge
  float top = clamp(1.0 - (frag.y - origin.y) / 10.0, 0.0, 1.0) * band;
  col.rgb += vec3(0.10) * top;
  frag_color = col;
}
