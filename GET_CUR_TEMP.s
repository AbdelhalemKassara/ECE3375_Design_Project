

/*
input:

output:
r0: contains the current temperature
 */
GET_CUR_TEMP:
push {r4-r12, lr}
	bl Get_Pot_Val //gets the temperature r0
	//ldr r0, =#0xffffff //test variable
	mov r4, r0, lsr #7 //this has the address offset to get the temp

	//convert the raw adc val to the temperature adc/2^7
	ldr r5, =MASK_7_BITS
	and r5, r0, r5 

	//check the the value is closer to the lower or larger value
	cmp r5, #0b111111
	addhi r4, #1 //add one to get the higher address

	//multiply by 4 because of the way addressing works
	add r4, r4
	add r4, r4
	ldr r5, ADCToTempConvStAdd
	ldr r0, [r5, r4] //gets the temperature value
pop {r4-r12, pc}


//this returns the value of the first pot in register r0 (12bits)
Get_Pot_Val:
push {r4, r5, r6, r7, r8, lr}
	ldr r4, =Mask_bit_15
	ldr r7, =Mask_12_bits
	ldr r6, =ADC_BASE
	
  mov r0, #0 //offset for the first pot
	str r5, [r6] //writing any value to channel 0 to update
	
	//reads the value and keeps looping until the value has been updated
	breakWhenUpdated_Pot_Val:
	ldr r5, [r6, r0] // reads the pot
	mov r8, r5
	orr r8, r4 //forcing the 15th bit to be 1 since we don't need to check
	and r8, r4 //applies the bit mask to get bit 15
	mov r8 , r8, lsr #15 //shift bit 15 to bit 0
	
	cmp r8, #1
	bne breakWhenUpdated_Pot_Val
	
	//r0 contains the pot value	
	and r0, r5, r7
pop {r4, r5, r6, r7, r8, pc}


