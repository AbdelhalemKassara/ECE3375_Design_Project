@these are all constants (= gets the value)
.text
.equ SWITCH_BASE, 0xff200040
.equ LEDS_BASE, 0xFF200000
.equ BUTTON_BASE, 0xff200050
.equ DEFAULT_TEMP, 0x19 

.equ DISP1, 0xFF200020
.equ DISP2, 0xFF200021
.equ DISP3, 0xFF200022
.equ DISP4, 0xFF200023
.equ DISP5, 0xFF200030
.equ DISP6, 0xFF200031

.global _start
_start:
mov r0, #1
loop:
  bl UPDATE_TARGET_TEMP
  bl PUSH_TO_DISPLAY
b loop

