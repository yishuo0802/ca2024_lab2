.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    li t0, 0            
    li t1, 0         
    li t2, 0
    li t3, 0

loop_start:
    bge t0, a2, loop_end
    # TODO: Add your own implementation
    slli s5, t1, 2 # s5 = t1 * 4 address offset
    slli s6, t2, 2 # s6 = t2 * 4 address offset
    add s7, s0, s5 # s7 = a0 + s5 = arr0 + i * stride0
    add s8, s1, s6 # s8 = a1 + s6 = arr1 + i * stride1

    lw a0, 0(s7) # a0 = arr0[i]
    lw a1, 0(s8) # a1 = arr1[i]

    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    jal mul_operation # a0 = a0 * a1
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16

    add t3, t3, a0 # t3 += arr0[i] * arr1[i]
    addi t0, t0, 1 # t0 += 1
    add t1, t1, s3 # t1 += skip distance in first array
    add t2, t2, s4 # t2 += skip distance in second array
    
    j loop_start
loop_end:
    mv a0, t3
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40

    jr ra

mul_operation: # a0 = a0 * a1
    # Prologue
    li t0, 0 # t0 = 0 (result)
    # Body
    beqz a1, end_mul # Check if a1 is zero
mul_loop:
    andi t1, a1, 1         # t1 = a1 & 1
    beqz t1, skip_add
    add t0, t0, a0         # t0 += a0
skip_add:
    slli a0, a0, 1         # a0 <<= 1
    srli a1, a1, 1         # a1 >>= 1
    bnez a1, mul_loop
end_mul:
    mv a0, t0              # Move result to a0
    # Epilogue
    jr ra
    
error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
