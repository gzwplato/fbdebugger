/'* \file act_step_end.bas
\brief Signal handler for a GtkAction (id="action006")

\since 3.0
'/

SUB act_step_end CDECL ALIAS "act_step_end" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_step_end")

END SUB
