.data
led_data_addr:
	.word 0x7f00
seg_rdy_addr:
	.word 0x7f04
seg_data_addr:
	.word 0x7f08
swx_vld_addr:
	.word 0x7f0C
swx_data_addr:
	.word 0x7f10
cnt_data_addr:
	.word 0x7f14
cnt_before_sort:
	.word 0
a:	
	.word 0
	
.text 
	j	main

heap_adjust:
	# heap adjust function
	# arguments:
	#	- a0 stands for s
	#	- a1 stands for n
	# Register number is enough, no need for save or restore registers.
	slli	t0, a0, 1	# t0 stands for j
	la	t6, a
	add	t5, t6, a0
	lw	t1, 0(t5)	# t1 stands for t
adjust_loop:
	bgtu	t0, a1, adjust_end
	add	t5, t6, t0
	lw	t3, 0(t5)	# t3 now stores a[j]
	beq	t0, a1, comp_end
comp:
	lw	t4, 4(t5)
	bltu	t4, t3, comp_end
	addi	t0, t0, 4
	mv	t3, t4
comp_end:
	bgtu	t1, t3, adjust_end
	add	t5, t6, a0
	sw	t3, 0(t5)
	mv	a0, t0
	slli	t0, t0, 1
	j	adjust_loop
adjust_end:
	add	t5, t6, a0
	sw	t1, 0(t5)
	ret
	# heap_adjust end
	
xor_shift:
	# xor-shift LFSR function
	# input:
	#	- a0: input x
	# output:
	#	- a0: xor-shifted x
	beqz	a0, x_eq_z
	j	x_ne_z
x_eq_z:
	li	a0, 1
x_ne_z:
	# x ^= (x & 0x0007ffff) << 13
	li 	t0, 0x0007ffff
	and	t0, a0, t0
	slli	t0, t0, 13
	xor	a0, a0, t0
	# x ^= x >> 17
	mv	t0, a0
	srli	t0, t0, 17
	xor	a0, a0, t0
	# x ^= (x & 0x07ffffff) << 5
	li	t0, 0x07ffffff
	and	t0, a0, t0
	slli	t0, t0, 5
	xor	a0, a0, t0
	ret

main:

	# query size of a
	lw	t4, led_data_addr
	li	t5, 1
	sw	t5, (t4)
	lw	t0, swx_vld_addr
	lw	t1, swx_data_addr
	la	t2, a
size_query:
	lw	t3, (t0)
	beqz	t3, size_query
	lw	t3, (t1)
	sw	t3, (t2)
	
	# query first element
	lw	t4, led_data_addr
	li	t5, 2
	sw	t5, (t4)
first_query:
	lw	t3, (t0)
	beqz	t3, first_query
	lw	t3, (t1)
	sw	t3, 4(t2)
	
	lw	t4, led_data_addr
	li	t5, 0
	sw	t5, (t4)
	# generate element 2-n
	lw	s0, a		# s0 stands for n
	mv	a0, t3		# a0 stands for ls
	li 	t1, 1		# t1 stands for cnt
	la	t2, a
	addi	t2, t2, 8	# t2 stands for now
gen_loop:
	blt	t1, s0, gen
	j	gen_end
gen:
	jal	xor_shift
	sw	a0, 0(t2)
	addi	t1, t1, 1
	addi	t2, t2, 4
	j	gen_loop
gen_end:

	# start_sort
	lw	t0, cnt_data_addr
	lw	t0, 0(t0)
	sw	t0, cnt_before_sort,t1
	lw	s0, a		# s0 stands for n
	srli	s1, s0, 1	# s1 stands for i
	slli	s1, s1, 2
	slli	s0, s0, 2
init_loop:
	beqz	s1, init_loop_end
	mv	a0, s1
	mv	a1, s0
	jal	ra, heap_adjust
	addi	s1, s1, -4
	j	init_loop
init_loop_end:

	mv	s1, s0
	li	s2, 4
sort_loop:
	beq	s1, s2, sort_loop_end
	
	# swap
	la	t0, a
	add	t1, t0, s1
	lw	t3, 0(t1)
	lw	t4, 4(t0)
	sw	t3, 4(t0)
	sw	t4, 0(t1)
	
	addi	s1, s1, -4
	li	a0, 4
	mv	a1, s1
	jal	ra, heap_adjust
	j	sort_loop
sort_loop_end:
	
	# sort end
	lw	t0, cnt_data_addr
	lw	t0, 0(t0)
	lw	t1, cnt_before_sort
	sub	a0, t0, t1
	# query save clock cycle used
	lw	t0, seg_rdy_addr
	lw	t1, seg_data_addr
cycle_query:
	lw	t3, (t0)
	beqz	t3, cycle_query
	sw	a0, (t1)
	
	li	ra, 1		# ra - ans
	la	t0, a		# t0 - a
	li	t1, 1		# t1 - cnt
	lw	t2, 4(t0)	# t2 - ls
	addi	t3, t0, 8	# t3 - now
	lw	t0, 0(t0)	# t0 - n
check_loop:
	blt	t1, t0, check
	j	check_end
check:
	lw	t4, 0(t3)
	bltu	t4, t2, check_fail
	j check_success
check_fail:
	li	ra, 0
	j	check_end
check_success:
	mv	t2, t4
	addi	t1, t1, 1
	addi	t3, t3, 4
	j	check_loop
check_end:
	lw 	t0, led_data_addr
	sw	ra, 0(t0)
	
end:
	j	end
	
