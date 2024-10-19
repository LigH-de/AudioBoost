cmake_minimum_required(VERSION 3.5)

project(AudioBoost VERSION 0.17 LANGUAGES CXX)

find_package(PkgConfig REQUIRED)
pkg_check_modules(avisynth REQUIRED avisynth)

option(ENABLE_CPP_PLUGIN "Build AviSynth C++ interface plugin" OFF)
option(ENABLE_C_PLUGIN "Build AviSynth C interface plugin" ON)

if(ENABLE_CPP_PLUGIN)
    add_library(audioboost SHARED AudioBoost.cpp)
    set(PROJECTLIB audioboost)
endif()

if(ENABLE_C_PLUGIN)
    add_library(audioboost-c SHARED AudioBoost_c.cpp)
    set(PROJECTLIB audioboost-c)
endif()

target_include_directories(${PROJECTLIB} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${AVISYNTH_INCLUDE_DIRS})
target_link_libraries(${PROJECTLIB} avisynth)

include(GNUInstallDirs)

if(ENABLE_CPP_PLUGIN)
INSTALL(TARGETS audioboost
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/avisynth")
endif()

if(ENABLE_C_PLUGIN)
INSTALL(TARGETS audioboost-c
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/avisynth")
endif()

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
