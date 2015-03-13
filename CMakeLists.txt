# TOP: create executable

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
PROJECT(fbdebugger Fbc)

# constants
SET(PROJ_NAME "fbdbg"              CACHE FILEPATH "project name" FORCE)
SET(PROJ_DESC "FreeBASIC Debugger" CACHE FILEPATH "project description" FORCE)
SET(PROJ_VERS "2.9.0"              CACHE FILEPATH "project version" FORCE)
SET(PROJ_AUTH "SARG, AGS, TJF"     CACHE FILEPATH "project authors" FORCE)
SET(PROJ_MAIL "sarg@aliceadsl.fr"  CACHE FILEPATH "project mail address" FORCE)
SET(PROJ_WEBS "http://github.com/fbdebugger/fbdebugger" CACHE FILEPATH "project website" FORCE)
SET(PROJ_LICE "GPLv3"              CACHE FILEPATH "project licence" FORCE)
STRING(TIMESTAMP tmp "%Y" UTC)
SET(PROJ_YEAR "${tmp}"             CACHE FILEPATH "project year" FORCE)

# transfer constants to FB source
SET(fnam ${CMAKE_CURRENT_SOURCE_DIR}/src/version.bas)
CONFIGURE_FILE(${fnam}.in  ${fnam} @ONLY)

# the documentation construction folder
ADD_SUBDIRECTORY(doc)

# the source folders
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
