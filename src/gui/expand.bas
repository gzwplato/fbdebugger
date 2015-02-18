/'* \file log_notes.bas
\brief Functions to handle the non-modal dialogs with text views.

This file contains code to handle non-modal dialog windows with text
view widgets, used for

- screen log
- file log
- notes

\since 3.0
'/


'' example code to fill a list store
SUB fillExpandTree cdecl(BYVAL Store as GtkTreeStore ptr, byval Dat as gpointer)
  DIM AS ZSTRING PTR entries(...) = { _ '                 some rows data
    @"--> PUDT1 <* UDT1>=0" _
  , @"A < Integer> No valid value" _
  , @"B <UDT2>" _
  , @"A2  [ 0-5 ] <TYPE>" _
  , @"AAA <Integer>=0 " _
  , @"BBB <Ulongint>=0" _
  , @"B2 <EENUM>=0 >> Unknown Enum value" _
  , @"C2 <* Integer>=0" _
  , @"<Integer>=0" _
  , @"D2 <* EENUM>=0" _
  , @"<EENUM>=0 >> Unknown Enum value" _
  , @"C <Ushort>=0" _
  }

  DIM AS GtkTreeIter iter(3) '               iterators, four levels here

  gtk_tree_store_clear(Store) '                          empty the Store

  gtk_tree_store_append(Store, @iter(0), NULL) '                 level 0
  gtk_tree_store_set(Store, @iter(0), 0, entries(0), -1)

  gtk_tree_store_append(Store, @iter(1), @iter(0)) '             level 1
  gtk_tree_store_set(Store, @iter(1), 0, entries(1), -1)

  gtk_tree_store_append(Store, @iter(1), @iter(0)) '             level 1
  gtk_tree_store_set(Store, @iter(1), 0, entries(2), -1)

  gtk_tree_store_append(Store, @iter(2), @iter(1)) '             level 2
  gtk_tree_store_set(Store, @iter(2), 0, entries(3), -1)

  gtk_tree_store_append(Store, @iter(3), @iter(2)) '             level 3
  gtk_tree_store_set(Store, @iter(3), 0, entries(4), -1)

  gtk_tree_store_append(Store, @iter(3), @iter(2)) '             level 3
  gtk_tree_store_set(Store, @iter(3), 0, entries(5), -1)

  gtk_tree_store_append(Store, @iter(2), @iter(1)) '             level 2
  gtk_tree_store_set(Store, @iter(2), 0, entries(6), -1)

  gtk_tree_store_append(Store, @iter(2), @iter(1)) '             level 2
  gtk_tree_store_set(Store, @iter(2), 0, entries(6), -1)

  gtk_tree_store_append(Store, @iter(3), @iter(2)) '             level 3
  gtk_tree_store_set(Store, @iter(3), 0, entries(7), -1)

  gtk_tree_store_append(Store, @iter(3), @iter(2)) '             level 3
  gtk_tree_store_set(Store, @iter(3), 0, entries(8), -1)

  gtk_tree_store_append(Store, @iter(2), @iter(1)) '             level 2
  gtk_tree_store_set(Store, @iter(2), 0, entries(9), -1)

  gtk_tree_store_append(Store, @iter(3), @iter(2)) '             level 3
  gtk_tree_store_set(Store, @iter(3), 0, entries(10), -1)

  gtk_tree_store_append(Store, @iter(1), @iter(0)) '             level 1
  gtk_tree_store_set(Store, @iter(1), 0, entries(11), -1)
END SUB


'TYPE as SUB cdecl(byval as gpointer) G_FUNC
'#define G_FUNC(_V_) cast(SUB cdecl(byval as gpointer), _V_)

TYPE ExpandUdt
  AS STRING Xml
  as GSList PTR List = NULL

  declare CONSTRUCTOR()
  declare sub addXpd(as SUB CDECL(BYVAL as GtkTreeStore ptr, byval as gpointer), byval as gpointer)
  declare sub destroyAll()
END TYPE

CONSTRUCTOR ExpandUdt()
  VAR fnam = "expand.ui", fnr = FREEFILE
  IF OPEN(fnam FOR INPUT AS fnr) THEN
    ?PROJ_NAME & ": Cannot open " & fnam : end 1
    'g_error("Cannot open " & fnam)
  ELSE
    Xml = string(lof(fnr), 0)
    get #fnr, , Xml
    CLOSE #fnr
  END IF
END CONSTRUCTOR


SUB ExpandUdt.destroyAll()
  'g_slist_foreach(List, G_FUNC(@gtk_widget_destroy), NULL)
END SUB

declare SUB on_expand_destroyed CDECL ( _
  BYVAL AS GtkWidget PTR, _
  BYVAL AS gpointer)

SUB ExpandUdt.addXpd( _
    FillStore as SUB CDECL(BYVAL as GtkTreeStore ptr, byval as gpointer) _
  , byval Dat as gpointer)

  VAR build = gtk_builder_new()
  DIM AS GError PTR meld
  IF 0 = gtk_builder_add_from_string(build, Xml, LEN(Xml), @meld) THEN
    WITH *meld
      ?"Fehler/Error (GTK-Builder in ExpandUdt.Notes):"
      ?*.message
    END WITH
    g_error_free(meld)
    END 2
  END IF
  var dia = gtk_builder_get_object(build, "window1")
  var gtv = gtk_builder_get_object(build, "tviewExpand")
  var store = gtk_builder_get_object(build, "tstoreExpand")
  gtk_builder_connect_signals(build, 0)
  g_object_unref(build)

  g_signal_connect(dia, "destroy" _
                 , G_CALLBACK(@on_expand_destroyed), gtv)

  gtk_window_set_title(GTK_WINDOW(dia), "Expand")
  FillStore(GTK_TREE_STORE(store), Dat)
  gtk_tree_view_expand_all(GTK_TREE_VIEW(gtv))

  List = g_slist_prepend(List, gtv)
END SUB

'* \brief The global class to handle expand windows
DIM SHARED AS ExpandUdt PTR XPD



SUB on_expand_destroyed CDECL ALIAS "on_expand_destroyed" ( _
  BYVAL Dia AS GtkWidget PTR, _
  BYVAL Gtv AS gpointer) EXPORT

?" --> callback on_expand_destroyed"
  XPD->List = g_slist_remove(XPD->List, Gtv)
END SUB


SUB exp_watched_clicked CDECL ALIAS "exp_watched_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_watched_clicked"

END SUB


SUB exp_dump_clicked CDECL ALIAS "exp_dump_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_dump_clicked"

END SUB


SUB exp_edit_clicked CDECL ALIAS "exp_edit_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_edit_clicked"

END SUB


SUB exp_show_clicked CDECL ALIAS "exp_show_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_show_clicked"

END SUB


SUB exp_new_clicked CDECL ALIAS "exp_new_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_new_clicked"
  XPD->addXpd(@fillExpandTree, NULL)

END SUB


SUB exp_replace_clicked CDECL ALIAS "exp_replace_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_replace_clicked"

END SUB


SUB exp_delta_m_clicked CDECL ALIAS "exp_delta_m_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_delta_m_clicked"

END SUB


SUB exp_delta_p_clicked CDECL ALIAS "exp_delta_p_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_delta_p_clicked"

END SUB


SUB exp_delta_set_clicked CDECL ALIAS "exp_delta_set_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_delta_set_clicked"

END SUB


SUB exp_close_clicked CDECL ALIAS "exp_close_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_close_clicked"

END SUB


SUB exp_arrange_clicked CDECL ALIAS "exp_arrange_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_arrange_clicked"

END SUB


SUB exp_about_clicked CDECL ALIAS "exp_about_clicked" ( _
  BYVAL Button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback exp_about_clicked"

END SUB
