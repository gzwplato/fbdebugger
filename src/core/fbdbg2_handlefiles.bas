/'* \file fbdbg2_handlefiles.bas
\brief Handle bas or exe file

Source code to handle bas or exe files

- by file chooser
- by command line
- by attach (running process)
- drag n drop
- restart last exe
- restart one of previous exes

\since 3.0
'/


Sub filechoose()
  prun=TRUE
If kill_process(*__("Trying to load a file")) Then

  Var dia = DBG_FILE_OPEN(*__("Select an exe or bas file name"))
  'gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_all_filter())
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_exe_filter())
  gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dia), dbg_bas_filter())

  Var ret = gtk_dialog_run(GTK_DIALOG(dia))

  IF ret=GTK_RESPONSE_ACCEPT Then
    Var fnam = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dia))
    gtk_widget_destroy(dia)
    IF 0 = fnam THEN             /' ToDo: no valid file name '/ EXIT SUB
    exename=*fnam
    g_free (fnam)
  Else
    gtk_widget_destroy(dia)
    Exit Sub
  END IF
? EXENAME
  'If lcase(Mid(exename, INSTRREV(exename,".")))<>".exe" Then
    ''''''VAR dia = gtk_message_dialog_new_with_markup(GTK_WINDOW(GUI.window1) _
    '''''', GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT _
    '''''', GTK_MESSAGE_WARNING _
    '''''', GTK_BUTTONS_OK _
    '''''', ( _
    ''''''*__("Sorry, for now, only exe files are handled") _
    '''''')_
    '''''', NULL)
    ''''''
    ''''''gtk_dialog_run(GTK_DIALOG(dia))
    ''''''gtk_widget_destroy(dia)
    'Var msg1=*__("Sorry, for now, only exe files are handled")
    'simple_message(msg1)
    'Exit Sub
  'EndIf

  DIM AS gsize flen
  DIM AS GError PTR errr
  VAR msg = g_filename_to_utf8(exename, -1, NULL, @flen, @errr)
  Print "txt";txt ':Sleep 5000
  if msg then
    TXT->add2notes("TEST, debuggee is " & *msg)
    g_free(msg)
  end if

  re_ini
  Print "Exename";exename

  extract_begin(exename)
  Print "after extract"; exename
  If sourcenb=-1 Then Exit sub
  Print "before source_load"
  source_load(0)
  Print "after source_load"
  proc_load
  Print "before treat file="; exename
' treat_file(exename)
  Print "after treat file"
EndIf
End Sub

Sub source_load(srcfirst As Long)
  Print "Source list"

  Var fnr = FreeFile
  For i As Long =srcfirst To sourcenb
    Print i,source(i).shortname

    If 0 = OPEN(source(i).fullname For INPUT AS fnr) THEN
       VAR l = LOF(fnr)
       IF l <= G_MAXINT THEN
          Var t = STRING(l, 0)
          Get #fnr, , t
          Close #fnr
        Print SRC->addBas(source(i).shortname,t)
          'Print SRC->addBas(MID(*fnam, INSTRREV(*fnam, ANY "/\") + 1), t)
       End IF
    End If
  Next

End Sub
