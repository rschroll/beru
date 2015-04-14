set(UI_SRC_FILES
    main.qml
    sqlout.js
)

if(${OUT_OF_TREE_BUILD})
    foreach( SRC_FILE ${UI_SRC_FILES} )
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILE})
    endforeach( SRC_FILE )
endif(${OUT_OF_TREE_BUILD})

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DESTINATION ${DATA_DIR}
    PATTERN "[Cc][Mm]ake*" EXCLUDE)
