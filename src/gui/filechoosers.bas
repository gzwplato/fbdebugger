/'* \file filechoosers.bas
\brief Defining file choosers and filters for different purposes

\since 3.0
'/

#IFndef __FB_UNIX__
#UNDEF gdk_pixbuf_new_from_file_at_size
#DEFINE gdk_pixbuf_new_from_file_at_size gdk_pixbuf_new_from_file_at_size_utf8

EXTERN "C" LIB "gdk_pixbuf-2.0"
DECLARE FUNCTION gdk_pixbuf_new_from_file_at_size(BYVAL AS CONST char PTR, BYVAL AS gint /'int'/, BYVAL AS gint /'int'/, BYVAL AS GError PTR PTR) AS GdkPixbuf PTR
END EXTERN
#define FIX_GDKEVENTKEY 0
#else
#define FIX_GDKEVENTKEY 16
#ENDIF


'* Macro to create a file save dialog
#DEFINE DBG_FILE_SAVE(_T_) _
  gtk_file_chooser_dialog_new(*__(_T_), NULL _
    , GTK_FILE_CHOOSER_ACTION_SAVE _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)

'* Macro to create a file open dialog
#DEFINE DBG_FILE_OPEN(_T_) _
  gtk_file_chooser_dialog_new(*__(_T_), NULL _
    , GTK_FILE_CHOOSER_ACTION_OPEN _
    , "gtk-cancel", GTK_RESPONSE_CANCEL _
    , "gtk-ok", GTK_RESPONSE_ACCEPT _
    , NULL)



/'* \brief Create a file filter for executable files
\returns The newly created filter

This function creates a file filter to select executable files. On
non-LINUX systems it sets only some patterns. On LINUX mime types are
used to specify binaries and batch scripts.

\since 3.0
'/
FUNCTION dbg_exe_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("Executable Files"))
  #IFDEF __FB_UNIX__
    gtk_file_filter_add_mime_type(filter, "application/x-csh")
    gtk_file_filter_add_mime_type(filter, "application/x-executable")
    'NO script gtk_file_filter_add_mime_type(filter, "application/x-shellscript")
    'NO script gtk_file_filter_add_pattern(filter, "*.sh")
  #ELSE
    gtk_file_filter_add_pattern(filter, "*.exe")
    'NO BAT gtk_file_filter_add_pattern(filter, "*.bat")
    'NO COM gtk_file_filter_add_pattern(filter, "*.com")
  #ENDIF
  RETURN filter
END FUNCTION


/'* \brief Create a file filter for FreeBASIC source files
\returns The newly created filter

This function creates a file filter to select FreeBASIC source code
files. It sets some patterns, using regex to allow case-insensitive
search.

\since 3.0
'/
FUNCTION dbg_bas_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("FB Source Files"))
  gtk_file_filter_add_pattern(filter, "*.[Bb][Aa][Ss]")
  RETURN filter
END FUNCTION


/'* \brief Create a file filter for all files
\returns The newly created filter

This function creates a file filter to select any files.

\since 3.0
'/
FUNCTION dbg_all_filter() AS GtkFileFilter PTR
  VAR filter = gtk_file_filter_new() '   don't free, dia takes ownership
  gtk_file_filter_set_name(filter, *__("All Files"))
  gtk_file_filter_add_pattern(filter, "*")
  RETURN filter
END FUNCTION
