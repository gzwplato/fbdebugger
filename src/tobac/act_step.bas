/'* \file act_step.bas
\brief Signal handler for a GtkAction (id="action002")

\since 3.0
'/

SUB act_step CDECL ALIAS "act_step" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_step")

END SUB
