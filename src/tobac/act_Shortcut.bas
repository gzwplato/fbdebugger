/'* \file act_Shortcut.bas
\brief Signal handler for a GtkAction (id="action464")

This file contains the signal handler and some auxiliary code.

\since 3.0
'/



/'* \brief Populate the list of shortcuts (GFunc callback)
\param P The GtkAction to handle
\param Store The GtkListStore to use

The callback gets called by g_list_foreach() on all GtkActions in
'actiongroup1'. It gets the shortcut and reads the label and the
tooltip to store that context in the list.

'/
SUB populateShortcuts CDECL(BYVAL P AS gpointer, BYVAL Store AS gpointer)
  STATIC AS GtkTreeIter iter
  STATIC AS GtkAccelKey acck

  VAR action = GTK_ACTION(P)
  VAR accel_path = gtk_action_get_accel_path(action)
  IF 0 = accel_path ORELSE _
     0 = gtk_accel_map_lookup_entry(accel_path, @acck) THEN EXIT SUB

  gtk_list_store_append(Store, @iter)
  gtk_list_store_set(Store, @iter _
    , 0, acck.accel_key _
    , 1, acck.accel_mods _
    , 2, gtk_action_get_label(action) _ '       don't free this and next
    , 3, gtk_action_get_tooltip(action) _
    , 4, action _
    , -1) '                                    parameter list terminator
END SUB


/'* \brief Evaluate the list of shortcuts (GFunc callback)
\param P The GtkAction to handle
\param Store The GtkListStore to use

The callback gets called by g_list_foreach() on all GtkActions in
'actiongroup1'. It gets the shortcut and reads the label and the
tooltip to store that context in the list.

'/
'FUNCTION evaluateShortcuts AS FUNCTION CDECL(
  'BYVAL Tree AS GtkTreeModel PTR _
', BYVAL Path AS GtkTreePath PTR _
', BYVAL Iter AS GtkTreeIter PTR _
', BYVAL user_data AS gpointer) AS gboolean

  'dim as guint accel_key, accel_mods
  'gtk_tree_model_get(Tree, Iter, _
    ', 0, accel_key _
    ', 1, accel_mods _
    ', -1) '                                    parameter list terminator
  'gtk_action_set

  'RETURN FALSE
'END FUNCTION

  'gtk_tree_model_get(Store, @iter _
    ', 0, acck.accel_key _
    ', 1, acck.accel_mods _
    ', 2, gtk_action_get_label(action) _ '       don't free this and next
    ', 3, gtk_action_get_tooltip(action) _
    ', -1) '                                    parameter list terminator
  'gtk_accel_map_change_entry (const gchar *accel_path,
                            'guint accel_key,
                            'GdkModifierType accel_mods,
                            'gboolean replace);
'END SUB



/'* \brief Populate or evaluate the shortcuts dialog
\param Mo The modus (0 = read, 1 = write)

Handle the data in the shortcuts dialog. The SUB either

- reads the dialog data and sets the parameter variables for the ini
  file, or

- sets the dialog to ini file parameter variables

When called first, the widgets get searched in the GUI description file.

\note We may add an invisible column to the list store in order to make
      it easy finding the matching variables (ini file).

'/
SUB ShortcutsForm(BYVAL Mo AS gint = 1)
  STATIC AS GObject PTR actgrp
  STATIC AS GtkListStore PTR store

  IF 0 = store THEN
    VAR xml = GUI_MAIN.XML '    initial get objects from GUI description
       store = GTK_LIST_STORE(gtk_builder_get_object(xml, "liststore600"))
      actgrp = gtk_builder_get_object(xml, "actiongroup1")
    gtk_accel_map_load("accels.tst") '                    load shortcuts
  END IF

  SELECT CASE AS CONST Mo
  CASE 0 '                                                load from form
    ' place the code to read from dialog
    'gtk_tree_model_foreach(GTK_TREE_MODEL(store), @evaluateShortcuts, NULL)
  CASE ELSE '                                                set to form
    VAR list = gtk_action_group_list_actions(GTK_ACTION_GROUP(actgrp))
    gtk_list_store_clear(store)
    g_list_foreach(list, @populateShortcuts, store)
    g_list_free(list)
  END SELECT
END SUB


/'* \brief Run the shortcuts dialog (GtkAction id="action024")
\param action The GtkAction that triggered the signal
\param user_data The GtkWidget PTR of the dialog window

This signal handler shows the settings dialog in modal mode. Depending
on the user action it either cancels all changes or reads the new data.

'/
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
