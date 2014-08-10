file(GLOB UI_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     BookPage.qml
     BookSources.qml
     BrowserPage.qml
     DefaultCover.qml
     historystack.js
     LocalBooks.qml
     main.qml
     qmlmessaging.js
     qmlmessaging-userscript.js
     Server.qml
)

foreach( SRC_FILE ${UI_SRC_FILES} )
     file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${UI_SRC_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endforeach( SRC_FILE )

#Add files to Qt Creator resources, so they are visible in SDK file list
QT5_ADD_RESOURCES (ResourceSources ${UI_SRC_FILES})

set(IMAGE_SRC
    images/stainedpaper_tiled.jpg
)

add_custom_command(OUTPUT Textures.qml
     COMMAND ./encoder.sh ${IMAGE_SRC} > ${CMAKE_CURRENT_BINARY_DIR}/Textures.qml
     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
     DEPENDS ${IMAGE_SRC}
)
add_custom_target(MakeTextures ALL DEPENDS Textures.qml)

add_subdirectory(components)
add_subdirectory(images)
