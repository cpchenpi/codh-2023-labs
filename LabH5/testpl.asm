.data 
w1:
	.word	32
w2:
	.word 	64
	
.text 

branch_test:
	li	x1, 2
	beq	x0, x0, branch_test_mid
	addi	x1, x0, 4
	addi	x1, x1, 6
	addi	x1, x1, 8
branch_test_mid:
	li	x2, 2
	nop
	nop
	nop
	beq	x1, x2, write_first_test
	j	fail

write_first_test:
	lw 	t1, w1
	lw	t2, w2
	nop
	add	t1, t1, t1
	li	t2, 64
	nop
	nop
	beq 	t1, t2, EX_forward_test
	j	fail
	
EX_forward_test:
	addi	t1, x0, 1
	addi	t2, t1, 1
	add	t3, t1, t2
	nop
	nop
	li	t4, 3
	beq	t3, t4, MEM_forward_test
	j	fail
	
MEM_forward_test:
	addi	t1, x0, 1
	addi	t2, x0, 1
	add	t1, t1, t1
	add	t2, t2, t2
	li	t4, 4
	add	t3, t1, t2
	nop
	beq	t3, t4, load_and_use_test
	j	fail
	
load_and_use_test:
	lw	t1, w1	
	add	t1, t1, t1
	lw	t2, w2
	add	t3, t1, t2
	li	t4, 128
	beq	t3, t4, success
	j	fail
	
success:
	li	ra, 1
	j	save
	
fail:
	li	ra, 0
	j	save
	
save:
	li	t1, 0x7f00
	sw	ra, (t1)
end:
	j 	end