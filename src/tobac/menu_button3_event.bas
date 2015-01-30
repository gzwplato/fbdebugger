/'* \file menu_button3_event.bas
\brief Signal handler for a several widgets

This signal handler shows up a popup menu. It gets called form the
context of the right notebook (tabs Proc/Var, Procs, Threads, Watch and
Mem), and from the left notebook (source) and its context.

\since 3.0
'/


/'* \brief Signal handler for right-click popup menues
\param Widget The widget where the right click occurs (unused)
\param Event The GdkEvent of the right click
\param PopUp The popup menu widget to show (user_data)
\returns TRUE when right clicked, FALSE otherwise

This signal handler gets called when the user right-clicks on a
notebook context. It shows a popup menu. Depending on the widget where
the right-click occurs, a different menu widget gets passed in
parameter *PopUp*.

\since 3.0
'/
FUNCTION menu_button3_event CDECL ALIAS "menu_button3_event" ( _
  BYVAL Widget AS GtkWidget PTR, _
  BYVAL Event AS GdkEvent PTR, _
  BYVAL PopUp AS gpointer) AS gboolean EXPORT

  WITH *CAST(GdkEventButton PTR, Event)
    IF .button <> 3 THEN RETURN FALSE
    gtk_menu_popup(PopUp, NULL, NULL, NULL, NULL, .button, .time)
  END WITH
  RETURN TRUE

END FUNCTION
