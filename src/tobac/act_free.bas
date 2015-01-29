/'* \file act_free.bas
\brief Signal handler for a GtkAction (id="action460")

\since 3.0
'/

SUB act_free CDECL ALIAS "act_free" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_free")

END SUB
