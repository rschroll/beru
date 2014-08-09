file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     index.html
     messaging.js
     styling.js
)

foreach( SRC_FILES ${SRC_FILES} )
     configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILES} ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILES})
endforeach( SRC_FILES )

