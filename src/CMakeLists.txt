# build rules to create the gui part

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# variables
SET(NAM fbdbg)      # base name
SET(BAS ${NAM}.bas) # FB source name
SET(UI_FILES        # list of ui files
  ${NAM}.ui
  log.ui
  CACHE FILEPATH "XML files" FORCE)

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


# fbdbg.pot: create translators file (make pot)
#
# check for xgettext tool
IF(NOT XGETTEXT_WORKS)
  EXECUTE_PROCESS(
    COMMAND xgettext -V
    RESULT_VARIABLE result
	  OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  IF(NOT (result EQUAL "0"))
    MESSAGE(FATAL_ERROR "xgettext tool not found! (tried command xgettext)")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Finding the xgettext tool failed!")
    RETURN()
  ENDIF()

  STRING(REGEX MATCH "[0-9][.][0-9]+[.][0-9]" XGETTEXT_ID "${output}")
  STRING(COMPARE LESS "${XGETTEXT_ID}" "0.18.3" not_working)

  IF(not_working)
    MESSAGE(STATUS "xgettext-${XGETTEXT_ID} found, but required is 0.18.3 ==> 'make pot' not available!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Determining if the xgettext tool works failed with "
      "the following output:\n${output}\n\n")
    RETURN()
  ENDIF()

  MESSAGE(STATUS "Check for working xgettext tool OK ==> ${XGETTEXT_ID}")
  SET(XGETTEXT_WORKS "1" CACHE FILEPATH "xgettext tool" FORCE)
  MARK_AS_ADVANCED(XGETTEXT_WORKS)
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    "Determining if the xgettext tool works passed with "
    "the following output:\n${output}\n\n")
ENDIF()


# collect all dependencies
GET_PROPERTY(deps  SOURCE ${BAS}  PROPERTY "OBJECT_DEPENDS")
FOREACH(fnam ${CORE_BAS})
  LIST(APPEND deps "${CMAKE_CURRENT_SOURCE_DIR}/core/${fnam}")
ENDFOREACH()

SET(POT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${NAM}.pot)
ADD_CUSTOM_COMMAND(OUTPUT ${POT_FILE}
  COMMAND xgettext
    --output=${POT_FILE}
    --no-wrap
    --from-code=utf-8
    --keyword= --keyword=__ --keyword=N_ --keyword=Q_:1g --keyword=C_:1c,2 --keyword=NC_:1c,2
    --keyword=gettext --keyword=dgettext:2 --keyword=dcgettext:2 --keyword=ngettext:1,2 --keyword=dngettext:2,3 --keyword=dcngettext:2,3 --keyword=gettext_noop --keyword=pgettext:1c,2 --keyword=dpgettext:2c,3 --keyword=dcpgettext:2c,3 --keyword=npgettext:1c,2,3 --keyword=dnpgettext:2c,3,4 --keyword=dcnpgettext:2c,3,4
    --language=awk
    --force-po
    ${deps}
  COMMAND xgettext
    --output=${POT_FILE}
    --no-wrap
    --from-code=utf-8
    --package-name=${CMAKE_PROJECT_NAME}
    --package-version=${CMAKE_PROJECT_VERSION}
    --msgid-bugs-address=sarg@aliceadsl.fr
    --copyright-holder=sarg@aliceadsl.fr
    --language=Glade
    --join-existing
    *.ui
  DEPENDS
    ${UI_FILES}
    ${deps}
    ${BAS}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
ADD_CUSTOM_TARGET(pot DEPENDS ${POT_FILE})
