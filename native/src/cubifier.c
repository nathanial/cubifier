#include "cubifier.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define CHECK_ERROR(CMD) \
do { \
  int code = CMD; \
  if(code){ \
    return code; \
  } \
} while(0)

static void get_dimensions(CubifierVolume *volume, int *width, int *height, int *depth){

}

static void set_start_position(CubifierVolume *volume, CubifierCube *cube){
}

static bool cube_needs_expansion(CubifierVolume *volume, CubifierCube* cube){
  return false;
}

static void new_cube(CubifierVolume *volume, CubifierCube *oldCube, CubifierCube *cube){

}

static bool expand_cube(CubifierVolume *volume, CubifierCube *cube){
  return false;
}

CUBIFIER_ERROR cubifier_create_volume(int xdim, int ydim, int zdim, CubifierVolume *outVolume){
  outVolume->width = xdim;
  outVolume->height = ydim;
  outVolume->depth = zdim;

  short *voxels = calloc(xdim*ydim*zdim, sizeof(short));
  if(voxels == NULL){
    return CUBIFIER_ERROR_OUT_OF_MEMORY;
  }

  outVolume->voxels = voxels;

  return CUBIFIER_ERROR_SUCCESS;
}

CUBIFIER_ERROR cubifier_destroy_volume(CubifierVolume *volume){
  volume->width = -1;
  volume->height = -1;
  volume->depth = -1;
  free(volume->voxels);
  return CUBIFIER_ERROR_SUCCESS;
}

CUBIFIER_ERROR cubifier_set_voxel(CubifierVolume *volume, int x, int y, int z, short value){
  if(x < 0 || x >= volume->width ||
     y < 0 || y >= volume->height ||
     z < 0 || z >= volume->depth){
    return CUBIFIER_ERROR_OUT_OF_RANGE;
  }
  volume->voxels[z*(volume->width*volume->height) + y*(volume->width) + x] = value;
  return CUBIFIER_ERROR_SUCCESS;
}

CUBIFIER_ERROR cubifier_get_voxel(CubifierVolume *volume, int x, int y, int z, short* outValue){
  if(x < 0 || x >= volume->width ||
    y < 0 || y >= volume->height ||
    z < 0 || z >= volume->depth){
    return CUBIFIER_ERROR_OUT_OF_RANGE;
  }
  *outValue = volume->voxels[z*(volume->width*volume->height) + y*(volume->width) + x];
  return CUBIFIER_ERROR_SUCCESS;
}

CUBIFIER_ERROR cubifier_cubify(CubifierVolume *volume, CubifierCube *outCubes, int *outCubeCount){
  int width, height, depth;

  get_dimensions(volume, &width, &height, &depth);

  int cubeCount = 0;
  CubifierCube *cubes = malloc(sizeof(CubifierCube) * 100);
  if(cubes == NULL){
    return CUBIFIER_ERROR_OUT_OF_MEMORY;
  }

  CubifierCube *cube = &cubes[0];

  set_start_position(volume, cube);

  while(cube_needs_expansion(volume, cube)) {
    if(!expand_cube(volume, cube)){
      CubifierCube *oldCube = cube;
      cubeCount++;
      if(cubeCount >= 100){
        return CUBIFIER_ERROR_OUT_OF_MEMORY;
      }
      cube = &cubes[cubeCount];
      new_cube(volume, oldCube, cube);
    }
  }

  return CUBIFIER_ERROR_SUCCESS;
}

const char* cubifier_get_error_string(CUBIFIER_ERROR code){
  switch(code){
    case CUBIFIER_ERROR_SUCCESS: return "SUCCESS";
    case CUBIFIER_ERROR_NOT_IMPLEMENTED: return "NOT_IMPLEMENTED";
    case CUBIFIER_ERROR_OUT_OF_MEMORY: return "OUT_OF_MEMORY";
    default:
      return "BAD ERROR CODE";
  }
}
