/'* \file settings.bas
\brief Code for settings dialog

This file contains the source code to handle the settings dialog. ???

\since 3.0
'/


'* \brief Enumerators for style change modi
ENUM
  STYLE_SYNTAX '*< Check button syntax highlighting changed
  STYLE_LINENO '*< Check button line numbers changed
  STYLE_FONT   '*< Font button source view changed
  STYLE_SCROLL '*< Scroll bar current position changed
  STYLE_COLOR  '*< One of the color buttons changed
  STYLE_SCHEME '*< Combo box style scheme changed
END ENUM


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


FUNCTION newScheme(byval Array AS GObject PTR PTR) AS gchar ptr
  if name("dat/fbdebugger.xml", "dat/fbdebugger.tmp") then _
                           return __("Cannot rename dat/fbdebugger.xml")
  VAR f_in = FREEFILE
  IF OPEN("dat/fbdebugger.tmp" FOR INPUT AS f_in) THEN _
                             return __("Cannot read dat/fbdebugger.tmp")
  VAR fout = FREEFILE
  IF OPEN("dat/fbdebugger.xml" FOR OUTPUT AS fout) THEN _
              close #f_in : return __("Cannot write dat/fbdebugger.xml")

  var allready_done = 0
  WHILE not eof(f_in)
    var l = ""
    line input #f_in, l
    IF instr(l, "<color ") THEN
      if allready_done then continue while
      allready_done += 1
      DIM AS GdkRGBA PTR col

#define COL_OUT(_I_,_N_) _
  g_object_get(Array[_I_], "rgba", @col, NULL) : _
  print #fout, !"\t<color name='" & _N_ & "' value='#" & HEX(colTrans(col), 6) & "'/>"

      COL_OUT(0,"text_fg")
      COL_OUT(1,"text_bg")
      COL_OUT(2,"line_highlight")
      COL_OUT(3,"line_no_bg")
      COL_OUT(4,"keyword_color")
      COL_OUT(5,"string_color")
      COL_OUT(6,"prepro_color")
      COL_OUT(7,"comment_color")
      COL_OUT(8,"number_color")
      COL_OUT(9,"escape_color")
      print #fout, !"\t<color name='error_color' value='#ff0000'/>"
    ELSE
      print #fout, l
    END IF
  WEND : CLOSE #f_in : CLOSE #fout
  WITH *SRC
    gtk_source_style_scheme_manager_force_rescan(.Manager)
    .Schema = gtk_source_style_scheme_manager_get_scheme(.Manager, @"fbdebugger")
  END WITH
  if kill("dat/fbdebugger.tmp") then _
                           return __("Cannot remove dat/fbdebugger.tmp")
  RETURN NULL
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
  , colKeyword, colStrings, colPrepro, colComment, colNumbers, colEscape _
  , boolTooltips, boolVerbose, boolScreen _
  , boolProctrace, boolLinetrace _
  , boolLineno, boolSyntax _
  , entryFbc, entryIDE, entryCmdl, entryDbg, entryLogfile _
  , numDelay, numCurpos, fontSource _
  , array(10)

  IF 0 = fontSource THEN '      initial get objects from GUI description
    VAR xml = GUI.XML ' the style scheme combobox text gets handled in SrcNotebook
          colBreak = gtk_builder_get_object(xml, "colorbutton511")
       colBreakTmp = gtk_builder_get_object(xml, "colorbutton512")
      colBackgrCur = gtk_builder_get_object(xml, "colorbutton510")
         colForegr = gtk_builder_get_object(xml, "colorbutton501")
         colBackgr = gtk_builder_get_object(xml, "colorbutton509")
         colLineNo = gtk_builder_get_object(xml, "colorbutton502")
        colKeyword = gtk_builder_get_object(xml, "colorbutton513")
        colStrings = gtk_builder_get_object(xml, "colorbutton514")
         colPrepro = gtk_builder_get_object(xml, "colorbutton515")
        colComment = gtk_builder_get_object(xml, "colorbutton516")
        colNumbers = gtk_builder_get_object(xml, "colorbutton517")
         colEscape = gtk_builder_get_object(xml, "colorbutton518")

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

    g_object_set_data(   colForegr, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(   colBackgr, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(colBackgrCur, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(   colLineNo, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(  colKeyword, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(  colStrings, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(   colPrepro, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(  colComment, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(  colNumbers, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(   colEscape, "TestId", cast(gpointer, STYLE_COLOR))
    g_object_set_data(  boolSyntax, "TestId", cast(gpointer, STYLE_SYNTAX))
    g_object_set_data(  boolLineno, "TestId", cast(gpointer, STYLE_LINENO))
    g_object_set_data(  fontSource, "TestId", cast(gpointer, STYLE_FONT))
    g_object_set_data(   numCurpos, "TestId", cast(gpointer, STYLE_SCROLL))
    g_object_set_data(G_OBJECT(SRC->CombBox), "TestId", cast(gpointer, STYLE_SCHEME))

    array( 0) = colForegr
    array( 1) = colBackgr
    array( 2) = colBackgrCur
    array( 3) = colLineNo
    array( 4) = colKeyword
    array( 5) = colStrings
    array( 6) = colPrepro
    array( 7) = colComment
    array( 8) = colNumbers
    array( 9) = colEscape
    array(10) = NULL
    g_object_set_data(G_OBJECT(SRC->CombBox), "WidgetArray", @array(0))
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
    g_object_get(  colNumbers, "rgba", @col, NULL) :   .colNumbers = colTrans(col) : gdk_rgba_free(col)
    g_object_get(   colEscape, "rgba", @col, NULL) :    .colEscape = colTrans(col) : gdk_rgba_free(col)

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
    g_object_get(     entryDbg, "text", @char, NULL) : .CmdExe(0) = *char : g_free(char)
    g_object_get( entryLogfile, "text", @char, NULL) : .FnamLog = *char : g_free(char)
    g_object_get(   fontSource, "font", @char, NULL) : .FontSrc = *char : g_free(char)
    g_object_get( SRC->CombBox, "active-id", @char, NULL) : .StlSchm = *char : g_free(char)

    DIM AS gdouble num
    g_object_get(     numDelay, "value", @num, NULL) : .DelVal = cast(guint32, num)
    g_object_get(    numCurpos, "value", @num, NULL) : .CurPos = cast(guint32, num)

    SRC->settingsChanged()
    VAR r = .saveIni() : IF r THEN ?PROJ_NAME & ": " & *r
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
    gdk_rgba_parse(@col, "#" & HEX(  .colNumbers, 6)) : g_object_set(  colNumbers, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#" & HEX(   .colEscape, 6)) : g_object_set(   colEscape, "rgba", @col, NULL)

    g_object_set( boolTooltips, "active", .Bool(.FTT), NULL)
    g_object_set(  boolVerbose, "active", .Bool(.FVM), NULL)
    g_object_set(   boolScreen, "active", .Bool(.FSL), NULL)
    g_object_set(boolProctrace, "active", .Bool(.FPT), NULL)
    g_object_set(boolLinetrace, "active", .Bool(.FLT), NULL)
    g_object_set(   boolLineno, "active", .Bool(.FLN), NULL)
    g_object_set(   boolSyntax, "active", .Bool(.FSH), NULL)

    g_object_set(     entryFbc, "text", IIF(LEN( .FbcExe), SADD(.FbcExe),  @""), NULL)
    g_object_set(     entryIde, "text", IIF(LEN( .IdeExe), SADD(.IdeExe),  @""), NULL)
    g_object_set(    entryCmdl, "text", IIF(LEN(.CmdlFbc), SADD(.CmdlFbc), @""), NULL)
    g_object_set(     entryDbg, "text", IIF(LEN(.CmdExe(0)), SADD(.CmdExe(0)), @""), NULL)
    g_object_set( entryLogfile, "text", IIF(LEN(.FnamLog), SADD(.FnamLog), @""), NULL)

    g_object_set( SRC->CombBox, "active-id", IIF(LEN(.StlSchm), SADD(.StlSchm), @""), NULL)
    g_object_set(   fontSource, "font", IIF(LEN(.FontSrc), SADD(.FontSrc), @""), NULL)
    g_object_set(     numDelay, "value", CAST(gdouble, .DelVal), NULL)
    g_object_set(    numCurpos, "value", CAST(gdouble, .CurPos), NULL)

    var bool = iif(.StlSchm = "fbdebugger", TRUE, FALSE)
    var i = 0
    WHILE array(i)
      gtk_widget_set_sensitive(GTK_WIDGET(array(i)), bool)
      i += 1
    WEND
    if bool then newScheme(@array(0))

    SRC->settingsChanged()
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

'#define GFunc(_P_) cast(SUB CDECL(BYVAL AS gpointer, BYVAL AS gpointer), _P_)


/'* \brief Signal handler to show changed settings
\param Objct The widget that triggered the signal
\param user_data The style scheme combo box, when triggered by a color change

This signal handler updates the style of the source view widgets in
case of a parameter change in settings dialog.

'/
SUB on_settings_changed CDECL ALIAS "on_settings_changed" ( _
  BYVAL Objct AS GObject PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback on_settings_changed"

  WITH *SRC
    var page = gtk_notebook_get_current_page(GTK_NOTEBOOK(.NoteBok)) _
      , widg = gtk_notebook_get_nth_page(GTK_NOTEBOOK(.NoteBok), page)

    SELECT CASE as const g_object_get_data(Objct, "TestId")
    CASE STYLE_SYNTAX
      DIM AS gboolean fsh
      g_object_get(Objct, "active", @fsh, NULL)

      var buff = g_object_get_data(G_Object(widg), "Buffer")
      gtk_source_buffer_set_highlight_syntax(GTKSOURCE_SOURCE_BUFFER(.BuffCur), fsh)
      gtk_source_buffer_set_highlight_syntax(buff, fsh)
    CASE STYLE_LINENO
      DIM AS gboolean fln
      g_object_get(Objct, "active", @fln, NULL)

      var srcv = g_object_get_data(G_Object(widg), "SrcView")
      gtk_source_view_set_show_line_numbers(GTKSOURCE_SOURCE_VIEW(srcv), fLn)
    CASE STYLE_FONT
      DIM AS gchar PTR fontsrc
      g_object_get(Objct, "font", @fontsrc, NULL)

      pango_font_description_free(.Font)
      .Font = pango_font_description_from_string(fontsrc)

      var srcv = g_object_get_data(G_Object(widg), "SrcView")
      gtk_widget_override_font(GTK_WIDGET(.ViewCur), .Font)
      gtk_widget_override_font(GTK_WIDGET(srcv), .Font)
      g_free(fontsrc)
    CASE STYLE_SCROLL
      DIM AS gdouble scroll
      g_object_get(Objct, "value", @scroll, NULL)

      var buff = g_object_get_data(G_Object(widg), "Buffer") _
        , srcv = g_object_get_data(G_Object(widg), "SrcView") _
        , mark = gtk_text_buffer_get_insert(buff)
      gtk_text_view_scroll_to_mark(srcv, mark, .0, TRUE, .0, 1. / 99 * scroll)
    CASE STYLE_COLOR
      newScheme(g_object_get_data(user_data, "WidgetArray"))

      var buff = g_object_get_data(G_Object(widg), "Buffer")
      gtk_source_buffer_set_style_scheme(GTKSOURCE_SOURCE_BUFFER(.BuffCur), .Schema)
      gtk_source_buffer_set_style_scheme(buff, .Schema)
    CASE STYLE_SCHEME
      DIM AS gchar PTR stlschm
      DIM AS GtkWidget PTR PTR array = g_object_get_data(Objct, "WidgetArray")

      g_object_get(Objct, "active-id", @stlschm, NULL)
      var bool = iif(*stlschm = "fbdebugger", TRUE, FALSE)
      .Schema = gtk_source_style_scheme_manager_get_scheme(.Manager, stlschm)
      g_free(stlschm)

      var i = 0
      WHILE array[i]
        gtk_widget_set_sensitive(array[i], bool)
        i += 1
      WEND

      var buff = g_object_get_data(G_Object(widg), "Buffer")
      gtk_source_buffer_set_style_scheme(GTKSOURCE_SOURCE_BUFFER(.BuffCur), .Schema)
      gtk_source_buffer_set_style_scheme(buff, .Schema)
    END SELECT
  END WITH
END SUB


' Here we initialize the dialog context (before starting the main window)
SettingsForm()
