/'* \file core2.bas
\brief Example code to show bindings between core and GUI part

\todo Create a similar file for each core module, remove core2.bas

\since 3.0
'/

FUNCTION core2_func(byval T AS STRING) AS INTEGER
  ?"==> core2_func: " & T
  RETURN IIF(len(t), 1, 0)
END FUNCTION
