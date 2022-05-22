.686P
.model flat, stdcall
option casemap:none

include ..\Core\const.inc

assume fs:nothing

c32 segment use32 para
org BASE_VA_2_FUNC

include ring3_functions.inc

.while 1

    mov esi, offset array
    xor ecx, ecx
    mov [min], 07FFFFFFFh

    .while ecx != [arraySize]

        mov eax, [min]
        mov ebx, [lastMin]

        .if [esi] < eax && sdword ptr [esi] > ebx
            mov eax, [esi]
            mov [min], eax
        .endif

        add esi, 4
        inc ecx

    .endw

    mov eax, [min]
    mov [lastMin], eax
    add eax, '0'

    invoke GotoXY, 0, 1
    invoke PrintSymbol, al

    .if [lastMin] == 9
        mov [lastMin], -1
    .endif

.endw

include ring3_functions.asm

array dd 9, 0, 8, 1, 7, 2, 6, 3, 5, 4
arraySize dd 10

min dd 07FFFFFFFh
lastMin dd -1

c32 ends

end