PARAMETERS: P_FILE LIKE RLGRAP-FILENAME DEFAULT 'C:\'. "Prsnt Srvr

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

CALL FUNCTION 'WS_FILENAME_GET'
EXPORTING
DEF_PATH = P_FILE
MASK = ',..'
MODE = '0 '
TITLE = 'Choose File'
IMPORTING
FILENAME = P_FILE
EXCEPTIONS
INV_WINSYS = 1
NO_BATCH = 2
SELECTION_CANCEL = 3
SELECTION_ERROR = 4
OTHERS = 5.