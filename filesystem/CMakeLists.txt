set(PLUGIN_DIR File)

set(filesystem_SRCS
    filesystem.cpp
    filesystem.h
    filesystemplugin.cpp
    filesystemplugin.h
)

add_library(filesystemplugin MODULE
    ${filesystem_SRCS}
)

qt5_use_modules(filesystemplugin Qml Quick)

# Copy the plugin, the qmldir file and other assets to the build dir for running in QtCreator
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(TARGET filesystemplugin POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Creating plugin directory layout in the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the qmldir file to the build directory"
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:filesystemplugin> ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
        COMMENT "Copying the plugin binary to the build directory"
    )
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

# Install plugin file
install(TARGETS filesystemplugin DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

