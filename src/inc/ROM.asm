;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mupid C2A2 ROM rutins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ABORT		EQU	0x0118	; Abort
BASIN		EQU	0x014B	; Start Basic Interpreter
BBANK		EQU	0x0112
BS		EQU	0x011B
BSET0		EQU	0x0106
BSET1		EQU	0x0109
BSET2		EQU	0x010C
BSET3		EQU	0x010F
BUINI		EQU	0x0100
CHSCREEN	EQU	0x001B	; write C character to current screen position, and move cursor. C in [ 0x20 - 0xFF ] exclude 0x9B
DOTINV		EQU	0x012A	; Invert Screen DOT. BC=X[0..319], E=Y[0..239] *:AF,BC,DE,HL,AF'
HT		EQU	0x011E	; Horizontal Tab
INTS0		EQU	0x0023
KADD		EQU	0x0115
SCRLUP		EQU	0x0121	;
SCRUDEL		EQU	0x0124	;
SP1ACT		EQU	0x0026	;
SWINI		EQU	0x014E	;
SWRES		EQU	0x0148	;
UMWAND		EQU	0x012D	;
WARTE		EQU	0x002B	;
XST2A		EQU	0x0013	;
XST3A		EQU	0x000B	;
XST4A		EQU	0x0003	;
TM		EQU	0x6D66	; 2 bytes incremented by NMI 25/sec
NMI_ADDR	EQU	0x6D68	; Start after 0x6D67 = 0

R75CLK		EQU	0x70D9	; Clock

APA	EQU	0x000B ; Set cursor on screen. H=Col[1-40], L=Row[1-24]
WAIT	EQU	0x002B ; Wait HL * 1/25 seconds
SYSERR	EQU	0x0118 ; Status line message. HL message start address. 0x0AH is end of message. Max message length=33.
