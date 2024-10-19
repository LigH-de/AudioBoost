cmake_minimum_required(VERSION 3.5)

project(AudioBoost VERSION 0.17 LANGUAGES CXX)

if (WIN32)
    set(CoreNameCPP "AudioBoost-CPP")
    set(CoreNameC "AudioBoost-C")
else()
    set(CoreNameCPP "audioboost-cpp")
    set(CoreNameC "audioboost-c")
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(avisynth REQUIRED avisynth)

option(ENABLE_CPP_PLUGIN "Build AviSynth C++ interface plugin" OFF)
option(ENABLE_C_PLUGIN "Build AviSynth C interface plugin" ON)

if(ENABLE_CPP_PLUGIN)
    add_library(${CoreNameCPP} SHARED AudioBoost.cpp)
    set(PROJECTLIB ${CoreNameCPP})

    set_target_properties(${PROJECTLIB} PROPERTIES OUTPUT_NAME ${PROJECTLIB})

    target_include_directories(${PROJECTLIB} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${AVISYNTH_INCLUDE_DIRS})

    if (MINGW)
        set_target_properties(${PROJECTLIB} PROPERTIES PREFIX "")
        set_target_properties(${PROJECTLIB} PROPERTIES IMPORT_PREFIX "")
    endif()
endif()

if(ENABLE_C_PLUGIN)
    add_library(${CoreNameC} SHARED AudioBoost_c.cpp)
    set(PROJECTLIB ${CoreNameC})

    set_target_properties(${PROJECTLIB} PROPERTIES OUTPUT_NAME ${PROJECTLIB})

    target_include_directories(${PROJECTLIB} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${AVISYNTH_INCLUDE_DIRS})
    target_link_libraries(${PROJECTLIB} avisynth)

    if (MINGW)
        set_target_properties(${PROJECTLIB} PROPERTIES PREFIX "")
        set_target_properties(${PROJECTLIB} PROPERTIES IMPORT_PREFIX "")
    endif()
endif()

include(GNUInstallDirs)

if(ENABLE_CPP_PLUGIN)
INSTALL(TARGETS ${CoreNameCPP}
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/avisynth")
endif()

if(ENABLE_C_PLUGIN)
INSTALL(TARGETS ${CoreNameC}
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/avisynth")
endif()

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
