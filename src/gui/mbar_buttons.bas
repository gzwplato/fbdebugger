/'* \file mbar_buttons.bas
\brief Signal handlers for actions in the toolbar (buttons)

\since 3.0
'/


SUB act_free CDECL ALIAS "act_free" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_free"

END SUB


SUB act_minicmd CDECL ALIAS "act_minicmd" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_minicmd"

END SUB


SUB act_restart CDECL ALIAS "act_restart" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_restart"

END SUB


SUB act_multiexe CDECL ALIAS "act_multiexe" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_multiexe"

END SUB


SUB act_attachexe CDECL ALIAS "act_attachexe" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_attachexe"

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

?" --> callback act_files"

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

        ?SRC->addBas(MID(*fnam, INSTRREV(*fnam, ANY "/\") + 1), t)
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

?" --> callback act_notes"
  TXT->Notes()

END SUB


SUB act_source CDECL ALIAS "act_source" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_source"

END SUB


SUB act_varproc CDECL ALIAS "act_varproc" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_varproc"

'' list some files to load
dim as gchar ptr fnam(...) => { _
  @"fbdbg.bas" _
, @"gui/shortcuts.bas" _
, @"gui/settings.bas" _
, @"gui/source.bas" _
}
'' references for pages
dim as any ptr ref(ubound(fnam))
?" load the files"
FOR i AS INTEGER = 0 TO ubound(fnam)
  var fnr = FREEFILE
  IF 0 = OPEN(*fnam(i) FOR INPUT AS fnr) THEN
    VAR l = LOF(fnr)
    IF l <= G_MAXINT THEN
      VAR t = STRING(l, 0)
      GET #fnr, , t
      CLOSE #fnr

      ref(i) = SRC->addBas(MID(*fnam(i), INSTRREV(*fnam(i), ANY "/\") + 1), t)
    END IF
  END IF
NEXT

'?" do some random scrolling soon ... (don't do GUI actions)"
'while gtk_events_pending() : gtk_main_iteration() : wend : sleep 2000 ' make changes visible

'randomize(timer)
'FOR i AS INTEGER = 0 TO 10
  'var l = cuint(rnd() * 150), ind = l mod ubound(ref)

'?" SRC->scroll(" & l & ", " & ref(ind) & ")", ind
  'SRC->scroll(l, ref(ind))

  'while gtk_events_pending() : gtk_main_iteration() : wend : sleep 2000 ' make changes visible
'NEXT

'?" remove all notebook pages (GUI actions alowed again)"
'SRC->removeAll()
''' alternative remove single pages
'FOR i AS INTEGER = 0 TO ubound(fnam)
  'SRC->remove(ref(i))
'NEXT
exit sub

while gtk_events_pending() : gtk_main_iteration() : wend
SRC->scroll(150, ref(1))
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "book")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "brkp")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "brkt")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "brkd")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "boo")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "brk")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "book")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "brkp")
while gtk_events_pending() : gtk_main_iteration() : wend : sleep 1000
SRC->changeMark(150, ref(1), "")
END SUB


SUB act_memory CDECL ALIAS "act_memory" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_memory"

'' test code to get removed
static as guint32 runtype = 0
?" runtype = "; runtype
ACT->setState(runtype)
runtype += 1 : if runtype > RTEND then runtype = 0
END SUB
