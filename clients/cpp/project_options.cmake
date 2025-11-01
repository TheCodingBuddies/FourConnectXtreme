include(${PROJECT_SOURCE_DIR}/cmake/warnings.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/sanitizers.cmake)

# the following function was taken from:
# https://github.com/cpp-best-practices/cmake_template/blob/main/ProjectOptions.cmake
macro(check_sanitizer_support)
    if ((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
        set(supports_ubsan ON)
        set(supports_thread_sanitizer ON)
    else ()
        set(supports_ubsan OFF)
        set(supports_thread_sanitizer OFF)
    endif ()

    if ((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
        set(supports_asan OFF)
        set(supports_thread_sanitizer OFF)
    else ()
        set(supports_asan ON)
        set(supports_thread_sanitizer OFF)
    endif ()
endmacro()

check_sanitizer_support()

if (PROJECT_IS_TOP_LEVEL)
    option(four_connect_extreme_warnings_as_errors "Treat warnings as errors" ON)
    option(four_connect_extreme_enable_undefined_behavior_sanitizer "Enable undefined behavior sanitizer" ${supports_ubsan})
    option(four_connect_extreme_enable_address_sanitizer "Enable address sanitizer" ${supports_asan})
else ()
    option(four_connect_extreme_warnings_as_errors "Treat warnings as errors" OFF)
    option(four_connect_extreme_enable_undefined_behavior_sanitizer "Enable undefined behavior sanitizer" OFF)
    option(four_connect_extreme_enable_address_sanitizer "Enable address sanitizer" OFF)
endif ()

add_library(four_connect_extreme_warnings INTERFACE)
set_warnings(four_connect_extreme_warnings ${four_connect_extreme_warnings_as_errors})

add_library(four_connect_extreme_sanitizers INTERFACE)
enable_sanitizers(
        four_connect_extreme_sanitizers
        ${four_connect_extreme_enable_address_sanitizer}
        ${four_connect_extreme_enable_undefined_behavior_sanitizer}
)

add_library(four_connect_extreme_options INTERFACE)
target_link_libraries(four_connect_extreme_options
        INTERFACE four_connect_extreme_warnings
        INTERFACE four_connect_extreme_sanitizers
)
