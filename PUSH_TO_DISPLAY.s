/*
inputs:
in r0 it takes in the value to be displayed
in r1 is the offset from the rightmost seven segment digit

outputs:
nothing
*/

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

