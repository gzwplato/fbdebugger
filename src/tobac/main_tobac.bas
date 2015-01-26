' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< _tobac.bas modul generated by utility                     GladeToBac V3.4.1 >
'< Modul _tobac.bas erzeugt von                                                >
'< Generated at / Generierung am                             2015-01-26, 19:45 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: main.bas                                           >
'< Author:  SARG, AGS, TJF                                                     >
'<  Email:  Thomas.Freiherr@gmx.net                                            >
' -----------------------------------------------------------------------------
'< declare names, signal handlers, load GUI-XML                   do not edit! >
'< deklariert Namen, Signale, laedt GUI-XML                  nicht veraendern! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

SCOPE
  VAR er = gtk_check_version(3, 10, 0)
  IF er THEN
    ?"Fehler/Error (GTK-Version):"
    ?*er
    END 1
  END IF
END SCOPE

TYPE GUI_MAINData
  AS GtkBuilder PTR XML
  AS GObject PTR _
  window1, lstoreMemory, srcbuff, srcbuffCur, tstoreProc, tstoreProcVar,  _
  tstoreThread, tstoreWatch, srcviewCur, sbarlab2, sbarlab3, sbarlab4,  _
  sbarlab5, nbookSrc, srcview, tvProcVar, tvProcs, tvThread, tvWatch, lvMemory
END TYPE
DIM SHARED AS GUI_MAINData GUI_MAIN

GUI_MAIN.XML = gtk_builder_new()

SCOPE
DIM AS GError PTR meld
IF 0 = gtk_builder_add_from_file(GUI_MAIN.XML, "main.ui", @meld) THEN
  WITH *meld
    ?"Fehler/Error (GTK-Builder):"
    ?*.message
  END WITH
  g_error_free(meld)
  END 2
END IF
END SCOPE

WITH GUI_MAIN
  .window1 = gtk_builder_get_object(.XML, "window1")
  .lstoreMemory = gtk_builder_get_object(.XML, "lstoreMemory")
  .srcbuff = gtk_builder_get_object(.XML, "srcbuff")
  .srcbuffCur = gtk_builder_get_object(.XML, "srcbuffCur")
  .tstoreProc = gtk_builder_get_object(.XML, "tstoreProc")
  .tstoreProcVar = gtk_builder_get_object(.XML, "tstoreProcVar")
  .tstoreThread = gtk_builder_get_object(.XML, "tstoreThread")
  .tstoreWatch = gtk_builder_get_object(.XML, "tstoreWatch")
  .srcviewCur = gtk_builder_get_object(.XML, "srcviewCur")
  .sbarlab2 = gtk_builder_get_object(.XML, "sbarlab2")
  .sbarlab3 = gtk_builder_get_object(.XML, "sbarlab3")
  .sbarlab4 = gtk_builder_get_object(.XML, "sbarlab4")
  .sbarlab5 = gtk_builder_get_object(.XML, "sbarlab5")
  .nbookSrc = gtk_builder_get_object(.XML, "nbookSrc")
  .srcview = gtk_builder_get_object(.XML, "srcview")
  .tvProcVar = gtk_builder_get_object(.XML, "tvProcVar")
  .tvProcs = gtk_builder_get_object(.XML, "tvProcs")
  .tvThread = gtk_builder_get_object(.XML, "tvThread")
  .tvWatch = gtk_builder_get_object(.XML, "tvWatch")
  .lvMemory = gtk_builder_get_object(.XML, "lvMemory")
END WITH

#INCLUDE "act_runto.bas"
#INCLUDE "act_step.bas"
#INCLUDE "act_step_over.bas"
#INCLUDE "act_step_out.bas"
#INCLUDE "act_step_start.bas"
#INCLUDE "act_step_end.bas"
#INCLUDE "act_run.bas"
#INCLUDE "act_fastrun.bas"
#INCLUDE "act_stop.bas"
#INCLUDE "act_kill.bas"
#INCLUDE "act_auto.bas"
#INCLUDE "act_ToDo.bas"
#INCLUDE "act_exemod.bas"
#INCLUDE "act_free.bas"
#INCLUDE "act_minicmd.bas"
#INCLUDE "act_restart.bas"
#INCLUDE "act_multiexe.bas"
#INCLUDE "act_attachexe.bas"
#INCLUDE "act_files.bas"
#INCLUDE "act_tools.bas"
#INCLUDE "act_notes.bas"
#INCLUDE "act_source.bas"
#INCLUDE "act_varproc.bas"
#INCLUDE "act_memory.bas"
#INCLUDE "act_Settings.bas"
#INCLUDE "act_help.bas"
#INCLUDE "on_entry_icon_press.bas"
#INCLUDE "menu_button3_event.bas"

