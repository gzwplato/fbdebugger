/'* \file on_accel_edited.bas
\brief Signal handler for a GtkCellRendererAccel (id="cellrendereraccel601")

\since 3.0
'/


/'* \brief Signal handler for clearing a GtkCellRendererAccel (id="cellrendereraccel601")
\param accel The widget that triggers the signal
\param path_string The path in the GtkTreeModel
\param user_data The GtkListStore where to change the data

This signal handler gets called when the user cleared a keyboard
shortcut in the shortcuts dialog (by pressing backspace key). It
up-dates the data in the related list store.

'/
SUB on_accel_cleared CDECL ALIAS "on_accel_cleared" ( _
  BYVAL accel AS GtkCellRendererAccel PTR, _
  BYVAL path_string AS gchar PTR, _
  BYVAL user_data AS gpointer) EXPORT

  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(user_data)
  gtk_tree_model_get_iter_from_string(model, @iter, path_string)
  gtk_list_store_set(user_data, @iter _
    , 0, CAST(guint, 0) _
    , 1, CAST(guint, 0) _
    , -1) '                                    parameter list terminator

END SUB
