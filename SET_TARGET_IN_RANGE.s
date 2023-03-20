

/*
r0 is the current target temperature

returns r0 if the target temp is in range if not then if it is over it is set to the max if it is less it is set to the min
*/
SET_TARGET_IN_RANGE: 
pop {r4-r12, lr}


push {r4-r12, pc}

