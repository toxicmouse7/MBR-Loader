.686P
.model flat, stdcall
option casemap:none

assume fs:nothing

c16 segment use16 byte
org 7C00h

    stage0:
    mov ax, 2
    int 10h

    cld
    mov si, 7C00h
    mov di, 600h
    mov cx, 512
    rep movsb

    mov ax, 600h + (stage1 - stage0)
    jmp ax

    stage1:

    mov ax, cs
    mov ds, ax

    mov ah, 42h
    mov dl, 80h
    mov si, offset [coreLbaAddress]
    int 13h

    mov ah, 42h
    mov dl, 80h
    mov si, offset [userLbaAddress]
    int 13h

    mov ax, 1000h
    jmp ax


org 7DE0h

    coreLbaAddress:
    db 10h      ; размер DAP (должно быть 10h)      0x00
    db 0        ; не используется (должно быть 0)   0x01
    dw 7        ; количество секторов для чтения    0x02
    dw 1000h, 0 ; смещение:сегмент куда читать код  0x04
    dq 882      ;                                   0x08
    ; LBA = (C * 16 + H) * 63 + (S - 1). Это 1/0/1

    userLbaAddress:
    db 10h
    db 0
    dw 3
    dw 4000h, 0
    dq 900

c16 ends

end