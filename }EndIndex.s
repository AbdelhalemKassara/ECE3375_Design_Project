

@these are all variables (= gets the address, by itself gets the value)
PREV_STATE_INC_BUT: .word 0x0
PREV_STATE_DEC_BUT: .word 0x0
ADCToTempConvStAdd: .word ADC_To_Temp_Arr
TARGET_TEMP_VAL: .word DEFAULT_TEMP
CUR_TEMP: .word DEFAULT_TEMP
CUR_TIME: .word 0 //this is time in seconds
LAST_ON_HEATER: .word 0 //this is time in seconds 
LAST_ON_AIRCON: .word 0 //this is time in seconds
HEATER_ON: .word 0
AIRCON_ON: .word 0