set(PLUGIN_DIR Epub)

set(epubreader_SRCS
    epubreader.cpp
    cbzreader.cpp
    pdfreader.cpp
    epubreaderplugin.cpp
    quazip/JlCompress.cpp
    quazip/qioapi.cpp
    quazip/quacrc32.cpp
    quazip/quaadler32.cpp
    quazip/quazip.cpp
    quazip/quazipfile.cpp
    quazip/quagzipfile.cpp
    quazip/quazipfileinfo.cpp
    quazip/quaziodevice.cpp
    quazip/quazipnewinfo.cpp
    quazip/unzip.c
    quazip/zip.c
    ../qhttpserver/qhttpconnection.cpp
    ../qhttpserver/qhttpresponse.cpp
    ../qhttpserver/qhttpserver.cpp
)

add_library(epubreaderplugin MODULE
    ${epubreader_SRCS}
)

qt5_use_modules(epubreaderplugin Gui Xml Qml Quick)
target_link_libraries(epubreaderplugin poppler-qt5)

# Copy the plugin file to the build dir
set_target_properties(epubreaderplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Copy the qmldir file to the build dir
add_custom_command(TARGET epubreaderplugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qmldir ${CMAKE_CURRENT_BINARY_DIR}/../${PLUGIN_DIR}
)

# Install plugin file
string(REPLACE "//" "/" LIB_DIR ${DATA_DIR}/${PLUGIN_DIR})
install(TARGETS epubreaderplugin DESTINATION ${LIB_DIR})
install(FILES qmldir DESTINATION ${LIB_DIR})
