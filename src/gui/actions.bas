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
SUB ActionsUDT.setState(BYVAL RunType AS INTEGER)
  SELECT CASE AS CONST RunType
  CASE RTSTEP '                                                     wait
    gtk_action_set_sensitive(act_step, TRUE)
    gtk_action_set_sensitive(act_step_over, TRUE)
    gtk_action_set_sensitive(act_step_start, TRUE)
    gtk_action_set_sensitive(act_step_end, TRUE)
    gtk_action_set_sensitive(act_step_out, TRUE)
    gtk_action_set_sensitive(act_auto, TRUE)
    gtk_action_set_sensitive(act_run, TRUE)
    gtk_action_set_sensitive(act_fastrun, TRUE)
    gtk_action_set_sensitive(act_stop, TRUE)
    gtk_action_set_sensitive(act_runto, TRUE)
    gtk_action_set_sensitive(act_free, TRUE)
    gtk_action_set_sensitive(act_kill, TRUE)
    gtk_action_set_sensitive(act_exemod, TRUE)
    gtk_action_set_sensitive(act_minicmd, TRUE)

    Message = "Waiting " '& stoplibel(stopcode)  'todo active the reason stop text
    gtk_label_set_text(GTK_LABEL(SbarLab1), Message)

    'statusthreadstr="Thread " & Str(thread(threadcur).id)
    'setlabel(statusthread, StrPtr(statusthreadstr))
    gtk_label_set_text(GTK_LABEL(SbarLab2), "Thread ...")

    'statusfilestr=name_extract(source(proc(procsv).sr).shortname)
    'setlabel(statusfile,StrPtr(statusfilestr))
    gtk_label_set_text(GTK_LABEL(SbarLab3), "Module ...")

    'setlabel(statusproc,StrPtr(proc(procsv).nm))
    gtk_label_set_text(GTK_LABEL(SbarLab4), "Proc ...")

    'statustimerstr=Left(Str(fasttimer),10)
    gtk_label_set_text(GTK_LABEL(SbarLab5), "Timer ...")
  CASE RTRUN, RTFREE, RTFRUN '   step over / out / free / run / fast run
    gtk_action_set_sensitive(act_step, FALSE)
    gtk_action_set_sensitive(act_step_over, FALSE)
    gtk_action_set_sensitive(act_step_start, FALSE)
    gtk_action_set_sensitive(act_step_end, FALSE)
    gtk_action_set_sensitive(act_step_out, FALSE)
    gtk_action_set_sensitive(act_auto, FALSE)
    gtk_action_set_sensitive(act_run, FALSE)
    gtk_action_set_sensitive(act_fastrun, FALSE)
    gtk_action_set_sensitive(act_runto, FALSE)
    gtk_action_set_sensitive(act_free, FALSE)
    gtk_action_set_sensitive(act_kill, FALSE)
    gtk_action_set_sensitive(act_exemod, FALSE)
    SELECT CASE AS CONST RunType
    	CASE RTRUN
      gtk_label_set_text(GTK_LABEL(SbarLab1), "Running")
    	CASE RTFRUN
      gtk_label_set_text(GTK_LABEL(SbarLab1), "FAST Running")
    	CASE Else
      gtk_label_set_text(GTK_LABEL(SbarLab1), "Released")
    END SELECT
  CASE RTAUTO 'auto
    gtk_action_set_sensitive(act_step, FALSE)
    gtk_action_set_sensitive(act_step_over, FALSE)
    gtk_action_set_sensitive(act_step_start, FALSE)
    gtk_action_set_sensitive(act_step_end, FALSE)
    gtk_action_set_sensitive(act_step_out, FALSE)
    gtk_action_set_sensitive(act_auto, FALSE)
    gtk_action_set_sensitive(act_run, FALSE)
    gtk_action_set_sensitive(act_fastrun, FALSE)
    gtk_action_set_sensitive(act_runto, FALSE)
    gtk_action_set_sensitive(act_free, FALSE)
    gtk_action_set_sensitive(act_kill, FALSE)
    gtk_action_set_sensitive(act_exemod, FALSE)
    gtk_label_set_text(GTK_LABEL(SbarLab1), "Auto")
  CASE ELSE '                        prun=false --> terminated or no pgm
    gtk_action_set_sensitive(act_step, FALSE)
    gtk_action_set_sensitive(act_step_over, FALSE)
    gtk_action_set_sensitive(act_step_start, FALSE)
    gtk_action_set_sensitive(act_step_end, FALSE)
    gtk_action_set_sensitive(act_step_out, FALSE)
    gtk_action_set_sensitive(act_auto, FALSE)
    gtk_action_set_sensitive(act_run, FALSE)
    gtk_action_set_sensitive(act_fastrun, FALSE)
    gtk_action_set_sensitive(act_stop, FALSE)
    gtk_action_set_sensitive(act_runto, FALSE)
    gtk_action_set_sensitive(act_free, FALSE)
    gtk_action_set_sensitive(act_kill, FALSE)
    gtk_action_set_sensitive(act_exemod, FALSE)
    IF RunType = RTEND THEN
      gtk_label_set_text(GTK_LABEL(SbarLab1), "Terminated")
    ENDIF
    gtk_action_set_sensitive(act_minicmd, FALSE)
  END SELECT
END SUB

DIM SHARED AS ActionsUDT PTR ACT '*< The global action variable for this class
