cmake_minimum_required(VERSION 3.27)
include(pico_sdk_import.cmake)
project(SeedAlmanac C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
include_directories(${CMAKE_SOURCE_DIR})
add_executable(SeedAlmanac
    seedAlmanac.S
)
pico_enable_stdio_uart(SeedAlmanac 1)
pico_enable_stdio_usb(SeedAlmanac 0)
target_link_libraries(SeedAlmanac pico_stdlib)
