set(PLUGIN_DIR HttpServer)

set(qhttpserver_SRCS
    fileserver.cpp
    httpserverplugin.cpp
    qhttpconnection.cpp
    qhttprequest.cpp
    qhttpresponse.cpp
    qhttpserver.cpp
    http-parser/http_parser.c
    http-parser/url_parser.c
)

add_library(qhttpserverplugin MODULE
    ${qhttpserver_SRCS}
)
add_definitions(-DQT_NO_DEBUG_OUTPUT)

qt5_use_modules(qhttpserverplugin Gui Qml Network)

# Copy the plugin file to the build dir
set_target_properties(qhttpserverplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Copy the qmldir file to the build dir
add_custom_command(TARGET qhttpserverplugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Install plugin file
install(TARGETS qhttpserverplugin DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})
