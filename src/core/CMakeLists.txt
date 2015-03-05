# build rules to create the functional part

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# module file names
SET(CORE_BAS
  ini.bas
  CACHE FILEPATH "core basic source" FORCE)

ADD_LIBRARY(fbdbg_core OBJECT ${CORE_BAS})
#SET_TARGET_PROPERTIES(fbdbg_core PROPERTIES
  #COMPILE_FLAGS "-w all"
  #)
ADD_Fbc_SRC_DEPS(fbdbg_core)
