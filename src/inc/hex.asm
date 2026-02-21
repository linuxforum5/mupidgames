;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHOW_HEX_A:
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
    RET

SHOW_HEX_HL:
    PUSH HL
    LD A, H
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

    POP HL
    PUSH HL
    LD A, H
    AND 15
    ADD  A, 90h
    DAA
    ADC  A, 40h
    DAA
    LD C, A
    CALL CHSCREEN

    POP HL
    PUSH HL
    LD A, L
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

    POP HL
    PUSH HL
    LD A, L
    AND 15
    ADD  A, 90h
    DAA
    ADC  A, 40h
    DAA
    LD C, A
    CALL CHSCREEN
    POP HL
RET
