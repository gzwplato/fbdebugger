/'* \file act_Shortcut.bas
\brief Signal handler for a GtkAction (id="action024")

This file contains the signal handler for the shortcut key edit and
some auxiliary code to handle the context of the list window.

\	odo We should set meaningful names for the accell paths of the
      actions in the ui file, like fbdbg/main/shortcuts.

\	odo Decide if we store shortcuts in the ini file or in a separate one
      (as is currently).

\since 3.0
'/


'* The file name for the shortcut keylist
#DEFINE ACCELL_FILE "dat/accelerators.rc"

/'* \brief Populate the list of shortcuts (GFunc callback)
\param Act The GtkAction to handle
\param Store The GtkListStore to use

The callback gets called by g_list_foreach() on all GtkActions in
'actiongroup1'. It gets the shortcut and reads the label and the
tooltip to store that context in the list. A hidden column (4) is used
to store the accell path for easy evaluation.

'/
SUB populateShortcuts CDECL(BYVAL Act AS gpointer, BYVAL Store AS gpointer)
  STATIC AS GtkTreeIter iter
  STATIC AS GtkAccelKey acck

  VAR action = GTK_ACTION(Act)
  VAR accel_path = gtk_action_get_accel_path(action)
  IF 0 = accel_path ORELSE _
     0 = gtk_accel_map_lookup_entry(accel_path, @acck) THEN EXIT SUB

  gtk_list_store_append(Store, @iter)
  gtk_list_store_set(Store, @iter _
    , 0, acck.accel_key _
    , 1, acck.accel_mods _
    , 2, gtk_action_get_label(action) _ '       don't free this and next
    , 3, gtk_action_get_tooltip(action) _
    , 4, accel_path _
    , -1) '                                    parameter list terminator
END SUB


/'* \brief Evaluate the list of shortcuts (GFunc callback)
\param Tree The tree model to get the data
\param Path The path (unused)
\param Iter The tree model iter where to read from
\param user_data unused

The callback gets called by gtk_tree_model_foreach() on all members of
the list store. It gets a current shortcut setting and changes its
entry in the GtkAccelMap.

'/
FUNCTION evaluateShortcuts CDECL( _
  BYVAL Tree AS GtkTreeModel PTR _
, BYVAL Path AS GtkTreePath PTR _
, BYVAL Iter AS GtkTreeIter PTR _
, BYVAL user_data AS gpointer) AS gboolean

  DIM AS gpointer accel_path
  DIM AS guint accel_key, accel_mods
  gtk_tree_model_get(Tree, Iter _
    , 0, @accel_key _
    , 1, @accel_mods _
    , 4, @accel_path _
    , -1) '                                    parameter list terminator
  gtk_accel_map_change_entry(accel_path, accel_key, accel_mods, TRUE)

  RETURN FALSE
END FUNCTION


/'* \brief Populate or evaluate the shortcuts dialog
\param Mo The modus (0 = read, 1 = write)

Handle the data in the shortcuts dialog. The SUB either

- reads the dialog data and sets the parameter variables for the ini
  file, or

- sets the dialog to ini file parameter variables

When called first, the widgets get searched in the GUI description file.

'/
SUB ShortcutsForm(BYVAL Mo AS gint = 1)
  STATIC AS GObject PTR actgrp
  STATIC AS GtkListStore PTR store

  IF 0 = store THEN
    VAR xml = GUI.XML '         initial get objects from GUI description
      store = GTK_LIST_STORE(gtk_builder_get_object(xml, "liststore600"))
     actgrp = gtk_builder_get_object(xml, "actiongroup1")
  END IF

  SELECT CASE AS CONST Mo
  CASE 0 '                                          evaluate from dialog
    gtk_tree_model_foreach(GTK_TREE_MODEL(store), @evaluateShortcuts, NULL)
    gtk_accel_map_save(ACCELL_FILE)
  CASE ELSE '                                        populate the dialog
    gtk_accel_map_load(ACCELL_FILE)
    gtk_list_store_clear(store)
    VAR list = gtk_action_group_list_actions(GTK_ACTION_GROUP(actgrp))
    g_list_foreach(list, @populateShortcuts, store)
    g_list_free(list)
  END SELECT
END SUB


/'* \brief Run the shortcuts dialog (GtkAction id="action024")
\param Action The GtkAction that triggered the signal
\param Dialog The GtkWidget PTR of the dialog window

This signal handler shows the settings dialog in modal mode. Depending
on the user action it either cancels all changes or reads the new data.

\todo Decide if we need a help button.

'/
SUB act_Shortcut CDECL ALIAS "act_Shortcut" ( _
  BYVAL Action AS GtkAction PTR, _
  BYVAL Dialog AS gpointer) EXPORT

var r = gtk_dialog_run(Dialog)
?*__("--> callback act_Shortcut"),r

  'SELECT CASE AS CONST gtk_dialog_run(Dialog)
  SELECT CASE AS CONST r
    CASE 0
      ?*__("callback act_Shortcut -> get changed settings")
      ShortcutsForm(0) ' load from form
    CASE ELSE
      ?*__("callback act_Shortcut -> dialog canceled, restore form")
      ShortcutsForm(1) ' restore form, because user canceled
  END SELECT
  gtk_widget_hide(Dialog)

END SUB

' Here we initialize the dialog context (before starting the main window)
ShortcutsForm()
