/'* \file actions.bas
\brief Code for handling the actions and status bar messages

This file contains the FB code to handle the actions, making them
sensible regarding the current state.

\todo Consider to move this code to main.bas

\todo Remove test code in SUB act_memory (mbar_buttons.bas)

\since 3.0
'/


/'* \brief Constructor to prepare the action objects

The constructor gets the objects from the file fbdbg.ui.

'/
CONSTRUCTOR ActionsUDT()
  WITH GUI
'' get the actions from the ui file
          act_step = GTK_ACTION(gtk_builder_get_object(.XML, "action002"))
     act_step_over = GTK_ACTION(gtk_builder_get_object(.XML, "action003"))
    act_step_start = GTK_ACTION(gtk_builder_get_object(.XML, "action005"))
      act_step_end = GTK_ACTION(gtk_builder_get_object(.XML, "action006"))
      act_step_out = GTK_ACTION(gtk_builder_get_object(.XML, "action004"))
          act_auto = GTK_ACTION(gtk_builder_get_object(.XML, "action011"))
           act_run = GTK_ACTION(gtk_builder_get_object(.XML, "action007"))
       act_fastrun = GTK_ACTION(gtk_builder_get_object(.XML, "action008"))
          act_stop = GTK_ACTION(gtk_builder_get_object(.XML, "action009"))
         act_runto = GTK_ACTION(gtk_builder_get_object(.XML, "action001"))
          act_free = GTK_ACTION(gtk_builder_get_object(.XML, "action460"))
          act_kill = GTK_ACTION(gtk_builder_get_object(.XML, "action010"))
        act_exemod = GTK_ACTION(gtk_builder_get_object(.XML, "action013"))
       act_minicmd = GTK_ACTION(gtk_builder_get_object(.XML, "action461"))

act_stringshow = GTK_ACTION(gtk_builder_get_object(.XML, "action023"))
act_brkenable = GTK_ACTION(gtk_builder_get_object(.XML, "action416"))
act_dlllist = GTK_ACTION(gtk_builder_get_object(.XML, "action914"))
act_brkmanage = GTK_ACTION(gtk_builder_get_object(.XML, "action417"))
act_brkset = GTK_ACTION(gtk_builder_get_object(.XML, "action414"))
act_brktempset = GTK_ACTION(gtk_builder_get_object(.XML, "action415"))
act_bzexchange = GTK_ACTION(gtk_builder_get_object(.XML, "action109"))
act_bmknext = GTK_ACTION(gtk_builder_get_object(.XML, "action422"))
act_bmkprev = GTK_ACTION(gtk_builder_get_object(.XML, "action423"))
act_lineaddress = GTK_ACTION(gtk_builder_get_object(.XML, "action4250"))
act_lineasm = GTK_ACTION(gtk_builder_get_object(.XML, "action4251"))
act_procaddresses = GTK_ACTION(gtk_builder_get_object(.XML, "action508")) 
act_procasm = GTK_ACTION(gtk_builder_get_object(.XML, "action027"))
act_procbacktrack = GTK_ACTION(gtk_builder_get_object(.XML, "action025"))
act_proccall = GTK_ACTION(gtk_builder_get_object(.XML, "action111"))
act_procchain = GTK_ACTION(gtk_builder_get_object(.XML, "action026"))
act_processlist = GTK_ACTION(gtk_builder_get_object(.XML, "action913"))
act_procfollow = GTK_ACTION(gtk_builder_get_object(.XML, "action203"))
act_procinvar = GTK_ACTION(gtk_builder_get_object(.XML, "action300"))
act_procnofollow = GTK_ACTION(gtk_builder_get_object(.XML, "action204"))
act_procsrcasm = GTK_ACTION(gtk_builder_get_object(.XML, "action4252"))
act_quickedit = GTK_ACTION(gtk_builder_get_object(.XML, "action906"))
act_wtch1 = GTK_ACTION(gtk_builder_get_object(.XML, "action307"))
act_wtch2 = GTK_ACTION(gtk_builder_get_object(.XML, "action308"))
act_wtch3 = GTK_ACTION(gtk_builder_get_object(.XML, "action309"))
act_wtch4 = GTK_ACTION(gtk_builder_get_object(.XML, "action310"))
act_wtchdel = GTK_ACTION(gtk_builder_get_object(.XML, "action311"))
act_wtchdellall = GTK_ACTION(gtk_builder_get_object(.XML, "action312"))
act_wtchnotrace = GTK_ACTION(gtk_builder_get_object(.XML, "action306"))
act_wtchtrace = GTK_ACTION(gtk_builder_get_object(.XML, "action305"))
act_automulti = GTK_ACTION(gtk_builder_get_object(.XML, "action012"))
act_varsrcshow = GTK_ACTION(gtk_builder_get_object(.XML, "action418"))
act_varsrcwtch = GTK_ACTION(gtk_builder_get_object(.XML, "action419"))
act_varwatched = GTK_ACTION(gtk_builder_get_object(.XML, "action1000"))
act_varwtchtrace = GTK_ACTION(gtk_builder_get_object(.XML, "action1001"))
act_threadcreate = GTK_ACTION(gtk_builder_get_object(.XML, "action502"))
act_threadcollapse = GTK_ACTION(gtk_builder_get_object(.XML, "action511"))
act_threadexpand = GTK_ACTION(gtk_builder_get_object(.XML, "action510"))
act_threadkill = GTK_ACTION(gtk_builder_get_object(.XML, "action509"))
act_threadline = GTK_ACTION(gtk_builder_get_object(.XML, "action501"))
act_threadlist = GTK_ACTION(gtk_builder_get_object(.XML, "action512"))
act_threadproc = GTK_ACTION(gtk_builder_get_object(.XML, "action503"))
act_threadselect = GTK_ACTION(gtk_builder_get_object(.XML, "action500"))
act_threadvar = GTK_ACTION(gtk_builder_get_object(.XML, "action504"))
act_tuto = GTK_ACTION(gtk_builder_get_object(.XML, "action904"))
act_varbrk = GTK_ACTION(gtk_builder_get_object(.XML, "action101"))
act_varcharpos = GTK_ACTION(gtk_builder_get_object(.XML, "action108"))
act_varclipall = GTK_ACTION(gtk_builder_get_object(.XML, "action1180"))
act_varclipsel = GTK_ACTION(gtk_builder_get_object(.XML, "action1181"))
act_varlistall = GTK_ACTION(gtk_builder_get_object(.XML, "action1170"))
act_varlistsel = GTK_ACTION(gtk_builder_get_object(.XML, "action1171"))
act_varderefdump = GTK_ACTION(gtk_builder_get_object(.XML, "action104"))
act_vardump = GTK_ACTION(gtk_builder_get_object(.XML, "action020"))
act_varedit = GTK_ACTION(gtk_builder_get_object(.XML, "action021"))
act_varexpand = GTK_ACTION(gtk_builder_get_object(.XML, "action022"))
act_varindex = GTK_ACTION(gtk_builder_get_object(.XML, "action102"))

'' get the status bar labels from the ui file
    SbarLab1 = GTK_LABEL(gtk_builder_get_object(.XML, "sbarlab1"))
    SbarLab2 = GTK_LABEL(gtk_builder_get_object(.XML, "sbarlab2"))
    SbarLab3 = GTK_LABEL(gtk_builder_get_object(.XML, "sbarlab3"))
    SbarLab4 = GTK_LABEL(gtk_builder_get_object(.XML, "sbarlab4"))
    SbarLab5 = GTK_LABEL(gtk_builder_get_object(.XML, "sbarlab5"))
  END WITH


setState(RTEND)
?" CONSTRUCTOR ActionsUDT"
END CONSTRUCTOR


/'* \brief Set action state based on run mode
\param RunType The type of run mode

Member procedure to set the state of the actions (buttons and menu
entries) and the status bar messages.

\todo Add message string variables for SbarLab[1-5], if necessary

'/
Sub ActionsUDT.setState(BYVAL RunType AS INTEGER)
	Dim As Integer flagall,flagstop
	flagall=FALSE 'except for RTSTEP
	flagstop=TRUE 'except for RTSTEP,RTEND,RTOFF
 	Select CASE AS CONST RunType
 		Case RTSTEP '                                                     wait
      	flagall=TRUE
      	flagstop=FALSE
 			Message = "Waiting " '& stoplibel(stopcode)  'todo active the reason stop text
			gtk_label_set_text(GTK_LABEL(SbarLab1), Message)
			'statusthreadstr="Thread " & Str(thread(threadcur).id)
			gtk_label_set_text(GTK_LABEL(SbarLab2), "Thread ...")
			'statusfilestr=name_extract(source(proc(procsv).sr).shortname)
			gtk_label_set_text(GTK_LABEL(SbarLab3), "Module ...")
			'setlabel(statusproc,StrPtr(proc(procsv).nm))
			gtk_label_set_text(GTK_LABEL(SbarLab4), "Proc ...")
			'statustimerstr=Left(Str(fasttimer),10)
			gtk_label_set_text(GTK_LABEL(SbarLab5), "Timer ...")
    	CASE RTRUN
      		gtk_label_set_text(GTK_LABEL(SbarLab1), "Running")
    	CASE RTFRUN
      		gtk_label_set_text(GTK_LABEL(SbarLab1), "FAST Running")
    	CASE RTFREE
      		gtk_label_set_text(GTK_LABEL(SbarLab1), "Released")
 		CASE RTEND
 			flagstop=FALSE
 			gtk_label_set_text(GTK_LABEL(SbarLab1), "Terminated")
 		Case RTOFF
 			flagstop=FALSE
   		gtk_label_set_text(GTK_LABEL(SbarLab1), "No program")
 	End Select
    	
 	gtk_action_set_sensitive(act_step,flagall)
	gtk_action_set_sensitive(act_step_over,flagall)
	gtk_action_set_sensitive(act_step_start,flagall)
	gtk_action_set_sensitive(act_step_end,flagall)
	gtk_action_set_sensitive(act_step_out,flagall)
	gtk_action_set_sensitive(act_auto,flagall)
	gtk_action_set_sensitive(act_run,flagall)
	gtk_action_set_sensitive(act_fastrun,flagall)
	gtk_action_set_sensitive(act_runto,flagall)
	gtk_action_set_sensitive(act_free,flagall)
	gtk_action_set_sensitive(act_kill,flagall)
	gtk_action_set_sensitive(act_exemod,flagall)
	gtk_action_set_sensitive(act_stringshow,flagall)
	gtk_action_set_sensitive(act_brkenable,flagall)
	gtk_action_set_sensitive(act_dlllist,flagall)
	If brknb Then gtk_action_set_sensitive(act_brkmanage,flagall)
	gtk_action_set_sensitive(act_brkset,flagall)
	gtk_action_set_sensitive(act_brktempset,flagall)
	gtk_action_set_sensitive(act_bzexchange,flagall)
	If bmkcpt Then 
		gtk_action_set_sensitive(act_bmknext,flagall)
		gtk_action_set_sensitive(act_bmkprev,flagall)
	EndIf
	gtk_action_set_sensitive(act_lineaddress,flagall)
	gtk_action_set_sensitive(act_lineasm,flagall)
	gtk_action_set_sensitive(act_procaddresses,flagall)
	gtk_action_set_sensitive(act_procasm,flagall)
	gtk_action_set_sensitive(act_procbacktrack,flagall)
	gtk_action_set_sensitive(act_proccall,flagall)
	gtk_action_set_sensitive(act_procchain,flagall)
	gtk_action_set_sensitive(act_processlist,flagall)
	gtk_action_set_sensitive(act_procfollow,flagall)
	gtk_action_set_sensitive(act_procinvar,flagall)
	gtk_action_set_sensitive(act_procnofollow,flagall)
	gtk_action_set_sensitive(act_procsrcasm,flagall)
	gtk_action_set_sensitive(act_quickedit,flagall)
	If wtchcpt Then
		gtk_action_set_sensitive(act_wtch1,flagall)
		gtk_action_set_sensitive(act_wtch2,flagall)
		gtk_action_set_sensitive(act_wtch3,flagall)
		gtk_action_set_sensitive(act_wtch4,flagall)
		gtk_action_set_sensitive(act_wtchdel,flagall)
		gtk_action_set_sensitive(act_wtchdellall,flagall)
		gtk_action_set_sensitive(act_wtchnotrace,flagall)
		gtk_action_set_sensitive(act_wtchtrace,flagall)
	EndIf
	gtk_action_set_sensitive(act_automulti,flagall)
	gtk_action_set_sensitive(act_varsrcshow,flagall)
	gtk_action_set_sensitive(act_varsrcwtch,flagall)
	gtk_action_set_sensitive(act_varwatched,flagall)
	gtk_action_set_sensitive(act_varwtchtrace,flagall)
	gtk_action_set_sensitive(act_threadcreate,flagall)
	gtk_action_set_sensitive(act_threadexpand,flagall)
	gtk_action_set_sensitive(act_threadkill,flagall)
	gtk_action_set_sensitive(act_threadline,flagall)
	gtk_action_set_sensitive(act_threadlist,flagall)
	gtk_action_set_sensitive(act_threadproc,flagall)
	gtk_action_set_sensitive(act_threadselect,flagall)
	gtk_action_set_sensitive(act_threadvar,flagall)
	gtk_action_set_sensitive(act_tuto,flagall)
	gtk_action_set_sensitive(act_varbrk,flagall)
	gtk_action_set_sensitive(act_varcharpos,flagall)
	gtk_action_set_sensitive(act_varclipall,flagall)
	gtk_action_set_sensitive(act_varclipsel,flagall)
	gtk_action_set_sensitive(act_varderefdump,flagall)
	gtk_action_set_sensitive(act_vardump,flagall)
	gtk_action_set_sensitive(act_varedit,flagall)
	gtk_action_set_sensitive(act_varexpand,flagall)
	gtk_action_set_sensitive(act_varindex,flagall)
	gtk_action_set_sensitive(act_varlistall,flagall)
	gtk_action_set_sensitive(act_varlistsel,flagall)
	'different action in case RTSTEP, RTOFF, RTEND
	gtk_action_set_sensitive(act_stop, flagstop)
End Sub

DIM SHARED AS ActionsUDT PTR ACT '*< The global action variable for this class
