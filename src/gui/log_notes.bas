/'* \file log_notes.bas
\brief Functions to handle the non-modal dialogs with text views.

This file contains code to handle non-modal dialog windows with text
view widgets, used for

- screen log
- file log
- notes

\since 3.0
'/


TYPE LOG_Udt
  AS STRING Xml
  'as GtkDialog PTR LogDialog, LogFileDialog, NotesDialog
  declare CONSTRUCTOR()
  declare sub Notes(BYVAL Txt AS gchar PTR = 0)
  declare sub ScreenLog()
  declare sub FileLog()
END TYPE

CONSTRUCTOR LOG_Udt()
  VAR fnam = "log.ui", fnr = FREEFILE
  'VAR fnam = "Expand.ui", fnr = FREEFILE
  IF OPEN(fnam FOR INPUT AS fnr) THEN
    ?"Cannot open " & fnam : end 1
    'g_error("Cannot open " & fnam)
  ELSE
    Xml = string(lof(fnr), 0)
    get #fnr, , Xml
    CLOSE #fnr
  END IF
END CONSTRUCTOR

SUB LOG_Udt.Notes(BYVAL Txt AS gchar PTR = 0)
  STATIC AS GtkWidget PTR dia
  STATIC AS GtkTextView PTR gtv
  STATIC AS GtkTextBuffer PTR buf

  IF 0 = buf THEN
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
    buf = gtk_text_view_get_buffer(gtv)
  END IF

  IF Txt ANDALSO 0 <> Txt[0] THEN gtk_text_buffer_set_text(buf, Txt, -1)

  IF gtk_widget_get_visible(dia) THEN
    gtk_widget_hide(dia)
  ELSE
    gtk_widget_show(dia)
  END IF
END SUB

DIM SHARED AS LOG_Udt PTR TXT
TXT = NEW LOG_Udt
