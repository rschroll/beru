project(beru)
cmake_minimum_required(VERSION 2.8.9)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra -fPIC")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(UBUNTU_PROJECT_TYPE "ClickApp" CACHE INTERNAL "Tells QtCreator this is a Click application project")
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tells QtCreator location and name of the manifest file")

# Standard install paths
include(GNUInstallDirs)
include(FindPkgConfig)

option(CLICK_MODE "Installs to a contained locaton" off)
option(FS_ACCESS "Gets filesystem access through apparmor" off)

set(APP_NAME com.ubuntu.developer.rschroll.beru)
set(SUFFIX "")

file(STRINGS VERSION VERSION_STRING)
separate_arguments(VERSION_STRING)
list(GET VERSION_STRING 0 VERSION_MAJOR)
list(GET VERSION_STRING 1 VERSION_MINOR)
list(GET VERSION_STRING 2 VERSION_REVISION)
if(FS_ACCESS)
    math(EXPR VERSION_REVISION "${VERSION_REVISION} + 1")
    set(SUFFIX ".access")
endif(FS_ACCESS)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})

set(DESKTOP_FILE "${PROJECT_NAME}.desktop")
set(DESKTOP_NAME "Beru")
set(DESKTOP_COMMENT "The Basic Epub Reader for Ubuntu")
set(APP_HARDCODE beru)
set(ICON_FILE beru.svg)

# Check if build is out of source tree and sets boolean value
set(OUT_OF_TREE_BUILD true)
if(${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR})
    set(OUT_OF_TREE_BUILD false)
endif(${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR})

# Scan the default include directories to find packages that will be needed for building plugins
find_package(Qt5Core REQUIRED Qt5Qml Qt5Quick Qt5Xml Qt5Gui Qt5Network)

file(GLOB I18N_SRC_FILES
     RELATIVE ${CMAKE_SOURCE_DIR}
     ui/*.qml ${DESKTOP_FILE}.tr)
# DefaultCover.qml doesn't have any translatable strings, but it does confuse xgettext.
list(REMOVE_ITEM I18N_SRC_FILES ui/DefaultCover.qml)

if(CLICK_MODE)
    # Find out the architecture for package building
    # to determine the plugin's installation path
    execute_process(
        COMMAND dpkg-architecture -qDEB_HOST_ARCH
        OUTPUT_VARIABLE ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(DESKTOP_DIR ${DATA_DIR})
    set(ICON ${ICON_FILE})
    set(EXEC "qmlscene -I ./ ui/main.qml --appargs=\"%f\"")
    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json DESTINATION ${DATA_DIR})
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/beru.contenthub.json DESTINATION ${DATA_DIR})
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/apparmor DESTINATION ${DATA_DIR})
else(CLICK_MODE)
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
    set(EXEC "${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/beru %f")
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    install(CODE "file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/beru.in
        \"${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/beru\")")
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/beru.in DESTINATION ${CMAKE_INSTALL_BINDIR} RENAME beru)
endif(CLICK_MODE)

#Copies specific individual files into the build directory
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/beru ${CMAKE_CURRENT_BINARY_DIR}/beru @ONLY)
configure_file(${DESKTOP_FILE}.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE})
configure_file(${DESKTOP_FILE}.tr ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}.tr)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/beru DESTINATION ${DATA_DIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE} DESTINATION ${DESKTOP_DIR})
install(FILES ${ICON_FILE} DESTINATION ${DATA_DIR})

# Add the needed subdirectories to be built and look for a CMakeLists.txt file in each directory
add_subdirectory(filesystem)
add_subdirectory(ui)

add_subdirectory(po)
