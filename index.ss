@these are all constants
.text
.equ SWITCH_BASE, 0xff200040
.equ LEDS_BASE, 0xFF200000
.equ BUTTON_BASE, 0xff200050
.equ DEFAULT_TEMP, 0x19 

@display base address
.equ DISP1, 0xFF200020
.equ DISP2, 0xFF200021
.equ DISP3, 0xFF200022
.equ DISP4, 0xFF200023
.equ DISP5, 0xFF200030
.equ DISP6, 0xFF200031

.global _start
_start:


b _start


@these are all variables

PREV_STATE_INC_BUT: .word 0x0
PREV_STATE_DEC_BUT: .word 0x0