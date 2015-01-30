/'* \file on_accel_cleared.bas
\brief Signal handler for a GtkCellRendererAccel (id="cellrendereraccel601")

\since 3.0
'/


/'* \brief Signal handler for editing a GtkCellRendererAccel (id="cellrendereraccel601")
\param Accel The widget that triggers the signal (unused)
\param PathString The path in the GtkTreeModel
\param AccelKey The key number of the shortcut
\param AccelMods The modifier mask (GdkModifierType)
\param HardwareKeycode A hardware keycode (unused)
\param Store The GtkListStore where to change the data (user_data)

This signal handler gets called when the user edited a keyboard
shortcut in the shortcuts dialog. It up-dates the data in the related
list store.

\todo Check for double defines (Cancel, Redefine, Remove)

'/
SUB on_accel_edited CDECL ALIAS "on_accel_edited" ( _
  BYVAL Accel AS GtkCellRendererAccel PTR, _
  BYVAL PathString AS gchar PTR, _
  BYVAL AccelKey AS guint, _
  BYVAL AccelMods AS GdkModifierType, _
  BYVAL HardwareKeycode AS guint, _
  BYVAL Store AS gpointer) EXPORT

  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(Store)
  gtk_tree_model_get_iter_from_string(model, @iter, PathString)
  gtk_list_store_set(Store, @iter _
    , 0, AccelKey _
    , 1, AccelMods _
    , -1) '                                    parameter list terminator

END SUB
