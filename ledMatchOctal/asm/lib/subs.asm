;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; rutinok
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RST_0x18:
    PUSH DE
    PUSH HL
    PUSH BC
    LD A, C
    LD (RSTMP), A
    LD HL, RSTMP
    LD DE, 1
    CALL BTX_PRINT_HL_DE
    POP BC
    POP HL
    POP DE
    RET

RSTMP: DB 0

SEND_SEQ_HL:
    LD A, (HL)
    CP 0
    RET Z
    PUSH HL
    LD C, A
    CALL RST_0x18
;    RST 0x18
    POP HL
    INC HL
    JR SEND_SEQ_HL

CLSC:
    LD HL, EMPTY_STATUS_LINE
    CALL SYSERR
;    LD C, 0x0F
;    RST 0x18
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
    CALL RST_0x18
;    RST 0x18
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
    CALL RST_0x18
    ;CALL CHSCREEN
    POP DE
    INC DE
    JR PRINTP_DE

PRINT0A_AT_HL_DE:
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
