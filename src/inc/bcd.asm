;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BCD rutinok
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A = packed BCD (00-99)
; eredmény A-ban
; 99 -> 00 és Carry = 1
BCD_Inc_A:
    ADD A,1        ; binárisan +1
    DAA            ; decimális korrekció
    RET

; (HL) = packed BCD
; visszaírja a növelt értéket
BCD_INC_HL:
    LD A,(HL)
    ADD A, 1
    DAA
    LD (HL), A
    RET

; A = packed BCD
; HL = cél memória
BCD_PRINT_HL_A:
    PUSH AF
    ; felső nibble (tízes)
    AND 0F0h
    SRL A
    SRL A
    SRL A
    SRL A
    ADD A,'0'
    LD (HL),A
    INC HL

    ; alsó nibble (egyes)
    POP AF
    AND 0Fh
    ADD A,'0'
    LD (HL),A
    INC HL

;    XOR A           ; string lezárás
;    LD (HL),A
    RET
