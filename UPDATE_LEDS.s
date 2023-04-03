

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
    bgt TURN_AIRCON_ON
    blt TURN_HEATER_ON
    beq TURN_AC_AND_HEATER_OFF
  UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED:

  bl CHECK_IF_HEATER_OR_AIRCON_BROKEN

  ldr r5, =LEDS_BASE
  str r0, [r5]
pop {r4-r12, pc}

TURN_AIRCON_ON: 
  ldr r6, AIRCON_ON
  mov r0, #0b01 //if current temp is greater than target turn on air conditiner
  cmp r6, #1
    beq UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED  

    mov r6, #1
    str r6, AIRCON_ON//set flag
    
    mov r7, #0
    str r7, HEATER_ON//set flag

    ldr r8, CUR_TIME
    str r8, LAST_ON_AIRCON
b UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED

TURN_HEATER_ON:
  ldr r6, HEATER_ON
  mov r0, #0b10 //if current temp is less than target turn on heater

  cmp r6, #1
    beq UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED
  
    mov r6, #1
    str r6, HEATER_ON
    
    mov r7, #0
    str r7, AIRCON_ON

    ldr r8, CUR_TIME
    str r8, LAST_ON_HEATER
b UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED


TURN_AC_AND_HEATER_OFF:
  mov r0, #0b00 //if it is equal turn both off
  
  mov r7, #0
  str r7, AIRCON_ON
  str r7, HEATER_ON
b UPDATE_LEDS_THEY_HAVE_BEEN_UPDATED


/*
input: 
r0 status of the leds
output:
r0 potentially updated status of the leds
 */
CHECK_IF_HEATER_OR_AIRCON_BROKEN:
push {r4-r12, lr}
  ldr r4, =MIN_5

  //check if there are any issues with the air conditiner
  ldr r5, AIRCON_ON
  cmp r5, #1 //check if the air conditiner is on
    bne CONTINUE_TO_HEATER_CHECKS//if it is not on skip and check the heater
    
    ldr r5, LAST_ON_AIRCON
    ldr r6, CUR_TIME
    sub r6, r5 //r7 now contains the duration that the aircon was on
    cmp r6, r4 //check if 5 min has passed
      ble CONTINUE_TO_HEATER_CHECKS
      
      ldr r5, CUR_TEMP
      ldr r6, TARGET_TEMP_VAL
      cmp r5, r6//check if the temperature has dropped
        ble CONTINUE_TO_HEATER_CHECKS
        ldr r0, =BIT_9_ON

  CONTINUE_TO_HEATER_CHECKS:
  //check if there are any issues with the heater
  ldr r5, HEATER_ON
  cmp r5, #1 //check if the heater is on
    bne SKIP_REMAINING_CHECKS//if it is not on skip
    
    ldr r5, LAST_ON_HEATER
    ldr r6, CUR_TIME
    sub r6, r5 //r7 now contains the duration that the heater was on
    cmp r6, r4 //check if 5 min has passed
      ble SKIP_REMAINING_CHECKS
      
      ldr r5, CUR_TEMP
      ldr r6, TARGET_TEMP_VAL
      cmp r5, r6//check if the temperature has risen
        bge SKIP_REMAINING_CHECKS
        ldr r0, =BIT_9_ON
  
  SKIP_REMAINING_CHECKS:
pop {r4-r12, pc}



