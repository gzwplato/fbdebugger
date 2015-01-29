/'* \file act_stop.bas
\brief Signal handler for a GtkAction (id="action009")

\since 3.0
'/

SUB act_stop CDECL ALIAS "act_stop" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_stop")

END SUB
