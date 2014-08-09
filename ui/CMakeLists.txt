file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     main.qml
     BookPage.qml
     LocalBooks.qml
     Server.qml
     BookSources.qml
     BrowserPage.qml
     DefaultCover.qml
     components/UbuntuWebView.qml
     components/StylableOptionSelectorDelegate.qml
     qmlmessaging.js
     historystack.js
)

foreach( SRC_FILES ${SRC_FILES} )
     configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILES} ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILES})
endforeach( SRC_FILES )

