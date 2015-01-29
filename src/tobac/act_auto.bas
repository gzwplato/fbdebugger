/'* \file act_auto.bas
\brief Signal handler for a GtkAction (id="action011")

\since 3.0
'/

SUB act_auto CDECL ALIAS "act_auto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_auto")

END SUB
