/'* \file mbar_buttons.bas
\brief Signal handlers for actions in the toolbar (buttons)

\since 3.0
'/


SUB act_free CDECL ALIAS "act_free" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_free")

END SUB


SUB act_minicmd CDECL ALIAS "act_minicmd" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_minicmd")

END SUB


SUB act_restart CDECL ALIAS "act_restart" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_restart")

END SUB


SUB act_multiexe CDECL ALIAS "act_multiexe" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_multiexe")

END SUB


SUB act_attachexe CDECL ALIAS "act_attachexe" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_attachexe")

END SUB


/'* \brief Signal handler for GtkAction (id="act_files")
\param action The action that triggered the signal
\param user_data (unused)

The signal handler gets called when the user clicks on the files
toolbar button.

Here, the handler contains example code on how to create a file chooser
dialog, set filters and run that dialog.

\todo Replace / extend example code

'/
SUB act_files CDECL ALIAS "act_files" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_files")
  VAR dia = DBG_FILE_OPEN("Select debuggee file name")
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_all_filter())
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_exe_filter())
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_bas_filter())

  IF GTK_RESPONSE_ACCEPT = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    VAR fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia)) _
       , fnr = FREEFILE
    IF 0 = OPEN(*fnam FOR INPUT AS fnr) THEN
      VAR l = LOF(fnr)
      IF l <= G_MAXINT THEN
        VAR t = STRING(l, 0)
        GET #fnr, , t
        CLOSE #fnr

        gtk_text_buffer_set_text(GTK_TEXT_BUFFER(GUI.srcbuff), t, l)
      END IF
    END IF
    g_free (fnam)
  END IF

  gtk_widget_destroy(dia)

END SUB



/'* \brief Open or close the notes window
\param Action The action that triggers the signal
\param user_data (unused)

\todo Handle context (ini file)

'/
SUB act_notes CDECL ALIAS "act_notes" ( _
  BYVAL Action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_notes")
  TXT.Notes()

END SUB


SUB act_source CDECL ALIAS "act_source" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_source")

END SUB


SUB act_varproc CDECL ALIAS "act_varproc" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_varproc")

END SUB


SUB act_memory CDECL ALIAS "act_memory" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_memory")

END SUB
