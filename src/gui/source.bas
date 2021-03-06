/'* \file source.bas
\brief Code for source notebook

This file contains the FB code to handle the source code notebook and
its tabulators.

\since 3.0
'/


DECLARE SUB view_mark_clicked CDECL( _
    BYVAL AS GtkSourceView PTR _
  , BYVAL AS GtkTextIter PTR _
  , BYVAL AS GdkEvent PTR _
  , BYVAL AS GtkSourceBuffer PTR)


/'* \brief Constructor to prepare the syntax highlighting

The constructor loads the language definitions for syntax highlighting
in to the default language manager.

\todo Where to load the language file from? Folder dat or GtkSourceView
      configuration?

\todo Compute the maximal length of the current source line, based on
      the font and size of the view widget.

\todo Replace deprecated function gtk_source_mark_attributes_set_stock_id()

'/
CONSTRUCTOR SrcNotebook()
'' get the widgets from the ui file
  MenuSrc = gtk_builder_get_object(GUI.XML, "menu40")
  BuffCur = gtk_builder_get_object(GUI.XML, "srcbuffCur")
  ViewCur = GTK_WIDGET(gtk_builder_get_object(GUI.XML, "viewSrcCur"))
  NoteBok = GTK_NOTEBOOK(gtk_builder_get_object(GUI.XML, "nbookSrc"))
  CBMarks = GTK_COMBO_BOX_TEXT(gtk_builder_get_object(GUI.XML, "comboBookmarks"))

'' prepare managers for syntax highlighting
  VAR lm = gtk_source_language_manager_get_default()
  LmPaths = MKI(CAST(INTEGER, @"dat"))
  VAR ind = 0 _
  , array = gtk_source_language_manager_get_search_path(lm)
  WHILE array[ind]
    LmPaths &= MKI(CAST(INTEGER, array[ind]))
    ind += 1
  WEND : LmPaths &= MKI(0)
  gtk_source_language_manager_set_search_path(lm, CAST(gchar PTR PTR, SADD(LmPaths)))

'' load syntax highlighting language
  Lang = gtk_source_language_manager_get_language(lm, "fbc")

  IF 0 = Lang THEN
    ?PROJ_NAME & ": " & *__("language fbc not available -> no syntax highlighting")
  ELSE
    gtk_source_buffer_set_language(GTKSOURCE_SOURCE_BUFFER(BuffCur), Lang)
  END IF
  gtk_source_buffer_set_highlight_matching_brackets(GTKSOURCE_SOURCE_BUFFER(BuffCur), FALSE)

  Attr0 = getAttr("img/brkd.png")
  Attr1 = getAttr("img/brkt.png")
  Attr2 = getAttr("img/brkp.png")
  Attr3 = getAttr("img/book.png")
  'gtk_combo_box_text_insert(CBMarks, 0, NULL, __("No bookmark"))
  'g_object_set(CBMarks, "active", CAST(gint, 0), NULL)
  initCombo(__("No bookmark"))


?" CONSTRUCTOR SrcNotebook"
END CONSTRUCTOR


/'* \brief Destructor to free used memory

The destructor frees the pango font description. (The language
structure *Lang* and the scheme *Schema* are owned by the language or
scheme managers.)

'/
DESTRUCTOR SrcNotebook()
  IF Font THEN pango_font_description_free(Font)
  g_object_unref(Attr3)
  g_object_unref(Attr2)
  g_object_unref(Attr1)
  g_object_unref(Attr0)
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

  gtk_source_view_set_mark_attributes(GTKSOURCE_SOURCE_VIEW(srcv), "fbdbg-brkd", Attr0, 999)
  gtk_source_view_set_mark_attributes(GTKSOURCE_SOURCE_VIEW(srcv), "fbdbg-brkt", Attr1, 999)
  gtk_source_view_set_mark_attributes(GTKSOURCE_SOURCE_VIEW(srcv), "fbdbg-brkp", Attr2, 999)
  gtk_source_view_set_mark_attributes(GTKSOURCE_SOURCE_VIEW(srcv), "fbdbg-book", Attr3, 909)
  g_signal_connect(srcv, "line-mark-activated" _
                 , G_CALLBACK(@view_mark_clicked), buff)

  WITH *INI
    gtk_source_buffer_set_highlight_syntax(buff, .Bool(.FSH))
    gtk_source_view_set_show_line_numbers(GTKSOURCE_SOURCE_VIEW(srcv), .Bool(.FLN))
  END WITH
  g_signal_connect(srcv, "button-press-event" _
                 , G_CALLBACK(@menu_button3_event), MenuSrc)

  g_object_set_data(G_OBJECT(widg), "SrcView", srcv)
  g_object_set_data_full(G_OBJECT(widg), "Buffer", buff, @g_object_unref)
  gtk_widget_show_all(widg)

  VAR i = gtk_notebook_append_page(NoteBok, widg, labl)
  gtk_notebook_set_current_page(NoteBok, i)
  Pages += 1 :                                               RETURN widg
END FUNCTION


/'* \brief Scroll the context to line, switch page if necessary
\param Lnr The line number to scroll to (starting at 1)
\param Widg The widget to show (reference returned by SrcNotebook::addBas() )
\param Mo The modus (0 = scroll only, otherwise copy current line)

Member function to switch to a certain page (if necessary) and scroll
to a certain line, select the context of that line and place a copy to
the current line source view.

'/
SUB SrcNotebook.scroll(BYVAL Lnr AS gint, BYVAL Widg AS GtkWidget PTR, BYVAL Mo AS guint32 = 1)
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB
  IF 0 = Widg THEN Widg = ScrWidg : Lnr = ScrLine

  VAR page = gtk_notebook_page_num(NoteBok, Widg)
  IF page < 0 THEN                           /' no such page '/ EXIT SUB
  gtk_notebook_set_current_page(NoteBok, page)

  VAR buff = GTK_TEXT_BUFFER(g_object_get_data(G_OBJECT(Widg), "Buffer")) _
    , srcv = GTK_TEXT_VIEW(g_object_get_data(G_OBJECT(Widg), "SrcView")) _

  DIM AS GtkTextIter iter
  gtk_text_buffer_get_iter_at_line(buff, @iter, Lnr - 1)
  gtk_text_view_scroll_to_iter(srcv, @iter, .0, TRUE, .0, ScrPos)
  IF 0 = Mo THEN                                                EXIT SUB

  VAR txt = getBuffLine(buff, @iter)
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), txt, LEN(txt))
  ScrWidg = Widg
  ScrLine = Lnr
END SUB


/'* \brief Set a book mark in the combo box
\param Lnr The line number
\param Widg The note book widget to operate at (scrolled window)

Member function to add a book mark to the combo box in main window. It
sorts the new book mark text to the GtkComboBoxText list store by
widget and line number.

'/
SUB SrcNotebook.addBookmark(BYVAL Lnr AS gint, BYVAL Widg AS GtkWidget PTR)
  VAR buff = g_object_get_data(G_Object(Widg), "Buffer")

  DIM AS GtkTextIter iter
  gtk_text_buffer_get_iter_at_line(GTK_TEXT_BUFFER(buff), @iter, Lnr - 1)

  VAR id = STR(Lnr) & "&h" & HEX(CAST(INTEGER, Widg)) _
   , txt = *gtk_notebook_get_tab_label_text(NoteBok, Widg) _
         & "(" & Lnr & "): " _
         & getBuffLine(buff, @iter) _
     , p = 0, n = 0 _
 , model = gtk_combo_box_get_model(GTK_COMBO_BOX(CBMarks)) _
, column = gtk_combo_box_get_id_column(GTK_COMBO_BOX(CBMarks))

  DIM AS GtkTreeIter tri
  gtk_tree_model_get_iter_first(model, @tri) ' skip first
  WHILE gtk_tree_model_iter_next(model, @tri)
    DIM AS gchar PTR dat
    gtk_tree_model_get(model, @tri, column, @dat, -1)
    n += 1 : IF 0 = dat THEN                              CONTINUE WHILE

    VAR l = CAST(gint, VALUINT(*dat)) _
      , w = VALUINT(MID(*dat, INSTR(*dat, "&h")))
    g_free(dat)

    IF Widg <> w then if p THEN exit while else           CONTINUE WHILE
    IF Lnr > l THEN p = n ELSE p = iif(p, p, n - 1) :         EXIT WHILE
  WEND
  IF 0 = BkMarks THEN initCombo(__("Select bookmark"))
  gtk_combo_box_text_insert(CBMarks, p + 1, id, txt)
  BkMarks += 1
END SUB


/'* \brief Delete a book mark
\param Lnr The line number
\param Widg The note book widget to operate at (scrolled window)

Member function to delete a bookmark in the combo box in main window.
It searches the entries for the specified book mark and deletes it from
the GtkComboBoxText list store, if any.

'/
SUB SrcNotebook.delBookmark(BYVAL Lnr AS gint, BYVAL Widg AS GtkWidget PTR)
  DIM AS GtkTreeIter iter
  VAR id = STR(Lnr) & "&h" & HEX(CAST(INTEGER, Widg)) _
 , model = gtk_combo_box_get_model(GTK_COMBO_BOX(CBMarks)) _
, column = gtk_combo_box_get_id_column(GTK_COMBO_BOX(CBMarks))

  IF 0 = gtk_tree_model_get_iter_first(model, @iter) THEN       EXIT SUB
  DO
    DIM AS gchar PTR dat
    gtk_tree_model_get(model, @iter, column, @dat, -1)
    IF 0 = dat THEN                                          CONTINUE DO
    VAR r = *dat <> id
    g_free(dat) : IF r THEN                                  CONTINUE DO
    gtk_list_store_remove(GTK_LIST_STORE(model), @iter) : BkMarks -= 1
    IF 0 = BkMarks THEN initCombo(__("No bookmark"))
                                                                EXIT SUB
  LOOP UNTIL 0 = gtk_tree_model_iter_next(model, @iter)
END SUB


/'* \brief Prepare an icon as gutter mark
\param Nam The name of the icon file
\returns A new mark attribute structure

Member function to load an icon in to a GdkPixbuf and renders it for
use as mark in the source view widgets.

'/
FUNCTION SrcNotebook.getAttr(BYVAL Nam AS gchar PTR) AS GtkSourceMarkAttributes PTR
  DIM AS GError PTR errr
  VAR size = 10 _
    , attr = gtk_source_mark_attributes_new() _
    , pixbuf = gdk_pixbuf_new_from_file_at_size(Nam, size, size, @errr)
  IF 0 = pixbuf THEN ?PROJ_NAME & ": missing file " & *Nam    : RETURN attr

  gtk_source_mark_attributes_set_pixbuf(attr, pixbuf)
  g_object_unref(pixbuf)

  gtk_source_mark_attributes_render_icon(attr, ViewCur, size) : RETURN attr
END FUNCTION


/'* \brief Get the context of a line from a buffer
\param Buff The buffer to read from
\param Iter The start of the line to get
\returns A STRING containing the line

Read the context of a line from a buffer. When the line is longer than
SrcNotebook::LenCur, the context gets cutted, setting three dots at the
end.

'/
FUNCTION SrcNotebook.getBuffLine( _
    BYVAL Buff AS GtkTextBuffer PTR _
  , BYVAL Iter AS GtkTextIter PTR) AS STRING

  VAR i2 = gtk_text_iter_copy(Iter)
  gtk_text_iter_forward_line(i2)
  gtk_text_iter_backward_char(i2)

  gtk_text_buffer_place_cursor(Buff, Iter)
  gtk_text_buffer_select_range(Buff, Iter, i2)

  VAR cont = gtk_text_buffer_get_text(Buff, Iter, i2, TRUE) _
       , r = *cont
  gtk_text_iter_free(i2)
  g_free(cont)

  IF LEN(r) > LenCur _
    THEN r = LEFT(r, LenCur - 4) & " ..." _
    ELSE IF 0 = LEN(r) THEN r = " "

  RETURN r
END FUNCTION


/'* \brief Remove a notebook page
\param Widg The child widget in the page to remove

Method to remove a single page from the notebook. The child widget is
used to identify the page, since the page index may change in case of
reordering, adding or removing pages.

'/
SUB SrcNotebook.remove(BYVAL Widg AS GtkWidget PTR)
  VAR page = gtk_notebook_page_num(NoteBok, Widg)
?" SrcNotebook.remove: "; Widg, page
  IF page < 0 THEN                         /' invalid widget '/ EXIT SUB
  IF page = gtk_notebook_get_current_page(NoteBok) THEN _
    gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), "", 0)

  Pages -= 1
  gtk_notebook_remove_page(NoteBok, page)
END SUB


/'* \brief Remove all pages from notebook
\param Mo Modus, when zero delete all bookmarks.

Method to remove all pages from the notebook.

'/
SUB SrcNotebook.removeAll(BYVAL Mo AS guint = 0)
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB

  VAR n = gtk_notebook_get_n_pages(NoteBok)
  FOR i AS gint = n - 1 TO 0 STEP -1
    gtk_notebook_remove_page(NoteBok, i)
  NEXT

  Pages = 0
  gtk_text_buffer_set_text(GTK_TEXT_BUFFER(BuffCur), "", 0)
  IF Mo THEN                                                    EXIT SUB
  initCombo(__("No bookmark"))
END SUB



/'* \brief Initialize the bookmark combo box
\param Txt The context for the first entry

Clear all entries in the combo box for book marks, then set first entry
to *Txt*. Also reset the counter BkMarks.

'/
SUB SrcNotebook.initCombo(BYVAL Txt AS gchar PTR)
  gtk_combo_box_text_remove_all(CBMarks) : BkMarks = 0
  gtk_combo_box_text_insert(CBMarks, 0, NULL, Txt)
  g_object_set(CBMarks, "active", CAST(gint, 0), NULL)
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
PROPERTY SrcNotebook.SchemeID(BYVAL Snam AS CONST gchar PTR)
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
PROPERTY SrcNotebook.FontID(BYVAL Fnam AS CONST gchar PTR)
  IF Font THEN pango_font_description_free(Font)
  Font = pango_font_description_from_string(Fnam)
  gtk_widget_override_font(ViewCur, Font)

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

    VAR n = gtk_notebook_get_n_pages(NoteBok)
    FOR i AS gint = n - 1 TO 0 STEP -1
      VAR widg = gtk_notebook_get_nth_page(NoteBok, i) _
        , buff = g_object_get_data(G_Object(widg), "Buffer") _
        , srcv = g_object_get_data(G_Object(widg), "SrcView") _
        , mark = gtk_text_buffer_get_insert(buff)
      gtk_widget_override_font(srcv, Font)
      gtk_source_buffer_set_style_scheme(buff, Schema)
      gtk_source_buffer_set_highlight_syntax(GTKSOURCE_SOURCE_BUFFER(buff), .Bool(.FSH))
      gtk_source_view_set_show_line_numbers(GTKSOURCE_SOURCE_VIEW(srcv), .Bool(.FLN))
      gtk_text_view_scroll_to_mark(srcv, mark, .0, TRUE, .0, ScrPos)
    NEXT
  END WITH

END SUB


/'* \brief Change a mark programmatically
\param Lnr The line number to scroll to (starting at 1)
\param Widg The widget to show (reference returned by SrcNotebook::addBas() )
\param Mo The modus how to change

Procedure to change marks in a source view widget at the specified line
number *Lnr*. It either creates or removes marks in the source view
widget contained in scrolled window *Widg*, by calling SUB
view_mark_clicked().

To set a mark, specify its type in parameter *Mo*. Existend break point
marks get overriden by the new type, existend bookmarks stay unchanged.

To remove marks,

- pass "brk" to remove a break point mark
- pass "boo" to remove a bookmark
- pass any other string (ie. "") to remove all marks

When the specified line number is too big (or negative), the procedure
operates at the last line.

'/
SUB SrcNotebook.changeMark( _
    BYVAL Lnr AS gint _
  , BYVAL Widg AS GtkWidget PTR _
  , BYREF Mo AS STRING = "")
  IF Pages < 1 THEN                   /' no page, do nothing '/ EXIT SUB

  VAR page = gtk_notebook_page_num(NoteBok, Widg)
  IF page < 0 THEN                           /' no such page '/ EXIT SUB

  DIM AS GtkTextIter iter
  DIM AS GdkEventButton event
  VAR buff = g_object_get_data(G_OBJECT(Widg), "Buffer") _
    , srcv = g_object_get_data(G_OBJECT(Widg), "SrcView")
  gtk_text_buffer_get_iter_at_line(GTK_TEXT_BUFFER(buff), @iter, Lnr - 1)

  WITH event
    .state = FIX_GDKEVENT_STATE

    SELECT CASE Mo
    CASE "book" : .button = 1 : .state += 3
    CASE "boo"  : .button = 3 : .state += 3
    CASE "brkp" : .button = 1
    CASE "brkt" : .button = 1 : .state += 1
    CASE "brkd" : .button = 1 : .state += 4
    CASE "brk"  : .button = 3
    CASE ELSE   : .button = 3
      view_mark_clicked(srcv, @iter, CAST(GdkEvent PTR, @event), GTKSOURCE_SOURCE_BUFFER(buff))
      .state += 3
    END SELECT
    view_mark_clicked(srcv, @iter, CAST(GdkEvent PTR, @event), GTKSOURCE_SOURCE_BUFFER(buff))
  END WITH
END SUB


/'* \brief The global class to handle the source notebook

We use a pointer here, since we need to search for GtkBuilder objects
in the constructor, so that the constructor must run after the XML file
is loaded and parsed.

'/
DIM SHARED AS SrcNotebook PTR SRC


/'* \brief Change mark in gutter
\param SView The source view widget
\param Iter The text iter where to operate
\param Event The mouse event that triggered the signal
\param Buff (unused)

Signal handler to create or remove a mark in the source view widgets. A
left click creates a mark, a right click removes it. The type of the
mark depends on the modifier keys

|                 Type | Set (l-click) | Remove (r-click)             |
| -------------------: | :-----------: | :--------------------------- |
| Breakpoint permanent |   < none >    | < none > or Shift or Control |
| Breakpoint temporary |    Shift      | < none > or Shift or Control |
| Breakpoint dissabled |   Control     | < none > or Shift or Control |
|             Bookmark |    Other      | Other                        |

Breakpoint marks replace existend, if any. Bookmarks can be set on top
of a breackpoint, but only one bookmark per line.

'/
SUB view_mark_clicked CDECL( _
    BYVAL SView AS GtkSourceView PTR _
  , BYVAL Iter AS GtkTextIter PTR _
  , BYVAL Event AS GdkEvent PTR _
  , BYVAL Buff AS GtkSourceBuffer PTR)

  WITH *CAST(GdkEventButton PTR, Event)
?"  --> callback view_mark_clicked: ";.button,.state
    SELECT CASE AS CONST .Button
    CASE 1
      VAR mark = "fbdbg-____"
      SELECT CASE AS CONST .state - FIX_GDKEVENT_STATE ' set mark, delete existend (if any)
      CASE 0 :             MID(mark, 7, 4) = "brkp"
        gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkd")
        gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkt")
        VAR list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, mark)
        IF list THEN
          g_slist_free(list)
          gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, mark) : EXIT SUB
        END IF
      CASE GDK_SHIFT_MASK : MID(mark, 7, 4) = "brkt"
        gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkd")
        gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkp")
        VAR list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, mark)
        IF list THEN
          g_slist_free(list)
          gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, mark) : EXIT SUB
        END IF
      CASE GDK_CONTROL_MASK : MID(mark, 7, 4) = "brkd"
        VAR list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, "fbdbg-brkp")
        IF list THEN
          g_slist_free(list)
          gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkp")
          ' permanent was set before, new mark is DP type
          EXIT SELECT
        END IF
        list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, "fbdbg-brkt")
        IF list THEN
          g_slist_free(list)
          gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, "fbdbg-brkt")
          ' temporary was set before, new mark is DT type
          EXIT SELECT
        END IF
        list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, mark)
        IF 0 = list THEN /' new mark is DP type '/                     EXIT SELECT
        g_slist_free(list)
        gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, mark)
        ' restore disabled here, set either ASC("p") or ASC("t")
        mark[9] = ASC("p")
      CASE ELSE : MID(mark, 7, 4) = "book"
        VAR list = gtk_source_buffer_get_source_marks_at_iter(Buff, Iter, mark) _
          , widg = gtk_widget_get_parent(GTK_WIDGET(SView)) _
           , lnr = gtk_text_iter_get_line(Iter) + 1
        IF list THEN
          g_slist_free(list)
          SRC->delBookmark(lnr, widg)
          gtk_source_buffer_remove_source_marks(Buff, Iter, Iter, mark) : EXIT SUB
        END IF
        SRC->addBookmark(lnr, widg)
      END SELECT
      gtk_source_buffer_create_source_mark(Buff, NULL, mark, Iter)
    CASE 3
      ?" --> right mouse click here"
    CASE ELSE
    END SELECT
  END WITH
END SUB


/'* \brief Signal handler for bookmarks combo box (id="comboBookmarks")
\param Widget The widget that triggered the signal
\param user_data (unused)

This signale handler gets called when the user changed the selection of
the GtkComboBoxText for the booksmarks.

\todo Enter code

'/
SUB on_comboBookmark_changed CDECL ALIAS "on_comboBookmark_changed" ( _
  BYVAL Widget AS GtkWidget PTR, _
  BYVAL user_data AS gpointer) EXPORT ' Standard-Parameterliste

  VAR id = gtk_combo_box_get_active_id(GTK_COMBO_BOX(Widget))
  IF id = NULL THEN                                             EXIT SUB

  VAR lnr = CAST(gint, VALUINT(*id)) _
   , widg = GTK_WIDGET(0 + VALUINT(MID(*id, INSTR(*id, "&h"))))
  SRC->scroll(lnr, widg, 0)

  gtk_combo_box_set_active(GTK_COMBO_BOX(Widget), 0) ' this invoces the signal (itself) again!

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
  SRC->scroll(0, 0)

END SUB

