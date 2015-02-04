/'* \file filechoosers.bas
\brief Defining file choosers and filters for different purposes

\since 3.0
'/


'* Create a file save dialog
#define DBG_FILE_SAVE(_T_) _
  gtk_file_chooser_dialog_new(*__(_T_), NULL _
    , GTK_FILE_CHOOSER_ACTION_SAVE _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)

'* Create a file open dialog
#define DBG_FILE_OPEN(_T_) _
  gtk_file_chooser_dialog_new(*__(_T_), NULL _
    , GTK_FILE_CHOOSER_ACTION_OPEN _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)


FUNCTION dbg_exe_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("Executable Files"))
  #IFDEF __FB_UNIX__
    gtk_file_filter_add_mime_type(filter, "application/x-csh")
    gtk_file_filter_add_mime_type(filter, "application/x-executable")
    gtk_file_filter_add_mime_type(filter, "application/x-shellscript")
    gtk_file_filter_add_pattern(filter, "*.sh")
  #ELSE
    gtk_file_filter_add_pattern(filter, "*.exe")
    gtk_file_filter_add_pattern(filter, "*.bat")
    gtk_file_filter_add_pattern(filter, "*.com")
  #ENDIF
  RETURN filter
END FUNCTION

FUNCTION dbg_bas_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("FB Source Files"))
  #IFDEF __FB_UNIX__
    gtk_file_filter_add_pattern(filter, "*.BAS")
    gtk_file_filter_add_pattern(filter, "*.Bas")
    gtk_file_filter_add_pattern(filter, "*.bas")
  #ENDIF
  gtk_file_filter_add_pattern(filter, "*.bas")
  RETURN filter
END FUNCTION

FUNCTION dbg_all_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("All Files"))
  gtk_file_filter_add_pattern(filter, "*")
  RETURN filter
END FUNCTION
