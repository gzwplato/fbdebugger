/'* \file multi_action.bas
\brief Signal handlers for actions that poxies more than one widgets

\since 3.0
'/


SUB act_runto CDECL ALIAS "act_runto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_runto"

END SUB


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


SUB act_step_over CDECL ALIAS "act_step_over" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_step_over"

END SUB


SUB act_step_out CDECL ALIAS "act_step_out" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_step_out"

END SUB


SUB act_step_start CDECL ALIAS "act_step_start" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_step_start"

END SUB


SUB act_step_end CDECL ALIAS "act_step_end" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_step_end"

END SUB


SUB act_run CDECL ALIAS "act_run" ( _
  BYVAL button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_run"

END SUB


SUB act_fastrun CDECL ALIAS "act_fastrun" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_fastrun"

END SUB


SUB act_stop CDECL ALIAS "act_stop" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_stop"

END SUB


SUB act_kill CDECL ALIAS "act_kill" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_kill"

END SUB


SUB act_auto CDECL ALIAS "act_auto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_auto"

END SUB


SUB act_automulti CDECL ALIAS "act_automulti" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_automulti, ToDo: insert code"

END SUB


SUB act_exemod CDECL ALIAS "act_exemod" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?"callback act_exemod"

END SUB


SUB act_vardump CDECL ALIAS "act_vardump" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_vardump, ToDo: insert code"

END SUB


SUB act_varedit CDECL ALIAS "act_varedit" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_varedit, ToDo: insert code"

END SUB


'??? same as action 116 ???
SUB act_varexpand CDECL ALIAS "act_varexpand" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_varexpand, ToDo: insert code"

END SUB


SUB act_stringshow CDECL ALIAS "act_stringshow" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_stringshow, ToDo: insert code"

END SUB


'' act_Shortcut in shortcuts.bas


SUB act_procbacktrack CDECL ALIAS "act_procbacktrack" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_procbacktrack, ToDo: insert code"

END SUB


SUB act_procchain CDECL ALIAS "act_procchain" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_procchain, ToDo: insert code"

END SUB


SUB act_procasm CDECL ALIAS "act_procasm" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?"--> callback act_procasm, ToDo: insert code"

END SUB
