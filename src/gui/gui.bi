/'* \file gui.bi
\brief The central header that provides gui stuff for core part

This file contains the declarations of the GUI part.

\since 3.0
'/


'' wired stuff to fix bugs
#IFDEF __FB_UNIX__
#DEFINE FIX_GDKEVENT_STATE 16
#ELSE
#DEFINE FIX_GDKEVENT_STATE 0

'' for GdkPixbuf-2.0.gir
#UNDEF gdk_pixbuf_new_from_file_at_size
#DEFINE gdk_pixbuf_new_from_file_at_size gdk_pixbuf_new_from_file_at_size_utf8

EXTERN "C" LIB "gdk_pixbuf-2.0"
DECLARE FUNCTION gdk_pixbuf_new_from_file_at_size(BYVAL AS CONST char PTR, BYVAL AS gint /'int'/, BYVAL AS gint /'int'/, BYVAL AS GError PTR PTR) AS GdkPixbuf PTR
END EXTERN

#ENDIF
'' end wired stuff

'' to get removed (code in testing.bas)
declare SUB access_viol( _
    BYVAL Adr AS gint _
  , byval Fnam AS zSTRING PTR _
  , byval Proc AS zSTRING PTR _
  , byval Lin_ AS gint _
  , byval Text AS zSTRING PTR _
  )


'* \brief class for global handling of the XML file fbdbg.ui
TYPE GUIData
  AS GtkBuilder PTR XML '*< The GthBuilder structure in use
  AS GObject PTR _
           window1 _ '*< The GObject PTR for the main window
  ,  tstoreProcVar _ '*< The GObject PTR for the GtkTreeStore in ProcVar tab
  ,    tstoreProcs _ '*< The GObject PTR for the GtkTreeStore in Procs tab
  ,  tstoreThreads _ '*< The GObject PTR for the GtkTreeStore in Threads tab
  ,    tstoreWatch _ '*< The GObject PTR for the GtkTreeStore in Watch tab
  ,   lstoreMemory _ '*< The GObject PTR for the GtkListStore in memory tab
  ,   tviewProcVar _ '*< The GObject PTR for the GtkTreeView in ProcVar tab
  ,     tviewProcs _ '*< The GObject PTR for the GtkTreeView in Procs tab
  ,   tviewThreads _ '*< The GObject PTR for the GtkTreeView in Threads tab
  ,     tviewWatch _ '*< The GObject PTR for the GtkTreeView in Watch tab
  ,    lviewMemory _ '*< The GObject PTR for the GtkTreeView in memory tab
  ,     butStopVar _ '*< The GObject PTR for the button StopVar in main window
  ,         nbook2 _ '*< The GObject PTR for the right notebook
  ,         watch1 _ '*< The GObject PTR for the label watch 1
  ,         watch2 _ '*< The GObject PTR for the label watch 2
  ,         watch3 _ '*< The GObject PTR for the label watch 3
  ,         watch4   '*< The GObject PTR for the label watch 4
  ', comboBookmarks _ '*< The GObject PTR for the bookmarks combo box text
END TYPE


/'* \brief Class to handle variable actions and status bar messages

This class handles the variable actions and the status bar messages. An
action can be sensitive or non-sensitive (greyed-out).

\todo Group the actions in a GSList, in order to shorten the code (g_slist_foreach)

\todo Decide if ENUM should be global

'/
TYPE ActionsUDT ' source code in actions.bas
  AS GtkLabel PTR _
    SbarLab1 _ '*< Status bar label message (left)
  , SbarLab2 _ '*< Status bar label thread
  , SbarLab3 _ '*< Status bar label module
  , SbarLab4 _ '*< Status bar label procedure
  , SbarLab5   '*< Status bar label timer (right)
  AS GtkAction PTR _
          act_step _ '*< Action ...
   , act_step_over _ '*< Action ...
  , act_step_start _ '*< Action ...
    , act_step_end _ '*< Action ...
    , act_step_out _ '*< Action ...
        , act_auto _ '*< Action ...
         , act_run _ '*< Action ...
     , act_fastrun _ '*< Action ...
        , act_stop _ '*< Action ...
       , act_runto _ '*< Action ...
        , act_free _ '*< Action ...
        , act_kill _ '*< Action ...
      , act_exemod _ '*< Action ...
   ,act_stringshow _ '*< Action ...
     ,act_brkenable _ '*< Action ...
,act_dlllist   _  '*< Action ...
,act_brkmanage   _  '*< Action ...
,act_brkset   _  '*< Action ...
,act_brktempset   _  '*< Action ...
,act_bzexchange   _  '*< Action ...
,act_bmknext   _  '*< Action ...
,act_bmkprev   _  '*< Action ...
,act_lineaddress   _  '*< Action ...
,act_lineasm   _  '*< Action ...
,act_procaddresses   _  '*< Action ... 
,act_procasm   _  '*< Action ... 
,act_procbacktrack   _  '*< Action ...
,act_proccall   _  '*< Action ...
,act_procchain   _  '*< Action ...
,act_processlist   _  '*< Action ...
,act_procfollow   _  '*< Action ...
,act_procinvar   _  '*< Action ...
,act_procnofollow   _  '*< Action ...
,act_procsrcasm   _  '*< Action ...
,act_quickedit   _  '*< Action ...
,act_wtch1   _  '*< Action ...
,act_wtch2   _  '*< Action ...
,act_wtch3   _  '*< Action ...
,act_wtch4   _  '*< Action ...
,act_wtchdel   _  '*< Action ...
,act_wtchdellall   _  '*< Action ...
,act_wtchnotrace   _  '*< Action ...
,act_wtchtrace   _  '*< Action ...
,act_automulti   _  '*< Action ...
,act_varsrcshow   _  '*< Action ...
,act_varsrcwtch   _  '*< Action ...
,act_varwatched   _  '*< Action ...
,act_varwtchtrace   _  '*< Action ...
,act_threadcreate   _  '*< Action ...
,act_threadcollapse   _  '*< Action ...
,act_threadexpand   _  '*< Action ...
,act_threadkill   _  '*< Action ...
,act_threadline   _  '*< Action ...
,act_threadlist   _  '*< Action ...
,act_threadproc   _  '*< Action ...
,act_threadselect   _  '*< Action ...
,act_threadvar   _  '*< Action ...
,act_tuto   _  '*< Action ...
,act_varbrk   _  '*< Action ...
,act_varcharpos   _  '*< Action ...
,act_varclipall   _  '*< Action ...
,act_varclipsel   _  '*< Action ...
,act_varderefdump   _  '*< Action ...
,act_vardump   _  '*< Action ...
,act_varedit   _  '*< Action ...
,act_varexpand   _  '*< Action ...
,act_varindex   _  '*< Action ...
,act_varlistall   _  '*< Action ...
,act_varlistsel   _  '*< Action ...
   , act_minicmd   '*< Action ...
     
     
  AS STRING _
    Message    '*< The current status bar message (left position)

  'ENUM
  '  RTSTEP '*< Run mode ...
  '  RTRUN  '*< Run mode ...
  '  RTFREE '*< Run mode ...
  '  RTFRUN '*< Run mode ...
  '  RTAUTO '*< Run mode ...
  '  RTEND  '*< Run mode ...
  'END ENUM

  DECLARE SUB setState(BYVAL AS INTEGER)
  DECLARE CONSTRUCTOR()
  'DECLARE DESTRUCTOR()
END TYPE


/'* \brief Class to handle expand dialogs

This class is used to handle the expand non-modal dialog windows.

'/
TYPE ExpandUdt ' source code in expand.bas
  AS STRING Xml
  AS GSList PTR List = NULL

  DECLARE CONSTRUCTOR()
  DECLARE SUB addXpd(BYVAL AS SUB CDECL(BYVAL AS GtkTreeStore PTR, BYVAL AS gpointer), BYVAL AS gpointer)
  DECLARE SUB destroyAll()
END TYPE


/'* \brief Class to handle the dialogs with text view

This class provides member functions to handle non-modal dialogs for
text views for

- Notes (editable)
- screen LOG (editable)
- file LOG (non-editable)

\todo Decide if we need a getNotes method here

'/
TYPE LOG_Udt ' source code in log_notes.bas
  AS STRING _
    Xml          '*< The design for the dialog windows (context of file log.ui)
  AS GtkTextBuffer PTR _
    BufNotes _   '*< The text buffer of the notes dialog
  , BufLogFile _ '*< The text buffer of the screen file dialog
  , BufLogScreen '*< The text buffer of the screen log dialog

  DECLARE CONSTRUCTOR()
  DECLARE SUB Notes(BYVAL AS gchar PTR = 0)
  DECLARE SUB add2Notes(BYVAL Txt AS gchar PTR = 0)
  'DECLARE SUB ScreenLog()
  DECLARE SUB FileLog(BYVAL AS gchar PTR)
END TYPE


/'* \brief Class to handle the context of the source notebook

This class prepares a GtkSourceView for highlighting the FreeBASIC
syntax and handles the pages of the source notebook. A single
GtkSourceView is used for all pages, and the files are loaded in to
several GtkSourceBuffers. Each page contains a GtkScrolledWindow that
is used as the parent for the GtkSourceView.

When switching a page, the GtkSourceView gets reparent to the related
scrolled window and the related text buffer gets connected.

'/
TYPE SrcNotebook ' source code in source.bas
  AS gdouble _
    ScrPos    '*< The position to scroll the current line in the source views
  AS guint _
    Pages _   '*< The number of pages in the notebook
  , ScrLine _ '*< The line number of the source current line
  , LenCur    '*< The number of characters in the source current line
  AS GObject PTR _
    MenuSrc _ '*< The popup menu for the source views
  , BuffCur   '*< The source buffer for current source line
  AS GtkWidget PTR _
    ViewCur _ '*< The source view for current source line
  , ScrWidg   '*< The widget of the current source line
  AS GtkComboBoxText PTR _
    CBMarks   '*< The combo box for book marks
  AS GtkNotebook PTR _
    NoteBok   '*< The notebook for source views
  AS GtkSourceMarkAttributes PTR _
    Attr0 _   '*< The attributes for inactive breakpoint marks
  , Attr1 _   '*< The attributes for temporary breakpoint marks
  , Attr2 _   '*< The attributes for permanent breakpoint marks
  , Attr3     '*< The attributes for book mark
  AS GtkSourceStyleScheme PTR _
    Schema    '*< The style scheme for syntax highlighting
  AS GtkSourceStyleSchemeManager PTR _
    Manager    '*< The manager for style schemes
  AS GtkSourceLanguage PTR _
    Lang      '*< The language definition for syntax highlighting
  AS PangoFontDescription PTR _
    Font      '*< The Pango font description for source views
  AS STRING _
    LmPaths   '*< The list of paths (gchar PTRs)

  DECLARE CONSTRUCTOR()
  DECLARE DESTRUCTOR()
  DECLARE PROPERTY ScrollPos(BYVAL AS gdouble)
  DECLARE PROPERTY SchemeID(BYVAL AS CONST gchar PTR)
  DECLARE PROPERTY FontID(BYVAL AS CONST gchar PTR)
  DECLARE FUNCTION addBas(BYVAL AS gchar PTR, BYVAL AS gchar PTR) AS GtkWidget PTR

  DECLARE FUNCTION getAttr(byval AS gchar ptr) AS GtkSourceMarkAttributes PTR
  DECLARE FUNCTION getBuffLine(byval as GtkTextBuffer ptr, byval as GtkTextIter ptr) AS string
  DECLARE SUB addBookmark(BYVAL AS gint, BYVAL AS GtkWidget PTR)
  DECLARE SUB delBookmark(BYVAL AS gint, BYVAL AS GtkWidget PTR)

  DECLARE SUB changeMark(BYVAL AS gint, BYVAL AS GtkWidget PTR, BYREF AS STRING = "")
  DECLARE SUB scroll(BYVAL AS gint, BYVAL AS GtkWidget PTR, BYVAL AS guint32 = 1)
  DECLARE SUB settingsChanged()
  DECLARE SUB remove(BYVAL AS GtkWidget PTR)
  DECLARE SUB removeAll()
END TYPE
