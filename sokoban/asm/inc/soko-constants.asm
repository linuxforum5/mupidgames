;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mupid Sokoban Original current level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EMPTY_BG		EQU	32   ; 0x20 00100000 SPACE
MAGICK_WALL_UP		EQU	"8"  ; 0x38 00111000
MAGICK_WALL_DOWN	EQU	"2"  ; 0x32 00110010
MAGICK_WALL_LEFT	EQU	"4"  ; 0x34 00110100
MAGICK_WALL_RIGHT	EQU	"6"  ; 0x36 00110110

STANDARD_WALL		EQU	"W"  ; 0x57 01010111
BOX_ON_EMPTY		EQU	"B"  ; 0x42 01000010
BOX_ON_PLACEHOLDER	EQU	"F"  ; 0x46 01000110
PLACEHOLDER		EQU	"P"  ; 0x50 01010000

PLAYER_UP		EQU	"U"  ; 0x55 01010101
PLAYER_DOWN		EQU	"D"  ; 0x44 01000100
PLAYER_LEFT		EQU	"L"  ; 0x4C 01001100
PLAYER_RIGHT		EQU	"R"  ; 0x52 01010010

SIZE_X	EQU 41
SIZE_Y	EQU 25
