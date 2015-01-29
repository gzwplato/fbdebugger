/'* \file act_runto.bas
\brief Signal handler for a GtkAction (id="action001")

\since 3.0
'/

SUB act_runto CDECL ALIAS "act_runto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_runto")

END SUB
