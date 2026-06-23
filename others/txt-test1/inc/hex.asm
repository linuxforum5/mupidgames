;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHOW_HEX_A_SP:
    PUSH AF
    CALL SHOW_HEX_A
    PUSH BC
    LD C, 32
    CALL CHSCREEN
    POP BC
    POP AF
    RET

SHOW_HEX_HL_SP:
    CALL SHOW_HEX_HL
    PUSH BC
    LD C, 32
    CALL CHSCREEN
    POP BC
    RET

SHOW_HEX_A:
    PUSH HL
    PUSH BC
    PUSH AF
    SRL A
    SRL A
    SRL A
    SRL A
    ADD  A, 90h
    DAA
    ADC  A, 40h
    DAA
    LD C, A
    CALL CHSCREEN
    POP AF
    AND 15
    ADD  A, 90h
    DAA
    ADC  A, 40h
    DAA
    LD C, A
;    LD A,0x11
;    LD (0x6D80), A
    CALL CHSCREEN
    POP BC
    POP HL
    RET

SHOW_HEX_HL:
    PUSH AF
    LD A, H
    CALL SHOW_HEX_A
    LD A, L
    CALL SHOW_HEX_A
    POP AF
    RET

;SHOW_HEX_HL:
;    PUSH HL
;    LD A, H
;    SRL A
;    SRL A
;    SRL A
;    SRL A
;    ADD  A, 90h
;    DAA
;    ADC  A, 40h
;    DAA
;    LD C, A
;    CALL CHSCREEN
;
;    POP HL
;    PUSH HL
;    LD A, H
;    AND 15
;    ADD  A, 90h
;    DAA
;    ADC  A, 40h
;    DAA
;    LD C, A
;    CALL CHSCREEN
;
;    POP HL
;    PUSH HL
;    LD A, L
;    SRL A
;    SRL A
;    SRL A
;    SRL A
;    ADD  A, 90h
;    DAA
;    ADC  A, 40h
;    DAA
;    LD C, A
;    CALL CHSCREEN
;
;    POP HL
;    PUSH HL
;    LD A, L
;    AND 15
;    ADD  A, 90h
;    DAA
;    ADC  A, 40h
;    DAA
;    LD C, A
;    CALL CHSCREEN
;    POP HL
;    RET

SHOW_HEX_IN_HL:
    PUSH HL
    LD A, (HL)
    CALL SHOW_HEX_A
    INC HL
    LD A, (HL)
    CALL SHOW_HEX_A
    POP HL
    RET

SHOW_HEX_HL_16:
    PUSH HL
    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    CALL SHOW_HEX_IN_HL
    PUSH HL
    LD C, 32
    CALL CHSCREEN
    POP HL
    INC HL
    INC HL

    POP HL
    RET
