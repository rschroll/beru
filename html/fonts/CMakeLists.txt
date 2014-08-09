file(GLOB HTML_FONTS_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     "Bitstream Charter.ttf"
     "Bitstream Charter Bold.ttf"
     "Bitstream Charter Bold Italic.ttf"
     "Bitstream Charter Italic.ttf"
     COPYING.URW
     license.charter.txt
     README.URW
     "URW Bookman L.ttf"
     "URW Bookman L Bold.ttf"
     "URW Bookman L Bold Italic.ttf"
     "URW Bookman L Italic.ttf"
     "URW Gothic L.ttf"
     "URW Gothic L Bold.ttf"
     "URW Gothic L Bold Italic.ttf"
     "URW Gothic L Italic.ttf"
)

foreach( SRC_FILE ${HTML_FONTS_SRC_FILES} )
     file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${HTML_FONTS_SRC_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endforeach( SRC_FILE )
