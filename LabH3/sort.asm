.data
a:
	.word 64, 64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32,
	 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
	
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

main:
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
	
end:
	j	end
	
