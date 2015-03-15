/'* \file fbdbg2_extract.bas
\brief FIXME

\since 3.0
'/

'============== extract

Function name_extract(a As String) As String 'extract file name from full name
  Dim i As Integer
  For i=Len(a) To 1 Step -1
    If a[i-1]=Asc(":") Or a[i-1]=Asc("\") Or a[i-1]=Asc("/") Then Exit For
  Next
  Return Mid(a,i+1)
End Function
Function Common_exist(ad As UInteger) As Integer
  For i As Integer = 1 To vrbgbl
    If vrb(i).adr=ad Then Return TRUE 'return true if a common still stored
  Next
  Return FALSE
End Function
Sub enum_check(idx As Integer)
  For i As Integer =1 To udtmax-1
      If udt(i).en Then 'enum
        If udt(idx).nm=udt(i).nm Then 'same name
           If udt(idx).ub-udt(idx).lb=udt(i).ub-udt(i).lb Then 'same number of elements
                If cudt(udt(idx).ub).nm=cudt(udt(i).ub).nm Then 'same name for last element
                  If cudt(udt(idx).lb).nm=cudt(udt(i).lb).nm Then 'same name for first element
                    'enum are considered same
                    udt(idx).lb=udt(i).lb:udt(idx).ub=udt(i).ub
                    udt(idx).en=i
                    cudtnb=cudtnbsav
                    Exit Sub
                  EndIf
                EndIf
           EndIf
        EndIf
      EndIf
  Next
End Sub
Function cutup_names(strg As String) As String
   '"__ZN9TESTNAMES2XXE:S1
  Dim As Integer p,d
  Dim As String nm,strg2,nm2
  p=InStr(strg,"_ZN")
  strg2=Mid(strg,p+3,999)
  p=Val(strg2)
  If p>9 Then d=3 Else d=2
  nm=Mid(strg2,d,p)
  strg2=Mid(strg2,d+p)
  p=Val(strg2)
  If p>9 Then d=3 Else d=2
  nm2=Mid(strg2,d,p)
  Return "NS : "+nm+"."+nm2
End Function
Function cutup_scp(gv As Byte, ad As UInteger,dlldelta As Integer=0) As Integer
  Dim msg As String
Select Case gv
  Case Asc("S"),Asc("G")     'shared/common
    If gv=Asc("G") Then If Common_exist(ad) Then Return 0 'to indicate that no needed to continue
    msg=*__("Reached limit ")'+Str(VGBLMAX)
    If vrbgbl=VGBLMAX Then simple_message("Init Globals",msg):Exit Function
    vrbgbl+=1
    vrb(vrbgbl).adr=ad
    vrbptr=@vrbgbl
    Select Case gv
      Case Asc("S")   'shared
        vrb(vrbgbl).mem=2
        vrb(vrbgbl).adr+=dlldelta 'in case of relocation dll, all shared addresses are relocated 06/02/2013
      Case Asc("G")     'common
        vrb(vrbgbl).mem=6
    End Select
    Return 2
  Case Else
    If vrbloc=VARMAX Then simple_message("Init locals","Reached limit "+Str(VARMAX-3000)):Exit Function
    vrbloc+=1
    vrb(vrbloc).adr=ad
    vrbptr=@vrbloc
    proc(procnb+1).vr=vrbloc+1 'just to have the next beginning
    Select Case gv
      Case Asc("V")     'static
        vrb(vrbloc).mem=3
        Return 2
      Case Asc("v")     'byref parameter
        vrb(vrbloc).mem=4
        Return 2
      Case Asc("p")     'byval parameter
        vrb(vrbloc).mem=5
        Return 2
      Case Else         'local
        vrb(vrbloc).mem=1
        Return 1
    End Select
End Select
End Function
Sub cutup_enum(readl As String)
'.stabs "TENUM:T26=eESSAI:5,TEST08:8,TEST09:9,TEST10:10,FIN:99,;",128,0,0,0
Dim As Integer p,q
Dim As String tnm
p=InStr(readl,":")
tnm=Left(readl,p-1)
p+=2 'skip :T
q=InStr(readl,"=")
udtidx=Val(Mid(readl,p,q-p))
udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
If udtmax > TYPEMAX Then simple_message("Storing ENUM="+tnm,"Max limit reached "+Str(TYPEMAX)):Exit Sub
udt(udtidx).nm=tnm 'enum name

udt(udtidx).en=udtidx 'flag enum, in case of already treated use same previous cudt
udt(udtidx).lg=Len(Integer) 'same size as integer
'each cudt contains the value (typ) and the associated text (nm)
udt(udtidx).lb=cudtnb+1
p=q+2
cudtnbsav=cudtnb 'save value for restoring see enum_check
If InStr(readl,";")=0 Then
  cudtnb+=1
  cudt(cudtnb).nm="DUMMY"
  cudt(cudtnb).val=0
  simple_message("Storing ENUM="+tnm,"Data not correctly formated "):Exit Sub '28/04/2014
Else
  While readl[p-1]<>Asc(";")
  q=InStr(p,readl,":") 'text
  If cudtnb>=CTYPEMAX Then simple_message("Storing ENUM="+tnm,"Max limit reached "+Str(CTYPEMAX)):Exit Sub '28/04/2014
  cudtnb+=1
  cudt(cudtnb).nm=Mid(readl,p,q-p)

  p=q+1
  q=InStr(p,readl,",") 'value
  cudt(cudtnb).val=Val(Mid(readl,p,q-p))
  p=q+1

  Wend
EndIf
udt(udtidx).ub=cudtnb
enum_check(udtidx) 'eliminate duplicates
End Sub
Function cutup_array(gv As String,d As Integer,f As Byte) As Integer
  Dim As Integer p=d,q,c

If arrnb>ARRMAX Then simple_message("Max array reached","can't store"):Exit Function
arrnb+=1

'While gv[p-1]=Asc("a")
While InStr(p,gv,"ar")
  'GCC
  'p+=4

  If InStr(gv,"=r(")Then
    p=InStr(p,gv,";;")+2 'skip range =r(n,n);n;n;;
  Else
    p=InStr(p,gv,";")+1 'skip ar1;
  End If


  q=InStr(p,gv,";")
  'END GCC
  arr(arrnb).nlu(c).lb=Val(Mid(gv,p,q-p)) 'lbound

  p=q+1
  q=InStr(p,gv,";")
  arr(arrnb).nlu(c).ub=Val(Mid(gv,p,q-p))'ubound
  '''arr(arrnb).nlu(c).nb=arr(arrnb).nlu(c).ub-arr(arrnb).nlu(c).lb+1 'dim
  p=q+1
  c+=1
Wend
  arr(arrnb).dm=c 'nb dim
If f=TYDIM Then
  vrb(*vrbptr).arr=@arr(arrnb)
Else
  cudt(cudtnb).arr=@arr(arrnb)
End If
Return p
End Function
Sub cutup_2(gv As String,f As Byte)
Dim p As Integer=1,c As Integer,e As Integer,gv2 As String,pp As Integer
If InStr(gv,"=")=0 Then
  c=Val(Mid(gv,p,9))
  If c=udt(15).index Then c=15 '05/11/2013
  If c>15 Then c+=udtcpt 'udt type so adding the decal
  pp=0
  If f=TYUDT Then
    cudt(cudtnb).typ=c
    cudt(cudtnb).pt=pp
    cudt(cudtnb).arr=0 'by default not an array
  Else
    vrb(*vrbptr).typ=c
    vrb(*vrbptr).pt=pp
    vrb(*vrbptr).arr=0 'by default not an array
  End If
Else
  If InStr(gv,"=ar1") Then p=cutup_array(gv,InStr(gv,"=ar1")+1,f)
  gv2=Mid(gv,p)
  For p=0 To Len(gv2)-1
    If gv2[p]=Asc("*") Then c+=1
    If gv2[p]=Asc("=") Then e=p+1
  Next
  If c Then 'pointer
    If InStr(gv2,"=f") Then 'proc
      If InStr(gv2,"=f7") Then
        pp=200+c 'sub
      Else
        pp=220+c 'function
      EndIf
    Else
      pp=c
      If gv2[e]=Asc("*")Then e+=1 '09/08/2013
    End If
  Else
    pp=0
  End If
  c=Val(Mid(gv2,e+1))
  If c=udt(15).index Then c=15 '05/11/2013
  If c>15 Then c+=udtcpt
  If f=TYUDT Then
    cudt(cudtnb).pt=pp
    cudt(cudtnb).typ=c
  Else
    vrb(*vrbptr).pt=pp
    vrb(*vrbptr).typ=c
  End If
EndIf
End Sub
Sub cutup_udt(readl As String)
Dim As Integer p,q,lgbits,flagdouble '31/07/2013
Dim As String tnm
p=InStr(readl,":")

tnm=Left(readl,p-1)
If InStr(readl,":Tt") Then
   p+=3 'skip :Tt
Else
   p+=2 'skip :T GCC
EndIf

q=InStr(readl,"=")

udtidx=Val(Mid(readl,p,q-p))
If tnm="OBJECT" OrElse tnm="$fb_Object" Then udt(15).index=udtidx:Exit sub '05/11/2013
udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
If udtmax > TYPEMAX-1 Then simple_message("Storing UDT","Max limit reached "+Str(TYPEMAX)):Exit Sub
udt(udtidx).nm=tnm
If left(tnm,4)="TMP$" Then Exit Sub 'gcc redim
p=q+2
q=p-1
While readl[q]<64
  q+=1
Wend
q+=1
udt(udtidx).lg=Val(Mid(readl,p,q-p))
p=q
udt(udtidx).lb=cudtnb+1
while readl[p-1]<>Asc(";")
  'dbg_prt("STORING CUDT "+readl)
  If cudtnb = CTYPEMAX Then simple_message("Storing CUDT","Max limit reached "+Str(CTYPEMAX)):Exit Sub
  cudtnb+=1



  q=InStr(p,readl,":")
  cudt(cudtnb).nm=Mid(readl,p,q-p) 'variable name
  p=q+1
  q=InStr(p,readl,",")

    cutup_2(Mid(readl,p,q-p),TYUDT) 'variable type

    '11/05/2014 'new way for redim
    If Left(udt(cudt(cudtnb).typ).nm,7)="FBARRAY" Then 'new way for redim array

  '.stabs "__FBARRAY1:Tt25=s32DATA:26=*1,0,32;PTR:27=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:28=ar1;0;0;29,160,96;;",128,0,0,0
  '.stabs "TTEST2:Tt23=s40VVV:24=ar1;0;1;2,0,16;XXX:1,32,32;ZZZ:25,64,256;;",128,0,0,0
  '.stabs "__FBARRAY1:Tt21=s32DATA:22=*23,0,32;PTR:30=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:31=ar1;0;0;29,160,96;;",128,0,0,0
  '.stabs "TTEST:Tt20=s56AAA:3,0,8;BBB:21,32,256;CCC:32=ar1;1;2;10,320,128;;",128,0,0,0
  '.stabs "__FBARRAY8:Tt18=s116DATA:19=*20,0,32;PTR:33=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:34=ar1;0;0;29,160,768;;",128,0,0,0
  '.stabs "VTEST:18",128,0,0,-176
      cudt(cudtnb).pt=cudt(udt(cudt(cudtnb).typ).lb).pt-1 'pointer always al least 1 so reduce by one
      cudt(cudtnb).typ=cudt(udt(cudt(cudtnb).typ).lb).typ 'real type
      cudt(cudtnb).arr=Cast(tarr Ptr,-1) 'defined as dyn arr

      'dbg_prt2("dyn array="+cudt(cudtnb).nm+" "+Str(cudt(cudtnb).typ)+" "+Str(cudt(cudtnb).pt)+" "+cudt(udt(cudt(cudtnb).typ).lb).nm)
    EndIf
    'end new redim


    p=q+1
    q=InStr(p,readl,",")
    cudt(cudtnb).ofs=Val(Mid(readl,p,q-p))  'bits offset / beginning
    p=q+1
    q=InStr(p,readl,";")
    lgbits=Val(Mid(readl,p,q-p))  'length in bits

    If cudt(cudtnb).typ<>4 And cudt(cudtnb).pt=0 And cudt(cudtnb).arr=0 Then 'not zstring, pointer,array !!!
      If lgbits<>udt(cudt(cudtnb).typ).lg*8 Then 'bitfield
        cudt(cudtnb).typ=TYPEMAX 'special type for bitfield
        cudt(cudtnb).ofb=cudt(cudtnb).ofs-(cudt(cudtnb).ofs\8) * 8 ' bits mod byte
        cudt(cudtnb).lg=lgbits  'length in bits
      End If
    End If
  ''''''''''''''''''EndIf 'end change 17/04/2014
  p=q+1
  cudt(cudtnb).ofs=cudt(cudtnb).ofs\8 'offset bytes
Wend
udt(udtidx).ub=cudtnb
End Sub
Sub cutup_1(gv As String,ad As UInteger, dlldelta As Integer=0) '06/02/2013
  Dim p As Integer
  Static defaulttype As Integer '08/08/2013
  Dim As String vname '13/08/2013
  If gengcc Then
    If InStr(gv,"long double:t")<>0 OrElse InStr(gv,"FBSTRING:t")<>0 Then '30/12/2013
          defaulttype=0
    ElseIf Left(gv,5)="int:t" OrElse InStr(gv,"_Decimal32:t")<>0 Then  '30/12/2013
          defaulttype=1
    EndIf
  Else
    If InStr(gv,"pchar:t") Then 'last default type
          defaulttype=0
    ElseIf InStr(gv,"integer:t") Then
          defaulttype=1
    EndIf
  EndIf
  If defaulttype Then Exit Sub

  ''''' TO BE REACTIVATE If gengcc Then translate_gcc(gv)

  '=====================================================
  vname=Left(gv,InStr(gv,":")+1)
  p=InStr(vname,"$")
  If p=0 Then 'no $ in the string
    If InStr(vname,":t")<>0 Then
      If UCase(Left(vname,InStr(vname,":")))<>Left(vname,InStr(vname,":")) Then
        Exit Sub 'don't keep  <lower case name>:t, keep <upper case name>:t  => enum
      EndIf
    ElseIf InStr(vname,"_ZTSN")<>0  orelse InStr(vname,"_ZTVN")<>0 then
      Exit Sub 'don't keep _ZTSN or _ZTVN (extra data for class) or with double underscore  __Z
    EndIf
    If Left(vname,2)="_{" Then Exit Sub '_{fbdata}_<label name>  07/04/2014
    If Left(vname,3)=".Lt" Then Exit Sub '.Ltxxxx used with data 07/04/2014
  Else '$ in the string
    If InStr(p+1,vname,"$") <>0 AndAlso InStr(vname,"$fb_Object")=0 Then '30/12/2013
      Exit Sub 'don't keep TMP$xx$xx:
    EndIf
    '$9CABRIOLET:T(0,51)=s16$BASE:(0,48),0,128;;
    If InStr(vname,":t")<>0 Then
      If Left(vname,5)<>"$fb_O" andalso Left(vname,4)<>"TMP$" Then  '01/09/2013 redim
        Exit Sub
      End If
    EndIf
    If InStr(vname,"$fb_RTTI") OrElse InStr(vname,"fb$result$") Then
      Exit Sub 'don't keep
    EndIf
    If Left(vname,3)="vr$" OrElse Left(vname,4)="tmp$" Then
      Exit Sub 'don't keep  vr$xx: or tmp$xx$xx:
    EndIf
    'eliminate $ and eventually the number at the end of name ex udt$1 --> udt
    If Left(vname,4)<>"TMP$" Then '01/09/2013 use with redim no need with 0.91
      If p<>1 Then gv=Left(gv,p-1)+Mid(gv,InStr(gv,":")) '13/08/2013
    EndIf
  EndIf
  '======================================================
  If InStr(gv,";;") Then 'defined type or redim var
    If InStr(gv,":T") Then 'GCC change ":Tt" in just ":T"
          'UDT
      cutup_udt(gv)
    Else
      'REDIM
      If cutup_scp(gv[InStr(gv,":")],ad,dlldelta)=0 Then Exit Sub 'Scope / increase number and put adr 06/02/2013
      'if common exists return 0 so exit sub
      vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter

    '.stabs "VTEST:22=s32DATA:25=*23=24=*1,0,32;PTR:26=*23=24=*1,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;dim1_LBOUND:1,192,32;
     'dim1_UBOUND:1,224,32;;
     'DATA:27=*dim1_20=*21,0,32;PTR:28=*dim1_20=*21,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;
     'dim1_LBOUND:1,192,32;dim1_UBOUND:1,224,32;;21",128,0,0,-168


      p=InStr(gv,";;")+2 ' case dyn var including dyn array field...... 21/04/2014 to be removed when 0.91 is released
      While InStr(p,gv,";;")<>0 '29/04/2014
        p=InStr(p,gv,";;")+2
      Wend

      cutup_2(Mid(gv,p),TYRDM) 'datatype
      vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'redim array
    EndIf
  ElseIf InStr(gv,"=e") Then
    'ENUM
    cutup_enum(gv)
  Else
    'DIM
    If InStr(gv,"FDBG_COMPIL_INFO") Then Exit Sub '25/04/2013
    If gv[0]=Asc(":") Then Exit Sub 'no name, added by compiler don't take it
    p=cutup_scp(gv[InStr(gv,":")],ad,dlldelta)'Scope / increase number and put adr 06/02/2013
    If p=0 Then Exit Sub 'see redim
    If InStr(gv,"_ZN") AndAlso InStr(gv,":") Then
      vrb(*vrbptr).nm=cutup_names(gv) 'namespace
    Else
      vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter
        'to avoid two lines in proc/var tree, case dim shared array and use of erase or u/lbound
      If vrb(*vrbptr).mem=2 AndAlso vrb(*vrbptr).nm=vrb(*vrbptr-1).nm Then 'check also if shared 09/08/2013
            *vrbptr-=1 'decrement pointed value, vrbgbl in this case 05/06/2013
            Exit Sub
      EndIf
    End If
    cutup_2(Mid(gv,InStr(gv,":")+p),TYDIM)
    '11/05/2014 'new way for redim
    If Left(udt(vrb(*vrbptr).typ).nm,7)="FBARRAY" Then 'new way for redim array

      '.stabs "__FBARRAY2:Tt23=s44DATA:24=*10,0,32;PTR:25=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:26=ar1;0;1;22,160,192;;",128,0,0,0
      '.stabs "MYARRAY2:S23",38,0,0,_MYARRAY2
      vrb(*vrbptr).pt=cudt(udt(vrb(*vrbptr).typ).lb).pt-1 'pointer always al least 1 so reduce by one
      vrb(*vrbptr).typ=cudt(udt(vrb(*vrbptr).typ).lb).typ 'real type
      vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'defined as dyn arr

      'dbg_prt2("dyn array="+vrb(*vrbptr).nm+" "+Str(vrb(*vrbptr).typ)+" "+Str(vrb(*vrbptr).pt)+" "+cudt(udt(vrb(*vrbptr).typ).lb).nm)
    EndIf
    'end new redim
  EndIf
End Sub
Function cutup_op (op As String) As String
Select Case  op
Case "aS"
    Function = "Let "
Case "pl"
    Function = "+"
Case "pL"
    Function = "+="
Case "mi"
    Function = "-"
Case "mI"
    Function = "-="
Case "ml"
    Function = "*"
Case "mL"
    Function = "*="
Case "dv"
    Function = "/"
Case "dV"
    Function = "/="
Case "Dv"
    Function = "\"
Case "DV"
    Function = "\="
Case "rm"
    Function = "mod"
Case "rM"
    Function = "mod="
Case "an"
    Function = "and"
Case "aN"
    Function = "and="
Case "or"
    Function = "or"
Case "oR"
    Function = "or="
Case "aa"
    Function = "andalso"
Case "aA"
    Function = "andalso="
Case "oe"
    Function = "orelse"
Case "oE"
    Function = "orelse="
Case "eo"
    Function = "xor"
Case "eO"
    Function = "xor="
Case "ev"
    Function = "eqv"
Case "eV"
    Function = "eqv="
Case "im"
    Function = "imp"
Case "iM"
    Function = "imp="
Case "ls"
    Function = "shl"
Case "lS"
    Function = "shl="
Case "rs"
    Function = "shr"
  Case "rS"
    Function = "shr="
Case "po"
    Function = "^"
Case "pO"
    Function = "^="
Case "ct"
    Function = "&"
Case "cT"
    Function = "&="
  Case "eq"
    Function = "eq"
Case "gt"
    Function = "gt"
Case "lt"
    Function = "lt"
Case "ne"
    Function = "ne"
Case "ge"
    Function = "ge"
Case "le"
    Function = "le"
Case "nt"
    Function = "not"
  Case "ng"
    Function = "neg"
  Case"ps"
    Function = "ps"
  Case "ab"
    Function = "ab"
  Case "fx"
    Function = "fix"
Case "fc"
    Function = "frac"
Case "sg"
    Function = "sgn"
Case "fl"
    Function = "floor"
Case "nw"
    Function = "new"
Case "na"
    Function = "new []?"
Case "dl"
    Function = "del"
Case "da"
    Function = "del[]?"
Case "de"
    Function = "."
Case "pt"
    Function = "->"
Case "ad"
    Function = "@"
Case "fR"
    Function = "for"
Case "sT"
    Function = "step"
Case "nX"
    Function = "next"
  Case "cv"
    Function = "Cast"
  Case "C1"
    Function = "(Constructor)" '02/11/2014
  Case "D1"
    Function = "(Destructor)"
Case Else
    Function = "Unknow"
End Select
End Function
Function parse_typeope(vchar As long) As String
  'RPiR8vector2D or R8vector2DS0_ or R8FBSTRINGR8VECTOR2D
  Dim As Long typ

  If vchar=Asc("P") Then
    Return "*" 'pointer
  Else
  'l=long/m=unsigned long/n=__int128/o=unsigned __int128/e=long double, __float80
    Select Case As Const vchar
      Case Asc("i")
        typ=1
      Case Asc("a")
        typ=2
      Case Asc("h")
        typ=3
      'Case Asc("") 'Zstring
      ' typ=4
      Case Asc("s")
        typ=5
      Case Asc("t")
        typ=6
      Case Asc("v")
        typ=7
      Case Asc("j")
        typ=8
      Case Asc("x")
        typ=9
      Case Asc("y")
        typ=10
      Case Asc("f")
        typ=11
      Case Asc("d")
        typ=12
      'Case Asc("")'String
      ' typ=13
      'Case Asc("")'Fstring
      ' typ=14
      Case Else
        typ=0
    End Select
    Return udt(typ).nm
  EndIf
End Function
Function cutup_proc(fullname As String) As String '02/11/2014
  Dim As Long p=3,lg,namecpt,ps
  Dim As String strg,strg2,names(10),mainname,strg3

  lg=InStr(fullname,"@")
   If lg=0 Then lg=InStr(fullname,":")
   strg=Left(fullname,lg-1)

  If InStr(strg,"_Z")=0 Then Return strg

  If strg[2]=Asc("Z") Then p+=1 'add 1 case _ _ Z
  If strg[p-1]=Asc("N") Then 'nested waiting "E"
    mainname=""
    p+=1
    While Strg[p-1]<>Asc("E")
      lg=ValInt(Mid(strg,p,2)) 'evaluate possible lenght of name eg 7NAMESPC
      If lg Then 'name of namespace or udt
        If lg>9 Then p+=1 '>9 --> 2 characters
        strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
        ps=InStr(strg3,"__get__")
            If ps Then
               strg3=Left(strg3,ps-1)+" (Get property)"
            Else
               ps=InStr(strg3,"__set__")
               If ps Then
                strg3=Left(strg3,ps-1)+" (Set property)"
               EndIf
            EndIf
          If mainname="" Then
          mainname=strg3
          strg2+=strg3
          Else
          mainname+="."+strg3
          strg2+="."+strg3
          EndIf
          namecpt+=1
          names(namecpt)=mainname
        p+=1+lg'next name
      Else 'operator
        strg2+=" "+cutup_op(Mid(strg,p,2))+" " 'extract name of operator
        p+=2
        mainname=""
        While Strg[p-1]<>Asc("E") 'more data eg FBSTRING,
          lg=ValInt(Mid(strg,p,2))
          If lg Then
            If lg>9 Then p+=1
            strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
            If strg3="FBSTRING" Then strg3="string"
                If mainname="" Then
                  mainname=strg3
                  strg2+=strg3
                Else
                  mainname+="."+strg3
                  strg2+="."+strg3
                endif
                namecpt+=1
                names(namecpt)=mainname
            p+=1+lg
          Else
            strg2+=parse_typeope(Asc(Mid(strg,p,1)))'mymodif
            p+=1
          EndIf
        Wend

      EndIf
    Wend
  Else
    strg2=cutup_op(Mid(strg,p,2))+" "
    p+=2
  EndIf

  If strg[p-1]=Asc("E") Then p+=1 'skip "E"

  'parameters
  mainname=""
  strg2+="("
  While p<=Len(strg)
    lg=ValInt(Mid(strg,p,2))
    If lg Then
      If lg>9 Then p+=1
      strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
      If strg3="FBSTRING" Then strg3="String"
         If mainname="" Then
        mainname=strg3
        strg2+=strg3
      Else
        mainname+="."+strg3
        strg2+="."+strg3
      EndIf
      namecpt+=1
         names(namecpt)=mainname
      p+=1+lg
    elseIf strg[p-1]=Asc("R") Then
      If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=","
      p+=1
    elseIf strg[p-1]=Asc("N") Then
      If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=","
      mainname=""
      p+=1
    elseIf strg[p-1]=Asc("K") Then
      If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then
        strg2+=",const."
      Else
        strg2+="const.T"
      EndIf
      p+=1
    elseIf strg[p-1]=Asc("E") Then
      'If Right(strg2,1)<>"," Then strg2+=","
      p+=1
    ElseIf strg[p-1]=Asc("S") Then 'S0_ --> 'repeating the previous type
    If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=",":mainname=""
      p+=1
      If strg[p-1]=asc("_") Then
        strg3=names(1)
        p+=1
      Else
        strg3=names(strg[p-1]-46)
        p+=2
      EndIf
        If mainname="" Then
        mainname=strg3
        strg2+=strg3
      Else
        mainname+="."+strg3
        strg2+="."+strg3
      EndIf
      namecpt+=1
         names(namecpt)=mainname
    Else
      If Right(strg2,1)="(" Then
        strg2+=parse_typeope(Asc(Mid(strg,p,1)))
      Else
        strg2+=","+parse_typeope(Asc(Mid(strg,p,1)))
      EndIf
      p+=1
    EndIf
  Wend

  strg2+=")"
  If Right(strg2,6)="(Void)" Then
    strg2=Left(strg2,Len(strg2)-6)
  EndIf

  Return strg2
End Function
Sub cutup_retval(prcnb As Integer,gv2 As String)
  'example :f7 --> private sub /  :F18=*19=f7" --> public sub ptr / :f18=*19=*1 --> private integer ptr ptr
  Dim p As Integer,c As Integer,e As Integer
  For p=0 To Len(gv2)-1
    If gv2[p]=Asc("*") Then c+=1
    If gv2[p]=Asc("=") Then e=p+1
  Next
  If c Then 'pointer
    If InStr(gv2,"=f") OrElse InStr(gv2,"=F") Then
      If InStr(gv2,"=f7") OrElse InStr(gv2,"=F7") Then
        p=200+c 'sub
      Else
        p=220+c 'function
      EndIf
    Else
      If gv2[e]=Asc("*")Then e+=1 '08/08/2013
         p=c
    End If
  Else
    p=0
  End If
  c=Val(Mid(gv2,e+1))
  If c=udt(15).index Then c=15 '05/11/2013
  If c>15 Then c+=udtcpt
  proc(prcnb).pt=p
  proc(prcnb).rv=c
End Sub

Function check_source(sourcenm As String) As Integer ' check if source yet stored if not store it, in all cases return the index
  Static As String fpath
  If sourcenm="" Then Return -1
  If Right(sourcenm,1)=SLASH Then fpath=sourcenm:Return -1
   If instr(sourcenm,":")=0 Then sourcenm=fpath+sourcenm

   For i As Integer=0 To sourcenb
      If source(i).fullname=sourcenm Then Return i 'found
   Next
   sourcenb+=1 'WARNING TO BE ADDED test source max
   source(sourcenb).fullname=sourcenm
   source(sourcenb).shortname=name_extract(sourcenm)
  Return  sourcenb
End Function
Function stabs_extract(nfile As String,adrdiff As uinteger) As Long 'return 1 if dwarf data for debuggee is found, if not return 0 07/11/2013
  Dim As Integer counter,flagstd
  Dim As String dissas_command,code,procnmt,fpath,fname
  'Dim As Long flagnoread
  Dim As Long srcprevnb=sourcenb,procnodll=TRUE,lastline,linen,temp
  Dim As UInteger procadr,varadr,linea

#ifndef __FB_UNIX__
  If Dir(ExePath2+SLASH+OBJDUMP)="" Then simple_message("Stabs extract","Error : objdump.exe must be in the directory of fbdebugger ("+ExePath2+SLASH+"objdump.exe)"):Return 0 '20/11/2013
  dissas_command=""""""+ExePath2+SLASH+OBJDUMP+""" -G " """"+nfile+""""""
#else
  dissas_command = OBJDUMP & " -G """ & nfile & """"
#endif
  stff=FreeFile
  counter=Open Pipe( dissas_command For Input As #stff)

  Do Until EOF(stff)
     'If flagnoread=0 Then
        Line Input #stff, stln
     'Else
     '   flagnoread=0
     'EndIf
     'dbg_prt2(stln)

     code=Mid(stln,8,5)
     Select Case code
      Case "SLINE" 'first position as most used
          'Print "Ligne=";Valint(Mid(stln,22,6));" ";ValInt("&h"+Mid(stln,29,8))+procadr
          linen=Valint(Mid(stln,22,6)):linea=ValInt("&h"+Mid(stln,29,8))+procadr
              If procnodll Then 'And recupstab.nline>lastline Then
            If linen Then '09/08/2013
              If linen>lastline Then
                  'asm with just comment 25/06/2012
                If linea<>rline(linenb).ad Then ' recupstab.ad+proc2<>rline(linenb).ad Then
                    linenb+=1
                Else
                    ''''''''TODO reported after start WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rLine(linenb).sv,1,0)
                EndIf
                ' 25/06/2012
                rline(linenb).ad=linea'recupstab.ad+proc2
                '''''''''TODO reported after start  ReadProcessMemory(dbghand,Cast(LPCVOID,rline(linenb).ad),@rLine(linenb).sv,1,0) 'sav 1 byte before writing &CC
                If rLine(linenb).sv=-112 Then 'nop, address of looping (eg in a for/next loop correponding to the command next)
                  linenb-=1
                ''' dbg_prt2("NUM LINE = NOP "+Str(recupstab.nline))'gcc only 25/08/2013
                Else
                  rLine(linenb).nu=linen:rLine(linenb).pr=procnb
                  Print "ligne=";linen,rline(linenb).ad
                  ''''''''TODO reported after start WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@breakcpu,1,0)
                  #Ifdef fulldbg_prt
                        dbg_prt("Line / adr : "+Str(linen)+" "+Hex(rline(linenb).ad))
                        dbg_prt("")
                  #EndIf
                  If linea-procadr Then lastline=linen 'recupstab.ad<>0 Then lastline=linen 'first proc line always coded 1 but ad=0
                EndIf
              Else
               'dbg_prt2("NUM LINE NOT > LAST LINE")'14/08/2013
              End If
            Else
              'dbg_prt2("NUM LINE = 0")'09/08/2013
            EndIf
            '12/01/2014''''''''''''''''Else
               ''''''''''''''''dbg_prt2("STILL VERY FIRST LINE = "+Str(firstline))'09/08/2013
            '12/01/2014'''''''''''EndIf
              End If


      Case "SO   "
        fname=Mid(stln,45)
          Print "File=";fname;"  xx  ";left(stln,45)
          temp=check_source(fname)
          If temp<>-1 Then
            sourceix=temp
            Print "Current File=";source(sourceix).fullname
          EndIf
      Case "LSYM "
        If Mid(stln,45,10)="integer:t1" Then
          flagstd=1
        ElseIf Mid(stln,45,8)="pchar:t1" Then
          flagstd=0
        ElseIf flagstd=0 Then
          If InStr(stln,":Tt") then
            Print "Udt=";Mid(stln,45,50)
            cutup_1(Mid(stln,45),0)
          Else
            varadr=ValInt("&h"+Mid(stln,29,8))
            Print "Local var=";Mid(stln,45);" ";varadr
            cutup_1(Mid(stln,45),varadr)
          endif
        EndIf
      Case "BINCL","SOL  "
        fname=Mid(stln,45)
        Print"Include file=";fname
          temp=check_source(fname)
          If temp<>-1 Then
            sourceix=temp
            Print "Current File=";source(sourceix).fullname
          EndIf

      Case "EINCL"
      Case "FUN  "

          If Mid(stln,45)="" Then ''End of proc
                  If procnodll Then
                    'If gengcc=1 Then proc1=recupstab.ad+proc2 'under gcc 36=224 or 224 not use 10/01/2014 TODO check with gengcc
                    'proc(procnb).fn=proc1:proc(procnb).db=proc2

                    procadr=ValInt("&h"+Mid(stln,29,8))'11/05/2015
                    procadr+=proc(procnb).db
                    proc(procnb).fn=procadr
                    If procadr>procfn Then procfn=procadr+1 '24/01/2013 just to be sure to be above see gest_brk
                    Print "procfn=";procfn
                    'dbg_prt2("Procfn stab="+Hex(procfn))
                  EndIf
                 If proc(procnb).nu=rline(linenb).nu AndAlso linenb>2 Then 'for proc added by fbc (constructor, operator, ...) '11/05/2014 adding >2 to avoid case only one line ...
                  proc(procnb).nu=-1
                  For i As Integer =1 To linenb
                    'dbg_prt2("Proc db/fn inside for stab="+Hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
                    'dbg_prt2("Line Adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
                    If rline(i).ad>=proc(procnb).db AndAlso rline(i).ad<=proc(procnb).fn Then
                      'dbg_prt2("Cancel breakpoint adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
                      '''''  WARNING to be rewritten  WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@rLine(i).sv,1,0)
                      'nota rline(linenb).nu=-1
                    EndIf
                  Next
                 Else
                    'for GCC 16/08/2013''''''''''
                    If gengcc Then
                      If proc(procnb).rv=7 Then 'sub return void
                      rline(linenb).nu-=1 'decrement the number of the last line of the proc
                      proc(procnb).fn=rline(linenb).ad    'replace address because = next proc address
                      ''' dbg_prt2("SPECIAL GCC1 "+proc(procnb).nm+" "+Str(rline(linenb).nu)+" "+Str(rline(linenb).ad))
                      Else 'function
                        linenb-=1 'remove the last line (added by gcc but unexist)
                        If proc(procnb).nm<>"main" Then 'main = NO CHANGE
                    '''''  WARNING to be rewritten writeProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rLine(linenb).sv,1,0) 'restore to avoid stop
                          rline(linenb).ad=rline(linenb+1).ad 'replace the address by these of the next one
                          rline(linenb).sv=rline(linenb+1).sv
                          proc(procnb).fn=rline(linenb).ad    'replace address because = next proc address
                          ''' dbg_prt2("SPECIAL GCC2 "+proc(procnb).nm+" "+Str(rline(linenb).ad))
                        Else
                          ''' dbg_prt2("SPECIAL GCC3")
                        EndIf
                      EndIf
                    EndIf
                 EndIf




            exit Select 'end of proc
          EndIf
        'begin of proc
          procadr=ValInt("&h"+Mid(stln,29,8))

          Print "Proc=";Mid(stln,45);" ";procadr

          procnodll=FALSE 'to jump some procs
              procnmt=cutup_proc(Left(Mid(stln,45),InStr(Mid(stln,45),":"))) 'name of proc

              If procnmt="{MODLEVEL}" Then Exit Select
              procnodll=TRUE
          procnb+=1:proc(procnb).sr=sourceix
                    'GCC to remove @ in proc name ex test@0: --> test:
                      If InStr(procnmt,"@") Then '08/08/2013
                         proc(procnb).nm=Left(procnmt,InStr(procnmt,"@")-1)
                      Else
                        proc(procnb).nm=procnmt
                      End If
          cutup_retval(procnb,Mid(stln,InStr(stln,":")+2,99))'skip :F --> public / :f --> private then return value .rv + pointer .pt
          proc(procnb).db=procadr '11/01/2015
          proc(procnb).st=1 'state no checked
          proc(procnb).nu=Valint(Mid(stln,22,6)):lastline=0
          proc(procnb+1).vr=proc(procnb).vr 'in case there is not param nor local var
      Case "PSYM "
          varadr=ValInt("&h"+Mid(stln,29,8))
          Print "Param=";Mid(stln,45);" ";varadr
          cutup_1(Mid(stln,45),varadr)
      Case "STSYM","LCSYM"
          varadr=ValInt("&h"+Mid(stln,29,8))
          Print "Shared/Common/Static=";Mid(stln,45);" ";varadr
          cutup_1(Mid(stln,45),varadr)
      Case "LBRAC","RBRAC" 'not used but could be for scope
      Case "MAIN "
          procadr=ValInt("&h"+Mid(stln,29,8))
          Print "Entry point (main)=";procadr
          'Line Input #stff, stln 'skip stabd 68,0,1
          procnodll=false
      Case Else
        Print "stabs unknow=";left(stln,45):':end
     End Select
  Loop
  Close #stff
  Return 1
End Function
Function display_pt(pt As Long)As String
  If pt>220 Then Return String(.pt-220,"*")
  If pt>200 Then Return String(.pt-200,"*")
  Return String(.pt,"*")
End Function
Sub extract_begin(nfile As String)
  vrbloc=VGBLMAX
  proc(1).vr=VGBLMAX+1 'for the first stored proc
  udt(0).nm="Typ Unknown"
     udt(1).nm="Integer" : udt( 1).lg=SIZEOF(INTEGER)
        udt(2).nm="Byte" : udt( 2).lg=SIZEOF(BYTE)
       udt(3).nm="Ubyte" : udt( 3).lg=SIZEOF(UBYTE)
     udt(4).nm="Zstring" : udt( 4).lg=SIZEOF(ANY PTR)
       udt(5).nm="Short" : udt( 5).lg=SIZEOF(SHORT)
      udt(6).nm="Ushort" : udt( 6).lg=SIZEOF(USHORT)
        udt(7).nm="Void" : udt( 7).lg=SIZEOF(ANY PTR) :udt(7).index=7'dwarf
    udt(8).nm="Uinteger" : udt( 8).lg=SIZEOF(UINTEGER)
     udt(9).nm="Longint" : udt( 9).lg=SIZEOF(LONGINT)
   udt(10).nm="Ulongint" : udt(10).lg=SIZEOF(ULONGINT)
     udt(11).nm="Single" : udt(11).lg=SIZEOF(SINGLE)
     udt(12).nm="Double" : udt(12).lg=SIZEOF(DOUBLE)
     udt(13).nm="String" : udt(13).lg=SIZEOF(STRING)
    udt(14).nm="Fstring" : udt(14).lg=SIZEOF(ANY PTR)
  udt(15).nm="fb_Object" : udt(15).lg=SIZEOF(UINTEGER)

  exepath2=ExePath
  'If Dir(exepath2+"\*")="" Then
  ' exepath2="D:\laurent divers\fb dev\En-cours\FBDEBUG NEW\tests fbdebugger"
  'EndIf

  stabs_extract(nfile,123456)



  Print "STORED DATA"
Print "global=";vrbgbl
For i As Long =1 To vrbgbl
  With vrb(i)
  Print .nm;" ";.typ;" ";.adr;" ";display_pt(.pt)
  End With
Next
Print:Print "local=";vrbloc
For i As Long =VGBLMAX+1 To vrbloc
  With vrb(i)
  Print .nm;" ";.typ;" ";.adr;" ";display_pt(.pt)
  End With
Next
Print:Print "Proc";procnb
For i As Long =1 To procnb
  With proc(i)
    Print i;" ";.nm;" ret=";udt(.rv).nm;" ";String(.pt,"*");" ";.vr;" ";proc(i+1).vr-1;" ";source(.sr).shortname;" nu=";.nu;':sleep
    If .nu=-1 Then Print " added by compiler" Else Print
    For j As Long =proc(i).vr To proc(i+1).vr-1
      With vrb(j)
        If .mem=4 OrElse .mem=5 Then Print "Param="; Else Print "Local=";
        Print j;" ";.nm;" ";.typ;" ";.adr;" ";display_pt(.pt)
      End With
    Next
  End With

  Print
  For j As Long=1 To linenb
    With rline(j)
      If .pr=i Then
        Print "nu=";.nu;" ad=";.ad
'       If proc(.pr).nu=-1 Then Print " never reached added by compiler" Else Print
      EndIf
    End With
  Next
  Print "------------------------"':sleep
Next
  ''''''''16/06/2014
  ''''''''proc(procnb).nm=procnmt 'proc(procnb).ad=proc2 keep it if needed
  ''''''''GCC to remove @ in proc name ex test@0: --> test:
   '''''''If InStr(procnmt,"@") Then '08/08/2013
   '''''''   proc(procnb).nm=Left(procnmt,InStr(procnmt,"@")-1)
   '''''''Else
   '''''''  proc(procnb).nm=procnmt
   '''''''End If

End Sub
Sub proc_load
  Dim As String prcname
  DIM AS GtkTreeIter tempiter
  If procnb=0 Then Exit Sub

  For i As Long =1 To procnb
  With proc(i)
    Print i;" ";.nm;" ret=";udt(.rv).nm;" ";String(.pt,"*");" ";.vr;" ";proc(i+1).vr-1;" ";source(.sr).shortname;" nu=";.nu;':sleep
    prcname=.nm+" ret="+udt(.rv).nm+" "+String(.pt,"*")+" "+source(.sr).shortname+" nu="+Str(.nu)
    gtk_tree_store_append( GTK_TREE_STORE(GUI.tstoreProcs), @tempiter, NULL)
    gtk_tree_store_set( GTK_TREE_STORE(GUI.tstoreProcs), @tempiter, 0, StrPtr(prcname), -1)
    proc(i).tv=@tempiter
  If .nu=-1 Then Print " added by compiler" Else Print
  For j As Long =proc(i).vr To proc(i+1).vr-1
    With vrb(j)
    If .mem=4 OrElse .mem=5 Then Print "Param="; Else Print "Local=";
      Print j;" ";.nm;" ";.typ;" ";.adr;" ";display_pt(.pt)
    End With
  Next
  End With
  Next
End Sub




