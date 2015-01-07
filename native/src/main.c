#include <stdio.h>
#include "cubifier.h"

#define CHECK_ERROR(CMD) \
  do { \
    int code = CMD; \
    if(code){ \
      fprintf(stderr, "ERROR %s on line #%d: " #CMD "\n", cubifier_get_error_string(code), __LINE__); \
      return code; \
    } \
  } while(0)

static CUBIFIER_ERROR create_giant_surface(CubifierVolume *volume){
  const int vwidth = 1000;
  const int vheight = 1000;
  CHECK_ERROR(cubifier_create_volume(vwidth, vheight, 1, volume));
  for(int x = 0; x < vwidth; x++){
    for(int y = 0; y < vheight; y++){
      CHECK_ERROR(cubifier_set_voxel(volume, x, y, 0, 1));
    }
  }
  return CUBIFIER_ERROR_SUCCESS;
}


int main(){
  CubifierVolume volume;

  CHECK_ERROR(create_giant_surface(&volume));
  CHECK_ERROR(cubifier_destroy_volume(&volume));

  return 0;
}
