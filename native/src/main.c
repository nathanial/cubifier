#include <stdio.h>
#include "cubifier.h"

#define VSIZE 1000

#define CHECK_ERROR(CMD) \
  do { \
    int code = CMD; \
    if(code){ \
      fprintf(stderr, "ERROR %s on line #%d: " #CMD "\n", cubifier_get_error_string(code), __LINE__); \
      return 1; \
    } \
  } while(0)

int main(){
  CubifierVolume volume;

  CHECK_ERROR(cubifier_create_volume(VSIZE, VSIZE, VSIZE, &volume));
  CHECK_ERROR(cubifier_destroy_volume(&volume));

  return 0;
}
