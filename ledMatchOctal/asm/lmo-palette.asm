;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PALETTE_REDEFINE:
    LD HL, PALETTE_REDEFINE_BTX
    LD DE, PALETTE_REDEFINE_BTX_END-PALETTE_REDEFINE_BTX
    CALL BTX_PRINT_HL_DE
    RET

PALETTE_REDEFINE_BTX:
     DB 0x1F, 0x26, 0x20          ; Begin palette definition
     DB 0x1F, 0x26, 0x32, 0x34    ; 24. paletta        1F 26 3t 3u    t = 1-től 3-ig (tíz)  u = 0-tól 9-ig (egy)
     DW PALETTE_16_RGB
     DW PALETTE_17_RGB
     DW PALETTE_18_RGB
     DW PALETTE_19_RGB
     DW PALETTE_20_RGB
     ; DB %01000111, %01000000      ; 0  1  R3 G3 B3 R2 G2 B2      0  1 R1 G1 B1 R0 G0 B0
     DB 0x1F, 0x41, 0x41          ; End of code
PALETTE_REDEFINE_BTX_END:

PALETTE_18_CHNG:
    LD A, (RGB18)
    INC A
    AND %00111111
    OR  %01000000
    LD (RGB18), A
    LD HL, PALETTE_18_REDEFINE_BTX
    LD DE, PALETTE_18_REDEFINE_BTX_END-PALETTE_18_REDEFINE_BTX
    CALL BTX_PRINT_HL_DE
    RET

PALETTE_18_DEFAULT:
    LD HL, PALETTE_18_RGB
    LD (RGB18), HL
    LD HL, PALETTE_18_REDEFINE_BTX
    LD DE, PALETTE_18_REDEFINE_BTX_END-PALETTE_18_REDEFINE_BTX
    CALL BTX_PRINT_HL_DE
    RET

PALETTE_18_REDEFINE_BTX:
        DB 0x1F, 0x26, 0x20          ; Begin palette definition
        DB 0x1F, 0x26, 0x32, 0x36    ; 26. paletta        1F 26 3t 3u    t = 1-től 3-ig (tíz)  u = 0-tól 9-ig (egy)
RGB18:  DW PALETTE_18_RGB            ; DB %01000111, %01000000      ; 0  1  R3 G3 B3 R2 G2 B2      0  1 R1 G1 B1 R0 G0 B0
        DB 0x1F, 0x41, 0x41          ; End of code
PALETTE_18_REDEFINE_BTX_END:
