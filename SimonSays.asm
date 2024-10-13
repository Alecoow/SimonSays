# Author:	Alex Cooper
# Description:	A simple hello world program!

.data	
	# load the hello string into data memory
	hello:	.asciiz "Hello, world!" 

.text
	li   $v0, 4
	la   $a0, hello	
	syscall
	li   $v0, 10
	syscall
