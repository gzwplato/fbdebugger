# build rules to create the documentation

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# check for Doxygen
INCLUDE(FindDoxygen)
IF(NOT DOXYGEN_FOUND)
  MESSAGE(STATUS "Doxygen not found ==> target doc not available!")
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if doxygen works failed\n\n")
  RETURN()
ENDIF()

# check for fbdoc tool (note: not fb-doc)
IF(NOT FBDOC_WORKS)
  EXECUTE_PROCESS(
    COMMAND fbdoc -v
    RESULT_VARIABLE result
	  ERROR_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  IF(NOT (result EQUAL "0"))
    MESSAGE(FATAL_ERROR "fbdoc tool not found! (tried command fbdoc)")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Finding the fbdoc tool failed!")
    RETURN()
  ENDIF()

  STRING(REGEX MATCH "[0-9][.][0-9][.][0-9]" FBDOC_ID "${output}")
  STRING(COMPARE LESS "${FBDOC_ID}" "0.3.9" not_working)

  IF(not_working)
    MESSAGE(STATUS "fbdoc-${FBDOC_ID} found, but required is 0.3.9 ==> 'make doc' not available!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Determining if the fbdoc tool works failed with "
      "the following output:\n${output}\n\n")
    RETURN()
  ENDIF()

  MESSAGE(STATUS "Check for working fbdoc tool OK ==> ${FBDOC_ID}")
  SET(FBDOC_WORKS "1" CACHE FILEPATH "fbdoc tool" FORCE)
  MARK_AS_ADVANCED(FBDOC_WORKS)
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    "Determining if the fbdoc tool works passed with "
    "the following output:\n${output}\n\n")
ENDIF()

# HTML and PDF build here, always from scratch and in source directory
SET(PDF_FILE ${CMAKE_CURRENT_SOURCE_DIR}/latex/refman.pdf)
SET(HTM_FILE ${CMAKE_CURRENT_SOURCE_DIR}/html/index.html)
ADD_CUSTOM_COMMAND(OUTPUT ${HTM_FILE}
  COMMAND ${CMAKE_COMMAND} -E remove_directory html
  COMMAND ${CMAKE_COMMAND} -E remove_directory latex
  COMMAND fbdoc -l
  COMMAND doxygen
  COMMAND fbdoc -s
  COMMAND ${CMAKE_COMMAND} -E touch Doxyfile
  DEPENDS Doxyfile fbdbg.xml fbdbg.css
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  )
ADD_CUSTOM_COMMAND(OUTPUT ${PDF_FILE}
  COMMAND make
  DEPENDS ${HTM_FILE}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/latex
  )

ADD_CUSTOM_TARGET(doc DEPENDS ${HTM_FILE} ${PDF_FILE})

