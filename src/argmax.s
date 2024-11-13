.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error
    
loop_start:
    li t4, -2147483648    # t4 = INT_MIN
    li t5, 0              # t5 = 0
    li t0, 0              # t0 = 0

loop:
    bge t0, a1, end       # If index >= array size, jump to end label
    slli t1, t0, 2       
    add t2, a0, t1        # t2 = start address + t1, calculate element address
    lw t3, 0(t2)          # Load current element into t3 register

    blt t3, t4, next      # If t3 < t4, jump to next label
    bne t3, t4, update    # If t3 != t4, jump to update label
    j next                # Otherwise, jump to next label

update:
    mv t4, t3             # Update max value t4 to t3
    mv t5, t0             # Update max value index t5 to current index t0

next:
    addi t0, t0, 1        # Increment index by 1
    j loop                # Jump back to the start of the loop

end:
    mv a0, t5
    jr ra                 # Return

handle_error:
    li a0, 36
    j exit
