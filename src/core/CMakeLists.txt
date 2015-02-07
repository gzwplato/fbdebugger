SET(CORE_BAS
  core1.bas
  core2.bas
  )

ADD_LIBRARY(fbdbg_core OBJECT ${CORE_BAS})
#SET_TARGET_PROPERTIES(fbdbg_core PROPERTIES
  #COMPILE_FLAGS "-w all"
  #)
ADD_Fbc_SRC_DEPS(fbdbg_core)
