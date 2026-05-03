.data
board: .space 9

msg_turnX: .asciiz "Turno X (0-8): "
msg_turnO: .asciiz "Turno O (0-8): "
msg_winX:  .asciiz "Gana X!\n"
msg_winO:  .asciiz "Gana O!\n"
msg_draw:  .asciiz "Empate!\n"
msg_invalid: .asciiz "Movimiento invalido\n"

.text
.globl main

main:
    lui $s0, 0x1001   

    jal clear_screen
    jal draw_grid

    li $s1, 1    
    li $s2, 0    

game_loop:
    beq $s1, 1, turnoX
    la $a0, msg_turnO
    j print_msg

turnoX:
    la $a0, msg_turnX

print_msg:
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    blt $t0, 0, invalid
    bgt $t0, 8, invalid

    la $t1, board
    add $t1, $t1, $t0
    lb $t2, 0($t1)
    bne $t2, $zero, invalid

    sb $s1, 0($t1)

    move $a0, $t0    
    move $a1, $s1    
    jal draw_move

    jal check_win
    bne $v0, $zero, fin

    addi $s2, $s2, 1
    li $t3, 9
    beq $s2, $t3, empate

    li $t4, 1
    beq $s1, $t4, cambiarO
    li $s1, 1
    j game_loop

cambiarO:
    li $s1, 2
    j game_loop

invalid:
    la $a0, msg_invalid
    li $v0, 4
    syscall
    j game_loop

empate:
    la $a0, msg_draw
    li $v0, 4
    syscall
    j exit

fin:
    beq $v0, 1, ganaX
    la $a0, msg_winO
    j print_fin

ganaX:
    la $a0, msg_winX

print_fin:
    li $v0, 4
    syscall

exit:
    li $v0, 10
    syscall

check_win:
    la $t0, board

    li $t1, 0
fila_loop:
    mul $t2, $t1, 3
    add $t3, $t0, $t2
    lb $t4, 0($t3)
    lb $t5, 1($t3)
    lb $t6, 2($t3)
    beq $t4, $zero, next_fila
    bne $t4, $t5, next_fila
    beq $t4, $t6, win
next_fila:
    addi $t1, $t1, 1
    blt $t1, 3, fila_loop

    li $t1, 0
col_loop:
    add $t3, $t0, $t1
    lb $t4, 0($t3)
    lb $t5, 3($t3)
    lb $t6, 6($t3)
    beq $t4, $zero, next_col
    bne $t4, $t5, next_col
    beq $t4, $t6, win
next_col:
    addi $t1, $t1, 1
    blt $t1, 3, col_loop

    lb $t4, 0($t0)
    lb $t5, 4($t0)
    lb $t6, 8($t0)
    beq $t4, $zero, diag2
    bne $t4, $t5, diag2
    beq $t4, $t6, win

diag2:
    lb $t4, 2($t0)
    lb $t5, 4($t0)
    lb $t6, 6($t0)
    beq $t4, $zero, no_win
    bne $t4, $t5, no_win
    beq $t4, $t6, win

no_win:
    li $v0, 0
    jr $ra
win:
    move $v0, $t4
    jr $ra

clear_screen:
    li $t0, 0
    li $t1, 262144    
clear_loop:
    sll $t2, $t0, 2
    add $t2, $t2, $s0
    sw $zero, 0($t2)
    addi $t0, $t0, 1
    blt $t0, $t1, clear_loop
    jr $ra

draw_grid:
    li $t3, 0x00FFFFFF
    li $t0, 0
vert_loop:
    mul $t2, $t0, 512
    addi $t8, $t2, 170
    sll $t8, $t8, 2
    add $t8, $t8, $s0
    sw $t3, 0($t8)
    addi $t8, $t2, 341
    sll $t8, $t8, 2
    add $t8, $t8, $s0
    sw $t3, 0($t8)
    addi $t0, $t0, 1
    blt $t0, 512, vert_loop

    li $t0, 0
horiz_loop:
    li $t1, 170
    mul $t2, $t1, 512
    add $t2, $t2, $t0
    sll $t2, $t2, 2
    add $t2, $t2, $s0
    sw $t3, 0($t2)
    li $t1, 341
    mul $t2, $t1, 512
    add $t2, $t2, $t0
    sll $t2, $t2, 2
    add $t2, $t2, $s0
    sw $t3, 0($t2)
    addi $t0, $t0, 1
    blt $t0, 512, horiz_loop
    jr $ra

draw_move:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 3
    div $a0, $t0
    mflo $t1 
    mfhi $t2 

    li $t3, 170
    mul $t4, $t1, $t3 
    mul $t5, $t2, $t3 
    addi $t4, $t4, 60
    addi $t5, $t5, 60

    beq $a1, 1, exec_drawX
    li $t6, 0x0000FF00 
    jal draw_O
    j draw_move_done

exec_drawX:
    li $t6, 0x00FF0000 
    jal draw_X

draw_move_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_X:
    li $t7, 0
loopX:
    mul $t9, $t4, 512
    add $t9, $t9, $t5
    add $t9, $t9, $t7
    add $t8, $t7, $t7
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    mul $t9, $t4, 512
    add $t9, $t9, $t5
    add $t9, $t9, $t7
    li $t8, 40
    sub $t8, $t8, $t7
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    addi $t7, $t7, 1
    blt $t7, 40, loopX
    jr $ra

draw_O:
    li $t7, 0
loopO_horiz:
    mul $t9, $t4, 512
    add $t9, $t9, $t5
    add $t9, $t9, $t7
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    addi $t8, $t4, 40
    mul $t9, $t8, 512
    add $t9, $t9, $t5
    add $t9, $t9, $t7
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    addi $t7, $t7, 1
    blt $t7, 40, loopO_horiz

    li $t7, 0
loopO_vert:
    add $t8, $t4, $t7
    mul $t9, $t8, 512
    add $t9, $t9, $t5
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    add $t8, $t4, $t7
    mul $t9, $t8, 512
    add $t9, $t9, $t5
    addi $t9, $t9, 40
    sll $t9, $t9, 2
    add $t9, $t9, $s0
    sw $t6, 0($t9)
    addi $t7, $t7, 1
    blt $t7, 40, loopO_vert
    jr $ra
