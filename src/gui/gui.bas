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
  window1, lstoreMemory, srcbuffCur, tstoreProcVar, tstoreProcs,  _
  tstoreThreads, tstoreWatch, sbarlab1, sbarlab2, sbarlab3, sbarlab4, sbarlab5,  _
  nbook2, tviewProcVar, tviewProcs, tviewThreads,  _
  tviewWatch, lviewMemory, comboBookmarks, watch1, watch3, watch2, watch4, scrolSrc
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

VAR dia = GTK_ABOUT_DIALOG(gtk_builder_get_object(GUI.XML, "aboutdialog1"))
gtk_about_dialog_set_program_name(dia, PROJ_NAME)
gtk_about_dialog_set_comments(dia, PROJ_DESC)
gtk_about_dialog_set_version(dia, PROJ_VERS)
gtk_about_dialog_set_copyright(dia, "© 2006-" & PROJ_YEAR & " by " & PROJ_MAIL & ", " & PROJ_LICE)
gtk_about_dialog_set_website(dia, PROJ_WEBS)
END SCOPE

WITH GUI
  .window1 = gtk_builder_get_object(.XML, "window1")
  .lstoreMemory = gtk_builder_get_object(.XML, "lstoreMemory")
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
  .scrolSrc = gtk_builder_get_object(.XML, "scrolSrc")
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

scope
  var css = gtk_css_provider_new()
  gtk_css_provider_load_from_data(css, _
    ".button{" _
    "-GtkButton-default-border: 0px;" _
    "-GtkButton-default-outside-border: 50px;" _
    "-GtkButton-inner-border: 0px;" _
    "-GtkWidget-focus-line-width: 0px;" _
    "-GtkWidget-focus-padding: 0px;" _
    "padding: 0px;" _
    "}" _
  , -1, NULL)
  VAR cont = gtk_widget_get_style_context(GTK_WIDGET(GUI.window1))
  'gtk_style_context_add_provider(cont, GTK_STYLE_PROVIDER(css), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
  gtk_style_context_add_provider(cont, GTK_STYLE_PROVIDER(css), 200)
END scope

#INCLUDE ONCE "filechoosers.bas"
#INCLUDE ONCE "log_notes.bas"
#INCLUDE ONCE "source.bas"

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
