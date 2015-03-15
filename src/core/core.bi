/'* \file core.bi
\brief Binding to provide core SUBs / FUNCTIONs to the GUI part

This header contains all UDTs /  SUBs / FUNCTIONs / EXTERNs declarations
from the core part that should be visible in the GUI part.

\todo Add entries

\since 3.0
'/

'* The slash character for paths
#IFDEF __FB_UNIX__
#DEFINE SLASH "/"
#ELSE
#DEFINE SLASH "\"
#ENDIF

'* \brief The upper boundary for IniUDT::SavExe array
#DEFINE EXEMAX 9
'* \brief The second upper boundary for IniUDT::BrkExe array
#DEFINE BRKMAX 10
'* \brief The second upper boundary for IniUDT::WtchExe array
#DEFINE WTCHMAX 9

'* \brief Class to handle values in the file fbdebugger.ini
TYPE IniUDT
  AS guint32 _
         Flags _ '*< All flags
,       CurPos _ '*< The position of the current line
,       DelVal _ '*< The value for step delays
,    ColForegr _ '*< The foreground color
,    ColLineNo _ '*< The background color for line numbers
,    ColBackgr _ '*< The background color
, ColBackgrCur _ '*< The background color for the current line
,   ColKeyword _ '*< The color to highlight keywords
,   ColStrings _ '*< The color to highlight strings
,    ColPrepro _ '*< The color to highlight pre-processors
,   ColComment _ '*< The color to highlight comments
,   ColNumbers _ '*< The color to highlight numbers
,    ColEscape _ '*< The color to highlight escape characters
,    ColCursor   '*< The color to highlight the cursor/selection
',     ColBreak _ '*< The background color for breack points
',  ColBreakTmp   '*< The background color for temporary breack points
  AS STRING _
        FbcExe _ '*< The path/file of the FreeBASIC compiler
,       IdeExe _ '*< The path/file of the IDE
,      CmdlFbc _ '*< Additional options for fbc
,      FnamLog _ '*< The path/file of the log file
,      JitPrev _ '*< The Just In Time debugger
,      FontSrc = "Monospace 8" _ '*< The (default) name of the font for source views
,      StlSchm = "fbdebugger"  _ '*< The (default) name of the style scheme for source views
,  SavExe(EXEMAX) _ '*< Array for path/name of last executables
,  CmdExe(EXEMAX) _ '*< Array for commands of last executables
,  BrkExe(EXEMAX, BRKMAX) _ '*< Array for breakpoints
, WtchExe(EXEMAX, WTCHMAX)  '*< Array for watch of executables

  ENUM ' max 32 enumerators (guint32)
    FSH '*< Flag syntax highlighting
    FVM '*< Flag verbose mode
    FSL '*< Flag screen log
    FFL '*< Flag file log
    FLT '*< Flag line trace
    FPT '*< Flag proc trace
    FTT '*< Flag tool tips
    FLN '*< Flag line numbers
  END ENUM

  DECLARE CONSTRUCTOR()
  DECLARE FUNCTION loadIni() AS gchar PTR
  DECLARE FUNCTION saveIni() AS gchar PTR
  DECLARE PROPERTY Bool(BYVAL AS INTEGER) AS gboolean
  DECLARE PROPERTY Bool(BYVAL AS INTEGER, BYVAL AS gboolean)
  DECLARE PROPERTY Flag(BYVAL AS INTEGER) AS STRING
  DECLARE PROPERTY Flag(BYVAL AS INTEGER, BYVAL AS STRING)
END TYPE

