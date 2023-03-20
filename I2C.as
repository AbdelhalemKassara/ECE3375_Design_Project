@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ DATA FOR G-SENSOR
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data
gs_data_array:
  .byte 0x11   @ for x0
  .byte 0x12   @ for x1
  .byte 0x21   @ for y0
  .byte 0x22   @ for y1
  .byte 0x31   @ for z0
  .byte 0x32   @ for z1
@ initial values given above are just so it is easy to check later
@ whether new data is written properly
@ reasonably unlikely that random accelerometer data will match the
@ above values
@ if something goes wrong it is more likely that 0x00 will be returned
@ so we can see if that happens as we initialized to non-zero values

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ ADDRESS DEFINITIONS
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text
  .equ LED_BASE, 0xFF200000
  .equ I2C_BASE, 0xFFC04000

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ MAIN PROGRAM
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.global _start
_start:
  @ first initialize I2C0 interface
  bl init_I2C
    
  @ now test if GS is available
  @ reading from ADXL345 register 0x00 should
  @ ALWAYS return 0xE5
  mov r0, #0x00
  bl read_over_I2C  
  cmp r0, #0xE5
  beq _everything_is_ok
  
  @ oh no, we aren't talking to device!
  @ light the signal fires!
  ldr r0, =LED_BASE
  ldr r1, =0x3FF
  str r1, [ r0 ]  
  @ loop endlessly
_dead_loop:
  b _dead_loop
 
_everything_is_ok:
  @ initialize GS
  bl init_GS
  
_main_loop:
  @ check if data acquisition is done
  @ ADXL345 manual states
  @  source register is 0x30
  @  bit 7 is 1 when data is ready
  mov r0, #0x30
  bl read_over_I2C
  @ check if bit 7 is 1
  tst r0, #0x80
  @ if not, go back
  beq _main_loop
  
  @ ok, try to multi-read from data
  @ ADXL345 register 0x32 and subsequent 6 registers
  @ should be read
  mov r2, #0x32
  mov r1, #6
  @ address for storing data
  ldr r0, gs_data_addr
  @ read all 6 bytes
  bl read_over_I2C_multiple
  @ ok, data is stored in memory starting at gs_data_addr
  @ now do something with it

   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
  @ loop back
  b _main_loop
  
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ SUBROUTINES
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ initialize I2C device to connect
@ to ADXL345 sensor
init_I2C:
  @ preserve state
  push { r4, lr }
  
  @ get address of I2C0
  ldr r4, =I2C_BASE
  @ make copy of I2C0 address offset by 0x9C
  @ because that is the frequently-used status register
  add r0, r4, #0x9C
  
  @ set enable register (offset by 0x6C)
  @ to #2 to disable device
  mov r1, #0x02
  str r1, [ r4, #0x6C ]
  @ loop until status register reads 0x00
  mov r1, #0x01
  bl spin_bit_clear

  @ control bits, see manual
  @ control register is offset by 0x00  
  mov r1, #0x65
  str r1, [ r4 ]
  
  @ ADXL345 hard-coded I2C address, see manual
  @ target address register is offset by 0x04
  mov r1, #0x53
  str r1, [ r4, #0x04 ]
  
  @ fast count high-period
  mov r1, #90
  str r1, [ r4, #0x1C ]
  @ fast count low-period
  mov r1, #160
  str r1, [ r4, #0x20 ]
  @ high- and low-periods must add to 250
  @ see ADXL345 manual for details
  
  @ enable I2C0
  mov r1, #0x01
  str r1, [ r4, #0x6C ]
  @ loop until status register reads 0x00
  bl spin_bit_set
  
  @ restore state
  pop { r4, lr }
  @ return
  bx lr
  
@ reads a byte from ADXL345 internal register at address
@ stored in r0, returns byte in r0
read_over_I2C:
  @ preserve state
  push { r4, lr }
  
  @ move ADXL345 register to r2
  @ this is because I always like passing addresses in r0
  @ and I also use a spin subroutine to idle until status is
  @ set, this spin subroutine requires address and bitmask
  @ in r0, r1 respectively
  mov r2, r0
  
  @ get address of I2C0
  ldr r4, =I2C_BASE
  @ make copy of I2C0 address offset by 0x78
  @ because that is the read FIFO queue status register
  add r0, r4, #0x78
  
  @ add 0x400 to address
  @ top 3 bits in I2C0 write instruction are command flag bits
  @ 0x4 issues restart before sending data
  mov r3, #0x400
  add r2, r3
  @ now write this data to I2C0 device, send register is offset by 0x10
  str r2, [ r4, #0x10 ]
  @ reset command bits to 0x1 for reading data
  mov r2, #0x100
  str r2, [ r4, #0x10 ]
  
  @ spin until data obtained, means FIFO queue is non-zero
  mov r1, #0xFF
  bl spin_bit_set
  
  @ get data from I2C0 device
  ldr r0, [ r4, #0x10 ]
  
  @ restore state
  pop { r4, lr }
  @ return 
  bx lr
  
@ writes a byte to ADXL345 internal register at address
@ stored in r0, the data byte is in r1
write_over_I2C:
  @ preserve state
  push { r4, lr }
  
  @ get address of I2C0
  ldr r4, =I2C_BASE  
  @ add 0x400 to address
  @ top 3 bits in I2C0 write instruction are command flag bits
  @ 0x4 issues restart before sending data
  mov r2, #0x400
  add r0, r2
  @ now write this data to I2C0 device, send register is offset by 0x10
  str r0, [ r4, #0x10 ]
  
  @ now write actual data to device
  str r1, [ r4, #0x10 ]
  
  @ restore state
  pop { r4, lr }
  @ return
  bx lr
  
@ reads multiple byte from ADXL345 internal register at address
@ stored in r2, number of bytes should be in r1, memory address for
@ storing data should be in r0
@ returns memory address in r0, rolled back to start
read_over_I2C_multiple:
  @ preserve state
  push { r4 - r7, lr }
  
  @ move memory address to r3
  @ this is because I always like passing addresses in r0
  @ and I also use a spin subroutine to idle until status is
  @ set, this spin subroutine requires address and bitmask
  @ in r0, r1 respectively
  mov r3, r0
  
  @ get address of I2C0
  ldr r4, =I2C_BASE
  @ make copy of I2C0 address offset by 0x78
  @ because that is the read FIFO queue status register
  add r0, r4, #0x78
  
  @ add 0x400 to address
  @ top 3 bits in I2C0 write instruction are command flag bits
  @ 0x4 issues restart before sending data
  mov r5, #0x400
  add r2, r5
  @ now write this data to I2C0 device, send register is offset by 0x10
  str r2, [ r4, #0x10 ]

  @ reset command bits to 0x1 for read
  mov r2, #0x100
  @ make copy of number of bytes to read
  mov r6, r1
  @ loop to make N sequential read requests
_multi_read_request_loop:
  @ make read request
  str r2, [ r4, #0x10 ]
  @ decrement counter
  subs r6, #1
  bne _multi_read_request_loop
  
  @ make copy of number of bytes to read, again
  mov r6, r1
  @ and another copy
  mov r7, r1
  @ put bit mask for FIFO queue in r1
  mov r1, #0xFF
  @ now loop to make N sequential reads  
_multi_read_loop: 
  @ spin until data obtained, means FIFO queue is non-zero
  bl spin_bit_set
  @ read data
  ldr r2, [ r4, #0x10 ]
  @ write to memory as a byte
  strb r2, [ r3, #1 ]!
  @ decrement counter
  subs r6, #1
  bne _multi_read_loop
  
  @ use the number of bytes read to roll-back memory address
  sub r3, r7
  @ put this rolled-back address back into r0
  mov r0, r3
  
  @ restore state
  pop { r4 - r7, lr }
  @ return 
  bx lr
 
@ initialize ADXL345 device over I2C
init_GS:
  @ preserve state
  push { lr }
  
  @ configure device for +/- 2g resolution
  @ write control bits 0x08 to ADXL345 register 0x31
  @ see manual for details
  mov r0, #0x31
  mov r1, #0x08
  bl write_over_I2C
  
  @ configure device for 200 Hz sampling
  @ write control bits 0x0B to ADXL345 register 0x2C
  @ see manual for details
  mov r0, #0x2C
  mov r1, #0x0B
  bl write_over_I2C
  
  @ configure device to start measuring continuously
  @ write control bits 0x08 to ADXL345 register 0x2D
  @ see manual for details
  mov r0, #0x2D
  mov r1, #0x08
  bl write_over_I2C

  @ restore state
  pop { lr }
  @ return
  bx lr

@ loops until a bit is set
@ assumes address of bit is in r0
@ assumes bit mask is in r1
spin_bit_set:
  ldr r2, [ r0 ]
  tst r1, r2
  beq spin_bit_set
  bx lr

@ loops until a bit is cleared
@ assumes address of bit is in r0
@ assumes bit mask is in r1
spin_bit_clear:
  ldr r2, [ r0 ]
  tst r1, r2
  bne spin_bit_clear
  bx lr  
 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ ADDRESSES FOR DATA
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
gs_data_addr :
  .word gs_data_array
 