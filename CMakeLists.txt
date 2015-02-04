CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

PROJECT(fbdbg Fbc)

#INCLUDE(AddFileDependencies)

ADD_SUBDIRECTORY(src)
ADD_EXECUTABLE(fbdbg $<TARGET_OBJECTS:fbdbg_gui> $<TARGET_OBJECTS:fbdbg_core>)

SET_TARGET_PROPERTIES(fbdbg PROPERTIES
  COMPILE_FLAGS "-m fbdbg -w all"
  )

SET(UI_FILES
  src/fbdbg.ui
  )
INSTALL(FILES ${UI_FILES}
        DESTINATION bin
        )
INSTALL(DIRECTORY src/dat src/img src/locale
        DESTINATION bin
        )
INSTALL(TARGETS fbdbg
        DESTINATION bin
        )


#SET_TARGET_PROPERTIES(fbdbg PROPERTIES
  #COMPILE_FLAGS "-m fbdbg -w all"
  #)

#ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:fbcode>)

#ADD_DEPENDENCIES(pruio fbcode)

#SET(CMAKE_VERBOSE_MAKEFILE 1)

#ADD_CUSTOM_TARGET(examples)
#ADD_DEPENDENCIES(examples pruio)
#SET_TARGET_PROPERTIES(examples PROPERTIES EXCLUDE_FROM_ALL 1)
#ADD_SUBDIRECTORY(src/examples)
#ADD_SUBDIRECTORY(src/c_examples)


#SET(LIBS
  #"src/pruio/pruio.hp"
  #"src/c_include/pruio.h"
  #"src/c_include/pruio_pins.h"
  #)

#SET(CPACK_GENERATOR "TBZ2")

# autogenerate dependency information
#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
#SET(CPACK_GENERATOR "DEB")
#SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Thomas Freiherr") #required

INCLUDE(CPack)
