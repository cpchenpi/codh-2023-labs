.data
wstdshort:
    .word 32
wstdlong:
    .word 1145141919
wshort:
    .word 0
wlong:
    .word 0
addr_led:
    .word 32512
addr_cnt:
    .word 0x7f20
    
.text 
    # arith operates
    li t1, 3
    li t2, 2
    
add_test:
    add t3, t1, t2
    li  t4, 5
    beq t3, t4, sub_test
    j   fail
    
sub_test:
    sub t3, t1, t2
    li  t4, 1
    beq t3, t4, addi_test
    j fail
    
addi_test:
    addi    t3, t1, 5
    li      t4, 8
    beq     t3, t4, lui_test
    j fail
    
    # test lui and auipc
lui_test:
    auipc   t3, 0
    auipc   t4, 100000
    addi    t3, t3, 4
    lui     t5, 100000
    add     t6, t3, t5
    beq     t4, t6, and_test
    j fail
    # arith operates end
    
    # logical operates
and_test:
    li      t1, 6  # 0b0110
    li      t2, 10 # 0b1010
    
    and     t3, t1, t2
    li      t4, 2 # 0b0010
    beq     t3, t4, or_test
    j fail
    
or_test:
    or      t3, t1, t2
    li      t4, 14 # 0b1110
    beq     t3, t4, xor_test
    j fail
    
xor_test:
    xor     t3, t1, t2
    li      t4, 12 # 0b1100
    beq     t3, t4, slli_test
    j fail
    # logical operates end
    
    # shift operates
slli_test:
    li      t1, 219       # 0b1101 1011
    
    slli    t3, t1, 4
    li      t4, 3504      # 0b1101 1011 0000
    beq     t3, t4, srli_test
    j fail
    
srli_test:
    li      t4, 13        # 0b1101
    srli    t3, t1, 4
    beq     t3, t4, srai_test
    j fail
    
srai_test:
    srai    t3, t1, 4
    beq     t3, t4, srli_test_1
    j fail
    
srli_test_1:
    li      t1, -268435456 # 0b1111 0000 0000 0000 0000 0000 0000 0000
    
    li      t4, -16        # 0b1111 1111 1111 1111 1111 1111 1111 0000
    srai    t3, t1, 24
    beq     t3, t4, srai_test_1
    j fail
    
srai_test_1:
    li      t4, 240        # 0b0000 0000 0000 0000 0000 0000 1111 0000
    srli    t3, t1, 24
    beq     t3, t4, lw_test_s
    j fail
    # shift operates end
    
    # memory operates
lw_test_s:
    li      t1, 32
    la      t2, wshort
    sw      t1, (t2)
    lw      t3, wstdshort
    beq     t3, t1, sw_test_s
    j       fail
    
sw_test_s:
    lw      t4, wshort
    beq     t4, t1, lw_test_l
    j       fail
    
lw_test_l:
    li      t1, 1145141919
    la      t2, wlong
    sw      t1, (t2)
    lw      t3, wstdlong
    beq     t3, t1, sw_test_l
    j       fail
    
sw_test_l:
    lw      t4, wlong
    beq     t4, t1, beq_addr
    j fail
    # memory operates end
    
    # branch/jump operates    
beq_addr:
    li      t1, 2
    li      t2, 2
    beq     t1, t2, blt_addr
    j       fail

blt_addr:
    li      t2, 3
    blt     t1, t2, bltu_addr
    j       fail

bltu_addr:
    li      t2, -3
    bltu    t1, t2, bltu_end
    j       fail
bltu_end:
    # nop

    jal     t2, jaltest
jaladdr:
    j       fail
jaltest:
    la      t3, jaladdr
    beq     t3, t2, jal_beg
    j	     fail
    # jal test end
    
jal_beg:
    la      t1, jalrtest
    jalr    t2, t1, 0
jalraddr:
    j       fail
jalrtest:
    la      t3, jalraddr
    beq     t3, t2, success
    j       fail
    # branch/jump operates end

    

success:
    li      ra, 1
    j       save
fail:	
    li      ra, 0
save:
    lw	    t1, addr_led
    sw	    ra, 0(t1)
    lw     t1, addr_cnt
    lw	    ra, 0(t1)
end:
    j       end
