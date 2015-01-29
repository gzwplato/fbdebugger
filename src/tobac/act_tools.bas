/'* \file act_tools.bas
\brief Signal handler for a GtkAction (id="action466")

\since 3.0
'/

SUB act_tools CDECL ALIAS "act_tools" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

  VAR tim = gtk_get_current_event_time()
  gtk_menu_popup(user_data, NULL, NULL, NULL, NULL, 1, tim)

END SUB
