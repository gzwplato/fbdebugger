/'* \file settings.bas
\brief Code for settings dialog

This file contains the source code to handle the settings dialog. ???

\since 3.0
'/



/'* \brief Transform a GdkRGBA value to guint32
\param Col A GdkRGBA color
\returns The guint32 equivalent

Transform a GdkRGBA color value used in the GtkSourceView widgets in to
a guint32 value used in the INI class.

'/
FUNCTION colTrans(byval Col as GdkRGBA PTR) AS guint32
  RETURN _
    CUSHORT(255 * Col->red) SHL 16 _
  + CUSHORT(255 * Col->green) SHL 8 _
  + CUSHORT(255 * Col->blue)
END FUNCTION

/'* \brief Populate or evaluate the settings dialog
\param Mo The modus (0 = read, 1 = write)

Handle the data in the settings dialog. The SUB either

- reads the dialog data and sets the parameter variables for the ini
  file, or

- sets the dialog to ini file parameter variables

When called first, the widgets get searched in the GUI description file.


\todo In the SELECT CASE 0 block: replace the PRINT commands by setting
      your matching parameter variables

\todo In the SELECT CASE 1 block: replace the literals by reading from
      your matching parameter variables.

'/
SUB SettingsForm(BYVAL Mo AS gint = 1)
  STATIC AS GObject PTR _
    colForegr, colBackgr, colBackgrCur, colBreak, colBreakTmp, colLineNo _
  , colKeyword, colStrings, colPrepro, colComment _
  , boolTooltips, boolVerbose, boolScreen _
  , boolProctrace, boolLinetrace _
  , boolLineno, boolSyntax _
  , entryFbc, entryIDE, entryCmdl, entryDbg, entryLogfile _
  , numDelay, numCurpos, fontSource

  IF 0 = fontSource THEN '      initial get objects from GUI description
    VAR xml = GUI.XML
         colForegr = gtk_builder_get_object(xml, "colorbutton501")
         colLineNo = gtk_builder_get_object(xml, "colorbutton502")
         colBackgr = gtk_builder_get_object(xml, "colorbutton509")
      colBackgrCur = gtk_builder_get_object(xml, "colorbutton510")
          colBreak = gtk_builder_get_object(xml, "colorbutton511")
       colBreakTmp = gtk_builder_get_object(xml, "colorbutton512")
        colKeyword = gtk_builder_get_object(xml, "colorbutton513")
        colStrings = gtk_builder_get_object(xml, "colorbutton514")
         colPrepro = gtk_builder_get_object(xml, "colorbutton515")
        colComment = gtk_builder_get_object(xml, "colorbutton516")

        boolSyntax = gtk_builder_get_object(xml, "checkbutton501")
       boolVerbose = gtk_builder_get_object(xml, "checkbutton502")
        boolScreen = gtk_builder_get_object(xml, "checkbutton503")
     boolLinetrace = gtk_builder_get_object(xml, "checkbutton504")
     boolProctrace = gtk_builder_get_object(xml, "checkbutton505")
      boolTooltips = gtk_builder_get_object(xml, "checkbutton506")
        boolLineno = gtk_builder_get_object(xml, "checkbutton507")

          entryFbc = gtk_builder_get_object(xml, "entry501")
          entryIde = gtk_builder_get_object(xml, "entry502")
         entryCmdl = gtk_builder_get_object(xml, "entry503")
          entryDbg = gtk_builder_get_object(xml, "entry504")
      entryLogfile = gtk_builder_get_object(xml, "entry505")
        fontSource = gtk_builder_get_object(xml, "fontbutton502")

          numDelay = gtk_builder_get_object(xml, "adjustment501")
         numCurpos = gtk_builder_get_object(xml, "adjustment502")
  END IF

WITH *INI
  SELECT CASE AS CONST Mo
  CASE 0 '                                                dialog --> INI
    DIM AS GdkRGBA PTR col ' passing a pointer, remember to free the data
    g_object_get(   colForegr, "rgba", @col, NULL) :    .colForegr = colTrans(col) : gdk_rgba_free(col)
    g_object_get(   colBackgr, "rgba", @col, NULL) :    .colBackgr = colTrans(col) : gdk_rgba_free(col)
    g_object_get(colBackgrCur, "rgba", @col, NULL) : .colBackgrCur = colTrans(col) : gdk_rgba_free(col)
    g_object_get(    colBreak, "rgba", @col, NULL) :     .colBreak = colTrans(col) : gdk_rgba_free(col)
    g_object_get( colBreakTmp, "rgba", @col, NULL) :  .colBreakTmp = colTrans(col) : gdk_rgba_free(col)
    g_object_get(   colLineNo, "rgba", @col, NULL) :    .colLineNo = colTrans(col) : gdk_rgba_free(col)
    g_object_get(  colKeyword, "rgba", @col, NULL) :   .colKeyword = colTrans(col) : gdk_rgba_free(col)
    g_object_get(  colStrings, "rgba", @col, NULL) :   .colStrings = colTrans(col) : gdk_rgba_free(col)
    g_object_get(   colPrepro, "rgba", @col, NULL) :    .colPrepro = colTrans(col) : gdk_rgba_free(col)
    g_object_get(  colComment, "rgba", @col, NULL) :   .colComment = colTrans(col) : gdk_rgba_free(col)

    DIM AS gboolean bool
    g_object_get( boolTooltips, "active", @bool, NULL) : .Bool(.FTT) = bool
    g_object_get(  boolVerbose, "active", @bool, NULL) : .Bool(.FVM) = bool
    g_object_get(   boolScreen, "active", @bool, NULL) : .Bool(.FSL) = bool
    g_object_get(boolProctrace, "active", @bool, NULL) : .Bool(.FPT) = bool
    g_object_get(boolLinetrace, "active", @bool, NULL) : .Bool(.FLT) = bool
    g_object_get(   boolLineno, "active", @bool, NULL) : .Bool(.FLN) = bool
    g_object_get(   boolSyntax, "active", @bool, NULL) : .Bool(.FSH) = bool

    DIM AS gchar PTR char ' passing a pointer, remember to free the data
    g_object_get(     entryFbc, "text", @char, NULL) : .FbcExe = *char : g_free(char)
    g_object_get(     entryIde, "text", @char, NULL) : .IdeExe = *char : g_free(char)
    g_object_get(    entryCmdl, "text", @char, NULL) : .CmdlFbc = *char : g_free(char)
    g_object_get(     entryDbg, "text", @char, NULL) : .CmdlDbg = *char : g_free(char)
    g_object_get( entryLogfile, "text", @char, NULL) : .FnamLog = *char : g_free(char)
    g_object_get(   fontSource, "font", @char, NULL) : .FontSrc = *char : g_free(char)

    DIM AS gdouble num
    g_object_get(     numDelay, "value", @num, NULL) : .DelVal = cast(guint32, num)
    g_object_get(    numCurpos, "value", @num, NULL) : .CurPos = cast(guint32, num)
    .saveIni()
  CASE ELSE '                                             INI --> dialog
    DIM AS GdkRGBA col
    gdk_rgba_parse(@col, "#" & HEX(   .colForegr, 6)) : g_object_set(   colForegr, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(   .colBackgr, 6)) : g_object_set(   colBackgr, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(.colBackgrCur, 6)) : g_object_set(colBackgrCur, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(    .colBreak, 6)) : g_object_set(    colBreak, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX( .colBreakTmp, 6)) : g_object_set( colBreakTmp, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(   .colLineNo, 6)) : g_object_set(   colLineNo, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(  .colKeyword, 6)) : g_object_set(  colKeyword, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(  .colStrings, 6)) : g_object_set(  colStrings, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(   .colPrepro, 6)) : g_object_set(   colPrepro, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(  .colComment, 6)) : g_object_set(  colComment, "rgba", @col, NULL)

    g_object_set( boolTooltips, "active", .Bool(.FTT), NULL)
    g_object_set(  boolVerbose, "active", .Bool(.FVM), NULL)
    g_object_set(   boolScreen, "active", .Bool(.FSL), NULL)
    g_object_set(boolProctrace, "active", .Bool(.FPT), NULL)
    g_object_set(boolLinetrace, "active", .Bool(.FLT), NULL)
    g_object_set(   boolLineno, "active", .Bool(.FLN), NULL)
    g_object_set(   boolSyntax, "active", .Bool(.FSH), NULL)

    g_object_set(     entryFbc, "text", IIF(LEN( .FbcExe), SADD(.FbcExe), @""), NULL)
    g_object_set(     entryIde, "text", IIF(LEN( .IdeExe), SADD(.IdeExe), @""), NULL)
    g_object_set(    entryCmdl, "text", IIF(LEN(.CmdlFbc), SADD(.CmdlFbc), @""), NULL)
    g_object_set(     entryDbg, "text", IIF(LEN(.CmdlDbg), SADD(.CmdlDbg), @""), NULL)
    g_object_set( entryLogfile, "text", IIF(LEN(.FnamLog), SADD(.FnamLog), @""), NULL)

    g_object_set(   fontSource, "font", IIF(LEN(.FontSrc), SADD(.FontSrc), @""), NULL)
    g_object_set(     numDelay, "value", CAST(gdouble, .DelVal), NULL)
    g_object_set(    numCurpos, "value", CAST(gdouble, .CurPos), NULL)
  END SELECT
END WITH
END SUB


/'* \brief Run the settings dialog (GtkAction id="action900")
\param action The GtkAction that triggered the signal
\param user_data The GtkWidget PTR of the dialog window

This signal handler shows the settings dialog in modal mode. Depending
on the user action it either cancels all changes or reads the new data.

\todo Decide if we need a help button.

'/
SUB act_Settings CDECL ALIAS "act_Settings" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

  ?" --> callback act_Settings"
  SELECT CASE AS CONST gtk_dialog_run(user_data)
    CASE 0
      ?" --> callback act_Settings -> save dialog settings"
      SettingsForm(0) ' load from form
    CASE ELSE
      ?" --> callback act_Settings -> dialog canceled, restore form"
      SettingsForm(1) ' restore form, because user canceled
  END SELECT
  gtk_widget_hide(user_data)

END SUB


/'* \brief Signal handler for icons in GtkEntries (id="entry501", "entry502")
\param Entry The entry widget where the icon was clicked
\param IconPos The icon position (GTK_ENTRY_ICON_PRIMARY or GTK_ENTRY_ICON_SECONDARY)
\param Event The GdkEvent that triggered the signal (unused)
\param user_data (unused)

This signal handler pops up a file chooser dialog in "save" mode. The
user can either select an existing file, or select a folder and enter a
name for a new file.

\todo Decide if we pass a GtkFileFilter as user_data in future (LINUX/non-LINUX)
\todo Decide if we enable the overwrite confirmation

'/
SUB on_entry_icon_save CDECL ALIAS "on_entry_icon_save" ( _
  BYVAL Entry AS GtkEntry PTR, _
  BYVAL IconPos AS GtkEntryIconPosition, _
  BYVAL Event AS GdkEvent PTR, _
  BYVAL user_data AS gpointer) EXPORT

  IF IconPos <> GTK_ENTRY_ICON_SECONDARY THEN EXIT SUB

  VAR fnam = *gtk_entry_get_text(Entry) ' don't free this one!
  VAR dia = DBG_FILE_SAVE("Select log file name")
  'gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dia), TRUE)
  gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dia), fnam)

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_entry_set_text(Entry, fnam)
    g_free (fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB


/'* \brief Signal handler for GtkEntry (id="entry505")
\param Entry The widget that triggered the signal
\param IconPos The icon position (GTK_ENTRY_ICON_PRIMARY or GTK_ENTRY_ICON_SECONDARY)
\param Event The GdkEvent that triggered the signal (unused)
\param user_data (unused)

This signal handler pops up a file chooser dialog in "load" mode. The
user can select an executable (existing files only, it's not possible
to enter a name for a new file).

\todo Decide if we pass a GtkFileFilter as user_data in future (LINUX/non-LINUX)

'/
SUB on_entry_icon_load CDECL ALIAS "on_entry_icon_load" ( _
  BYVAL Entry AS GtkEntry PTR, _
  BYVAL IconPos AS GtkEntryIconPosition, _
  BYVAL Event AS GdkEvent PTR, _
  BYVAL user_data AS gpointer) EXPORT

  IF IconPos <> GTK_ENTRY_ICON_SECONDARY THEN EXIT SUB

  VAR dia = DBG_FILE_OPEN("Select executable")
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_exe_filter())

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_entry_set_text(Entry, fnam)
    g_free(fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB


' Here we initialize the dialog context (before starting the main window)
SettingsForm()
