

/*
  this updates the leds on the board
  led 0 indicates that the air conditioner is on
  led 1 indicates that the heater is on
  led 9 indicates that there is an issue with the heater or air conditoner 
  
*/
UPDATE_LEDS:
push {r4-r12, lr}
  ldr r4, CUR_TEMP
  ldr r5, TARGET_TEMP_VAL 

  cmp r4, r5
  movgt r4, #0b01 //if current temp is greater than target turn on air conditiner
  movlt r4, #0b10 //if current temp is less than target turn on heater
  moveq r4, #0b00 //if it is equal turn both off

  //check if there are any issues here
  

  ldr r5, =LEDS_BASE
  str r4, [r5]
pop {r4-r12, pc}



