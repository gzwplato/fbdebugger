/'* \file act_tools.bas
\brief Signal handler for a GtkAction (id="action466")

\since 3.0
'/


/'* \brief Pop up the tools menu
\param Action The GtkAction that triggered the signal (unused, id="action466")
\param PopUp The popup menu widget to show (user_data)

This signal handler pops up the tools menu. We do not use a GtkMenuItem
here, because it expands all other tool buttons in the toolbar.

'/
SUB act_tools CDECL ALIAS "act_tools" ( _
  BYVAL Action AS GtkAction PTR, _
  BYVAL PopUp AS gpointer) EXPORT

  gtk_menu_popup(PopUp, NULL, NULL, NULL, NULL, 1, gtk_get_current_event_time())

END SUB
