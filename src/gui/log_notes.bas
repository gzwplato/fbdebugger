/'* \file log_notes.bas
\brief Functions to handle the non-modal dialogs with text views.

This file contains code to handle non-modal dialog windows with text
view widgets, used for

- Notes (editable)
- screen LOG (editable)
- file LOG (non-editable)

\since 3.0
'/



/'* \brief Class to handle the dialogs with text view

This class provides member functions to handle non-modal dialogs for
text views for

- Notes (editable)
- screen LOG (editable)
- file LOG (non-editable)

\todo Decide if we need a getNotes method here

'/
TYPE LOG_Udt
  AS STRING Xml
  AS GtkTextBuffer PTR BufNotes

  DECLARE CONSTRUCTOR()
  DECLARE SUB Notes(BYVAL Txt AS gchar PTR = 0)
  DECLARE SUB add2Notes(BYVAL Txt AS gchar PTR = 0)
  DECLARE SUB ScreenLog()
  DECLARE SUB FileLog()
END TYPE


/'* \brief Constructor reads the XML file

Constructor to read the XML file containing the dialog window design.
This file is used to build the dialog windows.

'/
CONSTRUCTOR LOG_Udt()
  VAR fnam = "log.ui", fnr = FREEFILE
  IF OPEN(fnam FOR INPUT AS fnr) THEN
    ?PROJ_NAME & ": Cannot open " & fnam : end 1
    'g_error("Cannot open " & fnam)
  ELSE
    Xml = string(lof(fnr), 0)
    get #fnr, , Xml
    CLOSE #fnr
  END IF
END CONSTRUCTOR


/'* \brief Add text to the notes text view buffer
\param Txt The context to add (may be NULL or empty string)

Member function to add some text to the notes text buffer. If the notes
window isn't realized yet, the window gets opened first.

\todo Decide if we add context from ini file when opening the window.

'/
SUB LOG_Udt.add2Notes(BYVAL Txt AS gchar PTR = 0)
  IF 0 = Txt ORELSE 0 = Txt[0] THEN EXIT SUB
  IF BufNotes _
    THEN gtk_text_buffer_insert_at_cursor(BufNotes, Txt, -1) _
    ELSE Notes(Txt)
END SUB


/'* \brief Toggle notes window
\param Txt Context to set in buffer (may be NULL or empty string)

Member function to toggle the state of the notes window, either visible
or invisible. When called first, a new dialog window gets created.

'/
SUB LOG_Udt.Notes(BYVAL Txt AS gchar PTR = 0)
  STATIC AS GtkWidget PTR dia
  STATIC AS GtkTextView PTR gtv

  IF 0 = BufNotes THEN
    VAR build = gtk_builder_new()
    DIM AS GError PTR meld
    IF 0 = gtk_builder_add_from_string(build, Xml, LEN(Xml), @meld) THEN
      WITH *meld
        ?"Fehler/Error (GTK-Builder in LOG_Udt.Notes):"
        ?*.message
      END WITH
      g_error_free(meld)
      END 2
    END IF
    dia = GTK_WIDGET(gtk_builder_get_object(build, "window1"))
    gtv = GTK_TEXT_VIEW(gtk_builder_get_object(build, "textview1"))
    gtk_builder_connect_signals(build, 0)
    g_object_unref(build)
    gtk_window_set_title(GTK_WINDOW(dia), "Notes")
    BufNotes = gtk_text_view_get_buffer(gtv)
  END IF

  IF Txt ANDALSO 0 <> Txt[0] THEN gtk_text_buffer_set_text(BufNotes, Txt, -1)

  IF gtk_widget_get_visible(dia) THEN
    gtk_widget_hide(dia)
  ELSE
    gtk_widget_show(dia)
  END IF
END SUB

'* \brief The global class to handle text windows (LOG & Notes)
DIM SHARED AS LOG_Udt PTR TXT
