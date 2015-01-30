/'* \file on_StopVar_clicked.bas
\brief Signal handler for GtkButton (id="button2")

\since 3.0
'/

SUB on_StopVar_clicked CDECL ALIAS "on_StopVar_clicked" ( _
  BYVAL button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("--> callback on_SopVar_clicked")
  gtk_button_set_label(button, "This text get set form code in file tobac/on_StopVar_clicked.bas")

END SUB
