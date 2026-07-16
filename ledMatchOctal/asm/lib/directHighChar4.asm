;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID Direct High resolution character (DRC 12x10) graphics with 4 colors 480x240
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; - DIRECTSHOW_DE_HL : Egy 12x10-es karakter kiírása. DE az adatterület, ahonnan olvassa a 44 bájtot, HL a képernyőkoordináta, ahol megjelenít (H=X,L=Y)
;;; - DIRECT_SET_PALETTES_DE_HL : A De címről beolvassa az első 3 palettt definiáló bájtot, és a HL koordináta karakteréhez beállítja
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Grafikus terület:                         0x8410-től
;;; Paletta azonosítás a 0. és 3. színhez:    0x6022-től
;;; Paletta azonosítás a 2. színhez és flash: 0x6802-től
;;; Paletta azonosítás a 0. és 3. színhez:    0x7002-től
;;; Character attributes:                     0x7802-től
;;; További karakterinormációk az 10 lapon, DRC4-hez nincs rá szükség
;;; A kiírt karakterek ASCII kódjai:          0xC302-től
;;; További valami:                           0xBE02-től
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Egy karakternyi terület kiírása
;;; A paletta felépítése: 0-15 fix, 16-31 definiálható
;;;   0-15: 000, 008, 080, 088, 800, 808, 880, 888, 000, 00f, 0f0, 0ff, f00, f0f, ff0, fff
;;; DE : A forrásadat címe. A forrásadat szerkezete (78* bájt értéke fixen 0x:
;;;      60* bájt értéke: Felső 3 bit a 11 color paletta indexe 0-7, alsó 5 bit 01 color palette indexe 0-31
;;;      68* bájt értéke: 7. bit flash (1=no flash), alsó 5 bit 10 color palette indexe 0-31 ; 6. bit 1 ( NE legyen 0 ); 5. bit 0
;;;      70* bájt értéke: Felső 2 bit a 11 color palettaválasztója 0-3, alsó 5 bit 00 color palette indexe 0-31
;;;      78* bájt értéke: Karaktertípus, fixen 0x10
;;;      40 bájt, ami a pixeleket írja le a következő formában:
;;;        - Minden bájt legfelső két bitje 0
;;;        - Minden további két bit egy-egy egymás melletti pixel színének indexét adja meg a bevezető 4 bájttal kiválasztott palettából
;;;        - A következő bájt az alatta lévő sor azonos oszlopainak pixeleit definiálja. Ha ez a 10 utáni lenne, akkor a következő 3 pixeles oszlopba ugrik
;;;      Vagyis az i. adatbájt a következő 3 pixel színét határozza meg: (X,Y),(X+1,Y),(X+2,Y) ahol Y=i%10, X=3*(i-Y)/10 
;;; HL : A karakter pozíciója H-horizontal (x), L = y
;;; Kimenet:
;;;   DE : A következő feldolgozandó bájt címe
;;; Elromlik: BC,HL,AF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DIRECT_SET_PALETTES_DE_HL
;;; A fenti folyamatnak az eleje, csak az első 3 palettadefiníciós bájtot helyezi el a megfelelő helyre, így átszinezhető a terület
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIRECTSHOW_DE_HL:
    CALL DIRECT_SET_PALETTES_DE_HL
    LD BC, 0x7802
    CALL ADD_BC_TO_COORDS_HL_AND_SET_DE_CONTENT ;    7802 +   Karaktertípus
;    CALL SET_10CELL5_HL        ; 10.BE02 <- 0x40 on page 0x10
;    CALL SET_10CELL6_HL        ; 10.C302 <- ASCII on page 0x10
    CALL CONVERT_APA_HL_TO_GRAPH_ADDR_HL ; HL := 0x8410+x
    EX DE, HL
    CALL COPY_PIXEL_DATA_INTO_GRAPH_HL_DE
    EX DE, HL
    RET

DIRECT_SET_PALETTES_DE_HL:
    LD BC, 0x6022
    CALL ADD_BC_TO_COORDS_HL_AND_SET_DE_CONTENT ;    6022 +   Felső 3 bit a 11 color paletta indexe 0-7, alsó 5 bit 01 color palette indexe 0-31
    LD BC, 0x6802
    CALL ADD_BC_TO_COORDS_HL_AND_SET_DE_CONTENT ;    6802 +   7. bit flash, alsó 5 bit 10 color palette indexe 0-31 ; 6. bit 1 ( NE legyen 0 ); 5. bit 0 ( NE legyen 0 )
    LD BC, 0x7002
    CALL ADD_BC_TO_COORDS_HL_AND_SET_DE_CONTENT ;    7002 +   Felső 2 bit a 11 color palettaválasztója 0-3, alsó 5 bit 00 color palette indexe 0-31
    RET

COPY_PIXEL_DATA_INTO_GRAPH_HL_DE:
    CALL COPY10BYTES_HL_DE
    CALL NEXT_DE ; RAM8510
    CALL COPY10BYTES_HL_DE
    CALL NEXT_DE ; RAM8610
    CALL COPY10BYTES_HL_DE
    CALL NEXT_DE ; RAM8710
    CALL COPY10BYTES_HL_DE
    RET

CONVERT_APA_HL_TO_GRAPH_ADDR_HL: ; A karakterpozícióból a kezdő grafikus memóriacím előállítása
    LD A, H
    ADD A,A
    ADD A,A
    ADD A, 0x80
    LD H, A
    LD A, L
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,L
    ADD A,L
    ADD A, 0x06
    LD L, A
    RET

;SET_L_22_HL:
;    CALL SET_L_02_HL
;    ADD A, 0x20
;    LD L, A
;    RET
;
;SET_L_02_HL: ; (H-1)*32+L
;    DEC H
;    LD A, H
;    ADD A,A
;    ADD A,A
;    ADD A,A
;    ADD A,A
;    ADD A,A
;    LD H, A
;    LD A, 1
;    ADD A, L
;    ADD A, H
;    LD L, A
;    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; HL a képernyőkoordináta címe H=x L=y
;;; BC a memória kezdőcíme, ehhez adjuk a (H-1)*32+(L-1)
;;; A  a betöltendő adat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADD_BC_TO_COORDS_HL_AND_SET_A: ; (BC+Coords(HL)) := A
    PUSH HL
    PUSH DE
    DEC H
    DEC L
    LD D, 0
    LD E, L
    LD L, H
    LD H, 0
    ADD HL, HL ;  *2
    ADD HL, HL ;  *4
    ADD HL, HL ;  *8
    ADD HL, HL ; *16
    ADD HL, HL ; *32
    ADD HL, DE ; HL = 32*(H-1)+(L-1)
    ADD HL, BC ; HL ok
    POP DE
    LD (HL), A
    POP HL
    RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; HL a képernyőkoordináta címe H=x L=y
;;; BC a memória kezdőcíme, ehhez adjuk a (H-1)*32+(L-1)
;;; DE a betöltendő adat forrása
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADD_BC_TO_COORDS_HL_AND_SET_DE_CONTENT: ; (BC+Coords(HL)) := (DE)
    PUSH HL
    PUSH DE
    DEC H
    DEC L
    LD D, 0
    LD E, L
    LD L, H
    LD H, 0
    ADD HL, HL ;  *2
    ADD HL, HL ;  *4
    ADD HL, HL ;  *8
    ADD HL, HL ; *16
    ADD HL, HL ; *32
    ADD HL, DE ; HL = 32*(H-1)+(L-1)
    ADD HL, BC ; HL ok
    POP DE
    LD A, (DE)
    LD (HL), A
    INC DE
    POP HL
    RET

;SET_10CELL5_HL:  ;   BE02 <- 40
;    PUSH HL
;    PUSH BC
;    CALL SET_L_02_HL
;    LD H, 0xBE
;    LD B, 0x40 ; %01000000
;    LD A, 0x10
;    RST 0x10  ; (HL):=B
;    POP BC
;    POP HL
;    RET

;SET_10CELL6_HL:  ;   C302 <- 'W'
;    PUSH HL
;    PUSH BC
;    CALL SET_L_02_HL
;    LD H, 0xBE
;    LD B, 'W'
;    LD A, 0x10
;    RST 0x10  ; (HL):=B
;    POP BC
;    POP HL
;    RET

NEXT_DE: ; DE := DE + 246 (+100h-10d)
    PUSH HL
    LD HL, 246
    ADD HL, DE
    EX DE, HL
    POP HL
    RET

LDIR_DEST_BANK: DB 0x18

COPY10BYTES_HL_DE:
    LD BC, 10
    LD A, D
    CP 0x80
    LD A, 0x18
    JR nc, BANK_OK
    LD A, 0x10
    SET 7, D
BANK_OK:
    LD (LDIR_DEST_BANK), A
LDIR18:
    PUSH BC
    LD B, (HL)
    EX DE, HL
    LD A, (LDIR_DEST_BANK)
    RST 0x10  ; (HL):=B
    EX DE, HL
    INC HL
    INC DE
    POP BC
    DEC BC
    LD A, B
    OR C
    JR NZ, LDIR18
    LD A, (LDIR_DEST_BANK)
    CP 0x10
    RET NZ
    RES 7, D
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; B - Palette 0 (C0 - color 0 patette index)   6022 : |3.2|3.1|3.0|1.4|1.3|1.2|1.1|1.0|
;;; C - Palette 1 (C1 - color 1 patette index)   6802 : |F=0| 0 | 0 |2.4|2.3|2.2|2.1|2.0|
;;; D - Palette 2 (C2 - color 2 patette index)   7002 : |3.4|3.3| 1 |0.4|0.3|0.2|0.1|0.0|
;;; E - Palette 3 (C3 - color 3 patette index)
;;; HL - pozíció H=X, L=Y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIRECT_RESET_PALETTES_BC_DE_HL:
    ; uint8_t c3_210 = c3 & 7;
    LD A, E                    ; A := C3
    AND 7
    LD (_C3_210), A            ; C3_210 := A ; A C3 alsó 3 bitje

    ; uint8_t c3_43 = (c3 >> 3) & 3;
    LD A, E                    ; A := C3
;    SRL A                      ; A = A / 2
;    SRL A                      ; A = A / 2
;    SRL A                      ; A = A / 2
    AND 24                     ; A := A & 3
    LD (_C3_43), A             ; C3_43 := A ; A C3 felső 2 bitje * 8

    ; 6022 +   Felső 3 bit a 11 color paletta indexe 0-7, alsó 5 bit 01 color palette indexe 0-31
    ; my $m6022 = 32 * $c3_210 + $c1; bytes[ 0 ] = 32 * c3_210 + c1;
    LD A, (_C3_210)            ; A := C3_210
    SLA A                     ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                     ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                     ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                     ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                     ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    ADD A, C                  ; A += C1
    PUSH BC
    LD BC, 0x6022
    CALL ADD_BC_TO_COORDS_HL_AND_SET_A    ; (0x6022+cc(HL)) := A
    POP BC

    ; 6802 +   7. bit flash ha 0, alsó 5 bit 10 color palette indexe 0-31 ; 6. bit 1 ( NE legyen 0 ); 5. bit 0 ( NE legyen 0 )
    ; my $m6802 = 0x80 + $c2; ; bytes[ 1 ] = 0x80 + c2;
    LD A, D                   ; A := C2
    ADD A, 0x80               ; A += 0x80
    PUSH BC
    LD BC, 0x6802
    CALL ADD_BC_TO_COORDS_HL_AND_SET_A    ; (0x6802+cc(HL)) := A
    POP BC

    ; 7002 +   Felső 2 bit a 11 color palettaválasztója 0-3, alsó 5 bit 00 color palette indexe 0-31
    ; my $m7002 = 64 * $c3_43 + 32 + $c0; ; bytes[ 2 ] = 64 * c3_43 + 32 + c0;
    LD A, (_C3_43)             ; A := C3_43
;    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
;    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
;    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    SLA A                      ; Az A regiszter bitjeinek eltolása balra (A = A * 2)
    ADD A, 32                  ; A += 32
    ADD A, B                   ; A += C0
    PUSH BC
    LD BC, 0x7002
    CALL ADD_BC_TO_COORDS_HL_AND_SET_A    ; (0x7002+cc(HL)) := A
    POP BC

    ; 7802 +   Karaktertípus
    ; my $m7802 = 0x10; # // 15
;    LD A, 0x15
;    PUSH BC
;    PUSH HL
;    LD BC, 0x7802
;    CALL ADD_BC_TO_COORDS_HL_AND_SET_A    ; (0x7803+cc(HL)) := A
;    POP HL
;    POP BC
    RET

_C3_210: DB 0
_C3_43:  DB 0
