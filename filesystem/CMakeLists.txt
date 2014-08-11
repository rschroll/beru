set(PLUGIN_DIR File)

set(filesystem_SRCS
    filesystem.cpp
    filesystemplugin.cpp
)

add_library(filesystemplugin MODULE
    ${filesystem_SRCS}
)

qt5_use_modules(filesystemplugin Qml Quick)

# Copy the plugin file to the build dir
set_target_properties(filesystemplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Copy the qmldir file to the build dir
add_custom_command(TARGET filesystemplugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Install plugin file
string(REPLACE "//" "/" LIB_DIR ${DATA_DIR}/${PLUGIN_DIR})
install(TARGETS filesystemplugin DESTINATION ${LIB_DIR})
install(FILES qmldir DESTINATION ${LIB_DIR})
