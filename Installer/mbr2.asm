.686P
.model tiny
option segment:use16

c16 segment
org 7C00h
begin:
    
    include strings.inc
    include code16.inc

    mov ax, 40h
    mov es, ax
    mov al, es:[75h]

    mov [numberOfDrives], al

    xor cx, cx

    .while cl != [numberOfDrives]

        push cx
        mov ah, 08h
        mov dl, [drive]
        int 13h

        mov [head], dh
        invoke CHStoLBA, [head], cx
        mov [diskCapacity], eax
        invoke SplitCS, cx
        mov [sector], al
        mov [cylinder], dx

        pop cx

        inc cx
        invoke decimal, cx
        dec cx
        invoke PrintSymbol, '.'
        invoke PrintSymbol, ' '
        invoke PrintString, addr [geometryString]

        inc [cylinder]
        invoke decimal, [cylinder]
        invoke PrintSymbol, '/'

        inc [head]
        invoke decimal, [head]
        invoke PrintSymbol, '/'

        inc [sector]
        invoke decimal, [sector]

        mov eax, [diskCapacity]
        mov ebx, 200h
        xor edx, edx
        mul ebx
        mov ebx, 400h
        div ebx
        mov [diskCapacity], eax

        invoke PrintString, addr [capacityString]
        invoke decimal, [diskCapacity]

        invoke PrintSymbol, 13
        invoke PrintSymbol, 10

        inc cx

    .endw

    include strings.asm
    include code16.asm

    hlt

numberOfDrives db 0
drive db 80h

head db 0
cylinder dw 0
sector db 0

diskCapacity dd 0

geometryString db "Geometry: ", 0
capacityString db " Capacity: ", 0

db 400h - ($ - begin) dup (0)

c16 ends

end