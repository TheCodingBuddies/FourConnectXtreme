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
