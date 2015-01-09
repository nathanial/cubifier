#include "cubifier.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

#define CHECK_ERROR(CMD) \
do { \
  int code = CMD; \
  if(code){ \
    return code; \
  } \
} while(0)

typedef struct {
  int width;
  int height;
  int depth;
  int xmin;
  int ymin;
  int zmin;
  int xmax;
  int ymax;
  int zmax;
} Dimensions;

static CUBIFIER_ERROR get_dimensions(CubifierVolume *volume, Dimensions *dimensions){
  short value;
  int xmin = INT_MIN, ymin = INT_MIN, zmin = INT_MIN;
  int xmax = INT_MAX, ymax = INT_MAX, zmax = INT_MAX;

  for(int x = 0; x < volume->width; x++){
    for(int y = 0; y < volume->height; y++){
      for(int z = 0; z < volume->depth; z++){
        CHECK_ERROR(cubifier_get_voxel(volume, x, y, z, &value));
        if(value){
          if(x < xmin){
            xmin = x;
          }
          if(x > xmax){
            xmax = x;
          }
          if(y < ymin){
            ymin = y;
          }
          if(y > ymax){
            ymax = y;
          }
          if(z < zmin){
            zmin = z;
          }
          if(z > zmax){
            zmax = z;
          }
        }
      }
    }
  }

  dimensions->width = abs(xmax - xmin) + 1;
  dimensions->height = abs(ymax - ymin) + 1;
  dimensions->depth = abs(zmax - zmin) + 1;
  dimensions->xmin = xmin;
  dimensions->xmax = xmax;
  dimensions->ymin = ymin;
  dimensions->ymax = ymax;
  dimensions->zmin = zmin;
  dimensions->zmax = zmax;

  return CUBIFIER_ERROR_SUCCESS;
}

static bool cube_needs_expansion(CubifierVolume *volume, CubifierCube* cube){
  if(volume->width == 0 || volume->height == 0 || volume->depth == 0){
    return false;
  }
  return (cube->width < volume->width ||
          cube->height < volume->height ||
          cube->depth < volume->depth);
}

static void new_cube(CubifierVolume *volume, CubifierCube *oldCube, CubifierCube *cube){

}

static bool expand_cube(CubifierVolume *volume, CubifierCube *cube){
  return false;
}

static void volume_subtract(CubifierVolume *volume, CubifierCube *cube){
  
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
  Dimensions dimensions;

  CHECK_ERROR(get_dimensions(volume, &dimensions));

  int cubeCount = 0;
  CubifierCube *cubes = malloc(sizeof(CubifierCube) * 100);
  if(cubes == NULL){
    return CUBIFIER_ERROR_OUT_OF_MEMORY;
  }

  CubifierCube *cube = &cubes[0];

  cube->width = dimensions.width;
  cube->height = dimensions.height;
  cube->depth = dimensions.depth;
  cube->offsetX = dimensions.xmin;
  cube->offsetY = dimensions.ymin;
  cube->offsetZ = dimensions.zmin;

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
