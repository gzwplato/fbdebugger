/'* \file gui.bas
\brief The central source code that glues all together

This file contains the code to load the main GUI description file and
glue all GUI source conponents together.

\note We do not compile modules separately here. All modules would need
      the GTK+ headers to compile and our amount of code id small in
      comparison to all headers.

\since 3.0
'/


SCOPE
  VAR er = gtk_check_version(3, 6, 0)
  IF er THEN
    ?"Fehler/Error (GTK-Version):"
    ?*er
    END 1
  END IF
END SCOPE

TYPE GUIData
  AS GtkBuilder PTR XML
  AS GObject PTR _
  window1, lstoreMemory, srcbuff, srcbuffCur, tstoreProcVar, tstoreProcs,  _
  tstoreThreads, tstoreWatch, sbarlab1, sbarlab2, sbarlab3, sbarlab4, sbarlab5,  _
  srcviewCur, nbookSrc, srcview, nbook2, tviewProcVar, tviewProcs, tviewThreads,  _
  tviewWatch, lviewMemory, comboBookmarks, watch1, watch3, watch2, watch4
END TYPE
DIM SHARED AS GUIData GUI

GUI.XML = gtk_builder_new()

SCOPE
DIM AS GError PTR meld
IF 0 = gtk_builder_add_from_file(GUI.XML, "fbdbg.ui", @meld) THEN
  WITH *meld
    ?"Fehler/Error (GTK-Builder):"
    ?*.message
  END WITH
  g_error_free(meld)
  END 2
END IF
END SCOPE

WITH GUI
  .window1 = gtk_builder_get_object(.XML, "window1")
  .lstoreMemory = gtk_builder_get_object(.XML, "lstoreMemory")
  .srcbuff = gtk_builder_get_object(.XML, "srcbuff")
  .srcbuffCur = gtk_builder_get_object(.XML, "srcbuffCur")
  .tstoreProcVar = gtk_builder_get_object(.XML, "tstoreProcVar")
  .tstoreProcs = gtk_builder_get_object(.XML, "tstoreProcs")
  .tstoreThreads = gtk_builder_get_object(.XML, "tstoreThreads")
  .tstoreWatch = gtk_builder_get_object(.XML, "tstoreWatch")
  .sbarlab1 = gtk_builder_get_object(.XML, "sbarlab1")
  .sbarlab2 = gtk_builder_get_object(.XML, "sbarlab2")
  .sbarlab3 = gtk_builder_get_object(.XML, "sbarlab3")
  .sbarlab4 = gtk_builder_get_object(.XML, "sbarlab4")
  .sbarlab5 = gtk_builder_get_object(.XML, "sbarlab5")
  .srcviewCur = gtk_builder_get_object(.XML, "srcviewCur")
  .nbookSrc = gtk_builder_get_object(.XML, "nbookSrc")
  .srcview = gtk_builder_get_object(.XML, "srcview")
  .nbook2 = gtk_builder_get_object(.XML, "nbook2")
  .tviewProcVar = gtk_builder_get_object(.XML, "tviewProcVar")
  .tviewProcs = gtk_builder_get_object(.XML, "tviewProcs")
  .tviewThreads = gtk_builder_get_object(.XML, "tviewThreads")
  .tviewWatch = gtk_builder_get_object(.XML, "tviewWatch")
  .lviewMemory = gtk_builder_get_object(.XML, "lviewMemory")
  .comboBookmarks = gtk_builder_get_object(.XML, "comboBookmarks")
  .watch1 = gtk_builder_get_object(.XML, "watch1")
  .watch3 = gtk_builder_get_object(.XML, "watch3")
  .watch2 = gtk_builder_get_object(.XML, "watch2")
  .watch4 = gtk_builder_get_object(.XML, "watch4")
END WITH


#INCLUDE ONCE "filechoosers.bas"
#INCLUDE ONCE "log_notes.bas"
#INCLUDE ONCE "multi_action.bas"
#INCLUDE ONCE "mbar_buttons.bas"
#INCLUDE ONCE "menu_procvar.bas"
#INCLUDE ONCE "menu_procs.bas"
#INCLUDE ONCE "menu_source.bas"
#INCLUDE ONCE "menu_watch.bas"
#INCLUDE ONCE "menu_threads.bas"
#INCLUDE ONCE "menu_tools.bas"

#INCLUDE ONCE "main.bas"
#INCLUDE ONCE "settings.bas"
#INCLUDE ONCE "shortcuts.bas"
