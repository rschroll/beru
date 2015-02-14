set(UI_SRC_FILES
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
    components/OptionSelector.qml
    components/StylableOptionSelectorDelegate.qml
    components/StyledButton.qml
    components/Toolbar.qml
    images/default_cover.svg
    images/error_cover.svg
    images/error_cover_full.svg
    images/toc.svg
)

if(${OUT_OF_TREE_BUILD})
    foreach( SRC_FILE ${UI_SRC_FILES} )
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE} ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILE})
    endforeach( SRC_FILE )
endif(${OUT_OF_TREE_BUILD})

set(IMAGE_SRC
    images/stainedpaper_tiled.jpg
)

add_custom_command(OUTPUT Textures.qml
    COMMAND ./encoder.sh ${IMAGE_SRC} > ${CMAKE_CURRENT_BINARY_DIR}/Textures.qml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS ${IMAGE_SRC}
)
add_custom_target(MakeTextures ALL DEPENDS Textures.qml)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DESTINATION ${DATA_DIR}
    PATTERN "[Cc][Mm]ake*" EXCLUDE)
