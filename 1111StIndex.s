@these are all constants (= gets the value)
.data
ADC_To_Temp_Arr:
  .word 0x4
  .word 0x12

.text
.equ SWITCH_BASE, 0xff200040
.equ LEDS_BASE, 0xFF200000
.equ BUTTON_BASE, 0xff200050
.equ DEFAULT_TEMP, 0x19 

//this is the address for each seven segment
.equ DISP1, 0xFF200020
.equ DISP2, 0xFF200021
.equ DISP3, 0xFF200022
.equ DISP4, 0xFF200023
.equ DISP5, 0xFF200030
.equ DISP6, 0xFF200031

//This is for the ADC (we are using the first potentiometer)
.equ Mask_bit_15, 0x8000
.equ Mask_12_bits, 0x00000FFF
.equ ADC_BASE, 0xFF204000 


//this is for the timer 
.equ MPCORE_PRIV_TIMER, 0xFFFEC600
.equ TIME_OUT, 200000000 //= 1/(200 MHz) x 2x10^8 = 1 sec

.global _start
_start:
mov r0, #1

@clear the registers
mov r1, #0
mov r2, #0
mov r3, #0
mov r4, #0
mov r5, #0
mov r6, #0
mov r7, #0
mov r8, #0
mov r9, #0
mov r10, #0
mov r11, #0
mov r12, #0

ldr r5, =MPCORE_PRIV_TIMER //MPCore private timer base address
ldr r6, =TIME_OUT
str r6, [r5, #0x8] //write the timeout to the timer control register

loop:
  bl WAIT_TIMER
  bl TIMER_DONE
b loop


WAIT_TIMER:
push {r4-r12, lr}
ldr r5, =MPCORE_PRIV_TIMER //MPCore private timer base address

WAIT_LOOP:
//do stuff here while waiting
  bl UPDATE_TARGET_TEMP //returns r0 as target temp
  ldr r1, TARGET_TEMP

ldr r6, [r5, #0xC]
cmp r6, #0 //check if we can break out of the loop
beq WAIT_LOOP
pop {r4-r12, pc}

TIMER_DONE:
push {r4-r12, lr}
  //do stuff here when the timer is done


pop {r4-r12, pc}




