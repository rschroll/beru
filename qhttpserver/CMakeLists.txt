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
)

add_library(qhttpserverplugin MODULE
    ${qhttpserver_SRCS}
)

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

