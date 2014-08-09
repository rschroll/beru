project(beru)
cmake_minimum_required(VERSION 2.8.9)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra -fPIC")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Standard install paths
include(GNUInstallDirs)
include(FindPkgConfig)

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Installs to a contained location" off)

set(APP_NAME beru)
set(DESKTOP_FILE "${PROJECT_NAME}.desktop")
set(APP_HARDCODE beru)
set(ICON_FILE beru.svg)
set(AUTOPILOT_DIR ${APP_NAME})
set(MAIN_QML "ui/main.qml")
set(EXEC ${APP_NAME})


include_directories (${CMAKE_CURRENT_BINARY_DIR}/File)

link_directories (${CMAKE_CURRENT_BINARY_DIR}/File)

find_package(Qt5Core REQUIRED Qt5Qml Qt5Quick Qt5Xml Qt5Gui Qt5Network)

FIND_LIBRARY(FILESYSTEMPLUGIN
  NAMES filesystemplugin libfilesystemplugin
  PATHS 
  ${CMAKE_CURRENT_BINARY_DIR}/File
  )

if(CLICK_MODE)
    if(NOT DEFINED BZR_SOURCE)
        set(BZR_SOURCE "lp:${APP_HARDCODE}")
        message("-- Setting BZR_SOURCE to ${BZR_SOURCE}")
    endif(NOT DEFINED BZR_SOURCE)
    # Find out the architecture for package building
    # to determine the plugin's installation path
    execute_process(
        COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
        OUTPUT_VARIABLE ARCH_TRIPLET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(DESKTOP_DIR ${DATA_DIR})
    set(ICON ${ICON_FILE})
    set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")
    set(BIN_DIR /lib/${ARCH_TRIPLET}/bin)
    if(NOT BZR_REVNO)
        set(BZR_REVNO "latest")
    endif(NOT BZR_REVNO)
    configure_file(manifest.json ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json apparmor.json DESTINATION ${CMAKE_INSTALL_PREFIX})
else(CLICK_MODE)
    execute_process(
        COMMAND qmake -query QT_INSTALL_QML
        OUTPUT_VARIABLE QT_IMPORTS_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_NAME})
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
endif(CLICK_MODE)

file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js *.png *.svg *.json)
install(FILES ${SRC_FILES}  DESTINATION ${DATA_DIR})

configure_file(${DESKTOP_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE})
configure_file(${DESKTOP_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}.in)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
    DESTINATION ${DESKTOP_DIR})

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/beru ${CMAKE_CURRENT_BINARY_DIR}/beru)

add_subdirectory(epubreader)
add_subdirectory(filesystem)
add_subdirectory(fontlister)
add_subdirectory(html)
add_subdirectory(qhttpserver)
add_subdirectory(ui)
