#ifndef CUBIFIER_H_
#define CUBIFIER_H_

typedef enum {
  CUBIFIER_ERROR_SUCCESS = 0,
  CUBIFIER_ERROR_NOT_IMPLEMENTED = 1,
  CUBIFIER_ERROR_OUT_OF_MEMORY = 2
} CUBIFIER_ERROR;

typedef struct {
  int width;
  int height;
  int depth;
  short *voxels;
} CubifierVolume;

typedef struct {
  int offsetX;
  int offsetY;
  int offsetZ;

  int width;
  int height;
  int depth;
} CubifierCube;

CUBIFIER_ERROR cubifier_create_volume(int xdim, int ydim, int zdim, CubifierVolume *outVolume);
CUBIFIER_ERROR cubifier_destroy_volume(CubifierVolume *volume);

CUBIFIER_ERROR cubifier_set_voxel(CubifierVolume *volume, int x, int y, int z, short value);
CUBIFIER_ERROR cubifier_get_voxel(CubifierVolume *volume, int x, int y, int z, short* outValue);

CUBIFIER_ERROR cubifier_cubify(CubifierVolume *volume, CubifierCube *outCubes, int *cubeCount);

const char* cubifier_get_error_string(CUBIFIER_ERROR code);

#endif
