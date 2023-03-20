

/*
inputs: (r0/r1)
r0 is the dividend
r1 is the divisor

outputs:
r1 is the result of division
r0 is the remainder
*/

DIVISION_MODULO:
push {r2, lr}
  mov r2, #0

  //repeatedly subtract until the cur dividend is less than the divisor
  Loop1:
  cmp r0, r1//checks if r0 is less than r1
  blo break_DIVISION_MODULO
  sub r0, r1
  add r2, #1
  b Loop1
  break_DIVISION_MODULO:

  mov r1, r2 //set the number of times we looped
pop {r2, pc}
