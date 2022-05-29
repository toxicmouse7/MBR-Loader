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

    mov ax, 0
    mov es, ax

    xor cx, cx

    .while cl != [numberOfDrives]

        push cx
        mov dl, [drive]
        mov dh, 0
        mov ch, 0
        mov cl, 1
        mov al, 1
        mov bx, 600h
        mov ah, 2
        int 13h
        mov bx, 7FCh
        mov ax, word ptr [bx]
        pop cx

        .if ax == 0ECECh
            mov al, [drive]
            mov [installerDrive], al
            sub [installerDrive], 80h
            inc [drive]
            inc cx
            .continue
        .endif

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
        inc [drive]

    .endw

@@:
    mov ah, 0
    int 16h

    .if al < '9' && al > '0'
        sub al, '0'
        dec al
        .if al == [installerDrive] || al > [numberOfDrives]
            jmp @b
        .endif
    .endif

    add al, 80h
    add [installerDrive], 80h

    push ax
    mov dl, al
    mov ah, 8h
    int 13h
    pop ax

    mov bx, 500h

    mov byte ptr [bx], dh
    mov byte ptr [bx + 1], ch
    mov byte ptr [bx + 2], cl

    movzx cx, [installerDrive]
    push cx
    push ax

    cld
    mov si, 7C00h
    mov di, 600h
    mov cx, 600h
    rep movsb

    mov ax, (stage1 - begin) + 600h
    jmp ax

stage1:

    mov dl, [installerDrive]
    mov dh, 0
    mov ch, 0
    mov cl, 5
    mov al, 2
    mov bx, 7C00h
    mov ah, 2
    int 13h

    mov ax, 7C00h
    jmp ax

    include strings.asm
    include code16.asm

numberOfDrives db 0
drive db 80h
installerDrive db 0

head db 0
cylinder dw 0
sector db 0

diskCapacity dd 0

geometryString db "Geometry: ", 0
capacityString db " Capacity: ", 0

db 600h - ($ - begin) dup (0)

c16 ends

end