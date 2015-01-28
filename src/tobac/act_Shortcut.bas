' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< Signal handler generated by utility                       GladeToBac V3.4.1 >
'< Signal-Modul erzeugt von                                                    >
'< Generated at / Generierung am                             2015-01-27, 19:24 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: main.bas                                           >
'< Author:  SARG, AGS, TJF                                                     >
'<  Email:  Thomas.Freiherr@gmx.net                                            >
' -----------------------------------------------------------------------------
'< callback SUB/FUNCTION                                          insert code! >
'< Ereignis Unterprogramm/Funktion                        Quelltext einfuegen! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

SUB populateShortcuts(BYVAL P as gpointer, BYVAL Store as gpointer)
  static as GtkTreeIter iter
  static as GtkAccelKey acck

  var action = GTK_ACTION(P)
  var accel_path = gtk_action_get_accel_path(action)
'?*accel_path
  if 0 = accel_path orelse _
     0 = gtk_accel_map_lookup_entry(accel_path, @acck) then exit sub

  var k = gtk_action_get_accel_closure(action)
  var label = gtk_action_get_label(action)
  var toolt = gtk_action_get_tooltip(action)
'?*label, *toolt

'dim as guint k = 50, m = GDK_CONTROL_MASK

  gtk_list_store_append(Store, @iter)
  gtk_list_store_set(Store, @iter _
    , 0, acck.accel_key _
    , 1, acck.accel_mods _
    , 2, label _
    , 3, toolt _
    , -1) '                                  parameter list terminator

END SUB

SUB ShortcutsForm(BYVAL Mo AS gint = 1)
  static as GObject PTR _
    actgrp _
  , liststore

  IF 0 = liststore THEN '       initial get objects from GUI description
    VAR xml = GUI_MAIN.XML
         liststore = gtk_builder_get_object(xml, "liststore600")
         actgrp = gtk_builder_get_object(xml, "actiongroup1")

    var list = gtk_action_group_list_actions(GTK_ACTION_GROUP(actgrp))
    var store = GTK_LIST_STORE(liststore)
    gtk_list_store_clear(store)
    g_list_foreach(list, @populateShortcuts, store)
    g_list_free(list)
  end if

  SELECT CASE AS CONST Mo
  CASE 0 '                                                load from form
  CASE ELSE '                                                set to form
  END SELECT

END SUB

SUB act_Shortcut CDECL ALIAS "act_Shortcut" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?*__("--> callback act_Shortcut")
  SELECT CASE AS CONST gtk_dialog_run(user_data)
    CASE 0
      ?*__("callback act_Shortcut -> get changed settings")
      ShortcutsForm(0) ' load from form
    CASE 1
      ?*__("callback act_Shortcut -> dialog canceled, restore form")
      ShortcutsForm(1) ' restore form, because user canceled

  ' CASE ... further dialog actions, ie. a Help button
  END SELECT
  gtk_widget_hide(user_data)

END SUB
