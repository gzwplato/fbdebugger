/'* \file core.bi
\brief Header binding core SUBs / FUNCTIONs to the GUI part

This header should contain all SUBs / FUNCTIONs / EXTERNs declarations
from the core part that should be visible in the GUI part.

\todo Add entries

\since 3.0
'/

'* The slash character for paths
#ifdef __FB_UNIX__
#define SLASH "/"
#else
#define SLASH "\"
#endif

DECLARE SUB core1_sub(BYVAL T AS STRING)
DECLARE FUNCTION core2_func(BYVAL T AS STRING) AS INTEGER
