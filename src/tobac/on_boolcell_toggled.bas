/'* \file on_boolcell_toggled.bas
\brief Signal handler for a GtkCellRendererToggle (id="cellrenderertoggle1")

\since 3.0
'/


/'* \brief Signal handler for a GtkCellRendererToggle (id="cellrenderertoggle1")
\param cell_renderer The widget that triggered the signal
\param path The path in the GtkTreeModel
\param user_data The related GtkTreeStore

This signal handler gets called when the user clicks on a
GtkCheckButton in the GtkTreeView of the "Procs" tab in the right
notebook. It toggles the tree store context.

'/
SUB on_boolcell_toggled CDECL ALIAS "on_boolcell_toggled" ( _
  BYVAL cell_renderer AS GtkCellRendererToggle PTR, _
  BYVAL path AS gchar PTR, _
  BYVAL user_data AS gpointer) EXPORT

  DIM AS gboolean v
  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(user_data)
  gtk_tree_model_get_iter_from_string(model, @iter, path)
  gtk_tree_model_get(model, @iter, 1, @v, -1)
  gtk_tree_store_set(user_data, @iter, 1, IIF(v, 0, 1), -1)

END SUB
