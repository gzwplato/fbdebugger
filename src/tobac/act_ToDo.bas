/'* \file act_ToDo.bas
\brief Signal handler for a GtkAction (all unhandled)

\since 3.0
'/

SUB act_ToDo CDECL ALIAS "act_ToDo" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_ToDo")

END SUB
