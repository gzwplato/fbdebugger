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
'CONST PROJ_NAME = "fbdbg"                   '*< The project name
'CONST PROJ_DESC = "FreeBASIC Debugger"      '*< The project description
'CONST PROJ_VERS = "3.0"                     '*< The version number
'CONST PROJ_YEAR = "2015"                    '*< The year of the release
'CONST PROJ_AUTH = "SARG, AGS, TJF"          '*< The authors
'CONST PROJ_MAIL = "Thomas.Freiherr@gmx.net" '*< An email address to get in contact
'CONST PROJ_WEBS = "http://github.com/fbdebugger/fbdebugger" '*< The website where to find the source
'CONST PROJ_LICE = "GPLv3"                   '*< The licence of the project
'<                                                                             >
'< Description / Beschreibung:                                                 >
'<                                                                             >
'<   FreeBASIC Debugger                                                        >
'<                                                                             >
'< License / Lizenz:                                                           >
'<                                                                             >
'<   (C) by ...                                                                >
'<   GPLv3 (Generell public licence version 3)                                 >
'<   details at http://www.gnu.org/licenses/gpl-3.0.html                       >
'<                                                                             >
' -----------------------------------------------------------------------------
'< Find program info in file:                                                               >
#INCLUDE "version.bas" '                   global constants (version, licence) >

    '#INCLUDE "Gir/Gtk-3.0.bi" '                  GTK+library / GTK+ Bibliothek >
    #INCLUDE "Gir/GtkSource-3.0.bi" '            GTK+library / GTK+ Bibliothek >
    '#INCLUDE "Gir/_GLibMacros-2.0.bi" '                            GLib macros >
    #INCLUDE "Gir/_GObjectMacros-2.0.bi" '                      GObject macros >
    gtk_init(@__FB_ARGC__, @__FB_ARGV__) '             start GKT / GTK starten >
    #INCLUDE "libintl.bi" '                     load I18N lib / I18N Lib laden >
    bindtextdomain(PROJ_NAME, EXEPATH & "/locale_") '              path / Pfad >
    bind_textdomain_codeset(PROJ_NAME, "UTF-8") '   set encoding / Zeichensatz >
    textdomain(PROJ_NAME) '                               Filename / Dateiname >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#INCLUDE ONCE "core/core.bi"

'' to get removed
declare SUB access_viol( _
    BYVAL Adr AS gint _
  , byval Fnam AS zSTRING PTR _
  , byval Proc AS zSTRING PTR _
  , byval Lin_ AS gint _
  , byval Text AS zSTRING PTR _
  )


' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GladeToBac:                                 load GUI stuff / GUI Anbindung >
    #INCLUDE "gui/gui.bas" '                                 Signals & GUI-XML >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#INCLUDE ONCE "testing.bas"

act_varproc(0, 0)

' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GladeToBac:          run GTK main, then end / GTK Hauptschleife, dann Ende >
    gtk_builder_connect_signals(GUI.XML, 0) '                 Signale anbinden >
    gtk_main() '                                     main loop / Hauptschleife >
    g_object_unref(GUI.XML) '                   dereference / Referenz abbauen >
'<  GladeToBac:                                          end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

DELETE SRC
DELETE TXT
DELETE XPD
