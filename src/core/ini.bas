/'* \file ini.bas
\brief The source code to read/write the ini file

\todo Move this code to folder core, when AGS and SARG are ready to use the CMake build system

\todo Remove break point color code

\since 3.0
'/


/'* \brief Constructor to initially load the ini file

This constructor initialy loads the file fbdebugger.ini on startup and
reports an error message in console window in case of a failure.

'/
CONSTRUCTOR IniUDT()
  VAR r = loadIni()
  IF r THEN ?PROJ_NAME & ": " & *r
?" CONSTRUCTOR IniUDT"
END CONSTRUCTOR


/'* \brief Receive the gboolean value of the specified flag
\param I The flag index [0, 31]
\returns The flag state [0, 1]

This property returns either TRUE or FALSE, depending on the flag state.

'/
PROPERTY IniUDT.Bool(BYVAL I AS INTEGER) AS gboolean
  RETURN IIF(BIT(Flags, I), TRUE, FALSE)
END PROPERTY


/'* \brief Set the state of the specified flag
\param I The flag index [0, 31]
\param V The new flag state to set

This property sets a new flag state. 0 (zero) is off (= FALSE), any
other value sets on (= TRUE).

'/
PROPERTY IniUDT.Bool(BYVAL I AS INTEGER, BYVAL V AS gboolean)
  Flags = IIF(V, _
              BITSET(Flags, I) _
            , BITRESET(Flags, I))
END PROPERTY


/'* \brief Receive the textual value of the specified flag
\param I The flag index [0, 31]
\returns The flag state string ["TRUE", "FALSE"]

This property returns the flag state as string (either "TRUE" or
"FALSE").

'/
PROPERTY IniUDT.Flag(BYVAL I AS INTEGER) AS STRING
  RETURN *IIF(BIT(Flags, I), @"TRUE", @"FALSE")
END PROPERTY


/'* \brief Set the state of the specified flag based on a string
\param I The flag index [0, 31]
\param V The new flag state to set

This property sets a new flag state. "TRUE" (non-case-sensitive) is on,
any other value sets off.

'/
PROPERTY IniUDT.Flag(BYVAL I AS INTEGER, BYVAL V AS STRING)
  Flags = IIF(UCASE(LTRIM(V, ANY !"\t\v ")) = "TRUE", _
              BITSET(Flags, I) _
            , BITRESET(Flags, I))
END PROPERTY


/'* \brief Load the ini file from disk
\returns NULL on success, an error code otherwise

Member function to load the data from file fbdebugger.ini and populate
the member variables. Strings get trimmed, flags are set when input is
"TRUE" (non-case-sensitive).

'/
FUNCTION IniUDT.loadIni() AS gchar PTR
  VAR t = "", fontsize = "", fontname = "", c = 0, w = 0, b = 1 _
  , fnr = FREEFILE
  IF OPEN(EXEPATH & SLASH & "fbdebugger.ini" FOR INPUT AS fnr) _
                            THEN RETURN __("Cannot open fbdebugger.ini")

  WHILE NOT EOF(fnr)
    LINE INPUT #fnr, t
    t = TRIM(t, ANY !"\t\v ")
    SELECT CASE LEFT(t, 6)
    CASE "[CFG]=" :    ColForegr = CULNG(MID(t, 7))
    CASE "[CLN]=" :    ColLineNo = CULNG(MID(t, 7))
    CASE "[CRE]=" :    ColBackgr = CULNG(MID(t, 7))
    CASE "[CBC]=" : ColBackgrCur = CULNG(MID(t, 7))
    'CASE "[CPB]=" :     ColBreak = CULNG(MID(t, 7))
    'CASE "[CTB]=" :  ColBreakTmp = CULNG(MID(t, 7))
    CASE "[CHK]=" :   ColKeyword = CULNG(MID(t, 7))
    CASE "[CHS]=" :   ColStrings = CULNG(MID(t, 7))
    CASE "[CHP]=" :    ColPrepro = CULNG(MID(t, 7))
    CASE "[CHC]=" :   ColComment = CULNG(MID(t, 7))
    CASE "[CHN]=" :   ColNumbers = CULNG(MID(t, 7))
    CASE "[CHE]=" :    ColEscape = CULNG(MID(t, 7))
    CASE "[CHL]=" :    ColCursor = CULNG(MID(t, 7))

    CASE "[POS]=" :       CurPos = CULNG(MID(t, 7))
    CASE "[DEL]=" :       DelVal = CULNG(MID(t, 7))

    CASE "[FBC]=" :       FbcExe = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[IDE]=" :       IdeExe = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[FCD]=" :      CmdlFbc = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[LOG]=" :      FnamLog = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[SRC]=" :      FontSrc = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[JIT]=" :      JitPrev = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[NSS]=" :      StlSchm = LTRIM(MID(t, 7), ANY !"\t\v ")

    CASE "[FSH]=" :    Flag(FSH) = MID(t, 7)
    CASE "[FVM]=" :    Flag(FVM) = MID(t, 7)
    CASE "[FSL]=" :    Flag(FSL) = MID(t, 7)
    CASE "[FFL]=" :    Flag(FFL) = MID(t, 7)
    CASE "[FLT]=" :    Flag(FLT) = MID(t, 7)
    CASE "[FPT]=" :    Flag(FPT) = MID(t, 7)
    CASE "[FTT]=" :    Flag(FTT) = MID(t, 7)
    CASE "[FLN]=" :    Flag(FLN) = MID(t, 7)

    CASE "[CMD]=" :    CmdExe(c) = LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE "[BRK]=" : BrkExe(c, b) = LTRIM(MID(t, 7), ANY !"\t\v ")
      b += 1 : IF b > UBOUND(BrkExe, 2) THEN b = UBOUND(BrkExe, 2)
    CASE "[WTC]=" : WtchExe(c, w) = LTRIM(MID(t, 7), ANY !"\t\v ")
      w += 1 : IF w > UBOUND(WtchExe, 2) THEN w = UBOUND(WtchExe, 2)
    CASE "[EXE]=" : t = RTRIM(MID(t, 7)) : IF DIR(t) = "" THEN EXIT SELECT
#IFNDEF __FB_UNIX__
      IF 0 = INSTR(LCASE(t), ".exe") THEN   /' not for UNIX '/ EXIT SELECT
#ENDIF
      SavExe(c) = t : CmdExe(c) = ""
      c += 1 : w = 0 : b = 1 : IF c > UBOUND(SavExe) THEN c = UBOUND(SavExe)

'' for compatibility
    CASE "[DPO]=" : CurPos = CULNG(MID(t, 7))
    CASE "[HLK]=" : Flag(FSH) = MID(t, 7)
    CASE "[TTP]=" : Flag(FTT) = MID(t, 7)
    CASE "[CNK]=" : ColKeyword = CULNG(MID(t, 7)) ' tag renamed [CHK]
    CASE "[FTN]=" : FontSrc = LTRIM(MID(t, 7), ANY !"\t\v ") & " " & fontsize
    CASE "[FTS]=" : FontSrc = fontname & " " & LTRIM(MID(t, 7), ANY !"\t\v ")
    CASE ELSE : ?!"unknown ini entry:\n  " & t
    END SELECT
  WEND : CLOSE #fnr :                                        RETURN NULL
END FUNCTION


/'* \brief Save data to ini file on disk
\returns NULL on success, an error code otherwise

Member function to save the data from the member variables to file
fbdebugger.ini. Strings get trimmed before saving.

'/
FUNCTION IniUDT.saveIni() AS gchar PTR
  IF DIR("fbdebuggersav.ini") <> "" THEN _
    IF KILL("fbdebuggersav.ini") THEN                   RETURN __("Cannot kill file fbdebuggersav.ini")
  IF DIR("fbdebugger.ini")    <> "" THEN _
    IF NAME("fbdebugger.ini", "fbdebuggersav.ini") THEN RETURN __("Cannot rename file fbdebugger.ini")

  VAR fnr = FREEFILE
  IF OPEN(EXEPATH & SLASH & "fbdebugger.ini" FOR OUTPUT AS fnr) _
                                                   THEN RETURN __("Cannot write file fbdebugger.ini")

  IF LEN(FbcExe) THEN
    PRINT #fnr, "[FBC]=" & TRIM( FbcExe, ANY !"\t\v ")
    IF LEN(CmdlFbc) THEN PRINT #fnr, "[FCD]=" & TRIM(CmdlFbc, ANY !"\t\v ")
  ENDIF
  IF LEN( IdeExe) THEN PRINT #fnr, "[IDE]=" & TRIM( IdeExe, ANY !"\t\v ")
  IF LEN(FnamLog) THEN PRINT #fnr, "[LOG]=" & TRIM(FnamLog, ANY !"\t\v ")
  IF LEN(FontSrc) THEN PRINT #fnr, "[SRC]=" & TRIM(FontSrc, ANY !"\t\v ")
  IF LEN(JitPrev) THEN PRINT #fnr, "[JIT]=" & JitPrev
  IF LEN(StlSchm) THEN PRINT #fnr, "[NSS]=" & StlSchm

  FOR i AS INTEGER = 0 TO UBOUND(SavExe)
    IF LEN(SavExe(i)) THEN
      PRINT #fnr, "[EXE]=" & SavExe(i)
      IF LEN(CmdExe(i)) THEN PRINT #fnr, "[CMD]=" & CmdExe(i)

      FOR j AS INTEGER = 0 TO UBOUND(WtchExe, 2)
        IF 0 = LEN(WtchExe(i,j)) THEN                           EXIT FOR
        PRINT #fnr, "[WTC]=" & WtchExe(i,j)
      NEXT

      FOR j AS INTEGER = 1 TO UBOUND(BrkExe, 2)
        IF LEN(BrkExe(i,j)) THEN  PRINT #fnr, "[BRK]=" & BrkExe(i,j)
      NEXT
    END IF
  NEXT

  PRINT #fnr, "[POS]=" & CurPos
  PRINT #fnr, "[DEL]=" & DelVal

  PRINT #fnr, "[CFG]=&h" & HEX(   ColForegr, 6)
  PRINT #fnr, "[CLN]=&h" & HEX(   ColLineNo, 6)
  PRINT #fnr, "[CRE]=&h" & HEX(   ColBackgr, 6)
  PRINT #fnr, "[CBC]=&h" & HEX(ColBackgrCur, 6)
  'PRINT #fnr, "[CPB]=&h" & HEX(    ColBreak, 6)
  'PRINT #fnr, "[CTB]=&h" & HEX( ColBreakTmp, 6)
  PRINT #fnr, "[CHK]=&h" & HEX(  ColKeyword, 6)
  PRINT #fnr, "[CHS]=&h" & HEX(  ColStrings, 6)
  PRINT #fnr, "[CHP]=&h" & HEX(   ColPrepro, 6)
  PRINT #fnr, "[CHC]=&h" & HEX(  ColComment, 6)
  PRINT #fnr, "[CHN]=&h" & HEX(  ColNumbers, 6)
  PRINT #fnr, "[CHE]=&h" & HEX(   ColEscape, 6)
  PRINT #fnr, "[CHL]=&h" & HEX(   ColCursor, 6)

  PRINT #fnr, "[FSH]=" & Flag(FSH)
  PRINT #fnr, "[FVM]=" & Flag(FVM)
  PRINT #fnr, "[FSL]=" & Flag(FSL)
  PRINT #fnr, "[FFL]=" & Flag(FFL)
  PRINT #fnr, "[FLT]=" & Flag(FLT)
  PRINT #fnr, "[FPT]=" & Flag(FTT)
  PRINT #fnr, "[TTP]=" & Flag(FTT)
  PRINT #fnr, "[FLN]=" & Flag(FLN)

  CLOSE #fnr :                                               RETURN NULL
END FUNCTION

DIM SHARED AS IniUDT PTR INI '*< The global INI variable for this class
