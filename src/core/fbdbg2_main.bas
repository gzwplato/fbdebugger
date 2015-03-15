/'* \file fbdbg2_main.bas
\brief Includes all other modules and contains common or general procs

\since 3.0
'/

ini_main
'#Include Once "fbdbg2_start.bas"
#Include Once "fbdbg2_extract.bas"
#Include Once "fbdbg2_handlefiles.bas"
'
'#include Once "fbdbg2_butmenu.bas"
'#include Once "fbdbg2_break.bas"
'#include Once "fbdbg2_thread.bas"

'#include Once "fbdbg2_var.bas"
'#include Once "fbdbg2_watch.bas"

'in string STRG all the occurences of SRCH are replaced by REPL
Sub str_replace(strg As String,srch As String, repl As String)
    Dim As Integer p,lgr=Len(repl),lgs=Len(srch)
    p=InStr(strg,srch)
    While p
        strg=Left(strg,p-1)+repl+Mid(strg,p+lgs)
        p=InStr(p+lgr,strg,srch)
    Wend
End Sub
'========================
'flaglog=0 --> no output / 1--> only screen / 2-->only file / 3 --> both
Sub dbg_prt(t As String)
  'TODO

  'Static As HANDLE scrnnumber
  'Static As Integer filenumber
  'Dim cpt As Integer,libel As String
  'Dim As COORD maxcoord
  'Dim As CONSOLE_SCREEN_BUFFER_INFO csbi
  'Dim As SMALL_RECT disparea=Type(0,0,0,0)
  '
  'If t=" $$$$___CLOSE ALL___$$$$ " Then
  ' If scrnnumber<>0 And (flaglog And 1)=0 Then FreeConsole():scrnnumber=0
  ' If filenumber And (flaglog And 2)=0 Then Close filenumber:filenumber=0
  ' Exit Sub
  'EndIf
  '
  'If scrnnumber=0 And (flaglog And 1) Then
  ' libel=Chr(13)+Chr(10)+Date+" "+Time+Chr(10)
  ' AllocConsole()
  ' scrnnumber=GetStdHandle(STD_OUTPUT_HANDLE)
  ' setconsoletitle(StrPtr("FBdebugger trace/log"))
  ' maxcoord=GetLargestConsoleWindowSize(scrnnumber)
  ' GetConsoleScreenBufferInfo(scrnnumber,@csbi)
  ' 'change buffer to max sizes
  ' maxcoord.y=csbi.dwsize.y
  ' SetConsoleScreenBufferSize(scrnnumber,maxcoord)
  ' 'change display
  ' disparea.right=(maxcoord.x-1)*.8
  ' disparea.bottom=(csbi.dwMaximumWindowSize.y-1)/2
  ' SetConsoleWindowInfo(scrnnumber,TRUE,@disparea)
  ' SetConsoleCtrlHandler(Cast(PHANDLER_ROUTINE,@CtrlHandler),TRUE)
  ' WriteConsole(scrnnumber, StrPtr(libel),Len(libel),@cpt,0)
  'EndIf
  '
  'If filenumber=0 And (flaglog And 2) Then
  ' filenumber=FreeFile:Open ExePath+"\dbg_log_file.txt"  For Append As filenumber
  ' Print #filenumber,Date,Time
  'EndIf
  '
  'If (flaglog And 1) Then libel=t+Chr(10):WriteConsole(scrnnumber, StrPtr(libel),Len(libel),@cpt,0)
  'If (flaglog And 2) Then Print # filenumber,t
End Sub
'=============================================
'todo If Command<>"" Then treat_file("") 'case command line exe see treat_file
'======== init =========================================
Sub re_ini()

'Reset all the widgets
gtk_text_buffer_set_text(GTK_TEXT_BUFFER(SRC->BuffCur), "", -1) 'clear curent line
gtk_label_set_text(GTK_LABEL(GUI.butStopVar),"Break on var") 'reset break on var
gtk_window_set_title (GTK_WINDOW(gui.window1),"Debug") 'reset title in main window

gtk_list_store_clear(GTK_LIST_STORE(GUI.lstoreMemory)) 'reset memory listview

gtk_tree_store_clear(GTK_TREE_STORE(GUI.tstoreProcVar))'reset the treeviews
gtk_tree_store_clear(GTK_TREE_STORE(GUI.tstoreProcs))
gtk_tree_store_clear(GTK_TREE_STORE(GUI.tstoreThreads))
gtk_tree_store_clear(GTK_TREE_STORE(GUI.tstoreWatch))

'TODO if dsptyp Then dsp_hide(dsptyp)  RESET DISPLAY
'TODO dsp_sizecalc
'TODO close all bx bx_closing

If flagrestart=-1 Then 'add test for restart without loading again all the files
  SRC->removeAll() 'remove all the source tabs
Else
  'TODO not sure to be needed reset selected line ???  : sel_line(curlig-1,0,1,richedit(curtab),FALSE) 'default color
EndIf

'reset status bar
WITH *ACT
  gtk_label_set_text(GTK_LABEL(.SbarLab1), "")
  gtk_label_set_text(GTK_LABEL(.SbarLab2), "")
  gtk_label_set_text(GTK_LABEL(.SbarLab3), "")
  gtk_label_set_text(GTK_LABEL(.SbarLab4), "")
  gtk_label_set_text(GTK_LABEL(.SbarLab5), "")
END WITH


' reset watch bar
WITH GUI
  gtk_label_set_text(GTK_LABEL(.watch1), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch2), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch3), "< empty >")
  gtk_label_set_text(GTK_LABEL(.watch4), "< empty >")
END With

'=========
prun=FALSE
runtype=RTOFF:ACT->setState(runtype)
brkv.adr=0 'no  on var
brknb=0 'no break on line
brkol(0).ad=0   'no break on cursor

curline=0
sourcenb=-1:dllnb=0
threadnb=-1
vrrnb=0:procnb=0:procrnb=0:linenb=0:cudtnb=0:arrnb=0:procr(1).vr=1:procin=0:procfn=0:procbot=0:proctop=FALSE
proc(1).vr=VGBLMAX+1 'for the first stored proc
excldnb=0
dumpadr=0
'TODO flaglog=0:dbg_prt(" $$$$___CLOSE ALL___$$$$ "):flagtrace=0
flagmain=TRUE:flagattach=FALSE:flagkill=FALSE
udtcpt=0:udtmax=0

vrbgbl=0:vrbloc=VGBLMAX:vrbgblprev=0
udtbeg=16:cudtbeg=1:locbeg=VGBLMAX+1:vrbbeg=1:prcbeg=1

'' code moved to gui/source.bas executed by SRC->removeAll()
  'Reset bookmarks TODO maybe keep them if rerun (caution with dll or so)
  'Var box = GTK_COMBO_BOX_TEXT(SRC->CBMarks)
  'gtk_combo_box_text_remove_all(box) 'remove all
  'gtk_combo_box_text_insert(box, -1, "0", "No bookmark")

'todo remove the 2 lines below no needed as all is handled by the gui part
For i As Integer =1 To bmkcpt:bmk(i).ntab=0:bmk(i).nline=0:Next
bmkcpt=0
gtk_action_set_sensitive(ACT->act_bmknext, FALSE)
gtk_action_set_sensitive(ACT->act_bmkprev, FALSE)

'TODO grey log button     EnableMenuItem(menutools,IDHIDLOG,MF_GRAYED)

compinfo="" 'information about compilation
threadprv=0
threadsel=0
ReDim Trans(70000)
Trans(1)="1"
Trans(2)="2"
Trans(3)="1"
Trans(4)="8"
Trans(5)="8"
Trans(6)="9"
Trans(7)="10"
Trans(8)="5"
Trans(9)="6"
Trans(10)="2"
Trans(11)="3"
Trans(12)="11"
Trans(13)="12"
Trans(18)="7"
Trans(19)="2"
Trans(20)="3"
Trans(21)="5"
Trans(22)="6"
Trans(23)="1"
Trans(24)="8"
Trans(25)="9"
Trans(26)="10"

End Sub
Function kill_process(text As String) As Integer
   If prun=0 Then Return TRUE 'not running.... TODO remove this line
   Var dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
    , GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
    , GTK_MESSAGE_QUESTION _
    , GTK_BUTTONS_YES_NO _
    , ( _
      *__(!"Kill current running Program ?\n\n") _
    & *__(!"From action : <b>%s</b>\n\n") _
    & *__(!"USE CARREFULLY SYSTEM CAN BECOME UNSTABLE, LOSS OF DATA, MEMORY LEAK\n") _
    & *__("Try to close your program first") _
    ) _
    , Text _
    , NULL)

    If GTK_RESPONSE_YES = gtk_dialog_run(GTK_DIALOG(dia)) THEN
       flagkill=TRUE
      #Ifdef __FB_LINUX__
      'TODO add terminate
    #Else
      #Ifdef __FB_WIN32__
          'TODO dbg_prt ("return code terminate process + lasterror "+Str(terminateprocess(dbghand,999))+" "+Str(GetLastError))
          'TODO thread_rsm()
          'TODO While prun:Sleep 500:Wend
        #Else
        'other OS Android,...
        #EndIf
      #EndIf
      kill_process=TRUE
    Else
    kill_process=FALSE
    End If
    gtk_widget_destroy(dia)
End Function
Sub simple_message(line1 As String,line2 As String =" ")
    Var dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
    , GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
    , GTK_MESSAGE_WARNING _
    , GTK_BUTTONS_OK _
    , ( _
      *__(!"<b>%s</b>\n\n") _
    & *__("%s") _
      ) _
    , line1 _
    , line2 _
    , NULL)

    gtk_dialog_run(GTK_DIALOG(dia))
    gtk_widget_destroy(dia)
End Sub

/'* \brief global initializations

\todo add test for 32 and 64bit as integer is not the same

'#if defined( __FB_64BIT__ ) and (not defined( __FB_WIN32__))
' '' On 64bit Linux/BSD systems (but not 64bit Windows), C's long is
' '' 64bit like FB's integer.
' '' Note: Using 64bit Integer here instead of LongInt, to match fbc's
' '' mangling: on 64bit Linux/BSD, Integer is mangled to C's long.
' type clong as integer
' type culong as uinteger
'#else
' '' On 32bit systems and 64bit Windows, C's long is 32bit like FB's long.
' '' Note: Using 32bit Long here instead of 32bit/64bit Integer, because
' '' this is also used for 64bit Windows where Integer isn't 32bit.
' type clong as long
' type culong as ulong
'#EndIf
'/
Sub ini_main
stoplibel(0)=@""
stoplibel(1)=__("cursor")
stoplibel(2)=__("tempo break")
stoplibel(3)=__("break")
stoplibel(4)=__("Break var")
stoplibel(5)=__("Break mem")
stoplibel(6)=__("Halt by user")
stoplibel(7)=__("Access violation")
stoplibel(8)=__("New thread")
stoplibel(9)=__("Exception")

udt(0).nm="Typ Unknown"
udt(1).nm="Integer":udt(1).lg=Len(Integer)
udt(2).nm="Byte":udt(2).lg=Len(Byte)
udt(3).nm="Ubyte":udt(3).lg=Len(UByte)
udt(4).nm="Zstring":udt(4).lg=4
udt(5).nm="Short":udt(5).lg=Len(Short)
udt(6).nm="Ushort":udt(6).lg=Len(UShort)
udt(7).nm="Void":udt(7).lg=4    :udt(7).index=7'dwarf
udt(8).nm="Uinteger":udt(8).lg=Len(UInteger)
udt(9).nm="Longint":udt(9).lg=Len(LongInt)
udt(10).nm="Ulongint":udt(10).lg=Len(ULongInt)
udt(11).nm="Single":udt(11).lg=Len(Single)
udt(12).nm="Double":udt(12).lg=Len(Double)
udt(13).nm="String":udt(13).lg=Len(String)
udt(14).nm="Fstring":udt(14).lg=4
udt(15).nm="fb_Object":udt(15).lg=Len(UInteger)
End Sub


