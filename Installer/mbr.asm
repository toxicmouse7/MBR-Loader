.686P
.model tiny
option segment:use16

c16 segment
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
    mov ah, 2   ; чтение секторов
    mov al, 3   ; количество секторов
    mov bx, 7C00h ; адрес буфера
    mov ch, 0   ; младшие 8 бит номера цилиндра, начиная с 0
    mov cl, 2   ; 6 бит номера сектора, начиная с 1, (в младших битах) и старшие 2 бита номера цилиндра
    mov dh, 0   ; номер головки
    mov dl, 80h ; номер диска, нумерация начинается с 0x80
    int 13h
    
    jmp bx

org 7DFCh
dw 0ECECh
dw 0AA55h
c16 ends

end