' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< _tobac.bas modul generated by utility                     GladeToBac V3.4.1 >
'< Modul _tobac.bas erzeugt von                                                >
'< Generated at / Generierung am                             2015-02-04, 16:05 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: fbdbg.bas                                          >
'< Author:  SARG, AGS, TJF                                                     >
'<  Email:  Thomas.Freiherr@gmx.net                                            >
'<    WWW:  github.com/fbdbg                                                   >
' -----------------------------------------------------------------------------
'< declare names, signal handlers, load GUI-XML                   do not edit! >
'< deklariert Namen, Signale, laedt GUI-XML                  nicht veraendern! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

SCOPE
  VAR er = gtk_check_version(3, 6, 0)
  IF er THEN
    ?"Fehler/Error (GTK-Version):"
    ?*er
    END 1
  END IF
END SCOPE

TYPE GUIData
  AS GtkBuilder PTR XML
  AS GObject PTR _
  window1, lstoreMemory, srcbuff, srcbuffCur, tstoreProcVar, tstoreProcs,  _
  tstoreThreads, tstoreWatch, sbarlab1, sbarlab2, sbarlab3, sbarlab4, sbarlab5,  _
  srcviewCur, nbookSrc, srcview, nbook2, tviewProcVar, tviewProcs, tviewThreads,  _
  tviewWatch, lviewMemory, comboBookmarks, watch1, watch3, watch2, watch4
END TYPE
DIM SHARED AS GUIData GUI

GUI.XML = gtk_builder_new()

SCOPE
DIM AS GError PTR meld
IF 0 = gtk_builder_add_from_file(GUI.XML, "fbdbg.ui", @meld) THEN
  WITH *meld
    ?"Fehler/Error (GTK-Builder):"
    ?*.message
  END WITH
  g_error_free(meld)
  END 2
END IF
END SCOPE

WITH GUI
  .window1 = gtk_builder_get_object(.XML, "window1")
  .lstoreMemory = gtk_builder_get_object(.XML, "lstoreMemory")
  .srcbuff = gtk_builder_get_object(.XML, "srcbuff")
  .srcbuffCur = gtk_builder_get_object(.XML, "srcbuffCur")
  .tstoreProcVar = gtk_builder_get_object(.XML, "tstoreProcVar")
  .tstoreProcs = gtk_builder_get_object(.XML, "tstoreProcs")
  .tstoreThreads = gtk_builder_get_object(.XML, "tstoreThreads")
  .tstoreWatch = gtk_builder_get_object(.XML, "tstoreWatch")
  .sbarlab1 = gtk_builder_get_object(.XML, "sbarlab1")
  .sbarlab2 = gtk_builder_get_object(.XML, "sbarlab2")
  .sbarlab3 = gtk_builder_get_object(.XML, "sbarlab3")
  .sbarlab4 = gtk_builder_get_object(.XML, "sbarlab4")
  .sbarlab5 = gtk_builder_get_object(.XML, "sbarlab5")
  .srcviewCur = gtk_builder_get_object(.XML, "srcviewCur")
  .nbookSrc = gtk_builder_get_object(.XML, "nbookSrc")
  .srcview = gtk_builder_get_object(.XML, "srcview")
  .nbook2 = gtk_builder_get_object(.XML, "nbook2")
  .tviewProcVar = gtk_builder_get_object(.XML, "tviewProcVar")
  .tviewProcs = gtk_builder_get_object(.XML, "tviewProcs")
  .tviewThreads = gtk_builder_get_object(.XML, "tviewThreads")
  .tviewWatch = gtk_builder_get_object(.XML, "tviewWatch")
  .lviewMemory = gtk_builder_get_object(.XML, "lviewMemory")
  .comboBookmarks = gtk_builder_get_object(.XML, "comboBookmarks")
  .watch1 = gtk_builder_get_object(.XML, "watch1")
  .watch3 = gtk_builder_get_object(.XML, "watch3")
  .watch2 = gtk_builder_get_object(.XML, "watch2")
  .watch4 = gtk_builder_get_object(.XML, "watch4")
END WITH

#INCLUDE "act_varderefdump.bas"
#INCLUDE "act_varcopysel.bas"
#INCLUDE "act_varcopyall.bas"
#INCLUDE "act_runto.bas"
#INCLUDE "act_step.bas"
#INCLUDE "act_step_over.bas"
#INCLUDE "act_step_out.bas"
#INCLUDE "act_step_start.bas"
#INCLUDE "act_step_end.bas"
#INCLUDE "act_run.bas"
#INCLUDE "act_fastrun.bas"
#INCLUDE "act_stop.bas"
#INCLUDE "act_kill.bas"
#INCLUDE "act_auto.bas"
#INCLUDE "act_automulti.bas"
#INCLUDE "act_exemod.bas"
#INCLUDE "act_vardump.bas"
#INCLUDE "act_varedit.bas"
#INCLUDE "act_varexpand.bas"
#INCLUDE "act_stringshow.bas"
#INCLUDE "act_varwatched.bas"
#INCLUDE "act_varwtchtrace.bas"
#INCLUDE "act_varbrk.bas"
#INCLUDE "act_varindex.bas"
#INCLUDE "act_bzexchange.bas"
#INCLUDE "act_procinsource.bas"
#INCLUDE "act_proccall.bas"
#INCLUDE "act_varcollapse.bas"
#INCLUDE "act_varlistall.bas"
#INCLUDE "act_varlistsel.bas"
#INCLUDE "act_procasm.bas"
#INCLUDE "act_procsort.bas"
#INCLUDE "act_procfollow.bas"
#INCLUDE "act_procnofollow.bas"
#INCLUDE "act_procinvar.bas"
#INCLUDE "act_wtchtrace.bas"
#INCLUDE "act_wtchnotrace.bas"
#INCLUDE "act_wtch1.bas"
#INCLUDE "act_wtch2.bas"
#INCLUDE "act_wtch3.bas"
#INCLUDE "act_wtch4.bas"
#INCLUDE "act_wtchdel.bas"
#INCLUDE "act_wtchdellall.bas"
#INCLUDE "act_brkset.bas"
#INCLUDE "act_brktempset.bas"
#INCLUDE "act_brkenable.bas"
#INCLUDE "act_brkmanage.bas"
#INCLUDE "act_varsrcshow.bas"
#INCLUDE "act_varsrcwtch.bas"
#INCLUDE "act_textfind.bas"
#INCLUDE "act_bmktoogle.bas"
#INCLUDE "act_bmknext.bas"
#INCLUDE "act_bmkprev.bas"
#INCLUDE "act_linegoto.bas"
#INCLUDE "act_lineaddress.bas"
#INCLUDE "act_lineasm.bas"
#INCLUDE "act_procsrcasm.bas"
#INCLUDE "act_linenoexec.bas"
#INCLUDE "act_linefocus.bas"
#INCLUDE "act_notesadd.bas"
#INCLUDE "act_free.bas"
#INCLUDE "act_minicmd.bas"
#INCLUDE "act_restart.bas"
#INCLUDE "act_multiexe.bas"
#INCLUDE "act_attachexe.bas"
#INCLUDE "act_files.bas"
#INCLUDE "act_tools.bas"
#INCLUDE "act_notes.bas"
#INCLUDE "act_source.bas"
#INCLUDE "act_varproc.bas"
#INCLUDE "act_memory.bas"
#INCLUDE "act_threadselect.bas"
#INCLUDE "act_threadline.bas"
#INCLUDE "act_threadcreate.bas"
#INCLUDE "act_threadproc.bas"
#INCLUDE "act_threadvar.bas"
#INCLUDE "act_procbacktrack.bas"
#INCLUDE "act_procchain.bas"
#INCLUDE "act_procaddresses.bas"
#INCLUDE "act_threadkill.bas"
#INCLUDE "act_threadexpand.bas"
#INCLUDE "act_threadcollapse.bas"
#INCLUDE "act_threadlist.bas"
#INCLUDE "act_compinfo.bas"
#INCLUDE "act_help.bas"
#INCLUDE "act_tuto.bas"
#INCLUDE "act_idelaunch.bas"
#INCLUDE "act_quickedit.bas"
#INCLUDE "act_compnrun.bas"
#INCLUDE "act_notescopy.bas"
#INCLUDE "act_logshow.bas"
#INCLUDE "act_loghide.bas"
#INCLUDE "act_logdel.bas"
#INCLUDE "act_enumlist.bas"
#INCLUDE "act_processlist.bas"
#INCLUDE "act_dlllist.bas"
#INCLUDE "act_winmsg.bas"
#INCLUDE "act_bdhtrans.bas"
#INCLUDE "act_fasttimer.bas"
#INCLUDE "act_jitset.bas"

