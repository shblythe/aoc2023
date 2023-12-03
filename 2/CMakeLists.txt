cmake_minimum_required(VERSION 3.27)
include(pico_sdk_import.cmake)
project(CubeConundrum C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
include_directories(${CMAKE_SOURCE_DIR})
add_executable(CubeConundrum
    cubeConundrum.S
)
pico_enable_stdio_uart(CubeConundrum 1)
pico_enable_stdio_usb(CubeConundrum 0)
target_link_libraries(CubeConundrum pico_stdlib)
