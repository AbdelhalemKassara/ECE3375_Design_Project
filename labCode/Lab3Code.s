.text
.equ ADC_BASE, 0xFF204000
.equ Mask_12_bits, 0x00000FFF
.equ Mask_bit_15, 0x8000
.equ SWITCH_BASE, 0xff200040
.equ LEDS_BASE, 0xFF200060 //0xFF200060 //double check that this is the correct value
.equ Mask_10_bits, 0x3FF
.equ LED_THRESH, 0x199 	//0xFFF = 4095, 4095/10 = 409
.equ Mask_bit_10, 0x400

.global _start
_start:
	//toggle which pot to read from
	bl checkSwitch
	cmp r0, #1
	moveq r0, #4
	movne r0, #0
	
	bl getPotVal
	bl CONV_POTVAL_TO_LEDS
	bl WriteToLEDS
b _start

//this returns the state of the switch (0 or 1)
checkSwitch:
push {r4, lr}
	ldr r4, =SWITCH_BASE
	ldr r0, [r4] //reads value from switches
	and r0, #1 //returns the value of only the lowest switch
pop {r4, pc}

//r0 is the offset needs to be 0 for first pot, 4 for the second pot
//this returns the value of the pot in r0
getPotVal:
push {r4, r5, r6, r7, r8, lr}
	ldr r4, =Mask_bit_15
	ldr r7, =Mask_12_bits
	ldr r6, =ADC_BASE
	
	str r5, [r6] //writing any value to channel 0 to update
	
	//reads the value and keeps looping until the value has been updated
	breakWhenUpdated:
	ldr r5, [r6, r0] // reads the pot
	mov r8, r5
	orr r8, r4 //forcing the 15th bit to be 1 since we don't need to check
	and r8, r4 //applies the bit mask to get bit 15
	mov r8 , r8, lsr #15 //shift bit 15 to bit 0
	
	cmp r8, #1
	bne breakWhenUpdated
	
	//r0 contains the pot value	
	and r0, r5, r7
pop {r4, r5, r6, r7, r8, pc}


//there are 10 leds
//r0 is the value to write (it is 10-bits)
WriteToLEDS:
push {r0, r4, r5, lr}
	ldr r4, =Mask_10_bits
	ldr r5, =LEDS_BASE
	str r4, [r5, #4] //set the lowest 12 bits as output
	
	str r0, [r5] //write the values
pop {r0, r4, r5, pc}


//takes in a pot val r0 (12-bits), and outputs binary number for leds 10-bits
CONV_POTVAL_TO_LEDS:
push {r4, r5, r6, r7, r8, lr}
//load the threashold
	ldr r4, =LED_THRESH
	ldr r8, =Mask_bit_10
	mov r5, #0 //stores the current threshhold
	mov r6, #0//stores the output val
	mov r7, #0 //count
	
	loop_leds:
	cmp r7, #10
	bhs loop_leds_end
	add r5, r4 //adds the threshold
	cmp r0, r5 //checks if the leds val is lower than the threshold
	addge r6, r8 //set the bit to 1 
	mov r6, r6, lsr #1 //shift the bits to the right by one
	
	add r7, #1 //increment the counter
	b loop_leds
	loop_leds_end:
		
	mov r0, r6
pop {r4, r5, r6, r7, r8, pc}
