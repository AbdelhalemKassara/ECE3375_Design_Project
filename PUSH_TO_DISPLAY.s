

/* 
inputs:
r0 is a signed value
outputs:
r0 as a positive value
and r1 is 1 if it was negative or 0 if it was a positive number
*/
CONV_SIGNED_TO_UNSIGNED:
push {r4-r12, lr}
	mov r4, r0, lsr #31
	cmp r4, #0

	//if it is positive this will run
	moveq r1, #0
	beq _SKIP_CONV_SIGNED

	//if it is negative this will run
	sub r0, #1 //subtracts one
	mvn r0, r0 //inverts the bits
	mov r1, #1 //sets r1 as the negative flag
	_SKIP_CONV_SIGNED:
pop {r4-r12, pc}

/*
inputs:
r0 is a signed value

outputs:
nothing (just displays value on seven segment)
 */

PUSH_TO_DISPLAY:
push {r4-r12, lr}
bl CONV_SIGNED_TO_UNSIGNED

cmp r1 , #1
moveq r1 , #5
mov r4 , r0 

moveq r0 , #0x10

bl SET_SINGLE_SEG

mov r1, #10
mov r0 , r4 

mov r5, #5
Loop_Signed:

bl DIVISION_MODULO

push{r0}
mov r0 , r1
mov r1, r5 
bl PUSH_TO_DISPLAY
pop{r0}
mov r1 , #10
sub r5 , #1
cmp r5 , #0
bhi Loop_Signed

pop {r4-r12, pc}

/*
inputs:
in r0 it takes in the value to be displayed
in r1 is the offset from the rightmost seven segment digit

if r0 is 0x10 then we will display a negative sign
outputs:
nothing
*/

SET_SINGLE_SEG:
push {r5, r6, lr}
  //r0 is the value being displayed
  //r1 is display offest
	mov r6, #0 @so it won't display anything when the value is invalid
	cmp r0, #0x0
	moveq r6, #0b0111111

	cmp r0, #0x1
	moveq r6, #0b0000110
	
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
	
	cmp r0, #0x10
	moveq r6, #0b1000000

  //this gets which seven seg display will be modified
	cmp r1, #0
	ldreq r5, =DISP1
	cmp r1, #1
	ldreq r5, =DISP2
	cmp r1, #2
	ldreq r5, =DISP3
	cmp r1, #3
	ldreq r5, =DISP4
	cmp r1, #4
	ldreq r5, =DISP5
	cmp r1, #5
	ldreq r5, =DISP6

	strb r6, [r5] @sets the seven segment digit
pop {r5, r6, pc}

