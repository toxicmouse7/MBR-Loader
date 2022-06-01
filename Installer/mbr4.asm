.686P
.model tiny
option segment:use16

c16 segment
org 7C00h
begin:
    include strings.inc
    include code16.inc

    pop bx
    mov [drive], bl

    mov bx, 500h

    mov al, byte ptr [bx]
    mov [maxHead], al

    mov ch, byte ptr [bx + 1]
    mov cl, byte ptr [bx + 2]
    invoke SplitCS, cx
    mov [maxCylinder], dx
    mov [maxSector], al

    mov ax, 2
    int 10h

    invoke PrintString, addr addrString
@@:
    invoke PrintString, addr cString
    invoke PrintString, addr newLine
    invoke ReadNumber, addr buffer
    mov [cylinder], ax
    .if ax > [maxCylinder]
        invoke PrintString, addr errString
        jmp @b
    .endif
@@:
    invoke PrintString, addr hString
    invoke PrintString, addr newLine
    invoke ReadNumber, addr buffer
    mov [head], al
    .if al > [maxHead]
        invoke PrintString, addr errString
        jmp @b
    .endif
@@:
    invoke PrintString, addr sString
    invoke PrintString, addr newLine
    invoke ReadNumber, addr buffer
    mov [sector], al
    .if al > [maxSector]
        invoke PrintString, addr errString
        jmp @b
    .endif

    pop ax
    pop bx
    mov [installerDrive], bl
    push ax

    mov dl, [drive]
    mov dh, 0
    mov ch, 0
    mov cl, 1
    mov al, 1
    mov ah, 2
    mov bx, 600h
    int 13h

    xor dx, dx
    pop ax
    mov ah, 0
    mov bx, 10h
    mul bx
    mov bx, 600h + 1BEh
    add bx, ax

    invoke MergeCS, [cylinder], [sector]
    mov cx, ax

    invoke CHStoLBA, [head], cx
    mov [lba], eax

    mov byte ptr [bx], 0
    mov al, [head]
    mov byte ptr [bx + 1], al
    mov word ptr [bx + 2], cx
    mov byte ptr [bx + 4], 1
    movzx ax, [sector]
    add ax, 15
    .if ax > 63
        sub ax, 63
        add [head], 1
        mov [sector], al
    .endif
    invoke MergeCS, [cylinder], al
    mov word ptr [bx + 6], ax
    mov al, [head]
    mov byte ptr [bx + 5], al
    mov eax, [lba]
    mov dword ptr [bx + 8], eax
    mov dword ptr [bx + 0Ch], 15

    mov dl, [drive]
    mov dh, 0
    mov ch, 0
    mov cl, 1
    mov al, 1
    mov bx, 600h
    mov ah, 3
    int 13h
    ;0x7d5c
    invoke ReadLBA, 15, 0A000h, 9, [installerDrive]
    mov bx, 0A800h + 1E0h
    mov eax, [lba]
    inc eax
    mov dword ptr [bx + 8h], eax ; подмена лба адреса ядра
    add bx, 10h
    add eax, 7
    mov dword ptr [bx + 8h], eax ; подмена лба адреса юзерспейса
    invoke WriteLBA, 11, 0A800h, [lba], [drive]

    mov ax, 2
    int 10h

    invoke PrintString, addr successString

    hlt


    include strings.asm
    include code16.asm


addrString db "Where OS should be installed?", 13, 10, 0
cString db "Cylinder: ", 0
hString db "Head: ", 0
sString db "Sector: ", 0
errString db "Incorrect size"
successString db "Success", 0
newLine db 13, 10, 0
buffer db 4 dup(?)
cylinder dw 0
head db 0
sector db 0
maxCylinder dw 0
maxHead db 0
maxSector db 0
lba dd 0
drive db 0
installerDrive db 0

db 600h - ($ - begin) dup(?)

c16 ends

end