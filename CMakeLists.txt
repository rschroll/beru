project(beru)
cmake_minimum_required(VERSION 2.8.9)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra -fPIC")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Standard install paths
include(GNUInstallDirs)
include(FindPkgConfig)

set(APP_NAME beru)
set(DESKTOP_FILE "${PROJECT_NAME}.desktop")
set(APP_HARDCODE beru)
set(ICON_FILE beru.svg)
set(AUTOPILOT_DIR ${APP_NAME})
set(MAIN_QML "ui/main.qml")
set(EXEC ${APP_NAME})
set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_NAME})
set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)

#Checks if build is out of source tree and sets boolean value
set(OUT_OF_TREE_BUILD true)
if (${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR})
     set(OUT_OF_TREE_BUILD false)
endif ( ${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR} )

#Scans the default include directories to find packages that will be needed for building plugins
find_package(Qt5Core REQUIRED Qt5Qml Qt5Quick Qt5Xml Qt5Gui Qt5Network)

execute_process(
     COMMAND qmake -query QT_INSTALL_QML
     OUTPUT_VARIABLE QT_IMPORTS_DIR
     OUTPUT_STRIP_TRAILING_WHITESPACE
)

#Creates a list of files in the root source directory to be copied into the build directory
file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js *.png *.svg *.json)

#Copies each file in the SRC_FILES list into the build directory
foreach( SRC_FILE ${SRC_FILES} )
     configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILES} ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILES})
endforeach( SRC_FILE )

#Add files to Qt Creator resources, so they are visible in SDK file list
QT5_ADD_RESOURCES (ResourceSources ${SRC_FILES})

#Copies specific individual files into the build directory
configure_file(${DESKTOP_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
    DESTINATION ${DESKTOP_DIR})

#Copies beru.in run script to build dir
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/beru.in ${CMAKE_CURRENT_BINARY_DIR}/beru @ONLY)

if(NOT ${OUT_OF_TREE_BUILD})
    add_custom_target(LinkToBin ALL
        COMMAND
            ${CMAKE_COMMAND} -E create_symlink ${CMAKE_CURRENT_BINARY_DIR}/beru ${CMAKE_CURRENT_SOURCE_DIR}/beru
    )
endif(NOT ${OUT_OF_TREE_BUILD})

#Adds the needed subdirectories to be built and looks for a CMakeLists.txt file in each directory
add_subdirectory(epubreader)
add_subdirectory(filesystem)
add_subdirectory(fontlister)
add_subdirectory(html)
add_subdirectory(qhttpserver)
add_subdirectory(ui)
