;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID RAM test
;;; Végigteszteli a memóriát, és számolja a hibák számát 128-ig - nehogy átforduljon.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ORG 0x7600

START:
    CALL CLSC
    LD HL, START_TEXT
    CALL SYSERR
    LD A,0x18
    OUT (0xC0), A
    CALL CHECK_BANK
    LD A,0x10
    OUT (0xC0), A
    CALL CHECK_BANK
    LD HL, VIDEO_TEXT
    CALL SYSERR
    LD A,0x01
    OUT (0xC0), A
    CALL CHECK_BANK
    LD A,0x00
    OUT (0xC0), A
    CALL CHECK_BANK
    CALL CHECK_PAGE0A
    CALL CHECK_PAGE0B
    LD HL, FINISH_TEXT
    CALL SYSERR
    LD A, (ERR_CNT)
    CALL SHOW_HEX_A_SP
RET

CHECK_PAGE0A:
    LD HL, 0x6000
RAM_LOOP0A:
    CALL CHECK_HL
    INC HL
    LD A, H
    CP 0x76
    JR NZ, RAM_LOOP0A
    RET

CHECK_PAGE0B:
    LD HL, 0x7800
RAM_LOOP0B:
    CALL CHECK_HL
    INC HL
    LD A, H
    CP 0x80
    JR NZ, RAM_LOOP0B
    RET

CHECK_BANK:
    LD HL, 0x8000
RAM_LOOP:
    CALL CHECK_HL
    INC HL
    LD A, H
    OR L
    JR NZ, RAM_LOOP
    RET

CHECK_HL:
    LD A, 0xAA
    CALL CHECK_HL_A
    LD A, 0x00
    CALL CHECK_HL_A
    LD A, 0xFF
    CALL CHECK_HL_A
    RET

CHECK_HL_A:
    LD C, (HL)
    DI
    LD (HL), A
    LD B, (HL)
    LD (HL), C
    EI
    CP B
    CALL NZ, ERROR
    RET

ERROR:
    LD A, (ERR_CNT)
    BIT 7, A
    RET NZ
    INC A
    LD (ERR_CNT), A
    RET

ERR_CNT: DB 0

START_TEXT:  DB "Wait for testing ...        ", 0xA0
VIDEO_TEXT:  DB "Video RAM finished, wait ...", 0xA0
FINISH_TEXT: DB "RAM test finished           ", 0xA0

include "inc/ROM.asm"
include "inc/hex.asm"
;include "inc/graph.asm"
include "inc/glob.asm"
