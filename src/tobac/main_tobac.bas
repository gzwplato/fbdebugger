' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< _tobac.bas modul generated by utility                       GladeToBac V3.4 >
'< Modul _tobac.bas erzeugt von                                                >
'< Generated at / Generierung am                             2015-01-21, 21:32 >
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
  window1, aboutdialog_vbox1, aboutdialog_action_area1, menuProcs, menuSrc,  _
  menuTools, menuWatch, menuThread, menuVarProc, lstoreProcs, srcbuff,  _
  tstoreProcVar, nbookSrc, srcview1, treeview_selection1, treeview_selection2,  _
  cellrenderercombo1, sbarlab2, sbarlab3, sbarlab4, sbarlab5
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
  .aboutdialog_vbox1 = gtk_builder_get_object(.XML, "aboutdialog_vbox1")
  .aboutdialog_action_area1 = gtk_builder_get_object(.XML, "aboutdialog_action_area1")
  .menuProcs = gtk_builder_get_object(.XML, "menuProcs")
  .menuSrc = gtk_builder_get_object(.XML, "menuSrc")
  .menuTools = gtk_builder_get_object(.XML, "menuTools")
  .menuWatch = gtk_builder_get_object(.XML, "menuWatch")
  .menuThread = gtk_builder_get_object(.XML, "menuThread")
  .menuVarProc = gtk_builder_get_object(.XML, "menuVarProc")
  .lstoreProcs = gtk_builder_get_object(.XML, "lstoreProcs")
  .srcbuff = gtk_builder_get_object(.XML, "srcbuff")
  .tstoreProcVar = gtk_builder_get_object(.XML, "tstoreProcVar")
  .nbookSrc = gtk_builder_get_object(.XML, "nbookSrc")
  .srcview1 = gtk_builder_get_object(.XML, "srcview1")
  .treeview_selection1 = gtk_builder_get_object(.XML, "treeview_selection1")
  .treeview_selection2 = gtk_builder_get_object(.XML, "treeview_selection2")
  .cellrenderercombo1 = gtk_builder_get_object(.XML, "cellrenderercombo1")
  .sbarlab2 = gtk_builder_get_object(.XML, "sbarlab2")
  .sbarlab3 = gtk_builder_get_object(.XML, "sbarlab3")
  .sbarlab4 = gtk_builder_get_object(.XML, "sbarlab4")
  .sbarlab5 = gtk_builder_get_object(.XML, "sbarlab5")
END WITH

#INCLUDE "act_runto.bas"
#INCLUDE "act_run.bas"
#INCLUDE "act_help.bas"
#INCLUDE "on_run_clicked.bas"
#INCLUDE "on_step_clicked.bas"
#INCLUDE "on_runto_clicked.bas"
#INCLUDE "on_step_over_clicked.bas"
#INCLUDE "on_step_start_clicked.bas"
#INCLUDE "on_step_end_clicked.bas"
#INCLUDE "on_step_out_clicked.bas"
#INCLUDE "on_auto_clicked.bas"
#INCLUDE "on_stop_clicked.bas"
#INCLUDE "on_fastrun_clicked.bas"
#INCLUDE "on_exemod_clicked.bas"
#INCLUDE "on_free_clicked.bas"
#INCLUDE "on_kill_clicked.bas"
#INCLUDE "on_minicmd_clicked.bas"
#INCLUDE "on_restart_clicked.bas"
#INCLUDE "on_multiexe_clicked.bas"
#INCLUDE "on_attachexe_clicked.bas"
#INCLUDE "on_files_clicked.bas"
#INCLUDE "on_tools_clicked.bas"
#INCLUDE "on_notes_clicked.bas"
#INCLUDE "on_source_clicked.bas"
#INCLUDE "on_varproc_clicked.bas"
#INCLUDE "on_memory_clicked.bas"
#INCLUDE "menu_button3_event.bas"

