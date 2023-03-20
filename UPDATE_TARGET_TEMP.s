

/*
takes in r0 current target
returns r0 updated current target
*/
UPDATE_TARGET_TEMP:
push {r4-r12, lr}
ldr r4, =BUTTON_BASE
ldr r4, [r4] @reads buttons

@checks if decrement button has been pressed
mov r5, r4
and r5, #2
mov r5, r5, lsr #1
cmp r5, #1 @check if the button has been pressed
ldr r6, =PREV_STATE_DEC_BUT
strne r5, [r6] @sets the previous state to 0
bne skip_dec
@loads the previous state of the button
ldr r7, [r6]
cmp r7, #0
subeq r0, #1
streq r5, [r6] @set PREV_STATE_DEC_BUT to 1
skip_dec:

@checks if the increment button has been pressed
mov r5, r4
and r5, #4
mov r5, r5, lsr #2
cmp r5, #1 @check if the button has been pressed
ldr r6, =PREV_STATE_INC_BUT
strne r5, [r6] @sets the previous state to 0
bne skip_inc
@loads the previous state of the button
ldr r7, [r6]
cmp r7, #0
addeq r0, #1
streq r5, [r6] @set PREV_STATE_DEC_BUT to 1
skip_inc:

@checks reset button
mov r5, r4
and r5, #1 
cmp r5, #1
ldreq r0, =DEFAULT_TEMP
pop {r4-r12, pc}