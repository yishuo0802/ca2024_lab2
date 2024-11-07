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
    bge t0, a1, end       # 如果索引 >= 陣列大小，跳到結束標籤
    slli t1, t0, 2       
    add t2, a0, t1        # t2 = 起始位址 + t1，計算元素的位址
    lw t3, 0(t2)          # 將當前元素讀入 t3 暫存器

    blt t3, t4, next      # 如果 t3 < t4，跳到 next 標籤
    bne t3, t4, update    # 如果 t3 != t4，跳到 update 標籤
    j next                # 否則跳到 next 標籤

update:
    mv t4, t3             # 更新最大值 t4 為 t3
    mv t5, t0             # 更新最大值的索引 t5 為當前索引 t0

next:
    addi t0, t0, 1        # 索引加 1
    j loop                # 跳回迴圈的起始處

end:
    lw t5, 0(a0)          # 將最大值的索引存入 a0 位置

handle_error:
    li a0, 36
    j exit
    slli t1, t0, 2        # t1 = t0 * 4 (假設每個元素是 4 bytes，即 32 位元)
    add t2, a0, t1        # t2 = 起始位址 + t1，計算元素的位址
    lw t3, 0(t2)          # 將當前元素讀入 t3 暫存器
    
    # 在這裡可以進行需要的處理，例如將元素輸出或進行運算
    # 假設我們只是將讀取的值存入一個寄存器或打印
    # mv a2, t3          # (例如，將當前元素值傳給另一函數)

    addi t0, t0, 1        # 索引加 1
    j loop                # 跳回迴圈的起始處

    lw t0, 0(a0)

end: 

handle_error:
    li a0, 36
    j exit
