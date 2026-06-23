;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID write text test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ORG 0x8100

START:
    LD A, 1
    LD ( 0x6D60 ), A     ; Disable BTX write

RESTART:
    CALL CLSC

    LD HL, 0x0303
    LD DE, Text1
    CALL PRINT0A_AT_HL_DE ; Print at HL position (H=row, L=col) text from DE to 0A character

    LD HL, 0x0305
    CALL APA ; Set cursor on screen. H=Col[1-40], L=Row[1-24]
    LD DE, Text2
    CALL PRINTP_DE ; Print at HL position (H=row, L=col) text from DE to 0A character

    LD HL, 25
    CALL WAIT       ; Wait for BTX read puffer

    LD HL, TextEnd
    CALL SYSERR

    RST 0x30 ; CALL WAIT_FOR_KEY_PRESS

    LD HL, TextEnd2
    CALL SYSERR

    JP RESTART

    CALL CLSC

    LD A, 0
    LD ( 0x6D60 ), A     ; Enabled BTX write
RET

Text1: DB "Text printed with CHSCREEN rutin",0x0A
Text2: DB "Text printed with RST 0x18",0
TextEnd:  DB " *** Press any key to return *** ", 0x0A
TextEnd2: DB " - - - - - - - - - - - - - - - - ", 0x0A

include "inc/ROM.asm"
include "inc/hex.asm"
include "inc/glob.asm"
include "inc/key.asm"
;include "inc/sound.asm"
