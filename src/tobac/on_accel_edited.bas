/'* \file on_accel_cleared.bas
\brief Signal handler for a GtkCellRendererAccel (id="cellrendereraccel601")

\since 3.0
'/


/'* \brief Signal handler for editing a GtkCellRendererAccel (id="cellrendereraccel601")
\param accel The widget that triggers the signal
\param path_string The path in the GtkTreeModel
\param accel_key The key number of the shortcut
\param accel_mods The modifier mask (GdkModifierType)
\param hardware_keycode A hardware keycode (not handled here)
\param user_data The GtkListStore where to change the data

This signal handler gets called when the user edited a keyboard
shortcut in the shortcuts dialog. It up-dates the data in the related
list store.

'/
SUB on_accel_edited CDECL ALIAS "on_accel_edited" ( _
  BYVAL accel AS GtkCellRendererAccel PTR, _
  BYVAL path_string AS gchar PTR, _
  BYVAL accel_key AS guint, _
  BYVAL accel_mods AS GdkModifierType, _
  BYVAL hardware_keycode AS guint, _
  BYVAL user_data AS gpointer) EXPORT

  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(user_data)
  gtk_tree_model_get_iter_from_string(model, @iter, path_string)
  gtk_list_store_set(user_data, @iter _
    , 0, accel_key _
    , 1, accel_mods _
    , -1) '                                    parameter list terminator

END SUB
