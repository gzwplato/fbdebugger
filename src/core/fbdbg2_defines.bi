/' fbdbg2_defines.bi
Defines for fbddebugger2


'/
'===================================
#Define fmt(t,l) Left(t,l)+Space(l-Len(t))+"  "
#Define fmt2(t,l) Left(t,l)+Space(l-Len(t))
' for proc_find / thread
#Define KFIRST 1
#Define KLAST 2

#include Once "vbcompat.bi" 'for use of filedatetime
'for linux   : lnx
'for windows : wnd
#Ifdef __FB_LINUX__
	'ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,4,0)
	
	'WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rLine(linenb).sv,1,0)
#Else
	#Ifdef __FB_WIN32__
		' DBG_EXCEPTION_NOT_HANDLED = &H80010001
		#Define EXCEPTION_GUARD_PAGE_VIOLATION      &H80000001
		#Define EXCEPTION_NO_MEMORY                 &HC0000017
		#Define EXCEPTION_FLOAT_DENORMAL_OPERAND    &HC000008D
		#Define EXCEPTION_FLOAT_DIVIDE_BY_ZERO      &HC000008E
		#Define EXCEPTION_FLOAT_INEXACT_RESULT      &HC000008F
		#Define EXCEPTION_FLOAT_INVALID_OPERATION   &HC0000090
		#Define EXCEPTION_FLOAT_OVERFLOW            &HC0000091
		#Define EXCEPTION_FLOAT_STACK_CHECK         &HC0000092
		#Define EXCEPTION_FLOAT_UNDERFLOW           &HC0000093
		#Define EXCEPTION_INTEGER_DIVIDE_BY_ZERO    &HC0000094
		#Define EXCEPTION_INTEGER_OVERFLOW          &HC0000095
		#Define EXCEPTION_PRIVILEGED_INSTRUCTION    &HC0000096
		#Define EXCEPTION_CONTROL_C_EXIT            &HC000013A
		
		'=============== Because collision with some defines from windows (atom and colormap) ===============
		#Ifdef atom 
			#Undef atom
		#EndIf
		#Ifdef colormap
			#Undef colormap
		#EndIf
		'================ end of special defines ========================
		#Include Once "windows.bi"
		#Include Once "win\commctrl.bi"
		#Include Once "win\commdlg.bi"
		#Include Once "win\tlhelp32.bi"
      #Include Once "win\shellapi.bi"
      #Include Once "win\psapi.bi" 
  	#EndIf
#EndIf


Union pointeurs
pxxx As Any Ptr
pinteger As Integer Ptr
puinteger As UInteger Ptr
psingle As Single Ptr
pdouble As Double Ptr
plinteger As LongInt Ptr
pulinteger As ULongInt Ptr
pbyte As Byte Ptr
pubyte As UByte Ptr
pshort As Short Ptr
pushort As UShort Ptr
pstring As String Ptr
pzstring As ZString Ptr
pwstring As WString Ptr
End Union

Union valeurs
vinteger As Integer
vuinteger As UInteger
vsingle As Single
vdouble As Double
vlinteger As LongInt
vulinteger As ULongInt
vbyte As Byte
vubyte As UByte
vshort As Short
vushort As UShort
'vstring as string
'vzstring as zstring
'vwstring as wstring
End Union

'BREAK ON LINE =================================================
Const BRKMAXI=10 'breakpoint index zero for "run to cursor"
Type breakol
	isrc  As UShort    'source index 
	nline As UInteger  'num line for display
	index As Integer   'index for rline
	ad    As UInteger  'address
	typ   As Byte	    'type normal=1 /temporary=0, 3 or 4 =disabled
End Type
Dim Shared brkol(BRKMAXI) As breakol,brknb As Byte
Dim Shared As String brkexe(9,BRKMAXI) 'to save breakpoints by session
'break on var =================================================
Type tbrkv
	typ As Integer   'type of variable
	adr As UInteger  'address
	arr As UInteger  'adr if dyn array
	ivr As Integer   'variable index
	psk As Integer   'stack proc
	Val As valeurs   'value
	vst As String    'value as string
	tst As Byte=1    'type of comparison (1 to 6)
	ttb As Byte      'type of comparison (16 to 0)
	txt As String	  'name and value just for brkv_box
End Type
Dim Shared brkv As tbrkv 
Dim Shared brkv2 As tbrkv 'copie for use inside brkv_box
'WATCHED =================================================
Const WTCHMAIN=3
Const WTCHMAXI=9
Const WTCHALL=9999999
Type twtch
    hnd As HWND     'handle                     TODO to be removed create 4 boxes ????
    tvl  As GtkTreeIter ptr 'tview handle
    adr As UInteger 'memory address
    typ As Integer  'type for var_sh2
    pnt As Integer  'nb pointer
    ivr As Integer  'index vrr
    psk As UInteger 'stk procr or -1 (empty)/-2 (memory)/-3 (non-existent local var)/-4 (session)
    lbl As String   'name & type,etc
    arr As UInteger 'ini for dyn arr
    tad As Integer  'additionnal type
    old As String   'keep previous value for tracing
    idx As Integer  'index proc only for local var
    dlt As Integer  'delta on stack only for local var
    vnb As Integer  'number of level
    vnm(10) As String   'name of var or component
    vty(10) As String   'type
    Var     As Integer  'array=1 / no array=0
End Type
'TODO remove this line ? --> dim shared As Gtk_Tree ptr wtchtree
Dim Shared wtch(wtchmaxi) As twtch
Dim Shared wtchcpt As Long 'counter of watched value, used for the menu 
Dim Shared hwtchbx As HWND    'handle
Dim Shared wtchidx As Integer 'index for delete 
Dim Shared wtchexe(9,wtchmaxi) As String 'watched var (no memory for next execution)
Dim Shared wtchnew As Integer 'to keep index after creating new watched
'status area  =================================================
'empty

'dump memory address
Dim Shared As UInteger dumpadr
'breakvar
'TODO  handle under Gtk 'Dim Shared brkvhnd As Gtk_box Ptr   'handle

'in case of module or DLL the udt number is initialized each time
Dim Shared As Integer udtcpt,udtmax 'current, max cpt
'dwarf management
Dim Shared As Long udtbeg,cudtbeg,locbeg,vrbbeg,prcbeg
'excluded lines for procs added in dll (DllMain and tmp$x)
Const EXCLDMAX=10
Type texcld
	db As UInteger
	fn As UInteger
End Type
Dim Shared As Long excldnb
Dim Shared As texcld	excldlines(EXCLDMAX)
'GCC
Dim Shared As Byte gengcc       ' flag for compiled with gcc
ReDim Shared As String Trans()
Dim   Shared As String stringarray
'type of running
Enum
	RTRUN
	RTSTEP
	RTAUTO
	RTOFF
	RTFRUN
	RTFREE
	RTEND
End Enum
Dim Shared As Byte runtype=RTOFF      'running type

Enum 'code stop
	CSSTEP=0
	CSCURSOR
	CSBRKTEMPO
	CSBRK
	CSBRKV
	CSBRKM
	CSHALTBU
   CSACCVIOL
   CSNEWTHRD
   CSEXCEP
End Enum

Dim Shared As Integer autostep=200 'delay for auto step
' reasons of stopping
Dim Shared stopcode As Integer
'TODO plan to translate
Dim Shared stoplibel(20) As String*17 =>{"","cursor","tempo break","break","Break var","Break mem"_
,"Halt by user","Access violation","New thread","Exception"}
Dim Shared breakcpu As Integer =&hCC
'THREAD ==========================================================
Type tthread
 hd  As HANDLE    'handle
 id  As UInteger  'ident
 pe  As Integer   'flag if true indicates proc end 
 sv  As Integer   'sav line
 od  As Integer   'previous line
 nk  As UInteger  'for naked proc, stack and used as flag
 st  As Integer   'to keep starting line 09/12/2012
 tv  As GtkTreeIter Ptr 'to keep handle of thread item '12/12/2012
 plt As GtkTreeIter Ptr 'to keep handle of last proc of thread in proc/var tview '12/12/2012
 ptv As GtkTreeIter ptr 'to keep handle of last proc of thread in thread tview '12/12/2012
 exc As Integer   'to indicate execution in case of auto 1=yes, 0=no '17/03/2013
End Type
Const THREADMAX=50
Dim Shared thread(THREADMAX) As tthread
Dim Shared threadnb As Integer =-1
Dim Shared threadcur As Integer
Dim Shared threadprv As Integer     'previous thread used when mutexunlock released thread or after thread create 12/02/2013
Dim Shared threadsel As Integer     'thread selected by user, used to send a message if not equal current
Dim Shared threadaut As Integer     'number of threads for change when  auto executing
Dim Shared threadcontext As HANDLE
Dim Shared threadhs As HANDLE       'handle thread to resume
Dim Shared dbgprocid As Integer     'pinfo.dwProcessId : debugged process id
Dim Shared dbgthreadID As Integer   'pinfo.dwThreadId : debugged thread id
Dim Shared dbghand As HANDLE  		'debugged proc handle
Dim Shared dbghthread As HANDLE     'debuggee thread handle
Dim Shared dbghfile  As HANDLE   	'debugged file handle
Dim Shared prun As Integer        	'indicateur process running

Dim Shared curline As Long          'current next executed line

#Ifdef __FB_WIN32__
	Dim Shared pinfo As PROCESS_INFORMATION 'todo if windows
#EndIf
' compiler,commandline for compilation and for debug
Dim Shared As String fbcexe,cmdlfbc,ideexe
Dim Shared exename As ZString *300 'debuggee executable
Dim Shared exedate As Double 'serial date
Dim Shared savexe(9) As String 'last 10 exe, 0=more recent
Dim Shared cmdexe(9) As String 'last 10 exe

Dim Shared flaglog As Byte=0    ' flag for dbg_prt 0 --> no output / 1--> only screen / 2-->only file / 3 --> both
Dim Shared flagtrace As Byte    ' flag for trace mode : 1 proc / +2 line
Dim Shared flagverbose As Byte  ' flag for verbose mode
Dim Shared flagmain As Byte     ' flag for first main
Dim Shared flagattach As Byte   ' flag for attach
Dim Shared flagtooltip As Integer =TRUE 'TRUE=activated/FALSE=DESACTIVATED
Dim Shared flagrestart As Integer=-1  'flag to indicate restart in fact number of bas files to avoid to reload those files
Dim Shared flagwtch As Integer =0 'flag =0 clean watched / 1 no cleaning in case of restart 
Dim Shared flagfollow As Integer =FALSE 'flag to follow next executed line on focus window
Dim Shared flagkill   As Integer =FALSE 'flag if killing process to avoid freeze in thread_del
Dim Shared flagtuto  As Integer 'flag for tutorial -1=no tuto / 2=let execution then return at value 1 / 1=tutorial so no possible command '03/01/2013
Dim Shared As Integer flagmodule,flagunion 'flag for dwarf
Dim Shared As Long dwlastprc,dwlastlnb 'to manage end of proc
Dim Shared compinfo As String   'information about compilation
Dim Shared hattach As HANDLE    'handle to signal attchement done
Dim Shared jitprev As String
Dim Shared fasttimer As Double
'Running variables ==============================================
Const VRRMAX=100000
Type tvrr
	ad    As UInteger 'address
	tv    As GtkTreeIter Ptr 'tview handle
	vr    As Integer  'variable if >0 or component if <0
	ini   As UInteger 'dyn array address (structure) or initial address in array
	gofs  As UInteger 'global offset to optimise access
	ix(4) As Integer  '5 index max in case of array
End Type
Dim Shared vrr(VRRMAX) As tvrr
Dim Shared vrrnb As UInteger
'===== DLL ==================================================
Type tdll
	As HANDLE   hdl 'handle to close
	As UInteger bse 'base address
	As GtkTreeIter Ptr tv 'item treeview to delete
	As Integer gblb 'index/number in global var table
	As Integer gbln 
	As Integer  lnb 'index/number in line '01/02/2013
	As Integer  lnn 
	As String   fnm 'full name
End Type
Const DLLMAX=300
Dim Shared As tdll dlldata(DLLMAX)
Dim Shared As Integer dllnb 'use index base 1
#Define dbg2

'SOURCES =================================================
Const MAXSRC=200 							   'max 200 sources
Type tsource
	fullname  As String 'full name
	shortname As String 'source names
	comptytp  As Long   'flag to keep the used compil option (gas=0, gcc=1, gcc+dwarf=2)
End Type
Dim Shared dbgsrc As String 			   'current source
Dim Shared dbgmaster As Integer 		   'index master source if include
Dim Shared dbgmain As Integer 		   'index main source proc entry point, to update dbgsrc see load_sources
Dim Shared As tsource source(MAXSRC)          'data about every source
'Dim Shared source(MAXSRC) As String    'source names
'Dim Shared srccomp(MAXSRC) As Integer  'flag to keep the used compil option (gas=0, gcc=1, gcc+dwarf=2)
Dim Shared sourcenb As long  =-1       'number of src
Dim Shared As String compdir           'compil directory (dwarf)

'line ==============================================
Const LINEMAX=100000
Type tline
	ad As UInteger
	nu As Integer
	sv As Byte
	pr As UShort
	hp As Integer
	hn As Integer
End Type
Dim Shared As Integer linenb,rlineold 'numbers of lines, index of previous executed line (rline) '14/12/2012
Dim Shared As Integer linenbprev 'used for dll 
Dim Shared rline(LINEMAX) As tline
'DIM ARRAY =========================================
Const ARRMAX=1500
Type tnlu
	lb As UInteger
	ub As UInteger
End Type
Type tarr 'five dimensions max
	dm As UInteger
	nlu(5) As tnlu
End Type
Dim Shared arr(ARRMAX) As tarr,arrnb As Integer
'var =============================
Const VARMAX=20000 'CAUTION 3000 elements taken for globals 
Const VGBLMAX=3000 'max globals
Const KBLOCKIDX=100 'max displayed lines inside index selection
Type tvrb
	nm As String    'name
	typ As Integer  'type
	adr As Integer  'address or offset 
	mem As UByte    'scope 
	arr As tarr Ptr 'pointer to array def
	pt As long    'pointer
End Type
Dim Shared vrbloc      As Integer 'pointer of loc variables or components (init VGBLMAX+1)

Dim Shared vrbgbl      As Integer 'pointer of globals or components
Dim Shared vrbgblprev  As Integer '26/01/2013 for dll, previous value of vrbgbl, initial 1
Dim Shared vrbptr      As Integer Ptr 'equal @vrbloc or @vrbgbl
Dim Shared vrb(VARMAX) As tvrb
'proc (sub or function) ============================
Const PROCMAX=20000 'in sources
Enum
 KMODULE=0 'used with IDSORTPRC
 KPROCNM
End Enum

Type tproc
	nm As String   'name
	db As UInteger 'lower address
	fn As UInteger 'upper address
	sr As UShort   'source index
	nu As Long     'line number to quick access
	vr As UInteger 'lower index variable upper (next proc) -1
	rv As Integer  'return value type
	pt As Integer  'counter pointer for return value (** -> 2)
	tv   As GtkTreeIter Ptr 'index for proctree
   st As Byte     'state followed = not checked
End Type
Dim Shared proc(PROCMAX) As tproc
Dim Shared procnb As Integer
Dim Shared As UInteger procsv,procad,procin,procsk,proccurad,procesp,procfn,procbot,proctop,procsort


'running proc (sub or function) ============================
Const PROCRMAX=50000 'Running proc
Type tprocr
	sk   As UInteger  'stack
	idx  As UInteger  'index for proc
	tv   As GtkTreeIter Ptr 'index for treeview
	'lst as uinteger 'future array in LIST
	cl   As Integer   'calling line
	thid As Integer   'idx thread
	vr   As Integer   'lower index running variable upper (next proc) -1
End Type
Dim Shared procr(PROCRMAX) As tprocr,procrnb As Integer 'list of running proc
'UDT ==============================
Type tudt
	nm As String  'name of udt
	lb As Integer 'lower limit for components
	ub As Integer 'upper
	lg As Integer 'lenght 
	en As Integer 'flag if enum 1 or 0
	index As Integer 'dwarf
	what As Integer 'dwarf udt/pointer/array
	typ As Integer 'dwarf
	dimnb As Long 'dwarf
	bounds(5) As UInteger 'dwarf
End Type
Type tcudt
	nm As String    'name of components or text for enum
	Union
	typ As Integer  'type
	Val As Integer  'value for enum
	End Union
	ofs As UInteger 'offset
	ofb As UInteger 'rest offset bits 
   lg As UInteger  'lenght
	arr As tarr Ptr 'arr ptr
	pt As Long
End Type
Const TYPEMAX=80000,CTYPEMAX=100000
'CAUTION : TYPEMAX is the type for bitfield so the real limit is typemax-1
Dim Shared udt(TYPEMAX) As tudt,udtidx As Integer
Dim Shared cudt(CTYPEMAX) As tcudt,cudtnb As Integer,cudtnbsav As Integer
'===============================

'check if local not possible 
Dim Shared As Integer stff '(stabs) freefile   LOCAL ???
Dim Shared As String  stln '(dwarf) line read  LOCAL ???
'end of check
Dim Shared As String exepath2

Dim Shared As Long sourceix
'*********************************** USE as string RECUP FOR MID(stln,45)

Enum 'type udt/redim/dim
	TYUDT
	TYRDM
	TYDIM
End Enum
'VAR FIND
Type tvarfind
	ty As Integer
	pt As Integer
	nm As String    'var name or description when not a variable
	pr As Integer   'index of running var parent (if no parent same as ivr)
	ad As UInteger
	iv As Integer   'index of running var
	tv As GtkTreeIter ptr      'handle treeview
   tl As GtkTreeIter Ptr 'handle line
End Type
Dim Shared As tvarfind varfind
'BOOKMARK
Type tbmk
	nline As Integer 'bookmark line
	ntab  As Integer 'bookmark tab number, =0--> empty
End Type
Const BMKMAX=10
Dim Shared As tbmk    bmk(BMKMAX) 
Dim Shared As Integer bmkcpt 'bmk counter
'====================== DECLARATIONS ========================
Declare Sub re_ini()
Declare Function kill_process(text As String) As Integer
declare Sub source_load(srcfirst As Long)
Declare Sub filechoose()
Declare Sub simple_message(line1 As String,line2 As String=" ")
'===================
Declare Sub frground()
Declare Function wait_debug() As Integer
Declare Sub start_pgm(p As Any Ptr) 
Declare Function thread_select(id As Integer =0) As Integer
Declare Sub thread_text(thd As Integer=-1)
Declare Sub thread_rsm()
Declare Sub dbg_prt(t As String)
Declare Sub dsp_change(index As Integer)
Declare Sub close_all
Declare Sub var_ini(j As UInteger ,bg As Integer ,ed As Integer)
Declare Sub var_fill(i As Integer)
Declare Function var_search(pproc As Integer,text() As String,vnb As Integer,varr As Integer,vpnt As Integer=0) As Integer
Declare Sub watch_add(f As Integer,r As Integer =-1)
Declare Sub watch_del(i As Integer=WTCHALL)
Declare Sub watch_array()
Declare Sub watch_sh(aff As Integer=WTCHALL)
Declare Sub var_sh()
Declare Sub str_replace(strg As String,srch As String, repl As String)
Declare Function dll_name(FileHandle As HANDLE,t As Integer =1 )As String
Declare Sub var_iniudt(Vrbe As UInteger,adr As UInteger,tv As GtkTreeIter ptr,voffset As UInteger)
Declare Function var_sh1(i As Integer) As String
Declare Function var_sh2(As Integer,As UInteger, As UByte=0,As String="") As String
'Declare Sub dsp_line(newtab As Long =curtab,newline As Long=curline)
'============================================================