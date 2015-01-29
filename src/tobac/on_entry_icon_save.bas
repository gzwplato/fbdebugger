/'* \file on_entry_icon_save.bas
\brief Signal handler for GtkEntries (id="entry501", "entry502")

\since 3.0
'/


/'* \brief Signal handler for icons in GtkEntries (id="entry501", "entry502")
\param entry The entry widget where the icon was clicked
\param icon_pos The icon position (GTK_ENTRY_ICON_PRIMARY or GTK_ENTRY_ICON_SECONDARY)
\param event The GdkEvent that triggered the signal
\param user_data Empty (no user_data specified)

This signal handler pops up a file chooser dialog in "save" mode. The
user can either select an existing file, or select a folder and enter a
name for a new file.

\note We may pass a GtkFileFilter as user_data in future

'/
SUB on_entry_icon_save CDECL ALIAS "on_entry_icon_save" ( _
  BYVAL entry AS GtkEntry PTR, _
  BYVAL icon_pos AS GtkEntryIconPosition, _
  BYVAL event AS GdkEvent PTR, _
  BYVAL user_data AS gpointer) EXPORT

  VAR fnam = *gtk_entry_get_text(entry) ' don't free this one!
  VAR dia = gtk_file_chooser_dialog_new(*__("Save file"), NULL _
    , GTK_FILE_CHOOSER_ACTION_SAVE _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)
  'gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dia), TRUE)
  gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dia), fnam)

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_entry_set_text(entry, fnam)
    g_free (fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB
