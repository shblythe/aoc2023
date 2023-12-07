cmake_minimum_required(VERSION 3.27)
include(pico_sdk_import.cmake)
project(CamelCards C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
include_directories(${CMAKE_SOURCE_DIR})
add_executable(CamelCards
    camelCards.S
)
pico_enable_stdio_uart(CamelCards 1)
pico_enable_stdio_usb(CamelCards 0)
target_link_libraries(CamelCards pico_stdlib pico_double)
