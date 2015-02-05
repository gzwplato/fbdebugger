/'* \file act_notes.bas
\brief Signal handler for a GtkAction (id="action467")

\since 3.0
'/

SUB act_notes CDECL ALIAS "act_notes" ( _
  BYVAL Action AS GtkAction PTR, _
  BYVAL TextView AS gpointer) EXPORT

?*__("callback act_notes")
  'dim as gboolean visible
  'g_object_get(TextView, "visible", @visible, NULL)
  'g_object_set(TextView, "visible", IIF(visible, FALSE, TRUE), NULL)
  TXT.Notes()

END SUB
