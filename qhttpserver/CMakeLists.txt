set(PLUGIN_DIR HttpServer)

set(qhttpserver_SRCS
    fileserver.cpp
    fileserver.h
    qhttpserver.cpp
    qhttpserver.h
    qhttpconnection.cpp
    qhttpconnection.h
    qhttprequest.cpp
    qhttprequest.h
    qhttpresponse.cpp
    qhttpresponse.h
    httpserverplugin.cpp
    httpserverplugin.h
    "${CMAKE_CURRENT_SOURCE_DIR}/http-parser/http_parser.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/http-parser/http_parser.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/http-parser/url_parser.c"
)

add_library(qhttpserverplugin MODULE
    ${qhttpserver_SRCS}
)

qt5_use_modules(qhttpserverplugin Gui Qml Network)

# Copy the plugin, the qmldir file and other assets to the build dir for running in QtCreator
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(TARGET qhttpserverplugin POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Creating plugin directory layout in the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the qmldir file to the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:qhttpserverplugin> ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the plugin binary to the build directory"
    )
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

# Install plugin file
install(TARGETS qhttpserverplugin DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

