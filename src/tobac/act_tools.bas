' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< Signal handler generated by utility                         GladeToBac V3.4 >
'< Signal-Modul erzeugt von                                                    >
'< Generated at / Generierung am                             2015-01-22, 19:21 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: main.bas                                           >
'< Author:  SARG, AGS, TJF                                                     >
'<  Email:  Thomas.Freiherr@gmx.net                                            >
' -----------------------------------------------------------------------------
'< callback SUB/FUNCTION                                          insert code! >
'< Ereignis Unterprogramm/Funktion                        Quelltext einfuegen! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
SUB act_tools CDECL ALIAS "act_tools" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("callback act_tools")
  var tim = gtk_get_current_event_time()
  gtk_menu_popup(user_data, NULL, NULL, NULL, NULL, 1, tim)

END SUB
