/'* \file act_run.bas
\brief Signal handler for a GtkAction (id="action007")

\since 3.0
'/

SUB act_run CDECL ALIAS "act_run" ( _
  BYVAL button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_run")

END SUB
