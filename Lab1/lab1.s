begin:
    la a0, LED_MATRIX_0_BASE
    la a1, LED_MATRIX_0_BASE
    li t0, 0
    li t1, 10
    li t2, 0x00FF
    li t3, 0xFFFF
    li t4, 0xFFFFFF
    li s1, 0
rem_number: 
    rem s1, t0, t1          
    bnez s1, check_odd_even 
    j decade                 

check_odd_even:
    andi s1, t0, 1          
    bnez s1, odd            
    j even                  

odd:
    sw t2, 0(a1)        
    addi a1, a1, 4          
    addi t0, t0, 1          
    j rem_number

even:
    sw t3, 0(a1)            
    addi a1, a1, 4          
    addi t0, t0, 1       
    j rem_number

decade:
    sw t4, 0(a1)            
    addi a1, a1, 4          
    addi t0, t0, 1         
    j rem_number