;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; rutinok
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BANK0:
    LD A,0x00
    OUT (0xC0), A
    RET
BANK1:
    LD A,0x08
    OUT (0xC0), A
    RET
BANK2:
    LD A,0x10
    OUT (0xC0), A
    RET
BANK3:
    LD A,0x18
    OUT (0xC0), A
    RET

SEND_SEQ_HL:
    LD A, (HL)
    CP 0
    RET Z
    PUSH HL
    LD C, A
    RST 0x18
    POP HL
    INC HL
    JR SEND_SEQ_HL

CLSC:
    LD C, 0x0F
    RST 0x18
    LD C,12
    CALL CHSCREEN
    RET

PRINTP_AT_HL_DE: ; Print over Puffer
;    PUSH DE
;    CALL APA
;    LD HL,2
;    CALL WAIT
;    POP DE
PRINTP_LOOP:
    LD A, (DE)
    CP 0
    RET Z
    LD C, A
    PUSH DE
    RST 0x18
    ;CALL CHSCREEN
    POP DE
    INC DE
    JR PRINTP_LOOP

PRINTP_DE: ; Print over Puffer
    LD A, (DE)
    CP 0
    RET Z
    LD C, A
    PUSH DE
    RST 0x18
    ;CALL CHSCREEN
    POP DE
    INC DE
    JR PRINTP_DE

PRINT0A_AT_HL_DE: ; Print at HL position (H=row, L=col) text from DE to 0A character
    PUSH DE
    CALL APA
    POP DE
PRINT0A_LOOP:
    LD A, (DE)
    CP 0x0A
    RET Z
    LD C, A
    PUSH DE
    CALL CHSCREEN
    POP DE
    INC DE
    JR PRINT0A_LOOP

