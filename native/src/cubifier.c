#include "cubifier.h"
#include <stdio.h>
#include <stdlib.h>

CUBIFIER_ERROR cubifier_create_volume(int xdim, int ydim, int zdim, CubifierVolume *outVolume){
  outVolume->width = xdim;
  outVolume->height = ydim;
  outVolume->depth = zdim;

  short *voxels = malloc(sizeof(short) * xdim * ydim * zdim);
  if(voxels == NULL){
    return CUBIFIER_ERROR_OUT_OF_MEMORY;
  }

  outVolume->voxels = voxels;

  return CUBIFIER_ERROR_SUCCESS;
}

CUBIFIER_ERROR cubifier_destroy_volume(CubifierVolume *volume){
  return CUBIFIER_ERROR_NOT_IMPLEMENTED;
}

CUBIFIER_ERROR cubifier_set_voxel(CubifierVolume *volume, int x, int y, int z, short value){
  return CUBIFIER_ERROR_NOT_IMPLEMENTED;
}

CUBIFIER_ERROR cubifier_get_voxel(CubifierVolume *volume, int x, int y, int z, short* outValue){
  return CUBIFIER_ERROR_NOT_IMPLEMENTED;
}

CUBIFIER_ERROR cubifier_cubify(CubifierVolume *volume, CubifierCube *outCubes, int *cubeCount){
  return CUBIFIER_ERROR_NOT_IMPLEMENTED;
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
