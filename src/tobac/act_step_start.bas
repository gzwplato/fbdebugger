/'* \file act_step_start.bas
\brief Signal handler for a GtkAction (id="action005")

\since 3.0
'/

SUB act_step_start CDECL ALIAS "act_step_start" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_step_start")

END SUB
