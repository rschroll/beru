set(PLUGIN_DIR Epub)

set(epubreader_SRCS
    epubreader.cpp
    epubreader.h
    epubreaderplugin.cpp
    epubreaderplugin.h
    quazip/qioapi.cpp
    quazip/quazip.cpp
    quazip/quacrc32.cpp
    quazip/JlCompress.cpp
    quazip/quaadler32.cpp
    quazip/quazipfile.cpp
    quazip/quagzipfile.cpp
    quazip/quaziodevice.cpp
    quazip/quazipnewinfo.cpp
    quazip/quazipfileinfo.cpp
    quazip/unzip.c
    quazip/zip.c
    ../qhttpserver/qhttpconnection.cpp
    ../qhttpserver/qhttprequest.cpp
    ../qhttpserver/qhttpresponse.cpp
    ../qhttpserver/qhttpserver.cpp
    ../qhttpserver/http-parser/http_parser.c
    ../qhttpserver/http-parser/url_parser.c
)

add_library(epubreaderplugin MODULE
    ${epubreader_SRCS}
)

qt5_use_modules(epubreaderplugin Gui Xml Qml Quick)

# Copy the plugin, the qmldir file and other assets to the build dir for running in QtCreator
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(TARGET epubreaderplugin POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Creating plugin directory layout in the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the qmldir file to the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:epubreaderplugin> ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the plugin binary to the build directory"
    )
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

# Install plugin file
install(TARGETS epubreaderplugin DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})
