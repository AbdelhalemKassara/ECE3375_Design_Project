.equ MPCORE_PRIV_TIMER, 0xFFFEC600



.text
.global _start
_start:
	LDR r5, =MPCORE_PRIV_TIMER 	// MPCore private timer base address

	LDR r6, =2000000 		// timeout = 1/(200 MHz) x 2x10^6 = 0.01 sec
	STR r6, [r5] 			// write to timer load register
	MOV r6, #0b011 			// set bits: mode = 1 (auto), enable = 1
	STR r6, [r5, #0x8] 		// write to timer control register

  ldr r8, MAX_TIME //max value we can display
  mov r4, #0 //intialize the time to zero
  mov r0, #0 //intialize r0

	//intialize the display
	mov r0, #0
    bl DISPLAY_VAL//update the display

//keeps looping the start until the user presses the start button
ldr r0, PB_BASE
ldr r0, [r0]
and r0, #1
cmp r0, #1
bne _start


LOOP:
WAIT:

	LDR r6, [r5, #0xC] 		// read timer status
	CMP r6, #0
BEQ WAIT 				// wait for timer to expire

  ldr r1, PB_BASE
  cmp r4, r8 //check if we have reached the max value
  movhs r4, #0 //reset the timer to zero

  //stops the stopwatch
  ldr r1, PB_BASE
  ldr r1, [r1]
  and r1, #2
  cmp r1, #2
  
  bne CONTINUEPROGRAM
  
  STOPTIME:

	
	//toggles between the stored and current time
  ldr r1, SW_BASE
  ldr r1, [r1]
  and r1, #1
 
  //if the switch is toggled display the stored value
  cmp r1, #0
  movne r0, r3
  moveq r0, r4
  bl DISPLAY_VAL//update the display
  	
	ldr r1, PB_BASE
	ldr r1, [r1]
	and r1, #1
	cmp r1, #1
  bne STOPTIME
  
  CONTINUEPROGRAM:
  add r4, #1 //adds 0.01s
  
  //stores the current time
  ldr r1, PB_BASE
  ldr r1, [r1]
  and r1, #4
  cmp r1, #4
  moveq r3, r4

  //reset the stopwatch back to zero
  ldr r1, PB_BASE
  ldr r1, [r1]
  and r1, #8
  cmp r1, #8
  moveq r3, #0
  moveq r4, #0

  //toggles between the stored and current time
  ldr r1, SW_BASE
  ldr r1, [r1]
  and r1, #1
 
  //if the switch is toggled display the stored value
  cmp r1, #0
  movne r0, r3
  moveq r0, r4
  bl DISPLAY_VAL

  STR r6, [r5, #0xC] 		// reset timer flag bit

  
  B LOOP

@functions


DISPLAY_VAL:
push {lr, r1}
  //r0 is the value being converted

  //divides r0 by r1
  ldr r1, DIV1
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1
  mov r1, #5
  bl PUSH_TO_DISPLAY
  pop {r0}

  ldr r1, DIV2//5th digit
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1 //moves the division to r0
  mov r1, #4
  bl PUSH_TO_DISPLAY
  pop {r0}

  mov r1, #1000//4th digit
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1 //moves the division to r0
  mov r1, #3
  bl PUSH_TO_DISPLAY
  pop {r0}

  mov r1, #100//3th digit
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1 //moves the division to r0
  mov r1, #2
  bl PUSH_TO_DISPLAY
  pop {r0}

  mov r1, #10//2th digit
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1 //moves the division to r0
  mov r1, #1
  bl PUSH_TO_DISPLAY
  pop {r0}

  mov r1, #1//1th digit
  bl DIVISION_MODULO
  push {r0}
  mov r0, r1 //moves the division to r0
  mov r1, #0
  bl PUSH_TO_DISPLAY
  pop {r0}
pop {pc, r1}

DIVISION_MODULO:  // (r0/r1)
  //r0 is the dividend
  //r1 is the divisor
push {r2, lr}
  mov r2, #0

  //repeatedly subtract until the cur dividend is less than the divisor
  Loop1:
  cmp r0, r1//checks if r0 is less than r1
  blo break
  sub r0, r1
  add r2, #1
  b Loop1
  break:

  
  mov r1, r2 //set the number of times we looped
  //r1 the division
  //r0 is the remainder
pop {r2, pc}


PUSH_TO_DISPLAY:
push {r5, r6, lr}
  //r0 is the value being displayed
  //r1 is display offest
	cmp r0, #0x0
	moveq r6, #0b0111111

	cmp r0, #0x1
	moveq r6, #0b0110000
	
	cmp r0, #0x2
	moveq r6, #0b01011011
	
	cmp r0, #0x3
	moveq r6, #0b1001111
	
	cmp r0, #0x4
	moveq r6, #0b1100110
	
	cmp r0, #0x5
	moveq r6, #0b1101101
	
	cmp r0, #0x6
	moveq r6, #0b1111101
	
	cmp r0, #0x7
	moveq r6, #0b0000111
	
	cmp r0, #0x8
	moveq r6, #0b1111111
	
	cmp r0, #0x9
	moveq r6, #0b1101111
	
  //this gets which seven seg display will be modified
	cmp r1, #0
	ldreq r5, DISP1
	cmp r1, #1
	ldreq r5, DISP2
	cmp r1, #2
	ldreq r5, DISP3
	cmp r1, #3
	ldreq r5, DISP4
	cmp r1, #4
	ldreq r5, DISP5
	cmp r1, #5
	ldreq r5, DISP6

	strb r6, [r5] @sets the seven segment digit
pop {r5, r6, pc}


@constants
SW_BASE: .word 0xFF200040
PB_BASE: .word 0xFF200050

DISP1: .word 0xFF200020
DISP2: .word 0xFF200021
DISP3: .word 0xFF200022
DISP4: .word 0xFF200023
DISP5: .word 0xFF200030
DISP6: .word 0xFF200031

MAX_TIME: .word 0x927bf

DIV1: .word 60000
DIV2: .word 6000