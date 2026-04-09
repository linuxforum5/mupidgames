;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID hangkezelő rutinok
;;; sound_init : zenélés indítása előtt kell kiadni egyszer
;;; sound_close : nem feltétlen szükséges
;;; music_play_HL : A HL címtől kezdődően lejtászik egy dallamot, amíg 127-es értéket nem talál. A hangok [0.61], a hosszváltásokat pedig [128..255] jelöli. Ez utóbbiak 7. bitje törölve lesz felhasználás előtt.
;;; music_play_next_HL : A HL címtől kezdődően lejtászik egy hangot.
;;; sound_play_n_A : Az n. félhang lejátszása. N értéke A--ban van [ 0 .. 61 ]
;;; music_set_length_A : A hosszúságú hanglejátszás állítása. 127 autoimatán visszatér Z=1 flaggel, különben Z=0 a visszatérés
;;; sound_play_C_A : hang indítása a CA-ban megadott magassággal, az utoljára beállított hosszal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SOUND_CTRL_PORT EQU 0x03
SOUND_DATA_PORT EQU 0x02
EOM             EQU 0x80

sound_play_A_BC: ; Egy hang lejátszása: A=hossz BC=masgasság (C első bájt, B második)
        PUSH BC
        ; init
        ld c, 0xF1
        CALL _rst20_l0627h_C
        ; length
        LD C, 0x40
        CALL _rst20_l0627h_C
        LD C, A
        CALL _rst20_l0627h_C
        POP BC
        CALL _rst20_l0627h_C
        LD C, B
        CALL _rst20_l0627h_C
    RET

sound_play_HL: ; Egy hang lejátszása (HL) címtől 3 bájt. Első=hossz, 2. magasság
        ld c, 0xFF
        CALL _rst20_l0627h_C
        ld c, 0xF2
        CALL _rst20_l0627h_C
        ld c, 0xF1
        CALL _rst20_l0627h_C
        ld c, 0xFF
        CALL _rst20_l0627h_C
        ld c, 0xF1
        CALL _rst20_l0627h_C

        ; length
        LD C, 0x40
        CALL _rst20_l0627h_C
        LD C, (HL)
        ;SLA C ; C=C*2
        CALL _rst20_l0627h_C
        INC HL

        LD A, (HL)
        CALL sound_play_n_A
        INC HL
    RET

sound_init:     ; Init sound device
        ld c, 0xF1
        CALL _rst20_l0627h_C
    RET 

sound_init1:                               ; Várakozás, sebesség beállítása A<=13
        ld c,0ffh	;f7f9
        CALL _rst20_l0627h_C
        ld c,0f1h	;f7fc
        CALL _rst20_l0627h_C
        ld c,0f1h	;f7ff
        CALL _rst20_l0627h_C
        LD C, 0xFF
        CALL _rst20_l0627h_C
    RET

sound_close:                               ; Várakozás, sebesség beállítása A<=13
        ld c,0ffh	;f7f9
        CALL _rst20_l0627h_C
        ld c,0f2h	;f7fc
        CALL _rst20_l0627h_C
        ld c,0f1h	;f7ff
        CALL _rst20_l0627h_C
        LD C, 0xFF
        CALL _rst20_l0627h_C
    RET

sound_play_C_A: ; Adott hangmagasság lejátszása az utoljára beállított sebességgel
        CALL _rst20_l0627h_C
        LD C, A
        CALL _rst20_l0627h_C
    RET

sound_play_n_A:
        PUSH HL
        PUSH DE
        PUSH BC
        LD HL, SOUND_DATA
        LD D, 0
        LD E, A
        ADD HL, DE
        LD C, 0
        CP SOUND_DATA_1 - SOUND_DATA
        JR nc, _send_first_byte
        INC C
        CP SOUND_DATA_2 - SOUND_DATA
        JR nc, _send_first_byte
        INC C
_send_first_byte:
        CALL _rst20_l0627h_C
        LD C, (HL)
        CALL _rst20_l0627h_C
        POP BC
        POP DE
        POP HL
        INC A ; clear Z flag
    RET

music_set_length_A:
        AND 127
        RET Z
        LD C, 0x40
        CALL _rst20_l0627h_C
        LD C, A
        CALL _rst20_l0627h_C
    RET

music_play_HL:
    CALL music_play_next_HL
    JR NZ, music_play_HL
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Play next sound from (HL) and set HL to next sound, while (HL) != 0x7F
;;; (hl) defines length if > 127
;;; Z flag return 1 if End of music, and 0 else
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
music_play_next_HL: ; (HL++)=length , (HL++)=pitch
        LD A, (HL)
        INC HL
        BIT 7, A                  ; Ha 1. akkor
        JR NZ, music_set_length_A ; hossz vagy EOM,
        JR sound_play_n_A         ; különben magasság

_rst20_l0627h_C:
    EX AF,AF'   ;    push af                 ;0627
_rst20_wait:
      in a,( SOUND_CTRL_PORT )             ;0612
      bit 2,a                 ;0614
    jr z,_rst20_wait        ;0616
    ld a,c                  ;0619
    out ( SOUND_DATA_PORT ),a            ;0622
    EX AF,AF'   ;    pop af                  ;00ca
    ret

SOUND_DATA:
    ; first byte = 2  ; 5 db: pos=D3
    DB 0xA6, 0x76, 0x53, 0x30, 0x12 ; 5 db
SOUND_DATA_2:
    ; first byte = 1  ; 12 db: pos=D8
    DB 0xF4, 0xD6, 0xBC, 0xA2, 0x8A, 0x72, 0x5E, 0x4A, 0x36, 0x25, 0x14, 0x04 ; 12 db
SOUND_DATA_1:
    ; first byte = 0  ; 45 hang majd 4 oktáv pos=E4
    DB 0xF4, 0xE5, 0xD7, 0xCA, 0xBE, 0xB3, 0xA8, 0x9E, 0x95, 0x8C, 0x83, 0x7B, 0x74, 0x6D, 0x66, 0x5F, 0x59, 0x54, 0x4E, 0x49, 0x45, 0x40 ; 22
    DB 0x3C, 0x38, 0x34, 0x31, 0x2D, 0x2A, 0x27, 0x24, 0x21, 0x1F, 0x1D, 0x1A, 0x18, 0x16, 0x14, 0x13, 0x11, 0x0F, 0x0D, 0x0C, 0x0B, 0x0A, 0x09 ; 23
    DB 0x00
SOUND_DATA_END:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;_rst20_l0627h_x:
;                                    ;;; RST 20h C=érték
;;        di
;        push af                 ;0627
;        push bc                 ;062a
;        ld b,c                  ;062b
;        ld c,003h               ;062c
;_rst20_wait_x:
;          in a,(c)                ;0612
;          bit 2,a                 ;0614
;        jr z,_rst20_wait_x             ;0616
;        dec c                   ;0618
;        ld a,b                  ;0619
;;        bit 1,c                 ;061a
;;        jr z, ret_l00c2h
;          out (c),a               ;0622
;;ret_l00c2h:
;;        ld a,(0x6DA1)           ;00c2
;;        out (0c0h),a            ;00c5
;        pop bc                  ;00c7
;        pop af                  ;00ca
;;        ei                      ;00cb
;        ret
