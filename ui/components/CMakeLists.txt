file(GLOB UI_COMPONENTS_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     OptionsSelector.qml
     StylableOptionSelectorDelegate.qml
     TitlelessDialog.qml
)

foreach( SRC_FILE ${UI_COMPONENTS_SRC_FILES} )
     file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${UI_COMPONENTS_SRC_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endforeach( SRC_FILE )
