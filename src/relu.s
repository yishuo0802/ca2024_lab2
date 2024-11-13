.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

loop_start:
    # TODO: Add your own implementation
    beq t1, a1, relu_end      # if t1 == a1, end loop
    slli t2, t1, 2            # t2 = t1 * 4 (byte offset)
    add t3, a0, t2            # t3 = address of array[t1]
    lw t4, 0(t3)              # t4 = array[t1]
    blt t4, zero, set_zero    # if t4 < 0, set to zero
    j next
set_zero:
    sw zero, 0(t3)            # array[t1] = 0
next:
    addi t1, t1, 1            # t1 = t1 + 1
    j loop_start
relu_end:
    ret

error:
    li a0, 36          
    j exit          
