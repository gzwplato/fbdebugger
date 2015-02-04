/'* \file main.bas
\brief Signal handlers for main window

This file contains the code to handle the widgets of the main window.

\since 3.0
'/


/'* \brief Signal handler for right-click popup menues
\param Widget The widget where the right click occurs (unused)
\param Event The GdkEvent of the right click
\param PopUp The popup menu widget to show (user_data)
\returns TRUE when right clicked, FALSE otherwise

This signal handler gets called when the user right-clicks on a
notebook context. It shows a popup menu. Depending on the widget where
the right-click occurs, a different menu widget gets passed in as
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


/'* \brief Signal handler for a GtkCellRendererToggle (id="cellrenderertoggle1")
\param CellRenderer The widget that triggered the signal (unused)
\param Path The path in the GtkTreeModel
\param Store The related GtkTreeStore (user_data)

This signal handler gets called when the user clicks on a
GtkCheckButton in the GtkTreeView of the "Procs" tab in the right
notebook. It toggles the tree store context.

'/
SUB on_boolcell_toggled CDECL ALIAS "on_boolcell_toggled" ( _
  BYVAL CellRenderer AS GtkCellRendererToggle PTR, _
  BYVAL Path AS gchar PTR, _
  BYVAL Store AS gpointer) EXPORT

  DIM AS gboolean v
  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(Store)
  gtk_tree_model_get_iter_from_string(model, @iter, Path)
  gtk_tree_model_get(model, @iter, 1, @v, -1)
  gtk_tree_store_set(Store, @iter, 1, IIF(v, 0, 1), -1)

END SUB



/'* \brief Signal handler for bookmarks combo box (id="comboBookmarks")
\param widget The widget that triggered the signal
\param user_data (unused)

This signale handler gets called when the user changed the selection of
the GtkComboBoxText for the booksmarks.

\todo Enter code

'/
SUB on_comboBookmarks_changed CDECL ALIAS "on_comboBookmarks_changed" ( _
  BYVAL widget AS GtkWidget PTR, _
  BYVAL user_data AS gpointer) EXPORT ' Standard-Parameterliste

' place your source code here / eigenen Quelltext hier einfuegen
?*__("--> callback on_comboBookmarks_changed") _
 & "  " & gtk_combo_box_get_active(GTK_COMBO_BOX(widget)) _ '   gint
 & "  " & *gtk_combo_box_get_active_id(GTK_COMBO_BOX(widget)) ' CONST gchar PTR

END SUB




/'* \brief Signal handler for botton stop at varible (id="button2")
\param button The widget that triggered the signal
\param user_data (unused)

This signale handler gets called when the user clicks on the button to
stop when a variable changed.

\todo Enter code

'/
SUB on_StopVar_clicked CDECL ALIAS "on_StopVar_clicked" ( _
  BYVAL button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("--> callback on_SopVar_clicked")
  gtk_button_set_label(button, "This text get set form code in file tobac/on_StopVar_clicked.bas")

END SUB
