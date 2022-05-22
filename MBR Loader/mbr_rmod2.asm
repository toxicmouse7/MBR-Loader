.686P
.model tiny
option segment:use16

c16 segment
org 7C00h
stage0:
    include code16.inc
    include strings.inc
    mov sp, 7C00h

    invoke AnalyzeSectionTable, 600h + 1BEh

    .if ax != 0
        invoke SetTimer, addr [timerFlag]
        mov [activeSection], ax
    .endif

    mov si, offset buffer

    .while 1
        .if [timerFlag] != 0
            .if [delay] == 0
                mov bx, [activeSection]
                jmp loadSection
            .endif
            dec [delay]
            mov [timerFlag], 0
            invoke SetTimer, addr [timerFlag]
        .endif

        mov ah, 1
        int 16h

        .if !zero?
            mov ah, 0
            int 16h

            .if al == 13
                invoke ResetTimer
                mov byte ptr [si], 0
                invoke StringToWord, offset buffer
                .if ax > 4 || ax < 1
                    invoke PrintString, addr newLine
                    mov si, offset buffer
                    .if [activeSection] != 0
                        mov [timerFlag], 0
                        invoke SetTimer, addr [timerFlag]
                    .endif
                    .continue
                .endif

                dec ax
                shl ax, 4
                add ax, 600h + 1BEh
                mov bx, ax
                .if bx != [activeSection]
                    mov byte ptr [bx], 80h
                    mov si, [activeSection]
                    mov byte ptr [si], 0

                    pushad
                    mov ah, 3   ; чтение секторов
                    mov al, 1   ; количество секторов
                    mov bx, 600h ; адрес буфера
                    mov ch, 0   ; младшие 8 бит номера цилиндра, начиная с 0
                    mov cl, 1   ; 6 бит номера сектора, начиная с 1, (в младших битах) и старшие 2 бита номера цилиндра
                    mov dh, 0   ; номер головки
                    mov dl, 80h ; номер диска, нумерация начинается с 0x80
                    int 13h
                    popad
                .endif
                
                loadSection:
                mov al, byte ptr [bx + 1]
                mov [startHead], al
                mov ax, word ptr [bx + 2]
                mov [startCS], ax

                mov al, byte ptr [bx + 5]
                mov dx, word ptr [bx + 6]

                invoke CHStoLBA, al, dx
                mov ebx, eax

                invoke CHStoLBA, [startHead], [startCS]
                sub ebx, eax
                inc bl

                cld
                mov si, 7C00h
                mov di, 600h
                mov cx, 600h
                rep movsb

                mov ax, 600h + (stage1 - stage0)
                jmp ax

                stage1:

                mov ah, 2   ; чтение секторов
                mov al, bl   ; количество секторов
                mov bx, 7C00h ; адрес буфера
                mov ch, byte ptr [startCS + 1]   ; младшие 8 бит номера цилиндра, начиная с 0
                mov cl, byte ptr [startCS]   ; 6 бит номера сектора, начиная с 1, (в младших битах) и старшие 2 бита номера цилиндра
                mov dh, [startHead]   ; номер головки
                mov dl, 80h ; номер диска, нумерация начинается с 0x80
                int 13h

                mov ax, 7C00h
                jmp ax

            .elseif al == 8
                .if si != offset buffer
                    invoke PrintBackspace
                    dec si
                .endif
                .continue
            .endif

            .if si != offset buffer + 4
                mov byte ptr [si], al
                inc si
                mov ah, 0Eh
                int 10h
            .endif
        .endif
    .endw

    include code16.asm
    include strings.asm
    
    timerFlag db 0
    delay dw 60

    buffer db 5 dup(?)

    activeSection dw 0
    startHead db 0
    startCS dw 0

    tab db 5 dup(20h), 0
    newLine db 13, 10, 0
    activeString db "Active", 0
    inactiveString db "Inactive", 0
    chsStartString db "CHS (Start): ", 0
    chsEndString db "CHS (End): ", 0
    typeString db "Type: ", 0
    lbaString db "LBA: ", 0
    lbaSizeString db "LBA Size: ", 0

c16 ends

end