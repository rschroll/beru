# Based on the Ubuntu Weather App

include(FindGettext)
find_program(GETTEXT_XGETTEXT_EXECUTABLE xgettext)

set(DOMAIN ${PROJECT_NAME})
set(POT_FILE ${DOMAIN}.pot)
file(GLOB PO_FILES *.po)

# Create the .pot file containing the translations template
# Note that I18N_SRC_FILES was generated from the source directory
# listing, but xgettext is being run in the binary directory.
add_custom_target(${POT_FILE} ALL
    COMMENT "Generating translation template"
    COMMAND ${GETTEXT_XGETTEXT_EXECUTABLE} -o ${POT_FILE}
        -D ${CMAKE_BINARY_DIR}
        --from-code=UTF-8
        -L javascript --qt --add-comments=/
        --keyword=tr --keyword=tr:1,2
        --package-name='${APP_HARDCODE}'
        --copyright-holder='Robert Schroll'
        --msgid-bugs-address='rschroll@gmail.com'
        ${I18N_SRC_FILES})

# Build the binary translations catalog for each language
# it finds source translations (*.po) for
foreach(PO_FILE ${PO_FILES})
    get_filename_component(LANG ${PO_FILE} NAME_WE)
    gettext_process_po_files(${LANG} ALL PO_FILES ${PO_FILE})
    set(INSTALL_DIR ${CMAKE_INSTALL_LOCALEDIR}/${LANG}/LC_MESSAGES)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.gmo
            DESTINATION ${INSTALL_DIR}
            RENAME ${DOMAIN}.mo)
endforeach(PO_FILE)
