/'* \file source.bas
\brief Code for source notebook

This file contains the FB code to handle the source code notebook and
its tabulators.

\todo Remove the PRINT statements without indentation (for testing /
      debugging purposes only)

\since 3.0
'/


/'* \brief Class to handle the context of the source notebook

This class prepares a GtkSourceView for highlighting the FreeBASIC
syntax and handles the pages of the source notebook. A single
GtkSourceView is used for all pages, and the files are loaded in to
several GtkSourceBuffers. Each page contains a GtkScrolledWindow that
is used as the parent for the GtkSourceView.

When switching a page, the GtkSourceView gets reparent to the related
scrolled window and the related text buffer gets connected.

'/
TYPE SrcNotebook
  AS gint Pages                 '*< The number of pages in the notebook
  AS GtkWidget PTR Parent       '*< The parent widget to park the source view in case of no page
  AS GtkSourceView PTR SrcView  '*< The source view for all pages
  AS GtkSourceLanguage PTR Lang '*< The language definitions for syntax highlighting
  AS GtkStyleProvider PTR Prov  '*< The CSS style provider for small buttons

  DECLARE SUB addBas(BYVAL AS gchar PTR, BYVAL AS gchar PTR)
  DECLARE SUB scroll(BYVAL AS gint)
  DECLARE SUB remove(BYVAL AS GtkWidget PTR)
  DECLARE CONSTRUCTOR()
  DECLARE DESTRUCTOR()
END TYPE


/'* \brief Constructor to prepare the syntax highlighting

The constructor loads the language definitions for syntax highlighting
in to the default language manager.

'/
CONSTRUCTOR SrcNotebook()
'' set a CSS style provider for small buttons
  VAR css = gtk_css_provider_new()
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

'' change the font
  VAR pf = pango_font_description_from_string(@"monospace 8")
  gtk_widget_override_font(GTK_WIDGET(GUI.srcview), pf)
  gtk_widget_override_font(GTK_WIDGET(GUI.srcviewCur), pf)
  pango_font_description_free(pf)

'' set the syntax highlighting
  VAR lm = gtk_source_language_manager_get_default()
  Lang = gtk_source_language_manager_get_language(lm, "fbc")
  IF 0 = Lang THEN
    ?PROJ_NAME & *__(": language fbc not available -> no syntax highlighting")
  ELSE
    gtk_source_buffer_set_language(GTKSOURCE_SOURCE_BUFFER(GUI.srcbuffCur), Lang)
  END IF

?" CONSTRUCTOR SrcNotebook: ";@THIS, GUI.srcview
END CONSTRUCTOR


/'* \brief Destructor for the class

Destructor to free the the list of GtkSourceBuffers. The buffers hold
the context of the files. Each one must get unrefed when finished.

'/
DESTRUCTOR SrcNotebook()
  g_object_unref(Prov)
END DESTRUCTOR


/'* \brief Scroll the context to line, update current
\param Lnr The line number to scroll to (starting at 1)

Member function to scroll the current source view to a certain line,
select the context of that line and place a copy to the current line
source view.

\todo Remove alternative syntax (marked by '~). The iter solution is
      shorter, but it cannot be used before the widget is realized the
      first time (= not at startup).

'/
SUB SrcNotebook.scroll(BYVAL Lnr AS gint)
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB
  VAR n = gtk_notebook_get_current_page(GTK_NOTEBOOK(GUI.nbookSrc)) _
    , w = gtk_notebook_get_nth_page(GTK_NOTEBOOK(GUI.nbookSrc), n) _
 , buff = GTK_TEXT_BUFFER(g_object_get_data(G_OBJECT(w), "Buffer"))

  DIM AS GtkTextIter start, stop_

  gtk_text_buffer_get_iter_at_line(buff, @start, Lnr - 1)
  gtk_text_buffer_place_cursor(buff, @start)
  gtk_text_view_scroll_to_iter(GTK_TEXT_VIEW(GUI.srcview), @start, .0, TRUE, .0, .5)
  '~ gtk_text_buffer_move_mark_by_name(buff, "insert", @start)
  '~ var mark = gtk_text_buffer_get_mark(buff, "insert")
  '~ gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(GUI.srcview), mark, 0.0, TRue, 0.0, 0.00009)

  gtk_text_buffer_get_iter_at_line(buff, @stop_, Lnr)
  '~ gtk_text_buffer_move_mark_by_name(buff, "selection_bound", @stop_)
  gtk_text_iter_backward_char(@stop_)

  VAR cont = gtk_text_buffer_get_text(buff, @start, @stop_, TRUE)
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(GUI.srcbuffCur), cont, -1)
  g_free(cont)
END SUB


'' forward declaration, body is after dimensioning shared variable SRC
DECLARE SUB on_noteSrc_close_clicked CDECL ALIAS "on_noteSrc_close_clicked" ( _
    BYVAL Widg AS GtkWidget PTR _
  , BYVAL Page AS GtkWidget PTR)

/'* \brief Add a page for FB source
\param Label The label in the notebook tab
\param Cont The context of the source view

Add a page to the notebook for FreeBASIC source code. The tabulator
contains a label with the given text and a close button in order to let
the user remove that page.

'/
SUB SrcNotebook.addBas(BYVAL Label AS gchar PTR, BYVAL Cont AS gchar PTR)
?" SrcNotebook.addBas: "; GUI.XML, gtk_widget_get_parent(GTK_WIDGET(GUI.srcview))

  VAR box = gtk_hbox_new(FALSE, 3) _
   , labl = gtk_label_new(Label) _
   , butt = gtk_button_new() _
  , image = gtk_image_new_from_stock(GTK_STOCK_CLOSE, GTK_ICON_SIZE_MENU)
  gtk_container_add(GTK_CONTAINER(butt), image)

  gtk_button_set_relief(GTK_BUTTON(butt), GTK_RELIEF_NONE)
  gtk_button_set_focus_on_click(GTK_BUTTON(butt), FALSE)
  gtk_widget_set_size_request(butt, 0, 0)

  VAR cntx = gtk_widget_get_style_context(butt)
  gtk_style_context_add_provider(cntx, Prov, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
  gtk_box_pack_start(GTK_BOX(box), labl, TRUE, TRUE, 0)
  gtk_box_pack_start(GTK_BOX(box), butt, FALSE, FALSE, 0)
  gtk_widget_show_all(box)

  VAR buff = gtk_source_buffer_new_with_language(Lang)
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(buff), Cont, -1)

  VAR widg = gtk_scrolled_window_new(NULL, NULL)
  g_object_set_data_full(G_OBJECT(widg), "Buffer", buff, @g_object_unref)
  g_signal_connect(G_OBJECT(butt), "clicked" _
                 , G_CALLBACK(@on_noteSrc_close_clicked), widg)
  gtk_widget_show(widg)

  WITH GUI
    IF 0 = Parent THEN Parent = gtk_widget_get_parent(GTK_WIDGET(.srcview))
    gtk_text_view_set_buffer(GTK_TEXT_VIEW(.srcview), GTK_TEXT_BUFFER(buff))

    gtk_widget_reparent(GTK_WIDGET(.srcview), widg)

    VAR i = gtk_notebook_append_page(GTK_NOTEBOOK(.nbookSrc), widg, box)
    gtk_notebook_set_current_page(GTK_NOTEBOOK(.nbookSrc), i)
  END WITH
  Pages += 1
END SUB


/'* \brief Remove a notebook page
\param Widg The child widget in the page to remove

Method to remove an existend page from the notebook. The child widget
is used to identify the page, since the page index may change in case
of reordering, adding or removing pages.

'/
SUB SrcNotebook.remove(BYVAL Widg AS GtkWidget PTR)
  VAR page = gtk_notebook_page_num(GTK_NOTEBOOK(GUI.nbookSrc), Widg)
?" SrcNotebook.remove: "; Widg, page
  IF page < 0 THEN                         /' invalid widget '/ EXIT SUB

  Pages -= 1
  IF Pages < 1 THEN gtk_widget_reparent(GTK_WIDGET(GUI.srcview), Parent)
  gtk_notebook_remove_page(GTK_NOTEBOOK(GUI.nbookSrc), page)
END SUB



/'* \brief Configure context before page-switch
\param Note The related notebook
\param Widg The widget in the new page
\param Indx The index of the new page
\param user_data (unused)

This signal handler configures the context of a notebook page before
the new page gets shown.

\todo Text scrolling when switching pages

'/
SUB on_noteSrc_switch CDECL ALIAS "on_noteSrc_switch" ( _
    BYVAL Note AS GtkNotebook PTR _
  , BYVAL Widg AS GtkWidget PTR _
  , BYVAL Indx AS guint _
  , BYVAL user_data AS gpointer) EXPORT

?" on_noteSrc_switch: ";gtk_notebook_get_current_page(Note) & " --> " & Indx

  WITH GUI
    g_object_set(.srcview, "buffer", g_object_get_data(G_Object(Widg), "Buffer"), NULL)
    gtk_widget_reparent(GTK_WIDGET(.srcview), Widg)
  END WITH
END SUB


/'* \brief The global class to handle the source notebook

We use a pointer here, since we need GtkBuilder objects in the
constructor, so that the constructor must run after the XML file is
loaded and parsed.

'/
DIM SHARED AS SrcNotebook PTR SRC
SRC = NEW SrcNotebook



/'* \brief Close a notebook tab
\param Widg The GtkButton that triggered the event
\param Child The child widget in the notebook page

This signal handler closes a notebook tabulator by calling the remove
method of the class SrcNotebook. It gets connected to each close button
in the notebook label widgets.

'/
SUB on_noteSrc_close_clicked CDECL ALIAS "on_noteSrc_close_clicked" ( _
    BYVAL Widg AS GtkWidget PTR _
  , BYVAL Child AS GtkWidget PTR) EXPORT
?" on_noteSrc_close_clicked: ";Child
  SRC->remove(Child)
END SUB


/'* \brief Handler for clicks on current source button
\param Butt The button that emits the signal
\param user_data (unused)

This signal handler gets called when the user clicks on the current
source code line.

'/
SUB on_CurSrc_clicked CDECL ALIAS "on_CurSrc_clicked" ( _
  BYVAL Butt AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback on_CurSrc_clicked"

END SUB

