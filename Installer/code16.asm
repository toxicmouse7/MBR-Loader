; Возвращает:
; 	dx - номер цилиндра
;	ax - номер сектора
SplitCS proc stdcall csAddress: word

    local cylinder: word
    local sector: byte

    mov word ptr [cylinder], 0
    mov byte ptr [sector], 0

    mov ax, csAddress
    mov byte ptr [cylinder], ah
    mov byte ptr [cylinder + 1], al
    shr byte ptr [cylinder + 1], 6

    and al, 3Fh
    mov [sector], al
    
    mov dx, [cylinder]
    xor ax, ax
    mov al, [sector]

    ret

SplitCS endp

; eax - LBA
CHStoLBA proc stdcall uses bx dx head: byte, csAddress: word
	
	local sector: byte
	local cylinder: word

	invoke SplitCS, [csAddress]
	mov [cylinder], dx
	mov [sector], al

	mov ax, [cylinder]
	shl ax, 4
	xor bx, bx
	mov bl, [head]
	add ax, bx

	xor dx, dx
	mov bx, 63
	mul bx

	mov bl, [sector]
	dec bl
	add ax, bx

	.if carry?
		inc dx
	.endif

	push ax
	mov ax, dx
	shl eax, 8
	pop ax

	ret

CHStoLBA endp