/'* \file on_entry_icon_load.bas
\brief Signal handler a GtkEntry (id="entry505")

\since 3.0
'/


/'* \brief Signal handler a GtkEntry (id="entry505")
\param Entry The widget that triggered the signal
\param IconPos The icon position (GTK_ENTRY_ICON_PRIMARY or GTK_ENTRY_ICON_SECONDARY)
\param Event The GdkEvent that triggered the signal (unused)
\param user_data (unused)


This signal handler pops up a file chooser dialog in "load" mode. The
user can select an existing file. It's not possible to enter a name for
a new file.

\todo Decide if we pass a GtkFileFilter as user_data in future (LINUX/non-LINUX)

'/
SUB on_entry_icon_load CDECL ALIAS "on_entry_icon_load" ( _
  BYVAL Entry AS GtkEntry PTR, _
  BYVAL IconPos AS GtkEntryIconPosition, _
  BYVAL Event AS GdkEvent PTR, _
  BYVAL user_data AS gpointer) EXPORT

  IF IconPos <> GTK_ENTRY_ICON_SECONDARY THEN EXIT SUB

  VAR dia = gtk_file_chooser_dialog_new(*__("Select file"), NULL _
    , GTK_FILE_CHOOSER_ACTION_OPEN _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)

  #IFNDEF __FB_UNIX__
    VAR filter = gtk_file_filter_new() ' don't free, dia takes ownership
    gtk_file_filter_set_name(filter, *__("Executables (*.exe)"))
    gtk_file_filter_add_pattern(filter, "*.exe")
    gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), filter)
  #ENDIF

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_entry_set_text(Entry, fnam)
    g_free(fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB
