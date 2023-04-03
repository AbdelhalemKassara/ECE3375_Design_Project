
.data
// to get temp it is adc(12bit)/2^5
ADC_To_Temp_Arr:
.word 0xFFFFFFE7
.word 0xFFFFFFE8
.word 0xFFFFFFE9
.word 0xFFFFFFEA
.word 0xFFFFFFEB
.word 0xFFFFFFEC
.word 0xFFFFFFED
.word 0xFFFFFFEE
.word 0xFFFFFFEF
.word 0xFFFFFFF0
.word 0xFFFFFFF1
.word 0xFFFFFFF2
.word 0xFFFFFFF3
.word 0xFFFFFFF4
.word 0xFFFFFFF5
.word 0xFFFFFFF6
.word 0xFFFFFFF7
.word 0xFFFFFFF8
.word 0xFFFFFFF9
.word 0xFFFFFFFA
.word 0xFFFFFFFB
.word 0xFFFFFFFC
.word 0xFFFFFFFD
.word 0xFFFFFFFE
.word 0xFFFFFFFF
.word 0x00000000
.word 0x00000001
.word 0x00000002
.word 0x00000003
.word 0x00000004
.word 0x00000005
.word 0x00000006
.word 0x00000007
.word 0x00000008
.word 0x00000009
.word 0x0000000A
.word 0x0000000B
.word 0x0000000C
.word 0x0000000D
.word 0x0000000E
.word 0x0000000F
.word 0x00000010
.word 0x00000011
.word 0x00000012
.word 0x00000013
.word 0x00000014
.word 0x00000015
.word 0x00000016
.word 0x00000017
.word 0x00000018
.word 0x00000019
.word 0x0000001A
.word 0x0000001B
.word 0x0000001C
.word 0x0000001D
.word 0x0000001E
.word 0x0000001F
.word 0x00000020
.word 0x00000021
.word 0x00000022
.word 0x00000023
.word 0x00000024
.word 0x00000025
.word 0x00000026
.word 0x00000027
.word 0x00000028
.word 0x00000029
.word 0x0000002A
.word 0x0000002B
.word 0x0000002C
.word 0x0000002D
.word 0x0000002E
.word 0x0000002F
.word 0x00000030
.word 0x00000031
.word 0x00000032
.word 0x00000033
.word 0x00000034
.word 0x00000035
.word 0x00000036
.word 0x00000037
.word 0x00000038
.word 0x00000039
.word 0x0000003A
.word 0x0000003B
.word 0x0000003C
.word 0x0000003D
.word 0x0000003E
.word 0x0000003F
.word 0x00000040
.word 0x00000041
.word 0x00000042
.word 0x00000043
.word 0x00000044
.word 0x00000045
.word 0x00000046
.word 0x00000047
.word 0x00000048
.word 0x00000049
.word 0x0000004A
.word 0x0000004B
.word 0x0000004C
.word 0x0000004D
.word 0x0000004E
.word 0x0000004F
.word 0x00000050
.word 0x00000051
.word 0x00000052
.word 0x00000053
.word 0x00000054
.word 0x00000055
.word 0x00000056
.word 0x00000057
.word 0x00000058
.word 0x00000059
.word 0x0000005A
.word 0x0000005B
.word 0x0000005C
.word 0x0000005D
.word 0x0000005E
.word 0x0000005F
.word 0x00000060
.word 0x00000061
.word 0x00000062
.word 0x00000063
.word 0x00000064
.word 0x00000065
.word 0x00000066
.word 0x00000067

@these are all constants (= gets the value)
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

//this is for the adc conversion
.equ MASK_7_BITS, 0b1111111

//this is for the UPDATE_LEDS 
.equ MIN_5, 300
.equ BIT_9_ON, 0b100000000

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
str r6, [r5] //write the timeout to the timer control register
mov r6, #0b011 // set bits: mode = 1 (auto), enable = 1
str r6, [r5, #0x8]

loop:
  bl WAIT_TIMER
  bl TIMER_DONE
b loop


WAIT_TIMER:
push {r4-r12, lr}

WAIT_LOOP:
//do stuff here while waiting
  ldr r0, TARGET_TEMP_VAL
  bl UPDATE_TARGET_TEMP //returns r0 as target temp
  str r0, TARGET_TEMP_VAL //store the current target temp

  //switch between which value we should display
  ldr r4, =SWITCH_BASE
  ldr r0, [r4] //read value from switch
  and r0, #1 
  cmp r0, #1
  ldrne r0, TARGET_TEMP_VAL
  ldreq r0, CUR_TEMP

  bl PUSH_TO_DISPLAY   //display value on the 7seg
  bl UPDATE_LEDS //update the leds wh
  

  //code for the loop
  ldr r5, =MPCORE_PRIV_TIMER //MPCore private timer base address
  ldr r6, [r5, #0xC] //read timer status
  cmp r6, #0 //check if we can break out of the loop
  beq WAIT_LOOP
pop {r4-r12, pc}

TIMER_DONE:
push {r4-r12, lr}
  //update the current time
  ldr r4, CUR_TIME
  add r4, #1 
  str r4, CUR_TIME
  
  //do stuff here when the timer is done
  bl GET_CUR_TEMP //gets the current temperature in r0
  ldr r4, =CUR_TEMP
  str r0, [r4] //store the current temperature in the CUR_TEMP variable

  mov r6, #1
  ldr r5, =MPCORE_PRIV_TIMER //MPCore private timer base address
  str r6, [r5, #0xC]
pop {r4-r12, pc}




