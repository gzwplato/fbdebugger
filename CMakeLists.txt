# TOP: create executable

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
PROJECT(fbdebugger Fbc)

# the documentation construction folder
ADD_SUBDIRECTORY(doc)

# the source folders
ADD_SUBDIRECTORY(src/core)
ADD_SUBDIRECTORY(src)

# fbdbg[.exe]: link the final executable
ADD_EXECUTABLE(fbdbg $<TARGET_OBJECTS:fbdbg_core> $<TARGET_OBJECTS:fbdbg_gui>)
SET_TARGET_PROPERTIES(fbdbg PROPERTIES
  LINK_FLAGS "-export"
  )

# installation
INSTALL(FILES ${UI_FILES}
   DESTINATION bin
   )
INSTALL(DIRECTORY src/dat src/img src/locale
  DESTINATION bin
  )
INSTALL(TARGETS fbdbg
  DESTINATION bin
  )

#SET(CPACK_GENERATOR "TBZ2")

# autogenerate dependency information
#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
#SET(CPACK_GENERATOR "DEB")
#SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Thomas Freiherr") #required

#INCLUDE(CPack)
