# Assignment 2: Classify

## Part A: Mathematical Functions

### Task 1: ReLU
#### Implement
Using a for loop to sequentially read the array up to the array size, and if the value is greater than zero, skip the `set_zero` part.
```asm
loop_start:
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
```

#### Error Condition
Return 36 if the array length is less than 1.

### Task 2: ArgMax

#### Implement
First, set the value of a `comparison register` to `INT_MIN` and the `target index register` to `0`.
Use a for loop to sequentially read through the array up to the array size.
If a value is greater than the `comparison register`, update the `comparison register` with the current value and set the `target index register` to the current index.

```asm
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
```
#### Error Condition
Return 36 if the array length is less than 1.


### Task 3.1: Dot Product
#### Implementation of multiplication
The mul_operation function implements multiplication using the `shift and add` method. 
It initializes t0 to 0 as the accumulator for the result.
1. Check if the multiplier is zero
    - If so, it jumps to the end since the result is zero.
3. In the main loop
    - Check if the least significant bit of a1 is set (odd).
        - If so, it adds a0 (the multiplicand) to t0.
    - Left-shifts a0 by 1 (doubling it) and right-shifts a1 by 1 (halving it)
4. This process continues until a1 becomes zero.
5. The accumulated result in t0 is moved to a0, and the function returns. 

```asm
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
```
#### Implementation of dot product
The loop calculates the dot product of two arrays with specific strides and stores the result in a0. It iterates over the elements until t0 reaches a2 (the number of iterations).
```asm
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
```
#### Error Condition
- Exits with code 36 if element count < 1
- Exits with code 37 if any stride < 1


### Task 3.2: Matrix Multiplication
#### Implementation
#### Outer Loop
The outer loop iterates over each row of `M0`. `s0` keeps track of the current row in `M0`.
Initializes `s1` to 0 and sets `s4` to point to the first column of `M1` for matrix multiplication.
```asm
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra
```
#### Inner Loop
1. For each element in the current row of `M0` and column of `M1`, it calculates the dot product and stores the result in D.
2. Saves the necessary registers before calling the dot function and sets arguments for dot, including the pointers, number of elements, and strides for M0 and M1.
3. Calls the dot function, which calculates M0_row × M1_col and stores the result in t0.
Stores t0 in D and increments the pointer for D by 4 bytes.
4. Increment Pointers and Loop Control
    - Increments `s4` (column pointer for `M1`) by 4 to move to the next column.
    - Increments `s1` for inner loop control and checks if all columns of `M1` have been processed for the current row of `M0`.
```asm
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation
    addi s0, s0, 1
    li t1, 4
mul_operation: # t1 = t1 * a2
    # Prologue
    li t0, 0 # t0 = 0 (result)
    mv t2, a2
    # Body
    beqz a2, end_mul # Check if a1 is zero
mul_loop:
    andi t3, t2, 1         # t2 = a2 & 1
    beqz t3, skip_add
    add t0, t0, t1         # t0 += t1
skip_add:
    slli t1, t1, 1         # t1 <<= 1
    srli t2, t2, 1         # a2 >>= 1
    bnez t2, mul_loop
end_mul:
    mv t1, t0              # Move result to t1
    add s3, s3, t1 # incrementing the row on Matrix A
    j outer_loop_start
```
#### 
#### Error Condition
- Validates M0: Ensures positive dimensions
- Validates M1: Ensures positive dimensions
- Validates multiplication compatibility: M0_cols = M1_rows
- All failures trigger program exit with code 38

## Part B: Mathematical Functions

### Task 1: Read Matrix
#### Implement
1. Opens the file using `jal fopen`
2. Read Matrix Dimensions
    - Calls fread to read 8 bytes, storing the row and column counts.
    - Verifies that fread read 8 bytes; otherwise, it jumps to fread_error.
    - Stores the row and column values in s3 and s4.
3. Calculate Matrix Size
    - Calculates the total number of elements by multiplying the row and column counts (`t1` and `t2`).
    - Implements the multiplication using `mul_operation` (shift-and-add method) and converts it to bytes by shifting left by 2 (each element is 4 bytes).
4. Allocate Memory (malloc) - Calls `malloc` to allocate memory for the matrix based on the calculated byte size.
5. Read Matrix Data - Sets up `fread` to read the matrix data into the allocated memory.
6. Closes the file using fclose
```asm
    mv s3, a1         # save and copy rows
    mv s4, a2         # save and copy cols

    li a1, 0

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file

    # read rows n columns
    mv a0, s0
    addi a1, sp, 28  # a1 is a buffer

    li a2, 8         # look at 2 numbers

    jal fread

    li t0, 8
    bne a0, t0, fread_error

    lw t1, 28(sp)    # opening to save num rows
    lw t2, 32(sp)    # opening to save num cols

    sw t1, 0(s3)     # saves num rows
    sw t2, 0(s4)     # saves num cols

    # mul s1, t1, t2   # s1 is number of elements
mul_operation:
    li s1, 0 # s1 = 0 (result)
    beqz t2, end_mul # Check if t2 is zero
mul_loop:
    andi t0, t2, 1         # t0 = t2 & 1
    beqz t0, skip_add
    add s1, s1, t1         # s1 += t1
skip_add:
    slli t1, t1, 1         # t1 <<= 1
    srli t2, t2, 1         # t2 >>= 1
    bnez t2, mul_loop
end_mul:
    slli t3, s1, 2
    sw t3, 24(sp)    # size in bytes

    lw a0, 24(sp)    # a0 = size in bytes

    jal malloc

    beq a0, x0, malloc_error

    # set up file, buffer and bytes to read
    mv s2, a0        # matrix
    mv a0, s0
    mv a1, s2
    lw a2, 24(sp)

    jal fread

    lw t3, 24(sp)
    bne a0, t3, fread_error

    mv a0, s0

    jal fclose

    li t0, -1

    beq a0, t0, fclose_error

    mv a0, s2
```
#### Error Condition
- Code 26: Dynamic memory allocation failed
- Code 27: File access error (open/EOF)
- Code 28: File closure error
- Code 29: Data read error

### Task 2: Write Matrix
#### Implement
1. Opens the file with `jal fopen`
2. Write Matrix Dimensions
    - Writes the row and column counts as a header.
    - Sets up `fwrite` with a buffer containing `s2` (rows) and `s3` (columns), each 4 bytes.
    - Verifies that `fwrite` wrote 2 elements (8 bytes total); if not, jumps to `fwrite_error`.
3. Calculate Matrix Size
    - Computes the total number of matrix elements by multiplying `s2` and `s3`.
    - Uses a shift-and-add method `mul_operation` to calculate s4 as `rows * columns`.
4. Calls `fwrite` to write the matrix data, with `s1` as the data pointer and `s4` as the element count.
```asm
    # save arguments
    mv s1, a1        # s1 = matrix pointer
    mv s2, a2        # s2 = number of rows
    mv s3, a3        # s3 = number of columns

    li a1, 1

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)    # number of rows
    sw s3, 28(sp)    # number of columns

    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error

    # mul s4, s2, s3   # s4 = total elements
mul_operation:
    li s4, 0 # s1 = 0 (result)
    beqz s3, end_mul # Check if s3 is zero
mul_loop:
    andi t0, s3, 1         # t0 = s3 & 1
    beqz t0, skip_add
    add s4, s4, s2         # s4 += s2
skip_add:
    slli s2, s2, 1         # s2 <<= 1
    srli s3, s3, 1         # s3 >>= 1
    bnez s3, mul_loop

end_mul:
    # write matrix data to file
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    bne a0, s4, fwrite_error

    mv a0, s0

    jal fclose

    li t0, -1
    beq a0, t0, fclose_error
```
#### Error Condition
- Terminates with error code 27 on `fopen` error or end-of-file (EOF).
- Terminates with error code 28 on `fclose` error or EOF.
- Terminates with error code 30 on `fwrite` error or EOF.

### Task 3: Classification
#### Implement
1. Read Pretrained Matrices (M0 and M1) and Input Matrix
    - Allocates memory for row and column pointers for each matrix.
    - Calls `read_matrix` to read matrices from files into memory, with `M0`, `M1`, and input matrix stored in `s0`, `s1`, and `s2`.
```asm
    # Read pretrained m0
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
    # Read pretrained m1
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 8(a1) # set argument 1 for the read_matrix function  
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Read input matrix
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 12(a1) # set argument 1 for the read_matrix function  
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
```
2. Compute Intermediate Matrix h
    - Multiplies M0 and the input matrix to produce an intermediate result, h.
    - Allocates memory for h, computes its size, and calls matmul to perform the multiplication.
``` asm
    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw a0, 0(s3)
    lw a1, 0(s8)
    jal mul_operation
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
```
3. Apply `relu` Activation to `h`
```asm
    # Compute h = relu(h)
    addi sp, sp, -8
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    lw a0, 0(s3)
    lw a1, 0(s8)
    jal mul_operation # mul a1, t0, t1 # length of h array and set it as second argument
    mv a1, a0 # move length of h array into second argument
    mv a0, s9 # move h to the first argument
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    
    addi sp, sp, 8
```
4. Compute Output Matrix `o`
    - Multiplies `M1` and `h` to produce the output matrix `o`.
    - Allocates memory for `o` and calls `matmul` to perform the multiplication.
5. Write Output Matrix to File
Calls `write_matrix` to save the output matrix `o` to the specified file.
6. Calls `argmax` to find the index of the largest element in `o`, setting `a0` to the classification result.
```asm
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw a0, 0(s3)
    lw a1, 0(s6)
    jal mul_operation # mul a0, t0, t1 
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0 # move o to s10
    
    mv a6, a0 # o
    
    mv a0, s1 # move m1 array to first arg
    lw a1, 0(s5) # move m1 rows to second arg
    lw a2, 0(s6) # move m1 cols to third arg
    
    mv a3, s9 # move h array to fourth arg
    lw a4, 0(s3) # move h rows to fifth arg
    lw a5, 0(s8) # move h cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    lw a0, 0(s3)
    lw a1, 0(s6)
    jal mul_operation # load length of array into second arg
    mv a1, a0
    mv a0, s10 # load o array into first arg
    jal argmax
    
    mv t0, a0 # move return value of argmax into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp 12
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4
```

#### Error Condition
- 31 - Invalid argument count
- 26 - Memory allocation failure
