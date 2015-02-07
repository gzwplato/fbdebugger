/'* \file shortcuts.bas
\brief Signal handler for a GtkAction (id="action024")

This file contains the code to handle the shortcut key list and edit
dialog and some auxiliary code. Shortcuts are stored in file
*dat/accelerators.rc*.

The actions in file fbdbg.ui are grouped after their appereance

- action0xx = actions that proxies multiple widgets
- action1xx = actions in menue100 = ProcVar
- action2xx = actions in menue200 = Procs
- action3xx = actions in menue300 = Watched
- action4xx = actions in menue400 = Source + toolbar
- action5xx = actions in menue500 = Threads
- action9xx = actions in menue900 = tools

\todo Decide if we store shortcuts in the ini file or in a separate one
      (as is currently in dat/accelerators.rc).

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

  IF 0 = accel_path THEN                                        EXIT SUB
  if 0 = gtk_accel_map_lookup_entry(accel_path, @acck) _
    then gtk_accel_map_add_entry(accel_path, 0, 0)

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
  STATIC AS GtkListStore PTR store
  STATIC AS GObject PTR actgrp

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

?*__("--> callback act_Shortcut")

  SELECT CASE AS CONST gtk_dialog_run(Dialog)
    CASE 0
?*__("callback act_Shortcut -> get changed settings")
      ShortcutsForm(0) ' load from form
    CASE ELSE
?*__("callback act_Shortcut -> dialog canceled, restore form")
      ShortcutsForm(1) ' restore form, because user canceled
  END SELECT
  gtk_widget_hide(Dialog)

END SUB


/'* \brief Signal handler for clearing a GtkCellRendererAccel (id="cellrendereraccel601")
\param accel The widget that triggers the signal (unused)
\param PathString The path in the GtkTreeModel
\param Store The GtkListStore where to change the data (user_data)

This signal handler gets called when the user cleared a keyboard
shortcut in the shortcuts dialog (by pressing backspace key). It
up-dates the data in the related list store.

'/
SUB on_accel_cleared CDECL ALIAS "on_accel_cleared" ( _
  BYVAL Accel AS GtkCellRendererAccel PTR, _
  BYVAL PathString AS gchar PTR, _
  BYVAL Store AS gpointer) EXPORT

  DIM AS GtkTreeIter iter
  VAR model = GTK_TREE_MODEL(Store)
  gtk_tree_model_get_iter_from_string(model, @iter, PathString)
  gtk_list_store_set(Store, @iter _
    , 0, CAST(guint, 0) _
    , 1, CAST(guint, 0) _
    , -1) '                                    parameter list terminator

END SUB


/'* \brief Signal handler for editing a GtkCellRendererAccel (id="cellrendereraccel601")
\param Accel The widget that triggers the signal (unused)
\param PathString The path in the GtkTreeModel
\param AccelKey The key number of the shortcut
\param AccelMods The modifier mask (GdkModifierType)
\param HardwareKeycode A hardware keycode (unused)
\param Store The GtkListStore where to change the data (user_data)

This signal handler gets called when the user edited a keyboard
shortcut in the shortcuts dialog. It checks for double-tees and
up-dates the data in the related list store.

\todo Decide if warning (no modifiers) should be used

'/
SUB on_accel_edited CDECL ALIAS "on_accel_edited" ( _
    BYVAL Accel AS GtkCellRendererAccel PTR _
  , BYVAL PathString AS gchar PTR _
  , BYVAL AccelKey AS guint _
  , BYVAL AccelMods AS GdkModifierType _
  , BYVAL HardwareKeycode AS guint _
  , BYVAL Store AS gpointer) EXPORT

  VAR model = GTK_TREE_MODEL(Store)

  DIM AS guint k, m
  DIM AS GtkTreeIter search
  IF gtk_tree_model_get_iter_first(model, @search) THEN
    DO
      gtk_tree_model_get(model, @search, 0, @k, 1, @m, -1)
      IF k <> AccelKey ORELSE m <> AccelMods THEN            CONTINUE DO

      DIM AS gchar PTR txt
      gtk_tree_model_get(model, @search, 2, @txt, -1)
      VAR dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
        , GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
        , GTK_MESSAGE_QUESTION _
        , GTK_BUTTONS_YES_NO _
        , ( _
          *__(!"Shortcut already defined for\n\n") _
        & *__(!"<b>%s</b>\n\n") _
        & *__(!"Override existing\n") _
        ) _
        , txt _
        , NULL)
      g_free(txt)

      VAR r = gtk_dialog_run(GTK_DIALOG(dia))
      gtk_widget_destroy(dia) : IF r <> GTK_RESPONSE_YES THEN   EXIT SUB
      gtk_list_store_set(Store, @search _
        , 0, CAST(guint, 0) _
        , 1, CAST(guint, 0) _
        , -1) :                                                  EXIT DO
    LOOP UNTIL 0 = gtk_tree_model_iter_next(model, @search)
  END IF

  IF 0 = AccelMods THEN '                          shall we use this ???
    VAR dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
      , GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
      , GTK_MESSAGE_QUESTION _
      , GTK_BUTTONS_YES_NO _
      , ( _
        *__(!"Shortcut has no modifier\n\n") _
      & *__(!"This interferes with the search\n") _
      & *__(!"function in the tree views\n\n") _
      & *__(!"Anyway, use it ...") _
      ) _
      , NULL)

    VAR r = gtk_dialog_run(GTK_DIALOG(dia))
    gtk_widget_destroy(dia) : IF r <> GTK_RESPONSE_YES THEN     EXIT SUB
  END IF

  DIM AS GtkTreeIter iter
  gtk_tree_model_get_iter_from_string(model, @iter, PathString)
  gtk_list_store_set(Store, @iter _
    , 0, AccelKey _
    , 1, AccelMods _
    , -1)
END SUB


' Here we initialize the dialog context (before starting the main window)
ShortcutsForm()
