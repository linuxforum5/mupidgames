; Bemenet: HL = az 5 bájtos tömb kezdőcíme
; Kimenet: A tömb helyben rendezve (növekvő sorrendben)

Sort5Bytes_HL:
    ld b, 4             ; Külső ciklus számláló (N-1 = 4 passz)

OuterLoop:
    push bc             ; Külső számláló mentése
    push hl             ; Tömbkezdőcím mentése a belső ciklushoz
    ld b, 4             ; Belső ciklus számláló (4 összehasonlítás passzonként)

InnerLoop:
    ld a, (hl)          ; Aktuális elem betöltése
    inc hl
    ld c, (hl)          ; Következő elem betöltése
    cp c                ; Összehasonlítás: A - C
    jr c, NoSwap        ; Ha A < C (jó a sorrend), nincs csere
    jr z, NoSwap        ; Ha A == C, szintén nincs csere

    ; Csere (Swap)
    ld (hl), a          ; A nagyobb érték megy a magasabb címre
    dec hl
    ld (hl), c          ; A kisebb érték megy az alacsonyabb címre
    inc hl              ; HL visszaállítása a következő lépéshez

NoSwap:
    djnz InnerLoop      ; Belső ciklus csökkentése és ismétlése, ha B > 0

    pop hl              ; HL visszaállítása a tömb elejére a következő passzhoz
    pop bc              ; Külső számláló visszaállítása
    djnz OuterLoop      ; Külső ciklus csökkentése és ismétlése, ha B > 0

    ret
