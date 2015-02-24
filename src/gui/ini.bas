/'* \file ini.bas
\brief The source code to read/write the ini file

\todo Move this code to folder core, when AGS and SARG are ready to use the CMake build system

\since 3.0
'/

'* \brief The upper boundary for IniUDT::SavExe array
#define EXEMAX 9
'* \brief The second upper boundary for IniUDT::BrkExe array
#define BRKMAX 10
'* \brief The second upper boundary for IniUDT::WtchExe array
#define WTCHMAX 9

'* \brief Class to handle values in the file fbdebugger.ini
TYPE IniUDT
  as gdouble _
    Scroll       '*< The scroll position for the current line
  as guint32 _
         Flags _ '*< All flags
      , CurPos _ '*< The position of the current line
      , DelVal _ '*< The value for step delays
,    ColForegr _ '*< The foreground color
,    ColLineNo _ '*< The background color for line numbers
,    ColBackgr _ '*< The background color
, ColBackgrCur _ '*< The background color for the current line
,     ColBreak _ '*< The background color for breack points
,  ColBreakTmp _ '*< The background color for temporary breack points
,   ColKeyword _ '*< The color to highlight keywords
,   ColStrings _ '*< The color to highlight strings
,    ColPrepro _ '*< The color to highlight pre-processors
,   ColComment   '*< The color to highlight comments
  as string _
        FbcExe _ '*< The path/file of the FreeBASIC compiler
,       IdeExe _ '*< The path/file of the IDE
,      CmdlFbc _ '*< Additional options for fbc
,      CmdlDbg _ '*< Additional options for debugger
,      FnamLog _ '*< The path/file of the log file
,      JitPrev _ '*< The Just In Time debugger
,      FontSrc = "Monospace 8" _ '*< The (default) name of the font for source views
,  SavExe(EXEMAX) _ '*< Array for path/name of last executables
,  CmdExe(EXEMAX) _ '*< Array for commands of last executables
,  BrkExe(EXEMAX, BRKMAX) _ '*< Array for breakpoints
, WtchExe(EXEMAX, WTCHMAX)  '*< Array for watch of executables

  ENUM
    FSH '*< Flag syntax highlighting
    FVM '*< Flag verbode mode
    FSL '*< Flag screen log
    FLT '*< Flag line trace
    FPT '*< Flag proc trace
    FTT '*< Flag tool tips
    FLN '*< Flag line numbers
  END ENUM

  declare constructor()
  declare function loadIni() as gchar ptr
  declare function saveIni() as gchar ptr
  declare property Bool(byval as integer) as gboolean
  declare property Bool(byval as integer, byval as gboolean)
  declare property Flag(byval as integer) as string
  declare property Flag(byval as integer, byval as string)
END TYPE


/'* \brief Constructor to initially load the ini file

This constructor initialy loads the file fbdebugger.ini on startup and
reports an error message in console window in case of a failure.

'/
CONSTRUCTOR IniUDT()
  var r = loadIni()
  if r then ?PROJ_NAME & ": " & *r
END CONSTRUCTOR


/'* \brief Receive the gboolean value of the specified flag
\param I The flag index [0, 31]
\returns The flag state [0, 1]

This property returns either TRUE or FALSE, depending on the flag state.

'/
property IniUDT.Bool(byval I as integer) as gboolean
  RETURN iif(BIT(Flags, I), TRUE, FALSE)
end property


/'* \brief Set the state of the specified flag
\param I The flag index [0, 31]
\param V The new flag state to set

This property sets a new flag state. 0 (zero) is off (= FALSE), any
other value sets on (= TRUE).

'/
property IniUDT.Bool(byval I as integer, byval V as gboolean)
  Flags = iif(V, _
              BITSET(Flags, I) _
            , BITRESET(Flags, I))
end property


/'* \brief Receive the textual value of the specified flag
\param I The flag index [0, 31]
\returns The flag state string ["TRUE", "FALSE"]

This property returns the flag state as string (either "TRUE" or
"FALSE").

'/
property IniUDT.Flag(byval I as integer) as string
  RETURN *iif(BIT(Flags, I), @"TRUE", @"FALSE")
end property


/'* \brief Set the state of the specified flag based on a string
\param I The flag index [0, 31]
\param V The new flag state to set

This property sets a new flag state. "TRUE" (non-case-sensitive) is on,
any other value sets off.

'/
property IniUDT.Flag(byval I as integer, byval V as string)
  Flags = iif(UCASE(ltrim(V, any !"\t\v ")) = "TRUE", _
              BITSET(Flags, I) _
            , BITRESET(Flags, I))
end property


/'* \brief Load the ini file from disk
\returns NULL on success, an error code otherwise

Member function to load the data from file fbdebugger.ini and populate
the member variables. Strings get trimmed, flags are set when input is
"TRUE" (non-case-sensitive).

'/
FUNCTION IniUDT.loadIni() AS gchar ptr
  VAR t = "", fontsize = "", fontname = "", c = 0, w = 0, b = 1 _
  , fnr = FREEFILE
  IF OPEN(ExePath & SLASH & "fbdebugger.ini" FOR INPUT AS fnr) _
                            THEN return __("Cannot open fbdebugger.ini")

  WHILE not eof(fnr)
    line input #fnr, t
    t = trim(t, any !"\t\v ")
    SELECT CASE left(t, 6)
    CASE "[CFG]=" :     ColForegr = CULNG(mid(t, 7))
    CASE "[CLN]=" :     ColLineNo = CULNG(mid(t, 7))
    CASE "[CRE]=" :     ColBackgr = CULNG(mid(t, 7))
    CASE "[CBC]=" :  ColBackgrCur = CULNG(mid(t, 7))
    CASE "[CPB]=" :      ColBreak = CULNG(mid(t, 7))
    CASE "[CTB]=" :   ColBreakTmp = CULNG(mid(t, 7))
    CASE "[CHK]=" :    ColKeyword = CULNG(mid(t, 7))
    CASE "[CHS]=" :    ColStrings = CULNG(mid(t, 7))
    CASE "[CHP]=" :     ColPrepro = CULNG(mid(t, 7))
    CASE "[CHC]=" :    ColComment = CULNG(mid(t, 7))

    CASE "[POS]=" :        CurPos = CULNG(mid(t, 7))
    CASE "[DEL]=" :        DelVal = CULNG(mid(t, 7))

    CASE "[FBC]=" :        FbcExe = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[IDE]=" :        IdeExe = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[FCD]=" :       CmdlFbc = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[DBG]=" :       CmdlDbg = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[LOG]=" :       FnamLog = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[SRC]=" :       FontSrc = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[JIT]=" :       JitPrev = ltrim(mid(t, 7), any !"\t\v ")

    CASE "[FSH]=" : Flag(FSH) = mid(t, 7)
    CASE "[FVM]=" : Flag(FVM) = mid(t, 7)
    CASE "[FSL]=" : Flag(FSL) = mid(t, 7)
    CASE "[FLT]=" : Flag(FLT) = mid(t, 7)
    CASE "[FPT]=" : Flag(FPT) = mid(t, 7)
    CASE "[FTT]=" : Flag(FTT) = mid(t, 7)
    CASE "[FLN]=" : Flag(FLN) = mid(t, 7)

    CASE "[CMD]=" :     CmdExe(c) = ltrim(mid(t, 7), any !"\t\v ")
    CASE "[BRK]=" :  BrkExe(c, b) = ltrim(mid(t, 7), any !"\t\v ")
      b += 1 : if b > ubound(BrkExe, 2) then b = ubound(BrkExe, 2)
    CASE "[WTC]=" : WtchExe(c, w) = ltrim(mid(t, 7), any !"\t\v ")
      w += 1 : if w > ubound(WtchExe, 2) then w = ubound(WtchExe, 2)
    CASE "[EXE]=" : t = RTrim(Mid(t, 7)) : If Dir(t) = "" then exit select
#ifndef __FB_UNIX__
      if 0 = InStr(LCase(t), ".exe") Then   /' not for UNIX '/ exit select
#endif
 			SavExe(c) = t : CmdExe(c) = "" '27/02/2013
 			c += 1 : w = 0 : b = 1 : if c > ubound(SavExe) then c = ubound(SavExe)

'' for compatibility
    CASE "[DPO]=" : CurPos = CULNG(mid(t, 7))
    CASE "[HLK]=" : Flag(FSH) = mid(t, 7)
    CASE "[TTP]=" : Flag(FTT) = mid(t, 7)
    CASE "[CNK]=" : ColKeyword = CULNG(mid(t, 7)) ' tag renamed [CHK]
    CASE "[FTN]=" : FontSrc = ltrim(mid(t, 7), any !"\t\v ") & " " & fontsize
    CASE "[FTS]=" : FontSrc = fontname & " " & ltrim(mid(t, 7), any !"\t\v ")
    CASE ELSE : ?!"unknow ini entry:\n  " & t
    END SELECT
  WEND
  Scroll = CurPos / 99

  CLOSE #fnr
  RETURN NULL
END FUNCTION


/'* \brief Save data to ini file on disk
\returns NULL on success, an error code otherwise

Member function to save the data from the member variables to file
fbdebugger.ini. Strings get trimmed before saving.

'/
FUNCTION IniUDT.saveIni() AS gchar ptr
  If Dir("fbdebuggersav.ini") <> "" Then Kill("fbdebuggersav.ini")
	If Dir("fbdebugger.ini") <> "" Then	Name("fbdebugger.ini", "fbdebuggersav.ini")

  VAR fnr = FREEFILE
  IF OPEN(ExePath & SLASH & "fbdebugger.ini" FOR OUTPUT AS fnr) _
                      THEN return __("Cannot write file fbdebugger.ini")

  If len(FbcExe) Then
  	Print #fnr, "[FBC]=" & trim( FbcExe, any !"\t\v ")
  	If LEN(CmdlFbc) Then Print #fnr, "[FCD]=" & trim(CmdlFbc, any !"\t\v ")
  EndIf
  If LEN( IdeExe) Then Print #fnr, "[IDE]=" & trim(IdeExe, any !"\t\v ")
  If LEN(CmdlDbg) Then Print #fnr, "[DBG]=" & trim(CmdlDbg, any !"\t\v ")
  If LEN(FnamLog) Then Print #fnr, "[LOG]=" & trim(FnamLog, any !"\t\v ")
  If LEN(FontSrc) Then Print #fnr, "[SRC]=" & trim(FontSrc, any !"\t\v ")
  If LEN(JitPrev) Then Print #fnr, "[JIT]=" & JitPrev

	For i As Integer = 0 To ubound(SavExe)
		If len(SavExe(i)) Then
			Print #fnr, "[EXE]=" & SavExe(i)
			If len(CmdExe(i)) Then Print #fnr, "[CMD]=" & CmdExe(i)

  		For j As Integer = 0 To ubound(WtchExe, 2)
				If 0 = len(WtchExe(i,j)) Then                           exit for
  			Print #fnr, "[WTC]=" & WtchExe(i,j)
			Next

			For j As Integer = 1 To ubound(BrkExe, 2)
				If len(BrkExe(i,j)) Then	Print #fnr, "[BRK]=" & BrkExe(i,j)
			Next
		End If
	Next

  print #fnr, "[POS]=" & CurPos
  print #fnr, "[DEL]=" & DelVal

  print #fnr, "[CFG]=&h" & hex(   ColForegr, 6)
  print #fnr, "[CLN]=&h" & hex(   ColLineNo, 6)
  print #fnr, "[CRE]=&h" & hex(   ColBackgr, 6)
  print #fnr, "[CBC]=&h" & hex(ColBackgrCur, 6)
  print #fnr, "[CPB]=&h" & hex(    ColBreak, 6)
  print #fnr, "[CTB]=&h" & hex( ColBreakTmp, 6)
  print #fnr, "[CHK]=&h" & hex(  ColKeyword, 6)
  print #fnr, "[CHS]=&h" & hex(  ColStrings, 6)
  print #fnr, "[CHP]=&h" & hex(   ColPrepro, 6)
  print #fnr, "[CHC]=&h" & hex(  ColComment, 6)

  print #fnr, "[FSH]=" & Flag(FSH)
  print #fnr, "[FVM]=" & Flag(FVM)
  print #fnr, "[FSL]=" & Flag(FSL)
  print #fnr, "[FLT]=" & Flag(FLT)
  print #fnr, "[FPT]=" & Flag(FTT)
  print #fnr, "[TTP]=" & Flag(FTT)
  print #fnr, "[FLN]=" & Flag(FLN)

  CLOSE #fnr :                                               RETURN NULL
END FUNCTION

DIM SHARED AS IniUDT PTR INI '*< The global INI variable for this class
