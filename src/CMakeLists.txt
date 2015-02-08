# build rules to create the gui part

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# variables
SET(NAM fbdbg)      # base name
SET(BAS ${NAM}.bas) # FB source name
SET(UI_FILES        # list of ui files
  ${NAM}.ui
  log.ui
  )

# copy auxiliary files to build folder in case of out-of-source build
IF(NOT(CMAKE_CURRENT_BINARY_DIR STREQUAL
       CMAKE_CURRENT_SOURCE_DIR))

  FOREACH(n ${UI_FILES})
    SET(t ${CMAKE_BINARY_DIR}/${n})
    ADD_CUSTOM_COMMAND(OUTPUT ${t}
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/${n} ${t}
      DEPENDS ${n}
      )
  ENDFOREACH(n)
  ADD_CUSTOM_TARGET(ui_copy ALL DEPENDS ${UI_FILES})

  FILE(COPY img locale dat # doing only once, no check for changes
    DESTINATION ${CMAKE_BINARY_DIR}
    )
ENDIF()

# fbdbg.bas.o: create the object file
ADD_LIBRARY(fbdbg_gui OBJECT ${BAS})
SET_TARGET_PROPERTIES(fbdbg_gui PROPERTIES
  COMPILE_FLAGS "-m ${NAM} -w all"
  )
ADD_Fbc_SRC_DEPS(fbdbg_gui)


# fbdbg.pot create translators file
GET_PROPERTY(GUI_SRC
  SOURCE ${BAS}
  PROPERTY "OBJECT_DEPENDS"
  )
ADD_CUSTOM_COMMAND(OUTPUT ${NAM}.pot
  COMMAND gettext -V
  DEPENDS ${UI_FILES} ${GUI_SRC} ${BAS}
  )
ADD_CUSTOM_TARGET(I18N DEPENDS ${NAM}.pot)
