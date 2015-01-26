scope
var lm = gtk_source_language_manager_get_default()
?"lm: ";lm
var sl = gtk_source_language_manager_get_language(lm, "fbc")
?"sl: ";sl
var sb = GTKSOURCE_SOURCE_BUFFER(GUI_MAIN.srcbuff)
?"sb: ";sb
gtk_source_buffer_set_language(sb, sl)

sb = GTKSOURCE_SOURCE_BUFFER(GUI_MAIN.srcbuffCur)
?"sb: ";sb
gtk_source_buffer_set_language(sb, sl)

VAR pf = pango_font_description_from_string(@"monospace 8")
gtk_widget_modify_font(GTK_WIDGET(GUI_MAIN.srcview), pf)
gtk_widget_modify_font(GTK_WIDGET(GUI_MAIN.srcviewCur), pf)
pango_font_description_free(pf)

dim as GtkTreeIter iter1, iter2

var store = GTK_TREE_STORE(GUI_MAIN.tstoreProcVar)
gtk_tree_store_append (store, @iter1, NULL)
gtk_tree_store_set (store, @iter1, _
                    0, "Globals (shared/common in : main", _
                    -1)

gtk_tree_store_append (store, @iter2, @iter1)
gtk_tree_store_set (store, @iter2, _
                    0, "NS : TESTNAMES.XX < Shared / Integer >", _
                    -1)

gtk_tree_store_append (store, @iter2, @iter1)
gtk_tree_store_set (store, @iter2, _
                    0, "VENUM <Shared /EENMU>=0 >> Unknowm", _
                    -1)

gtk_tree_store_append (store, @iter2, @iter1)
gtk_tree_store_set (store, @iter2, _
                    0, "PUDT1 <Shared / * UDT>=0", _
                    -1)

gtk_tree_store_append (store, @iter1, NULL)
gtk_tree_store_set (store, @iter1, _
                    0, "ThID=3012 main:Integer", _
                    -1)

gtk_tree_store_append (store, @iter2, @iter1)
gtk_tree_store_set (store, @iter2, _
                    0, "__FB_ARGC__ <Byval param / Long>=0", _
                    -1)

gtk_tree_store_append (store, @iter2, @iter1)
gtk_tree_store_set (store, @iter2, _
                    0, "__FB_ARGV__ <Byval param / Long>=0", _
                    -1)
gtk_tree_view_expand_all(GTK_TREE_VIEW(GUI_MAIN.tvProcVar))
end scope
