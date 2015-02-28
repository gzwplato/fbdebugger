/'* \file source.bas
\brief Code for source notebook

This file contains the FB code to handle the source code notebook and
its tabulators.

\since 3.0
'/


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
  AS gdouble _
    ScrPos    '*< The position to scroll the current line in the source views
  AS guint _
    Pages _   '*< The number of pages in the notebook
  , LenCur    '*< The number of characters in the source current line
  AS GObject PTR _
    MenuSrc _ '*< The popup menu for the source views
  , ViewCur _ '*< The source view for current source line
  , BuffCur _ '*< The source buffer for current source line
  , NoteBok   '*< The notebook for source views
  AS GtkSourceStyleScheme PTR _
    Schema    '*< The style schema for syntax highlighting
  AS GtkSourceStyleSchemeManager PTR _
    Manager    '*< The manager for style schemes
  AS GtkSourceLanguage PTR _
    Lang      '*< The language definitions for syntax highlighting
  AS PangoFontDescription PTR _
    Font      '*< The font description for source views
  AS STRING _
    LmPaths   '*< The list of paths (gchar PTRs)

  DECLARE function addBas(BYVAL AS gchar PTR, BYVAL AS gchar PTR) as GtkWidget PTR
  DECLARE SUB scroll(BYVAL AS gint, BYVAL AS GtkWidget PTR)
  DECLARE SUB remove(BYVAL AS GtkWidget PTR)
  DECLARE SUB removeAll()
  DECLARE SUB settingsChanged()
  DECLARE SUB setStyle(byval as GtkSourceBuffer ptr)
  declare property ScrollPos(byval as gdouble)
  declare property SchemeID(byval as const gchar ptr)
  declare property FontId(byval as const gchar ptr)
  DECLARE CONSTRUCTOR()
  DECLARE DESTRUCTOR()
END TYPE


/'* \brief Constructor to prepare the syntax highlighting

The constructor loads the language definitions for syntax highlighting
in to the default language manager.

\todo Where to load the language file from? Folder dat or GtkSourceView
      configuration?

\todo Compute the maximal length of the current source line, based on
      the font and size of the view widget.

'/
CONSTRUCTOR SrcNotebook()
'' get the widgets from the ui file
  MenuSrc = gtk_builder_get_object(GUI.XML, "menu40")
  ViewCur = gtk_builder_get_object(GUI.XML, "viewSrcCur")
  BuffCur = gtk_builder_get_object(GUI.XML, "srcbuffCur")
  NoteBok = gtk_builder_get_object(GUI.XML, "nbookSrc")

'' prepare managers for syntax highlighting
  VAR lm = gtk_source_language_manager_get_default()
  LmPaths = MKI(cast(integer, @"dat"))
  var ind = 0 _
  , array = gtk_source_language_manager_get_search_path(lm)
  WHILE array[ind]
    LmPaths &= MKI(cast(integer, array[ind]))
    ind += 1
  WEND : LmPaths &= MKI(0)
  gtk_source_language_manager_set_search_path(lm, cast(gchar ptr ptr, sadd(LmPaths)))

'' load syntax highlighting language
  Lang = gtk_source_language_manager_get_language(lm, "fbc")

  IF 0 = Lang THEN
    ?PROJ_NAME & ": " & *__("language fbc not available -> no syntax highlighting")
  ELSE
    gtk_source_buffer_set_language(GTKSOURCE_SOURCE_BUFFER(BuffCur), Lang)
  END IF
  gtk_source_buffer_set_highlight_matching_brackets(GTKSOURCE_SOURCE_BUFFER(BuffCur), FALSE)

?" CONSTRUCTOR SrcNotebook: "
END CONSTRUCTOR


/'* \brief Destructor to free used memory

The destructor frees the pango font description. (The language
structure *Lang* and the scheme *Schema* are owned by the language or
scheme managers.)

'/
DESTRUCTOR SrcNotebook()
  If Font then pango_font_description_free(Font)
END DESTRUCTOR


/'* \brief Add a page for FB source
\param Label The label in the notebook tab
\param Cont The context of the source view
\returns A pointer to the widget in the notebook page

Add a page to the notebook for FreeBASIC source code. The new page is
named as parameter *Label* and its source view shows the text passed as
parameter *Cont* with FreeBASIC syntax highlighting.

'/
FUNCTION SrcNotebook.addBas(BYVAL Label AS gchar PTR, BYVAL Cont AS gchar PTR) AS GtkWidget PTR
?" SrcNotebook.addBas: " & *Label

  VAR labl = gtk_label_new(Label) _
    , buff = gtk_source_buffer_new_with_language(Lang) _
    , srcv = gtk_source_view_new_with_buffer(buff) _
    , widg = gtk_scrolled_window_new(NULL, NULL)

  gtk_source_buffer_set_style_scheme(buff, Schema)
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(buff), Cont, -1)
  gtk_container_add(GTK_CONTAINER(widg), srcv)

  gtk_widget_override_font(srcv, Font)
  gtk_text_view_set_editable(GTK_TEXT_VIEW(srcv), FALSE)
  gtk_source_view_set_show_line_marks(GTKSOURCE_SOURCE_VIEW(srcv), TRUE)
  WITH *INI
    gtk_source_buffer_set_highlight_syntax(buff, .Bool(.FSH))
    gtk_source_view_set_show_line_numbers(GTKSOURCE_SOURCE_VIEW(srcv), .Bool(.FLN))
  END WITH
  g_signal_connect(srcv, "button-press-event" _
                 , G_CALLBACK(@menu_button3_event), MenuSrc)

  g_object_set_data(G_OBJECT(widg), "SrcView", srcv)
  g_object_set_data_full(G_OBJECT(widg), "Buffer", buff, @g_object_unref)
  gtk_widget_show_all(widg)

  VAR i = gtk_notebook_append_page(GTK_NOTEBOOK(NoteBok), widg, labl)
  gtk_notebook_set_current_page(GTK_NOTEBOOK(NoteBok), i)
  Pages += 1 :                                               RETURN widg
END FUNCTION


/'* \brief Scroll the context to line, switch page if necessary
\param Lnr The line number to scroll to (starting at 1)
\param Widg The widget to show (reference returned by SrcNotebook::addBas() )

Member function to switch to a certain page (if necessary) and scroll
to a certain line, select the context of that line and place a copy to
the current line source view.

'/
SUB SrcNotebook.scroll(BYVAL Lnr AS gint, BYVAL Widg AS GtkWidget PTR)
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB

  VAR page = gtk_notebook_page_num(GTK_NOTEBOOK(NoteBok), Widg)
  IF page < 0 THEN                           /' no such page '/ EXIT SUB
  gtk_notebook_set_current_page(GTK_NOTEBOOK(NoteBok), page)

  VAR buff = GTK_TEXT_BUFFER(g_object_get_data(G_OBJECT(Widg), "Buffer")) _
    , srcv = GTK_TEXT_VIEW(g_object_get_data(G_OBJECT(Widg), "SrcView")) _

  DIM AS GtkTextIter i2
  gtk_text_buffer_get_iter_at_line(buff, @i2, Lnr)
  VAR i1 = gtk_text_iter_copy(@i2)
  gtk_text_iter_backward_line(i1)
  gtk_text_iter_backward_char(@i2)

  gtk_text_buffer_place_cursor(buff, i1)
  gtk_text_view_scroll_to_iter(srcv, i1, .0, TRUE, .0, ScrPos)

  gtk_text_buffer_select_range(buff, i1, @i2)
  VAR cont = gtk_text_buffer_get_text(buff, i1, @i2, TRUE) _
    , curr = *cont
  gtk_text_iter_free(i1)
  g_free(cont)

  IF LEN(curr) > LenCur _
    THEN curr = LEFT(curr, LenCur - 4) & " ..." _
    ELSE IF 0 = LEN(curr) THEN curr = " "
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), curr, LEN(curr))
END SUB


/'* \brief Remove a notebook page
\param Widg The child widget in the page to remove

Method to remove a single page from the notebook. The child widget is
used to identify the page, since the page index may change in case of
reordering, adding or removing pages.

'/
SUB SrcNotebook.remove(BYVAL Widg AS GtkWidget PTR)
  VAR page = gtk_notebook_page_num(GTK_NOTEBOOK(NoteBok), Widg)
?" SrcNotebook.remove: "; Widg, page
  IF page < 0 THEN                         /' invalid widget '/ EXIT SUB
  IF page = gtk_notebook_get_current_page(GTK_NOTEBOOK(NoteBok)) THEN _
    gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), "", 0)

  Pages -= 1
  gtk_notebook_remove_page(GTK_NOTEBOOK(NoteBok), page)
END SUB


/'* \brief Remove all pages from notebook

Method to remove all pages from the notebook.

'/
SUB SrcNotebook.removeAll()
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB

  VAR n = gtk_notebook_get_n_pages(GTK_NOTEBOOK(NoteBok))
  FOR i AS gint = n - 1 TO 0 STEP -1
    gtk_notebook_remove_page(GTK_NOTEBOOK(NoteBok), i)
  NEXT

  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), "", 0)
  Pages = 0
END SUB


/'* \brief Property to set the scroll position for the current line
\param Posi The position [0.0,1.0]

Gets the new position to scroll the current line in the source view
widgets.

'/
PROPERTY SrcNotebook.ScrollPos(BYVAL Posi AS gdouble)
  ScrPos = Posi
END PROPERTY


/'* \brief Property to set the style scheme
\param Snam The name of the style (scheme_id)

Loads the specified style scheme and applies it to the buffer for the
current line. All other buffers need separate adaption (if any).

'/
PROPERTY SrcNotebook.SchemeId(BYVAL Snam AS CONST gchar PTR)
  Schema = gtk_source_style_scheme_manager_get_scheme(Manager, Snam)
  gtk_source_buffer_set_style_scheme(GTKSOURCE_SOURCE_BUFFER(BuffCur), Schema)
END PROPERTY


/'* \brief Property to set the font
\param Fnam The font name to use

Creates a PangoFontDescription for the specified font and applies it to
the source view widget for the current line. All other notebook pages
need separate adaption (if any).

\todo Re-compute the length of the line based on the new font (and widget size)

'/
PROPERTY SrcNotebook.FontId(BYVAL Fnam AS CONST gchar PTR)
  IF Font THEN pango_font_description_free(Font)
  Font = pango_font_description_from_string(Fnam)
  gtk_widget_override_font(GTK_WIDGET(ViewCur), Font)

'' compute maximal len of current source view line (ToDo)
  LenCur = 80
END PROPERTY


/'* \brief Update all pages from notebook

Method to update the style for all pages in the notebook, when the user
changed settings.

'/
SUB SrcNotebook.settingsChanged()
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB

  WITH *INI
    gtk_source_buffer_set_highlight_syntax(GTKSOURCE_SOURCE_BUFFER(BuffCur), .Bool(.FSH))

    VAR n = gtk_notebook_get_n_pages(GTK_NOTEBOOK(NoteBok))
    FOR i AS gint = n - 1 TO 0 STEP -1
      var widg = gtk_notebook_get_nth_page(GTK_NOTEBOOK(NoteBok), i) _
        , buff = g_object_get_data(G_Object(widg), "Buffer") _
        , srcv = g_object_get_data(G_Object(widg), "SrcView") _
        , mark = gtk_text_buffer_get_insert(buff)
      gtk_widget_override_font(GTK_WIDGET(srcv), Font)
      gtk_source_buffer_set_style_scheme(buff, Schema)
      gtk_source_buffer_set_highlight_syntax(GTKSOURCE_SOURCE_BUFFER(buff), .Bool(.FSH))
      gtk_source_view_set_show_line_numbers(GTKSOURCE_SOURCE_VIEW(srcv), .Bool(.FLN))
      gtk_text_view_scroll_to_mark(srcv, mark, .0, TRUE, .0, ScrPos)
    NEXT
  END WITH

END SUB


/'* \brief The global class to handle the source notebook

We use a pointer here, since we need to search for GtkBuilder objects
in the constructor, so that the constructor must run after the XML file
is loaded and parsed.

'/
DIM SHARED AS SrcNotebook PTR SRC
