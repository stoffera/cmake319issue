cmake_minimum_required(VERSION 3.19)

# make sure we create an iOS project
set(CMAKE_SYSTEM_NAME iOS)

project(LinkDemo)

find_library(FOUNDATION Foundation)
find_library(CG CoreGraphics)

add_executable(Demo MACOSX_BUNDLE main.mm)
target_link_libraries(Demo ${FOUNDATION} ${CG} objc)
set_target_properties(Demo PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME Demo
    MACOSX_BUNDLE_GUI_IDENTIFIER dk.stoffera.linkdemo
    MACOSX_BUNDLE_BUNDLE_VERSION 1.0.0
    MACOSX_BUNDLE_SHORT_VERSION_STRING 1.0
)