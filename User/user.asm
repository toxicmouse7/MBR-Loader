.686P
.model flat, stdcall
option casemap:none

include ..\Core\const.inc

assume fs:nothing

c32 segment use32 para
org BASE_VA_RING3

include ring3_functions.inc

invoke RunTask, BASE_VA_2_FUNC, BASE_VA_2F_STACK
invoke RunTask, BASE_VA_1_FUNC, BASE_VA_1F_STACK

@@:
xor eax, eax
jmp @b

include ring3_functions.asm

c32 ends

end