cmake_minimum_required(VERSION 3.28)
project(four_connect_extreme CXX)
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(${PROJECT_SOURCE_DIR}/project_options.cmake)
include(${PROJECT_SOURCE_DIR}/dependencies.cmake)

four_connect_extreme_setup_dependencies()

add_subdirectory(src bin)

set(TARGET_LIST Client Bot spdlog ixwebsocket gtest gtest_main)

foreach (target ${TARGET_LIST})
    # static runtime library
    set_property(TARGET ${target} PROPERTY
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

    if (CMAKE_BUILD_TYPE STREQUAL "Release")
        message("Enabling LTO for target ${target}")
        set_property(TARGET ${target} PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
    else ()
        message("Not enabling LTO for target ${target} (not a release build)")
    endif ()
endforeach ()
