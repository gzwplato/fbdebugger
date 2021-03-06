/'* \file fbdbg.bas
\brief The main source code of the debugger GUI.

This is the main source code of the debugger GUI part. It gets compiled
as a single module, since separate compilation wont gain build speed,
because the header overhead is much bigger than the source.

See file ../ReadMe.md for licence information.

\since 3.0
'/

' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< main program generated by utility                           GladeToBac V3.4 >
'< Hauptprogramm erzeugt von                                                   >
'< Generated at / Generierung am                             2015-01-20, 10:56 >
' -----------------------------------------------------------------------------
'<                                                                             >
'< Description / Beschreibung:                                                 >
'<                                                                             >
'<   FreeBASIC Debugger                                                        >
'<                                                                             >
'< License / Lizenz:                                                           >
'<                                                                             >
'<   (C) by sarg@aliceadsl.fr                                                  >
'<   GPLv3 (Generell public licence version 3)                                 >
'<   details at http://www.gnu.org/licenses/gpl-3.0.html                       >
'<                                                                             >
' -----------------------------------------------------------------------------
'< Find program info in file:                                                  >
    #INCLUDE "version.bas" '               global constants (version, licence) >

    '#INCLUDE "Gir/_GdkPixbuf-2.0.bi" '    Woe32 fix due to uncomplete Gir file >
    #INCLUDE "Gir/GtkSource-3.0.bi" '            GTK+library / GTK+ Bibliothek >
    #INCLUDE "Gir/_GObjectMacros-2.0.bi" '                      GObject macros >
    gtk_init(@__FB_ARGC__, @__FB_ARGV__) '             start GKT / GTK starten >
    #INCLUDE "libintl.bi" '                     load I18N lib / I18N Lib laden >
    bindtextdomain(PROJ_NAME, EXEPATH & "/locale_") '              path / Pfad >
    bind_textdomain_codeset(PROJ_NAME, "UTF-8") '   set encoding / Zeichensatz >
    textdomain(PROJ_NAME) '                               Filename / Dateiname >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#INCLUDE ONCE "core/core.bi"
#INCLUDE ONCE "gui/gui.bi"
#INCLUDE Once "core/fbdbg2_defines.bi"
#INCLUDE ONCE "core/ini.bas"

INI = NEW IniUdt

' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GladeToBac:                                 load GUI stuff / GUI Anbindung >
    #INCLUDE "gui/gui.bas" '                                 Signals & GUI-XML >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#INCLUDE ONCE "testing.bas"
#INCLUDE ONCE "core/fbdbg2_main.bas"
' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GladeToBac:          run GTK main, then end / GTK Hauptschleife, dann Ende >
    gtk_builder_connect_signals(GUI.XML, 0) '                 Signale anbinden >
    gtk_main() '                                     main loop / Hauptschleife >
    g_object_unref(GUI.XML) '                   dereference / Referenz abbauen >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

'' delete global UDTs, created in gui/gui.bas
DELETE ACT
DELETE SRC
DELETE TXT
DELETE XPD
DELETE INI
