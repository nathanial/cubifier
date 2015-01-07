#--- executable
file(GLOB SRC_SOURCES ./ *.c *.h)
add_executable(cubifier ${SRC_SOURCES})
target_link_libraries(cubifier)
