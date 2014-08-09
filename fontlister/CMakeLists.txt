set(PLUGIN_DIR FontList)

set(fontlister_SRCS
    fontlister.cpp
    fontlisterplugin.cpp
)

add_library(fontlisterplugin MODULE
    ${fontlister_SRCS}
)

qt5_use_modules(fontlisterplugin Qml Quick)

# Copy the plugin file to the build dir
set_target_properties(fontlisterplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Copy the qmldir file to the build dir
add_custom_command(TARGET fontlisterplugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Install plugin file
install(TARGETS fontlisterplugin DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})
