/'* \file act_step.bas
\brief Signal handler for FIXME

\since 3.0
'/

SUB act_step CDECL ALIAS "act_step" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_step, ToDo: insert code"

access_viol( _
    222 _
  , "D:\a\b\c\d\debuggee.bas" _
  , "TEST" _
  , 279 _
  , "Print ""Line with crash"": Poke testa, 10 'for access violation" _ _
  )

END SUB
