;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID Sokoban teszt debug műveletek
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHOW_DEBUG:
    LD HL,0x0101
LOOP_XY:
    CALL GET_OBJECT_HL_A
    LD C, A
    PUSH HL
    PUSH BC
    CALL APA
    POP BC
    CALL CHSCREEN
    POP HL
    INC H
    LD A, H
    CP 41
    JR NZ, LOOP_XY
    LD H, 1
    INC L
    LD A, L
    CP 25
    JR NZ, LOOP_XY
STOP: JR STOP

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
