;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID GRAFIKA
;;; (0X6da1) - (0Xc0) az eredeti lapkiosztás értéke, grafikus írás után innen lehet visszaállítani Default value: 0x80
;;; 0xC0 port bitjei
;;;     7. 1 - 
;;;     6.
;;;     5.
;;;     4. 1 - grafikus lapok, 0 standard lapok
;;;     3. 1 - baloldali képernyő, 0 jobboldali
;;;     2.
;;;     1. ???
;;;     0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Grafikus memória felépítése
;;; Képernyő bal széle 11 lap, jobb széle, ha a 32K elfogyott (
;;; 0x8410-től kezdődően 
;;; Egymás alatti pixelpárok. Egy bájt 2 pixel, minden pixel 16 szín (8 szín{0-2.bit} + 1{3.bit} fényesség)
;;; 240 sor, de 256 bájt oszloponként
;;; Amennyiben elfogyott a 32KB, akkor belapozódik az 10 lap, és 0x8000-tól folytatódik a kitöltés, de persze itt is az első 16 bájt nem pixel
;;; Egy dupla oszlopon belül tehát a látható pixelek címtartománya:
;;; 0x10 - FF
;;; 0x00-0x0F : ismeretlen
;;; Az utolsó oszlop tartalma az oszlop memóriacímének alacsonyabb bájtja - a sor sorszáma -, AND 254
;;; A400-A4FE:00 A4FF:C0
;;; A4FF:04
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Grafikus rutinok
;;; PLOT_BC_E_D:     ; X=BC, Y=E Color=D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PLOT_BC_E_D:     ; X=BC, Y=E Color=D
    LD A, 15
    AND D        ; A-ban a szín paletta indexe, Cy flag 0
    LD D, 0xF0   ; D-ben eltároljuk a másik oszlop maszkját
    RR B
    RR C               ; Cy -> C.7 -> C.0 -> Cy C-ben most a duplaoszlop indexe van [0-239]
    JR NC, A_COLOR_OK   ; Páratlan koordináta, A ok
    LD D, 0x0F
    SLA A               ; Páros koordináta, A *= 16
    SLA A
    SLA A
    SLA A
A_COLOR_OK:
    LD B, A     ; Ideiglenesen tároljuk B-ben, amiben most úgysincs értékes adat
    LD A, C
    CP 0x7C
    LD HL, 0x8400
    LD A, %00011000    ; Left side page
    JR C, PAGE_IN_A   ;
    LD HL, 0x0400
    LD A, %00010000    ; Right side page
PAGE_IN_A:
    OUT (0xC0), A      ; A megfelelő grafikus RAM belapozása
    LD A, B            ; Visszaraktjuk a pixelértéket A-be, mert B kelleni fog, meg amúgyis
    LD B, C            ; BC = C*256 + C
    LD C, 0x10         ; BC a dupla-oszlop kezdőcímét tárolja Amennyiben 0x76 van B-ben vagy ennél nagyobb, akkor a másik lapot kell belapozni
    ADD HL, BC
    LD B, 0
    LD C, E
    ADD HL, BC         ; Most a sorok számát is hozzáadjuk
    LD C, A            ; A -ban a pixel színe
    LD A, (HL)
    AND D              ; A másik pixelt nem módosítjuk
    OR C               ; De ezt a pixelt felülírjuk
    LD (HL), A         ; Szín kirakása mindkét oszlopba
    LD A, %00000000
    OUT (0xC0), A      ; 0-ás ram visszalapozása. Ez azonban lehetne 01 is ??? !!!
    RET

SET_CHAR_COLOR_HL_A:     ; H az oszlop, L a sor, A a betűszín. Cím=6022+H*32+L (*:HL,DE,BC)
    LD DE, 0x6022
    CALL SET_DE_COLOR_HL_A
    RET

SET_CHAR_BG_COLOR_HL_A:     ; H az oszlop, L a sor, A a betűszín. Cím=6022+H*32+L (*:HL,DE,BC)
    LD DE, 0x7002
    CALL SET_DE_COLOR_HL_A
    RET

SET_DE_COLOR_HL_A:
    LD B, L
    LD L, H          ; L = H
    LD H, 0          ; HL = H (most a 16 bites HL regiszterben van az eredeti H)
    ; HL eltolása balra 5-ször (HL = HL * 32)
    add hl, hl       ; *2
    add hl, hl       ; *4
    add hl, hl       ; *8
    add hl, hl       ; *16
    add hl, hl       ; *32
    ; Hozzáadás DE-hez
    add hl, de       ; HL = (H * 32) + DE
    LD E, B
    LD D, 0
    ADD HL, DE
    LD (HL), A
    RET
