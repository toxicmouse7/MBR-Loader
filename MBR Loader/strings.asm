PrintString proc stdcall uses si ax stringPtr: ptr word

	mov si, [stringPtr]

@@:
	lodsb
	
	cmp al, 0
	je @f

	mov ah, 0Eh
	int 10h
	jmp @b

@@:

	ret

PrintString endp

PrintSymbol proc stdcall uses ax symbol: byte

	mov ah, 0Eh
	mov al, [symbol]
	int 10h
	ret

PrintSymbol endp

PrintBackspace proc stdcall uses ax

	; получаем текущую позицию курсора
    xor bx, bx
    mov ah, 3
    int 10h
    ; сдвигаем
    dec dl
	push dx
	push bx
    mov ah, 2
    int 10h

	mov ah, 0Eh
	mov al, 0
	int 10h

	pop bx
	pop dx
	mov ah, 2
	int 10h

	ret

PrintBackspace endp

hexb proc stdcall number: dword

	invoke hex, 4, number
	ret

hexb endp


hexw proc stdcall number: dword

	invoke hex, 12, number
	ret

hexw endp

hexd proc stdcall number: dword

	invoke hex, 28, number
	ret

hexd endp

hex proc stdcall uses ax cx dx param: byte, number: dword

	mov eax, [number]
	mov cl, [param]
hexBegin:
	mov edx, eax
	shr eax, cl
	and al, 0Fh
	add al, '0'
	cmp al, '9'
	jbe  @f
	add al, 'A' - ('9' + 1)
@@:
	mov ah, 0Eh
	int 10h

	test cl, cl
	je @f
	
	sub cl, 4
	mov eax, edx
	jmp hexBegin

@@:
	ret

hex endp

decimal proc stdcall uses ax bx dx number: word
	local count: byte
	mov [count], 0

	.if [number] == 0
		mov al, '0'
		mov ah, 0Eh
		int 10h
		ret
	.endif

	mov ax, number
	mov bx, 10

	.while ax != 0
		xor dx, dx
		div bx
		add dl, '0'
		push dx
		inc [count]
	.endw

	.while [count] != 0
		pop ax
		mov ah, 0Eh
		int 10h
		dec [count]
	.endw

	ret

decimal endp

StringToWord proc stdcall uses bx cx si stringAddress: ptr byte

	local strLength: word

	invoke StringLength, [stringAddress]
	mov [strLength], ax
	mov si, [stringAddress]

	xor cx, cx
	xor ax, ax
	.while cx != [strLength]
		mov bx, 10
		mul bx
		mov bl, byte ptr [si]
		xor bh, bh
		sub bl, '0'
		add ax, bx
		inc si
		inc cx
	.endw

	ret

StringToWord endp

StringLength proc stdcall uses si stringAddress: ptr byte

	xor ax, ax
	mov si, [stringAddress]

	.while byte ptr [si] != 0
		inc ax
		inc si
	.endw

	ret

StringLength endp