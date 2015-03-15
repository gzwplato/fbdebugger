/'* \file menu_source.bas
\brief Signal handlers for actions in the Source popup menu

\since 3.0
'/


SUB act_brkset CDECL ALIAS "act_brkset" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_brkset, ToDo: insert code"

END SUB


SUB act_brktempset CDECL ALIAS "act_brktempset" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_brktempset, ToDo: insert code"

END SUB


SUB act_brkenable CDECL ALIAS "act_brkenable" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_brkenable, ToDo: insert code"

END SUB


SUB act_brkmanage CDECL ALIAS "act_brkmanage" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_brkmanage, ToDo: insert code"

END SUB


SUB act_varsrcshow CDECL ALIAS "act_varsrcshow" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_varsrcshow, ToDo: insert code"

END SUB


SUB act_varsrcwtch CDECL ALIAS "act_varsrcwtch" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_varsrcwtch, ToDo: insert code"

END SUB


SUB act_textfind CDECL ALIAS "act_textfind" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_textfind, ToDo: insert code"

END SUB


SUB act_bmktoogle CDECL ALIAS "act_bmktoogle" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_bmktoogle, ToDo: insert code"

END SUB


SUB act_bmknext CDECL ALIAS "act_bmknext" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_bmknext, ToDo: insert code"

END SUB


SUB act_bmkprev CDECL ALIAS "act_bmkprev" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_bmkprev, ToDo: insert code"

END SUB


SUB act_linegoto CDECL ALIAS "act_linegoto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_linegoto, ToDo: insert code"

END SUB


SUB act_lineaddress CDECL ALIAS "act_lineaddress" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_lineaddress, ToDo: insert code"

END SUB


SUB act_lineasm CDECL ALIAS "act_lineasm" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_lineasm, ToDo: insert code"

END SUB


SUB act_procsrcasm CDECL ALIAS "act_procsrcasm" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_procsrcasm, ToDo: insert code"

END SUB


SUB act_linenoexec CDECL ALIAS "act_linenoexec" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_linenoexec, ToDo: insert code"

END SUB


SUB act_linefocus CDECL ALIAS "act_linefocus" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_linefocus, ToDo: insert code"

END SUB



/'* \brief Add the selected text to the notes window
\param action The action that triggered the signal
\param NoteBook The notebook for source views

This callback gets called when the user chooses the add to notes item
in the popup menu of the source view notebook. It checks if text is
selected in the current page. If so, the text gets copied to the notes
context at its current cursor position, prepended by a time stamp.

'/
SUB act_notesadd CDECL ALIAS "act_notesadd" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL NoteBook AS gpointer) EXPORT

  VAR page = gtk_notebook_get_current_page(GTK_NOTEBOOK(NoteBook))
  IF 0 > page THEN EXIT SUB

  DIM AS GtkTextIter i1, i2
  VAR widg = gtk_notebook_get_nth_page(GTK_NOTEBOOK(NoteBook), page) _
    , buff = g_object_get_data(G_OBJECT(widg), "Buffer")

  IF gtk_text_buffer_get_selection_bounds(buff, @i1, @i2) THEN
    VAR cont = gtk_text_buffer_get_text(buff, @i1, @i2, TRUE) _
      , tizo = g_time_zone_new_local() _
      , tida = g_date_time_new_now(tizo) _
      , tstp = g_date_time_format(tida, "[%y%m%d-%H:%M:%S] ") _
      , strg = *tstp & *cont & !"\n"
    g_free(tstp)
    g_date_time_unref(tida)
    g_time_zone_unref(tizo)
    g_free(cont)

    TXT->add2Notes(strg)
  END IF
END SUB
