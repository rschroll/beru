file(GLOB HTML_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     background_paper@30.png
     background_paper_invert@30.png
     index.html
     messaging.js
     styling.js
)

foreach( SRC_FILE ${HTML_SRC_FILES} )
     file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${HTML_SRC_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endforeach( SRC_FILE )

#Add files to Qt Creator resources, so they are visible in SDK file list
QT5_ADD_RESOURCES (ResourceSources ${HTML_SRC_FILES})

add_subdirectory(fonts)
add_subdirectory(monocle)
