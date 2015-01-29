/'* \file act_Settings.bas
\brief Signal handler for a GtkAction (id="action464")

This file contains the signal handler and some auxiliary code.

\since 3.0
'/



/'* \brief Populate or evaluate the settings dialog
\param Mo The modus (0 = read, 1 = write)

Handle the data in the settings dialog. The SUB either

- reads the dialog data and sets the parameter variables for the ini
  file, or

- sets the dialog to ini file parameter variables

When called first, the widgets get searched in the GUI description file.

\ToDo Replace the literals by your matching parameter variables in the
      SELECT block.

'/
SUB SettingsForm(BYVAL Mo AS gint = 1)
  STATIC AS GObject PTR _
    colForegr, colBackbr, colBackgrCur, colBreak, colBreakTmp, colLineNo _
  , colKeyword, colStrings, colPrepro, colComment _
  , boolTooltips, boolVerbose, boolScreen _
  , boolProctrace, boolLinetrace _
  , boolLineno, boolSyntax _
  , entryFbc, entryIDE, entryCmpl, entryDbg, entryLogfile _
  , numDelay, numCurpos, fontSource

  IF 0 = fontSource THEN '      initial get objects from GUI description
    VAR xml = GUI_MAIN.XML
         colForegr = gtk_builder_get_object(xml, "colorbutton501")
         colBackbr = gtk_builder_get_object(xml, "colorbutton509")
      colBackgrCur = gtk_builder_get_object(xml, "colorbutton510")
          colBreak = gtk_builder_get_object(xml, "colorbutton511")
       colBreakTmp = gtk_builder_get_object(xml, "colorbutton512")
         colLineNo = gtk_builder_get_object(xml, "colorbutton502")
        colKeyword = gtk_builder_get_object(xml, "colorbutton513")
        colStrings = gtk_builder_get_object(xml, "colorbutton514")
         colPrepro = gtk_builder_get_object(xml, "colorbutton515")
        colComment = gtk_builder_get_object(xml, "colorbutton516")

      boolTooltips = gtk_builder_get_object(xml, "checkbutton506")
       boolVerbose = gtk_builder_get_object(xml, "checkbutton502")
        boolScreen = gtk_builder_get_object(xml, "checkbutton503")
     boolProctrace = gtk_builder_get_object(xml, "checkbutton505")
     boolLinetrace = gtk_builder_get_object(xml, "checkbutton504")
        boolLineno = gtk_builder_get_object(xml, "checkbutton507")
        boolSyntax = gtk_builder_get_object(xml, "checkbutton501")

          entryFbc = gtk_builder_get_object(xml, "entry501")
          entryIde = gtk_builder_get_object(xml, "entry502")
         entryCmpl = gtk_builder_get_object(xml, "entry503")
          entryDbg = gtk_builder_get_object(xml, "entry504")
      entryLogfile = gtk_builder_get_object(xml, "entry505")
        fontSource = gtk_builder_get_object(xml, "fontbutton502")

          numDelay = gtk_builder_get_object(xml, "adjustment2")
         numCurpos = gtk_builder_get_object(xml, "adjustment1")
  END IF

  SELECT CASE AS CONST Mo
  CASE 0 '                                                load from form
    DIM AS GdkRGBA PTR col ' passing a pointer, remember to free the data
    g_object_get(   colForegr, "rgba", @col, NULL) :     ?"      colForegr = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(   colBackbr, "rgba", @col, NULL) :     ?"      colBackbr = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(colBackgrCur, "rgba", @col, NULL) :     ?"   colBackgrCur = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(    colBreak, "rgba", @col, NULL) :     ?"       colBreak = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get( colBreakTmp, "rgba", @col, NULL) :     ?"    colBreakTmp = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(   colLineNo, "rgba", @col, NULL) :     ?"      colLineNo = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(  colKeyword, "rgba", @col, NULL) :     ?"     colKeyword = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(  colStrings, "rgba", @col, NULL) :     ?"     colStrings = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(   colPrepro, "rgba", @col, NULL) :     ?"      colPrepro = "; col->red, col->green, col->blue : gdk_rgba_free(col)
    g_object_get(  colComment, "rgba", @col, NULL) :     ?"     colComment = "; col->red, col->green, col->blue : gdk_rgba_free(col)

    DIM AS gboolean bool
    g_object_get( boolTooltips, "active", @bool, NULL) : ?"   boolTooltips = "; bool
    g_object_get(  boolVerbose, "active", @bool, NULL) : ?"    boolVerbose = "; bool
    g_object_get(   boolScreen, "active", @bool, NULL) : ?"     boolScreen = "; bool
    g_object_get(boolProctrace, "active", @bool, NULL) : ?"  boolProctrace = "; bool
    g_object_get(boolLinetrace, "active", @bool, NULL) : ?"  boolLinetrace = "; bool
    g_object_get(   boolLineno, "active", @bool, NULL) : ?"     boolLineno = "; bool
    g_object_get(   boolSyntax, "active", @bool, NULL) : ?"     boolSyntax = "; bool

    DIM AS gchar PTR char ' passing a pointer, remember to free the data
    g_object_get(     entryFbc, "text", @char, NULL) :   ?"       entryFbc = "; *char : g_free(char)
    g_object_get(     entryIde, "text", @char, NULL) :   ?"       entryIde = "; *char : g_free(char)
    g_object_get(    entryCmpl, "text", @char, NULL) :   ?"      entryCmpl = "; *char : g_free(char)
    g_object_get(     entryDbg, "text", @char, NULL) :   ?"       entryDbg = "; *char : g_free(char)
    g_object_get( entryLogfile, "text", @char, NULL) :   ?"   entryLogfile = "; *char : g_free(char)
    g_object_get(   fontSource, "font", @char, NULL) :   ?"     fontSource = "; *char : g_free(char)

    DIM AS gdouble num
    g_object_get(     numDelay, "value", @num, NULL) :   ?"       numDelay = "; num
    g_object_get(    numCurpos, "value", @num, NULL) :   ?"      numCurpos = "; num
  CASE ELSE '                                                set to form
    DIM AS GdkRGBA col
    gdk_rgba_parse(@col, "#FFFFFF") : g_object_set(   colForegr, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#FFFFFF") : g_object_set(   colBackbr, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#CFCFCF") : g_object_set(colBackgrCur, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#AFAFAF") : g_object_set(    colBreak, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#8F8F8F") : g_object_set( colBreakTmp, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#6F6F6F") : g_object_set(   colLineNo, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#4F4F4F") : g_object_set(  colKeyword, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#2F2F2F") : g_object_set(  colStrings, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#0000FF") : g_object_set(   colPrepro, "rgba", @col, NULL)
    gdk_rgba_parse(@col, "#FF00FF") ': g_object_set(  colComment, "rgba", @col, NULL)
    gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(colComment), @col) ' alternative syntax

    g_object_set( boolTooltips, "active", TRUE, NULL)
    g_object_set(  boolVerbose, "active", TRUE, NULL)
    g_object_set(   boolScreen, "active", TRUE, NULL)
    g_object_set(boolProctrace, "active", TRUE, NULL)
    g_object_set(boolLinetrace, "active", TRUE, NULL)
    g_object_set(   boolLineno, "active", TRUE, NULL)
    g_object_set(   boolSyntax, "active", TRUE, NULL)

    g_object_set(     entryFbc, "text", "fbc", NULL)
    g_object_set(     entryIde, "text", "geany", NULL)
    g_object_set(    entryCmpl, "text", "-v", NULL)
    g_object_set(     entryDbg, "text", "-g -v", NULL)
    g_object_set( entryLogfile, "text", "log.txt", NULL)

    g_object_set(   fontSource, "font", "Monospace 8", NULL)
    g_object_set(     numDelay, "value", 200., NULL)
    g_object_set(    numCurpos, "value", 55., NULL)
  END SELECT
END SUB


/'* \brief Run the settings dialog (GtkAction id="action900")
\param action The GtkAction that triggered the signal
\param user_data The GtkWidget PTR of the dialog window

This signal handler shows the settings dialog in modal mode. Depending
on the user action it either cancels all changes or reads the new data.

\note Further action buttons may get added.

'/
SUB act_Settings CDECL ALIAS "act_Settings" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

  ?*__("callback act_Settings")
  SELECT CASE AS CONST gtk_dialog_run(user_data)
    CASE 0
      ?*__("callback act_Settings -> get changed settings")
      SettingsForm(0) ' load from form
    CASE 1
      ?*__("callback act_Settings -> dialog canceled, restore form")
      SettingsForm(1) ' restore form, because user canceled

  ' CASE ... further dialog actions, ie. a Help button
  END SELECT
  gtk_widget_hide(user_data)

END SUB
