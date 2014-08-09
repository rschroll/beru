set(HTML_SRC_FILES
    index.html
    messaging.js
    styling.js
    monocle/scripts/monocore.js
    monocle/scripts/monoctrl.js
    monocle/styles/monocore.css
    monocle/styles/monoctrl.css
)
set(HTML_SUPPORTING_FILES
    background_paper@30.png
    background_paper_invert@30.png
    "fonts/Bitstream Charter.ttf"
    "fonts/Bitstream Charter Bold.ttf"
    "fonts/Bitstream Charter Bold Italic.ttf"
    "fonts/Bitstream Charter Italic.ttf"
    fonts/COPYING.URW
    fonts/license.charter.txt
    fonts/README.URW
    "fonts/URW Bookman L.ttf"
    "fonts/URW Bookman L Bold.ttf"
    "fonts/URW Bookman L Bold Italic.ttf"
    "fonts/URW Bookman L Italic.ttf"
    "fonts/URW Gothic L.ttf"
    "fonts/URW Gothic L Bold.ttf"
    "fonts/URW Gothic L Bold Italic.ttf"
    "fonts/URW Gothic L Italic.ttf"
)

if(${OUT_OF_TREE_BUILD})
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR} DESTINATION ${CMAKE_BINARY_DIR})
endif(${OUT_OF_TREE_BUILD})
