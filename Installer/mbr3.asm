.686P
.model tiny
option segment:use16

c16 segment
org 7C00h
begin:
    include strings.inc
    include code16.inc

    mov ax, 2
    int 10h

    pop ax
    mov [drive], al
    mov dx, ax
    mov dh, 0
    mov ch, 0
    mov cl, 1
    mov al, 1
    mov ah, 2
    mov bx, 1000h
    int 13h

    xor cx, cx
    mov si, 11BEh

    .while cx != 4

        inc cx
        invoke decimal, cx
        dec cx
        
        mov ax, [si + 2]
        invoke SplitCS, ax

        .if ax == 0 && dx == 0 && byte ptr [si + 1] == 0
            invoke PrintString, addr freeStr
            jmp @f
        .endif

        invoke PrintString, addr chsString

        invoke decimal, dx
        invoke PrintSymbol, '/'
        invoke decimal, byte ptr [si + 1]
        invoke PrintSymbol, '/'
        invoke decimal, al

        invoke PrintString, addr betweenStr

        mov ax, [si + 6]
        invoke SplitCS, ax

        invoke decimal, dx
        invoke PrintSymbol, '/'
        invoke decimal, byte ptr [si + 5]
        invoke PrintSymbol, '/'
        invoke decimal, al

    @@:
        invoke PrintSymbol, 13
        invoke PrintSymbol, 10

        inc cx
        add si, 10h

    .endw

@@:
    mov ah, 0
    int 16h

    .if al > '4' || al < '1'
        jmp @b
    .endif

    sub al, '0'
    dec al

    pop bx
    push bx
    push ax
    cld
    mov si, 7C00h
    mov di, 600h
    mov cx, 400h
    rep movsb

    movzx di, [drive]
    push di

    mov ax, 600h + (stage1 - begin)
    jmp ax

stage1:

    mov dl, bl
    mov dh, 0
    mov ch, 0
    mov cl, 7
    mov al, 3
    mov bx, 7C00h
    mov ah, 2
    int 13h

    mov ax, 7C00h
    jmp ax


    include strings.asm
    include code16.asm

chsString db ". C/H/S: ", 0
betweenStr db " - ", 0
freeStr db ". Free", 0

drive db 0

db 400h - ($ - begin) dup(0)

c16 ends

end