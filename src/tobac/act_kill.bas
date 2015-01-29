/'* \file act_kill.bas
\brief Signal handler for a GtkAction (id="action010")

\since 3.0
'/

SUB act_kill CDECL ALIAS "act_kill" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_kill")

END SUB
