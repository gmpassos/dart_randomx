cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(wrapper_randomx_library VERSION 1.0.0 LANGUAGES C)

add_library(wrapper_randomx_library SHARED wrapper_randomx.c wrapper_randomx.def)

add_library(randomx STATIC IMPORTED)

target_link_libraries(wrapper_randomx_library librandomx.a -lstdc++)
target_link_libraries(wrapper_randomx_library -L.)

set_target_properties(wrapper_randomx_library PROPERTIES
    PUBLIC_HEADER wrapper_randomx.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "wrapper_randomx"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
