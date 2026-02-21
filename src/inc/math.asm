;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INPUT: THE VALUES IN REGISTER B EN C
; OUTPUT: HL = B * C
; CHANGES: AF,DE,HL,B
;
MULT8_B_C_HL:
    LD HL,0
    LD A,B
    OR C
    RET Z
    LD D,0
    LD E,C
MLOOP:	ADD HL,DE
    DJNZ MLOOP
    RET

;
; Multiply 8-bit values
; In:  Multiply H with E
; Out: HL = result
;
Mult8_H_E:
    ld d,0
    ld l,d
    ld b,8
Mult8_Loop:
    add hl,hl
    jr nc,Mult8_NoAdd
    add hl,de
Mult8_NoAdd:
    djnz Mult8_Loop
    ret

;; Bemenet:  H, L
;; Kimenet:  HL (az eredmény felülírja az eredeti értékeket)
;; Megjegyzés: Ez a rutin HL = H * L műveletet végez.
;Multiply8:
;    ld c, l         ; C-be mentjük az egyik szorzót
;    ld d, 0         ; D-t nullázzuk a későbbi összeadáshoz
;    ld e, h         ; E-be tesszük a másik szorzót (DE = szorzandó)
;    ld l, d         ; L-t nullázzuk (HL lesz az akkumulátor)
;    ld h, d         ; H-t is nullázzuk
;
;    ld b, 8         ; 8 ciklus
;MulLoop:
;    srl c           ; C (egyik szorzó) bitjeit jobbra toljuk a Carry-be
;    jr nc, NoAdd    ; Ha a bit 0, nincs összeadás
;    add hl, de      ; HL = HL + DE
;NoAdd:
;    sla e           ; DE szorzása 2-vel (balra tolás)
;    rl d
;    djnz MulLoop    ; Ciklus 8-szor
;    ret
