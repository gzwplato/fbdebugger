/'* \file act_step.bas
\brief Signal handler for a GtkAction (id="action002")

\since 3.0
'/

SUB act_step CDECL ALIAS "act_step" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_step")
  VAR dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
    , GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
    , GTK_MESSAGE_WARNING _
    , GTK_BUTTONS_YES_NO _
    , __(!"TRYING TO WRITE AT ADR: <b>%d</b>\n") _
    & __(!"Possible error on this line but not SURE\n\n") _
    & __(!"<i>File</i>: <b>%s</b>\n") _
    & __(!"<i>Proc</i>: <b>%s</b>\n") _
    & __(!"<i>Line</i>: <b>%d</b> (selected and put in red)\n") _
    & __(!"<b>%s</b>\n\n") _
    & __(!"Try to continue ? (if yes change value and/or use [M]odify execution)\n") _
    , 222 _
    , "D:\a\b\c\d\debuggee.bas" _
    , "TEST" _
    , 279 _
    , "Print ""Line with crash"": Poke testa, 10 'for access violation" _
    , NULL)

  IF GTK_RESPONSE_YES = gtk_dialog_run(GTK_DIALOG(dia)) THEN
    ?*__("==> YES selected")
  ELSE
    ?*__("==> NO selected")
  END IF
  gtk_widget_destroy(dia)

END SUB
