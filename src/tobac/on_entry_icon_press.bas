' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< Signal handler generated by utility                       GladeToBac V3.4.1 >
'< Signal-Modul erzeugt von                                                    >
'< Generated at / Generierung am                             2015-01-26, 19:45 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: main.bas                                           >
'< Author:  SARG, AGS, TJF                                                     >
'<  Email:  Thomas.Freiherr@gmx.net                                            >
' -----------------------------------------------------------------------------
'< callback SUB/FUNCTION                                          insert code! >
'< Ereignis Unterprogramm/Funktion                        Quelltext einfuegen! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
SUB on_entry_icon_press CDECL ALIAS "on_entry_icon_press" ( _
  BYVAL entry AS GtkEntry PTR, _
  BYVAL icon_pos AS GtkEntryIconPosition, _
  BYVAL event AS GdkEvent PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?*__("--> callback on_entry_icon_press")

END SUB
