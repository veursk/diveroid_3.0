//
//  pratice.metal
//  Diveroid300
//
//  Created by diveroid on 2022/11/11.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(                           // 1
  const device packed_float3* vertex_array [[ buffer(0) ]], // 2
  unsigned int vid [[ vertex_id ]]) {                 // 3
  return float4(vertex_array[vid], 1.0);              // 4
}


