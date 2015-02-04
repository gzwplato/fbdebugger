
' here we call SUBs / FUNCTIONs from the core part
core1_sub(__FILE__)
?"==> result: " ;core2_func(__FILE__)

' here's how to set the texts in the status bar
WITH GUI
  gtk_label_set_text(GTK_LABEL(.sbarlab1), "Waiting")
  gtk_label_set_text(GTK_LABEL(.sbarlab2), "Thread")
  gtk_label_set_text(GTK_LABEL(.sbarlab3), "Module")
  gtk_label_set_text(GTK_LABEL(.sbarlab4), "Proc")
  gtk_label_set_text(GTK_LABEL(.sbarlab5), "Timer")
END WITH


' here's how to set the texts in the watch bar
WITH GUI
  gtk_label_set_text(GTK_LABEL(.watch1), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch2), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch3), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch4), "< empty >")
END WITH


' here's how to set the texts in combo box
scope
  var box = GTK_COMBO_BOX_TEXT(GUI.comboBookmarks)
  gtk_combo_box_text_insert(box, -1, "0", "BMK --> testthread.bas[10] Print ""yes and then... valeur origine="";p")
  gtk_combo_box_text_insert(box, -1, "1", "BMK --> testthread.bas[21] ""c=""test (""+Str(b)+""+Str(i)")
  gtk_combo_box_text_insert(box, -1, "SARG", "BMK --> testthread.bas[24] j+=1")
  g_object_set(GUI.comboBookmarks, "active-id", "SARG", NULL)
end scope


' here's how to set the source view, font and language for syntax highlighting
scope
  var buff = GTK_TEXT_BUFFER(GUI.srcbuff)
  ' load a file and set the text buffer
  VAR fnr = FREEFILE
  IF 0 = OPEN(__FILE__ FOR INPUT AS fnr) THEN
    VAR l = LOF(fnr)
    IF l <= G_MAXINT THEN
      VAR t = STRING(l, 0)
      GET #fnr, , t
      CLOSE #fnr

      gtk_text_buffer_set_text(buff, t, l)
    END IF
  END IF

'' scroll to a certain line
  dim as GtkTextIter iter
  gtk_text_buffer_get_iter_at_line(buff, @iter, 150)
  var mark = gtk_text_mark_new("curr line", TRUE)
  gtk_text_buffer_add_mark(buff, mark, @iter)
  gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(GUI.srcview), mark, 0.0, TRUE, 0.0, 0.05)
  g_object_unref(mark)

'' change the font
  VAR pf = pango_font_description_from_string(@"monospace 8")
  gtk_widget_override_font(GTK_WIDGET(GUI.srcview), pf)
  gtk_widget_override_font(GTK_WIDGET(GUI.srcviewCur), pf)
  pango_font_description_free(pf)
  'gtk_widget_get_pango_context(GTK_WIDGET(GUI.srcview))

'' set syntax highlighting
  var lm = gtk_source_language_manager_get_default()
  var sl = gtk_source_language_manager_get_language(lm, "fbc")
  if 0 = sl then
    ?PROJ_NAME & ": language fbc not available -> no syntax highlighting"
  else
    var sb = GTKSOURCE_SOURCE_BUFFER(GUI.srcbuff)
    gtk_source_buffer_set_language(sb, sl)

    sb = GTKSOURCE_SOURCE_BUFFER(GUI.srcbuffCur)
    gtk_source_buffer_set_language(sb, sl)
  end if
end scope

scope
  'var pc = gtk_widget_get_pango_context(GTK_WIDGET(GUI.nbook2))
  var pc = gtk_widget_get_pango_context(GTK_WIDGET(GUI.tviewThreads))
  var fd = pango_context_get_font_description(pc)
  var size = pango_font_description_get_size(fd)

?"HIER: ";size
'?*pango_font_family_get_name(fd)

pango_font_description_set_size(fd, size * 1.5)
end scope

' here's an example on how to populate tree stores
scope
  dim as zstring ptr entries(...) = { _ '                 some rows data
    @"Globals(shared/common in : main" _
  , @"NS : TESTNAMES.XX < Shared / Integer >" _
  , @"VENUM <Shared /EENMU>=0 >> Unknowm" _
  , @"PUDT1 <Shared / * UDT>=0" _
  , @"ThID=3012 main:Integer" _
  , @"__FB_ARGC__ <Byval param / Long>=0" _
  , @"__FB_ARGV__ <Byval param / Long>=0" _
  }

  dim as GtkTreeIter iter(1) '                iterators, two levels here
  dim as GObject PTR stores(...) = { _ '          all stores we populate
      GUI.tstoreProcVar _
    , GUI.tstoreProcs _
    , GUI.tstoreThreads _
    , GUI.tstoreWatch _
    }

  FOR i AS INTEGER = 0 TO ubound(stores)
    var store = GTK_TREE_STORE(stores(i))
    gtk_tree_store_clear(store) '                        empty the store

    gtk_tree_store_append(store, @iter(0), NULL) '              level 0
    gtk_tree_store_set(store, @iter(0), 0, entries(0), -1)

    gtk_tree_store_append(store, @iter(1), @iter(0)) '          level 1
    gtk_tree_store_set(store, @iter(1), 0, entries(1), -1)

    gtk_tree_store_append(store, @iter(1), @iter(0)) '          level 1
    gtk_tree_store_set(store, @iter(1), 0, entries(2), -1)

    gtk_tree_store_append(store, @iter(1), @iter(0)) '          level 1
    gtk_tree_store_set(store, @iter(1), 0, entries(3), -1)

    gtk_tree_store_append(store, @iter(0), NULL) '              level 0
    gtk_tree_store_set(store, @iter(0), 0, entries(4), -1)

    gtk_tree_store_append(store, @iter(1), @iter(0)) '          level 1
    gtk_tree_store_set(store, @iter(1), 0, entries(5), -1)

    gtk_tree_store_append(store, @iter(1), @iter(0)) '          level 1
    gtk_tree_store_set(store, @iter(1), 0, entries(6), -1)
  NEXT


  ' GtkTreeViews are collapsed by default.

  ' example: expand all sublevels of the tree view
  gtk_tree_view_expand_all(GTK_TREE_VIEW(GUI.tviewProcVar))
  gtk_tree_view_expand_all(GTK_TREE_VIEW(GUI.tviewProcs))

  ' example: expand to a certain row of the tree view
  var path = gtk_tree_path_new_from_string("0:2")
  gtk_tree_view_expand_to_path(GTK_TREE_VIEW(GUI.tviewWatch), path)
  gtk_tree_path_free(path)

  var model = GTK_TREE_MODEL(stores(1))
  var store = GTK_TREE_STORE(stores(1))

  gtk_tree_model_get_iter_from_string(model, @iter(0), "0:1")
  gtk_tree_store_set(store, @iter(0), 1, TRUE, -1)

  gtk_tree_model_get_iter_from_string(model, @iter(0), "1")
  gtk_tree_store_set(store, @iter(0), 1, TRUE, -1)

  gtk_tree_model_get_iter_from_string(model, @iter(0), "1:0")
  gtk_tree_store_set(store, @iter(0), 1, TRUE, -1)
end scope

scope
  'var path = gtk_tree_path_new_from_string("0:2")

  'FOR i AS INTEGER = 0 TO ubound(entries)

  'NEXT
  'gtk_tree_path_free(path)
end scope


' here's an example on how to populate the list store(Memory dump)

/'*\brief Function to set columns visible in the treeview
\param P The pointer to the GtkTreeViewColoumn object
\param D The number of columns to show (+ index column)

Makes a column visible if the sort column number is smaller or equal to
the sort column number, otherwise unvisible.

'/
SUB list_column_visible CDECL(BYVAL P AS gpointer, BYVAL D AS gpointer)
  DIM AS gint i
  g_object_get(P, "sort-column-id", @i, NULL)
  g_object_set(P, "visible", IIF(i <= D, TRUE, FALSE), NULL)
END SUB

SCOPE
  ' choose visible columns
  VAR list = gtk_tree_view_get_columns(GTK_TREE_VIEW(GUI.lviewMemory))
  g_list_foreach(list, @list_column_visible, CAST(gpointer, 8)) ' <= no of columns (1 to 16)
  g_list_free(list)

  ' populate the list store
  VAR store = GTK_LIST_STORE(GUI.lstoreMemory)
  gtk_list_store_clear(store) '                          empty the store
  DIM AS GtkTreeIter iter '       one iterator, list store has one level
  FOR r AS LONG = 0 TO 15 '                                     all rows
    VAR t = r * 16

    gtk_list_store_append(store, @iter)
    gtk_list_store_set(store, @iter _
      , 0, STR(r) _ '  column 0=index, only once if index doesn't change
      , 1, HEX(t) _ '                                           cloumn 1
      , 2, HEX(t + 1) _ '                                       cloumn 2
      , 3, HEX(t + 2) _'                                             ...
      , 4, HEX(t + 3) _
      , 5, HEX(t + 4) _
      , 6, HEX(t + 5) _
      , 7, HEX(t + 6) _
      , 8, HEX(t + 7) _
      , -1) '                                  parameter list terminator
  NEXT
END SCOPE

