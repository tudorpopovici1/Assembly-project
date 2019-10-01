# Authors: 
# Toma Zamfirescu - Student Number: 4948777 - NETID: tzamfirescu@tudelft.nl
# Tudor-Alexandru Popovici - Student Number: 4812379 - NETID: tudorpopovici@tudelft.nl

.global brainfuck

format_str: .asciz "%s\n"
char: .asciz "%c"


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	#printing the brainfuck code that we want to execute

	pushq %rbp # pushing the base pointer on the stack
	movq %rsp, %rbp	# moving the stack pointer to the base pointer

	movq %rdi, %rsi # moving our string into rsi

	subq $1000000, %rsp # allocating space on the stack
	
	movq $0, %r13 # initialising r13 with 0
	movq $0, %r12 # initialising r12 with 0

	movq %rsp, %r15 # assigning the address of the stack pointer to r15 

	movq $0, %rcx
	movq $0, %rax
	movq $0, %rbx
	movq $0, %rdx 

	call _loop # calling the subroutine _loop

	

	movq %rbp, %rsp # moving the base pointer to the stack pointer
	popq %rbp  # popping the base pointer 

	call exit # calling the exit function

	#reading every character from the string
	_loop:
	movb (%rsi), %cl # getting the character into %cl (only a byte)

	cmpb $0x2B, %cl # checking if it is +
	je _plus # jumping to the subroutine for +

	cmpb $0x2D, %cl # checking if it is -
	je _minus 	# jumping to the subroutine for -

	cmpb $0x2E, %cl # checking if it is .
	je _period # jumping to the subroutine for .

	cmpb $0x2C, %cl # checking if it is ,
	je _comma # jumping to the subroutine for ,

	cmpb $0x5B, %cl # checking if it is [
	je _leftLoop # jumping to the subroutine for [

	cmpb $0x5D, %cl # checking if it is ]
	je _rightLoop # jumping to the subroutine for ]

	cmpb $0x3E, %cl # checking if it is >
	je _forward # jumping to the subroutine for >

	cmpb $0x3C, %cl # checking if it is <
	je _back # jumping to the subroutine for <

	cmpb $0x00, %cl # checking if the character is the end of string
	je _zero # jumping to the subroutine _zero

	incq %rsi # if it is not any of these, increase the value of rsi
	jmp _loop # jump to _loop again

	ret # return

_zero:
	movq %rbp, %rsp # moving the base pointer to the stack pointer
	popq %rbp # popping rbp from the stack
	ret 

_plus:
	cmpq $255, %rbx # if rbx is equal to 255
	je _plus255	 # jump to the _plus255 subroutine

	incq %rbx # else increase rbx (our cell)
	incq %rsi # increase the rsi to go further into our brainfuck code

	jmp _loop # jump back to the loop


_plus255:
	movq $0, %rbx # if it is 255, then the next number is 0
	incq %rsi # go further in rsi

	jmp _loop # jump to _loop 
	
_minus:
	cmpq $0, %rbx # if rbx is 0
	je _minus0 	# jump to _minus0

	decq %rbx # else decrease the rbx
	incq %rsi # increase rsi

	jmp _loop # jump back to _loop

_minus0:
	movq $255, %rbx # if rbx is 0, the number smaller by 1 is 255
	incq %rsi # increase rsi

	jmp _loop # jump back to _loop
	

_comma:
	movq %rsi, %R14 # moving rsi into r14 so we don't lose rsi

	movq $0, %rax # no vector registers needed
	movq (%rsp), %rcx # moving the stack pointer in rcx so we don't lose it
	leaq (%rsp), %rsi # loading the effective address of %rsp into rsi
	movq $char, %rdi # the format of the character
	call scanf # calling the scanf function

	movq (%rsp), %rbx # moving the read char into rbx
	movq %rcx, (%rsp) # assining the former value of (%rsp) back to it
	movq %R14, %rsi # moving back r14 to rsi 

	incq %rsi # increasing rsi
	jmp _loop # jumping back to _loop


_period:
	movq %rsi, %R14 # moving rsi into r14 so we don't lose rsi

	movq $0, %rax # no vector registers needed
	movq %rbx, %rsi # loading the effective address of rbx into rsi
	movq $char, %rdi # the format of the value
	call printf # calling the printf subroutine

	movq %R14, %rsi # moving back r14 back to rsi
	incq %rsi # increasing r14
	jmp _loop # jumping back to _loop


_leftLoop:
	movq $0, %rdx # number of open loops

	cmpq $0, %rbx # if our cell is 0
	je _leftZero # we want to ignore the loop so we go to _leftZero

	cmpq %rsi, (%rsp) # if rsi is different to the element on the stack
	jne _pushIndex # we push the address of the [ to the stack

	incq %rsi # increase rsi
	jmp _loop # jump back to _loop

_pushIndex:
	pushq %rsi # pusing rsi on the stack

	incq %rsi # increasing rsi
	jmp _loop # jumping back to loop



# we want to ignore a loop if rbx is 0 when getting into the loop

_leftZero:
	movb (%rsi), %cl # getting the ascii code into cl
	cmpb $0x5B, %cl # checking if cl is [
	je _addPar # if equal, jump to _addPar

	cmpb $0x5D, %cl # checking if cl is ]
	je _removePar # if equal, jump to _removePar

	incq %rsi # increasing rsi

	jmp _leftZero # if the char is not [ or ], jump back to _leftZero 	

_addPar:
	incq %rdx # increasing the number of opened paranthesis
	incq %rsi # increasing rsi
	jmp _leftZero # jumping back to _leftZero

_removePar:
	decq %rdx # decreasing the number of opened, but not closed loops
	incq %rsi # increasing rsi

	cmpq $0, %rdx # if the number of open loops which are not closed
	jne _leftZero # is not 0, jump to _leftZero

	jmp _loop # jump back to _loop


_rightLoop:
	cmp $0, %rbx # checking if our cell is 0
	je _rightLoopZero # then we want to go further in our code, so we jump to _righLoopZero

	cmp $0, %rbx # is rbx is not 0
	jne _rightLoopNotZero # jump to _rightLoopNotZero

	_rightLoopZero:
		popq %rdx # popping the address of the corresponding paranthesis from the stack into rdx
		movq $0, %rdx # cleaning rdx

		incq %rsi # increasing rsi

		jmp _loop # jump to _loop

	_rightLoopNotZero:
		movq %rsi, %R14 # saving the address of rsi into r14
 
		subq (%rsp), %R14 # subtracting the address of the stack pointer from the current rsi
		subq %R14, %rsi # subtracting rsi from the difference between [ and ]
		# therefore, we get the number of positions we have to go back

		incq %rsi # increasing rsi

		jmp _loop # jump to _loop


_forward:
	# r12 is the number of cells we have initialised
	# r13 is the current position we're at
	cmp %r12, %r13 # if r13 is equal to r12
	je _fwd1 # jump to _fwd1
	
	cmp %r12,%r13 # if r12 is greater than r13
	jl _fwd2 # jump to _fwd2

	_fwd1:
		incq %r12 # increasing the position we're at
		incq %r13 # increasing the number of initialised cells
  
		movq %rbx, (%r15) # moving rbx to the location where r15 points to 

		addq $8, %r15 # increasing r15 by 8, so we make place for another element

		movq $0, %rbx # initialise the cell with 0

		incq %rsi # increasing rsi

		jmp _loop # jump back to _loop
	

	_fwd2:
		incq %r13 # increasing the position we're at

		movq %rbx, (%r15) # moving rbx int (%r15)
		addq $8, %r15 # increasing r15 by 8
		movq (%r15), %rbx # moving the element that is it (%r15) into rbx, our cell

		incq %rsi # increasing rsi
		jmp _loop # jumping back to _loop

_back:
	decq %R13 # decreasing the position we're at 
	movq %rbx, (%r15) # moving the element in our cell into (%r15)
	subq $8, %r15 # subracting 8 from r15
	movq (%r15), %rbx # moving the element from (%r15) into our cell
	 
	incq %rsi # increasing rsi
	jmp _loop # jumping back to _loop