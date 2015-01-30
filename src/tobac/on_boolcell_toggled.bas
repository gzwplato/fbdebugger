/'* \file on_boolcell_toggled.bas
\brief Signal handler for a GtkCellRendererToggle (id="cellrenderertoggle1")

\since 3.0
'/


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
