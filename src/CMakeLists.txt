

#ADD_CUSTOM_COMMAND(OUTPUT pasm_init.bi
  #COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  #COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  #DEPENDS pasm_init.p ${PASM_SRC}
  #)

#ADD_CUSTOM_COMMAND(OUTPUT pasm_run.bi
  #COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  #COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  #DEPENDS pasm_run.p ${PASM_SRC}
  #)

#ADD_CUSTOM_TARGET(pasm
  #DEPENDS pasm_init.bi pasm_run.bi
  #)


ADD_SUBDIRECTORY(core)


ADD_LIBRARY(fbdbg_gui OBJECT fbdbg.bas)
SET_TARGET_PROPERTIES(fbdbg_gui PROPERTIES
  COMPILE_FLAGS "-m fbdbg -w all"
  )
ADD_Fbc_SRC_DEPS(fbdbg_gui)

#INSTALL(FILES fbdbg
        #DESTINATION bin
        #)
#INSTALL(TARGETS fbdbg
        #DESTINATION bin
        #)
