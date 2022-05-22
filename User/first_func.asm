.686P
.model flat, stdcall
option casemap:none

include ..\Core\const.inc

assume fs:nothing

c32 segment use32 para
org BASE_VA_1_FUNC

include ring3_functions.inc

xor ecx, ecx

.while 1

    .if ecx == sdword ptr [stringPtrArraySize]
        mov ecx, 0
    .endif

    lea eax, [offset stringPtrArray + ecx * 4]
    mov eax, [eax]
    invoke PrintString, eax
    invoke GotoXY, 0, 0
    inc ecx

.endw

include ring3_functions.asm


stringPtrArray dd string1, string2, string3, string4, string5, string6, string7, string8
stringPtrArraySize dd 8

string1 db "This is the first   string!", 0
string2 db "This is the second  string!", 0
string3 db "This is the third   string!", 0
string4 db "This is the fourth  string!", 0
string5 db "This is the fifth   string!", 0
string6 db "This is the sixth   string!", 0
string7 db "This is the seventh string!", 0
string8 db "This is the eighth  string!", 0

stringIndex db 0


c32 ends

end