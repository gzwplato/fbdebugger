/'* \file source.bas
\brief Code for source notebook

This file contains the source code to handle the source code notebook
and its tabulators.

\note We don't use a variable length array for the SrcContext PTRs.
      Instead we use a simple STRING solution, in order to be able with
      old FB compilers (< 1.0). We could use a GList as well.

\since 3.0
'/

'declare SUB on_noteSrc_switch CDECL ALIAS "on_noteSrc_switch" ( _
    'BYVAL Note AS GtkNotebook PTR _
  ', BYVAL Widg AS GtkWidget PTR _
  ', BYVAL Indx AS guint _
  ', BYVAL SrcD AS gpointer)


TYPE SrcContext
  as GtkSourceBuffer ptr Objct
  as GtkTextBuffer ptr Buff
  'as GtkWidget ptr Scrol
  as gint Index

  declare SUB add(BYVAL AS GtkSourceLanguage ptr, byval AS GtkWidget ptr)
  declare deSTRUCTOR()
END TYPE

SUB SrcContext.add( _
    BYVAL Lang AS GtkSourceLanguage ptr _
  , byval Widg AS GtkWidget ptr)
  Objct = gtk_source_buffer_new_with_language(Lang)
  Buff = GTK_TEXT_BUFFER(Objct)

  var scrol = gtk_scrolled_window_new(NULL, NULL)
  gtk_widget_show(Scrol)
  WITH GUI
    gtk_text_view_set_buffer(GTK_TEXT_VIEW(.srcview), Buff)
    gtk_widget_reparent(GTK_WIDGET(.srcview), scrol)
    Index = gtk_notebook_append_page(GTK_NOTEBOOK(.nbookSrc), scrol, Widg)
    gtk_notebook_set_current_page(GTK_NOTEBOOK(.nbookSrc), Index)
  END WITH
END SUB

DESTRUCTOR SrcContext()
?Index
  if 0 = Index then exit destructor
  g_object_unref(Objct)
END DESTRUCTOR





TYPE SrcNotebook
  as string Tabs
  as gint CurTab
  as GtkSourceLanguage ptr Lang
  as GtkStyleProvider ptr Prov

  declare sub add(BYVAL AS gchar ptr, byval AS gchar ptr)
  declare sub scroll(byval AS gint)
  declare sub switch(byval AS gint)
  declare sub remove(byval AS gint)
  declare function makeLabel(byval AS gchar ptr) as GtkWidget PTR
  declare conSTRUCTOR()
  declare DESTRUCTOR()
END TYPE

CONSTRUCTOR SrcNotebook()
  var css = gtk_css_provider_new()
  gtk_css_provider_load_from_data(css, _
    ".button{" _
    "-GtkButton-default-border: 0px;" _
    "-GtkButton-default-outside-border: 0px;" _
    "-GtkButton-inner-border: 0px;" _
    "-GtkWidget-focus-line-width: 0px;" _
    "-GtkWidget-focus-padding: 0px;" _
    "padding: 0px;" _
    "}" _
  , -1, NULL)
  Prov = GTK_STYLE_PROVIDER(css)

  VAR lm = gtk_source_language_manager_get_default()
  Lang = gtk_source_language_manager_get_language(lm, "fbc")

  var p = new SrcContext
  Tabs = mki(cast(INTEGER, p))
  CurTab = 0
  p->Buff = GTK_TEXT_BUFFER(GUI.srcbuff)
  'p->Scrol = GTK_WIDGET(GUI.scrolSrc)
  p->Index = CurTab
?" CONSTRUCTOR SrcNotebook: ";@THIS, p

  IF 0 = Lang THEN _
    ?PROJ_NAME & *__(": language fbc not available -> no syntax highlighting")
END CONSTRUCTOR

DESTRUCTOR SrcNotebook()
  var p = cast(integer ptr, sadd(Tabs)), n = len(Tabs) \ sizeof(any ptr)
  FOR i AS INTEGER = 0 TO n - 1
    delete cast(SrcContext ptr, p[i])
  NEXT
  g_object_unref(Prov)
END DESTRUCTOR

'SUB SrcNotebook.scroll(BYVAL I AS gint)
  'var p = cast(SrcContext ptr, sadd(Tabs)) + CurTab
  'dim as GtkTextIter iter
  'gtk_text_buffer_get_iter_at_line(p->Buff, @iter, I)
  'gtk_text_buffer_move_mark_by_name(p->Buff, "selection_bound", @iter)

  'var eiter = gtk_text_iter_copy(@iter)
  'gtk_text_iter_backward_line(@iter)
  'gtk_text_buffer_move_mark_by_name(p->Buff, "insert", @iter)
  ''?"HIER: ";gtk_text_view_scroll_to_iter(GTK_TEXT_VIEW(GUI.srcview), @iter, 0.40, FALSE, 0.5, 0.5)
  'var mark = gtk_text_buffer_get_mark(p->Buff, "insert")
  'gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(GUI.srcview), mark, 0.0, TRue, 0.0, 0.00009)
  'var cur = gtk_text_buffer_get_text(p->Buff, @iter, eiter, TRUE)
  'gtk_text_iter_free(eiter)

  'gtk_text_buffer_set_text(GTK_TEXT_BUFFER(GUI.srcbuffCur), cur, -1)
  'g_free(cur)
'END SUB


FUNCTION SrcNotebook.makeLabel(BYVAL T AS gchar PTR) AS GtkWidget PTR
  VAR box = gtk_hbox_new(FALSE, 3) _
  , label = gtk_label_new(MID(*T, INSTRREV(*T, ANY "/\") + 1)) _
   , butt = gtk_button_new_from_icon_name("gtk-close", GTK_ICON_SIZE_MENU)
  gtk_button_set_relief(GTK_BUTTON(butt), GTK_RELIEF_NONE)
  gtk_button_set_focus_on_click(GTK_BUTTON(butt), FALSE)
  'gtk_widget_set_size_request(butt, 0, 0)

  VAR cont = gtk_widget_get_style_context(butt)
  gtk_style_context_add_provider(cont, Prov, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
  gtk_box_pack_start(GTK_BOX(box), label, TRUE, TRUE, 0)
  gtk_box_pack_start(GTK_BOX(box), butt, FALSE, FALSE, 0)
  gtk_widget_show_all(box)
  RETURN box
END FUNCTION



SUB SrcNotebook.add(BYVAL Label AS gchar ptr, BYVAL Cont AS gchar ptr)
?" SrcNotebook.add: ";
  var p = new SrcContext
? p,
  Tabs &= mki(cast(INTEGER, p))
?sadd(Tabs)
  CurTab = (len(Tabs) \ sizeof(any ptr)) - 1
  p->add(Lang, makeLabel(Label))
  gtk_text_buffer_set_text(p->Buff, Cont, -1)
END SUB

'SUB SrcNotebook.remove(BYVAL I AS gint)
  'var p = cast(SrcContext ptr ptr, sadd(Tabs)), l = len(Tabs) \ sizeof(any ptr)
'?" SrcNotebook.remove: "; p, I, l
  'if l < (I + 1) then                       /' invalid index '/ exit sub
  'gtk_notebook_remove_page(GTK_NOTEBOOK(GUI.nbookSrc), p[I]->Index)
  'delete p[I]
  'if l = 1 then Tabs = "" :                      /' last tab '/ exit sub
  'var a = I * sizeof(any ptr) _
    ', e = a + sizeof(any ptr)
  'Tabs = left(Tabs, a) & mid(Tabs, e + 1)
'END SUB


'SUB SrcNotebook.switch(BYVAL I AS gint)
  'var p = cast(SrcContext ptr, sadd(Tabs)) + I, l = len(Tabs)
  'if l < (I + 1) * sizeof(any ptr) then     /' invalid index '/ exit sub
'END SUB



SUB on_noteSrc_switch CDECL ALIAS "on_noteSrc_switch" ( _
    BYVAL Note AS GtkNotebook PTR _
  , BYVAL Widg AS GtkWidget PTR _
  , BYVAL Indx AS guint _
  , BYVAL SrcD AS gpointer) export

  WITH *cast(SrcNotebook ptr, SrcD)
    'var i = cast(integer ptr, sadd(.Tabs))
    'var p = cast(SrcContext ptr, i[Indx])

'?" on_noteSrc_switch: ";SrcD, p, Indx, i[Indx], sadd(.Tabs)
    var p = cast(SrcContext ptr ptr, sadd(.Tabs))
'?" on_noteSrc_switch: ";p[Indx], p[Indx]->Index , len(.Tabs)
    'if l < (Indx + 1) * sizeof(any ptr) then /'invalid index '/ exit sub

    gtk_text_view_set_buffer(GTK_TEXT_VIEW(GUI.srcview), p[Indx]->Buff)
    gtk_widget_reparent(GTK_WIDGET(GUI.srcview), Widg)
  END WITH

end sub


dim shared as SrcNotebook SRC

g_signal_connect(GUI.nbookSrc, "switch-page" _
               , G_CALLBACK(@on_noteSrc_switch), @SRC)
