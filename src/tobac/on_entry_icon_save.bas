/'* \file on_entry_icon_save.bas
\brief Signal handler for GtkEntries (id="entry501", "entry502")

\since 3.0
'/


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
  VAR dia = gtk_file_chooser_dialog_new(*__("Save file"), NULL _
    , GTK_FILE_CHOOSER_ACTION_SAVE _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)
  'gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dia), TRUE)
  gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dia), fnam)

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_entry_set_text(Entry, fnam)
    g_free (fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB
