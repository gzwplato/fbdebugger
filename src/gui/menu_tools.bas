/'* \file menu_tools.bas
\brief Signal handlers for actions the Tools popup menu

\since 3.0
'/


'' act_Settings is located in settings.bas

SUB act_compinfo CDECL ALIAS "act_compinfo" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_compinfo, ToDo: insert code"

END SUB


SUB act_help CDECL ALIAS "act_help" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

?" --> callback act_help"

END SUB


SUB act_tuto CDECL ALIAS "act_tuto" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_tuto, ToDo: insert code"

END SUB


SUB act_idelaunch CDECL ALIAS "act_idelaunch" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_idelaunch, ToDo: insert code"

END SUB


SUB act_quickedit CDECL ALIAS "act_quickedit" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_quickedit, ToDo: insert code"

END SUB


SUB act_compnrun CDECL ALIAS "act_compnrun" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_compnrun, ToDo: insert code"

END SUB


SUB act_notescopy CDECL ALIAS "act_notescopy" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_notescopy, ToDo: insert code"

END SUB


SUB act_logshow CDECL ALIAS "act_logshow" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_logshow, ToDo: insert code"

END SUB


SUB act_loghide CDECL ALIAS "act_loghide" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_loghide, ToDo: insert code"

END SUB


SUB act_logdel CDECL ALIAS "act_logdel" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_logdel, ToDo: insert code"

END SUB


SUB act_enumlist CDECL ALIAS "act_enumlist" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_enumlist, ToDo: insert code"

END SUB


SUB act_processlist CDECL ALIAS "act_processlist" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_processlist, ToDo: insert code"

XPD->addXpd(@fillExpandTree, NULL)
END SUB


SUB act_dlllist CDECL ALIAS "act_dlllist" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_dlllist, ToDo: insert code"

END SUB


SUB act_winmsg CDECL ALIAS "act_winmsg" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_winmsg, ToDo: insert code"

END SUB


/'* \brief Callback to update the label in Hex/Dec/Oct/Bin dialog
\param Entry The GtkEntry to read from
\param Label The GtkLabel to write to

This callback gets called on each change of the dialog entry. It
updates the label context.

'/
SUB on_hdob_entry_changed CDECL( _
    BYVAL Entry AS GtkEntry PTR _
  , BYVAL Label AS GtkLabel PTR)

  VAR num = VALLNG(*gtk_entry_get_text(Entry)) _
    , txt = g_strdup_printf(!"%s\n%s\n%s\n%s"_
             , HEX(num) _
             , STR(num) _
             , OCT(num) _
             , BIN(num) _
             , NULL)
  gtk_label_set_text(Label, txt)
  g_free(txt)
END SUB


/'* \brief Callback to copy results in a different format
\param Entry The GtkEntry to read from
\param Event The keyboard event
\param user_data (unused)
\returns TRUE when key gets handled, FALSE otherwise

Callback that filters <crtl>[HDOB] keystrokes and transforms the entry
context in a different format.

'/
FUNCTION on_hdob_entry_key CDECL( _
    BYVAL Entry AS GtkWidget PTR _
  , BYVAL Event AS GdkEvent PTR _
  , BYVAL user_data AS gpointer) AS gboolean

  WITH *CAST(GdkEventKey PTR, Event)
    IF .state - 16 <> GDK_CONTROL_MASK THEN                 RETURN FALSE

    VAR num = VALLNG(*gtk_entry_get_text(GTK_ENTRY(Entry))) _
      , txt = ""
    SELECT CASE AS CONST .keyval
    CASE GDK_KEY_m : RETURN true
    CASE GDK_KEY_h : txt = "&h" & HEX(num)
    CASE GDK_KEY_d : txt = STR(num)
    CASE GDK_KEY_o : txt = "&o" & OCT(num)
    CASE GDK_KEY_b : txt = "&b" & BIN(num)
    CASE ELSE :                                             RETURN false
    END SELECT
  END WITH : gtk_entry_set_text(GTK_ENTRY(Entry), txt)     : RETURN true
END FUNCTION


/'* \brief Dialog to transform integer values
\param action The action that triggered the signal (id="action917")
\param user_data (unused)

This signal handler gets called when the user chooses the menu item
'Hex/Dec/Oct/Bin' in the tools menu. It creates a dialog with an entry.
The number in the entry gets transformed to the other formats and shown
in a label, updating on each entry change.

'/
SUB act_bdohtrans CDECL ALIAS "act_bdohtrans" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

  VAR dia = gtk_dialog_new_with_buttons( _
      *__("HEX/DEC/OCT/BIN") _
    , GTK_WINDOW(GUI.window1) _
    , GTK_DIALOG_DESTROY_WITH_PARENT _
    , *__("Cancel"), GTK_RESPONSE_CANCEL _
    , NULL)
  VAR cont = gtk_dialog_get_content_area(GTK_DIALOG(dia))

  /' Create a label for header line '/
  VAR tlabel = gtk_label_new(*__(!"Value in hexadecimal, decimal, octal and binary"))
  gtk_box_pack_start(GTK_BOX(cont), tlabel, TRUE, TRUE, 0)

  /' Create a label for variable values '/
  VAR llabel = gtk_label_new(NULL)
  gtk_label_set_justify(GTK_LABEL(llabel), GTK_JUSTIFY_RIGHT)
  gtk_misc_set_alignment(GTK_MISC(llabel), 1., .0)

  /' Create GtkEntry '/
  VAR pEntry = gtk_entry_new()
  gtk_entry_set_alignment(GTK_ENTRY(pEntry), 1.)

  /' Create a label for types '/
  VAR rlabel = gtk_label_new(NULL)
  gtk_label_set_markup(GTK_LABEL(rlabel), !"<i><u>H</u>ex \n<u>D</u>ec\n<u>O</u>ct\n<u>B</u>in</i>")
  gtk_label_set_mnemonic_widget(GTK_LABEL(rlabel), pEntry)
  /' Create a hbox container '/
  VAR hbox = gtk_hbox_new(FALSE, 5)
  /' Insert value label in GtkHBox '/
  gtk_box_pack_start(GTK_BOX(hbox), llabel, TRUE, TRUE, 0)
  /' Insert types label in GtkHBox '/
  gtk_box_pack_start(GTK_BOX(hbox), rlabel, FALSE, TRUE, 0)
  /' Insert GtkHBox in dialog contents '/
  gtk_box_pack_start(GTK_BOX(cont), hbox, FALSE, TRUE, 0)

  /' Insert GtkEntry in GtkVBox '/
  gtk_box_pack_start(GTK_BOX(cont), pEntry, FALSE, FALSE, 0)
  /' Update the GtkLabel on changes in GtkEntry '/
  g_signal_connect(G_OBJECT(pEntry), "changed" _
                 , G_CALLBACK(@on_hdob_entry_changed), GTK_LABEL(llabel))
  g_signal_connect(G_OBJECT(pEntry), "key-press-event" _
                 , G_CALLBACK(@on_hdob_entry_key), GTK_LABEL(llabel))
  /' Set initial value (emits changed signal) '/
  gtk_entry_set_text(GTK_ENTRY(pEntry), "0")
  /' End dialog on Return/Enter key '/
  g_signal_connect_swapped(G_OBJECT(pEntry), "activate" _
                         , G_CALLBACK(@gtk_widget_destroy), dia)
  /' End dialog on button clicked '/
  g_signal_connect(G_OBJECT(dia), "response" _
                 , G_CALLBACK(@gtk_widget_destroy), dia)

  gtk_widget_show_all(dia)
END SUB


SUB act_fasttimer CDECL ALIAS "act_fasttimer" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_fasttimer, ToDo: insert code"

END SUB


SUB act_jitset CDECL ALIAS "act_jitset" ( _
  BYVAL action AS GtkAction PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
?" --> callback act_jitset, ToDo: insert code"

END SUB

