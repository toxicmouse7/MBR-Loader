AnalyzeSectionTable proc stdcall uses si sectionTableAddress: word

	local activity: byte ; флаг активиности (0 или 80h)
	local startHead: byte ; номер головки, с которой начинается раздел
	local startCS: word ; номер цилиндра и сектора, с которых начинается раздел
	local startCylinder: word ; номер цилиндра, с которого начинается раздел
	local startSector: byte ; номер сектора, с которого начинается раздел
	local sectionTypeCode: byte ; код типа раздела
	local endHead: byte ; номер головки, на которой заканчивается раздел
	local endCS: word ; номер цилиндра и сектора, на которых заканчивается раздел
	local endCylinder: word ; номер цилиндра, которым заканчивается раздел
	local endSector: byte ; номер сектора, которым заканчивается раздел
	local lba: dword ; абсолютный номер начального сектора раздела
	local lbaSize: dword ; число секторов в разделе
	local count: word
	local activeSection: word

	mov [count], 0
	mov [activeSection], 0

	mov si, [sectionTableAddress]

	.while [count] != 4
		inc [count]
		invoke decimal, [count]
		dec [count]
		invoke PrintString, addr tab
		.if byte ptr [si] == 80h
			invoke PrintString, addr activeString
			mov [activeSection], si
		.else
			invoke PrintString, addr inactiveString
		.endif
		invoke PrintString, addr newLine

		mov al, [si + 1]
		mov [startHead], al

		mov ax, [si + 2]
		mov [startCS], ax

		invoke SplitCS, [startCS]
		mov [startCylinder], dx
		mov [startSector], al

		mov al, [si + 4]
		mov [sectionTypeCode], al

		invoke PrintString, addr tab
		invoke PrintString, addr typeString
		invoke hexb, [sectionTypeCode]
		invoke PrintString, addr newLine

		mov al, [si + 5]
		mov [endHead], al

		mov ax, [si + 6]
		mov [endCS], ax

		invoke SplitCS, [endCS]
		mov [endCylinder], dx
		mov [endSector], al

		invoke PrintString, addr tab
		invoke PrintString, addr chsStartString
		invoke hexw, [startCylinder]
		invoke PrintSymbol, ' '
		invoke hexb, [startHead]
		invoke PrintSymbol, ' '
		invoke hexb, [startSector]
		invoke PrintString, addr newLine

		invoke PrintString, addr tab
		invoke PrintString, addr chsEndString
		invoke hexw, [endCylinder]
		invoke PrintSymbol, ' '
		invoke hexb, [endHead]
		invoke PrintSymbol, ' '
		invoke hexb, [endSector]
		invoke PrintString, addr newLine

		mov eax, [si + 8]
		mov [lba], eax

		mov eax, [si + 12]
		mov [lbaSize], eax


		invoke PrintString, addr tab
		invoke PrintString, addr lbaString
		invoke hexd, [lba]
		invoke PrintString, addr newLine

		invoke PrintString, addr tab
		invoke PrintString, addr lbaSizeString
		invoke hexd, [lbaSize]
		invoke PrintString, addr newLine

		add si, 10h
		inc [count]
	.endw

	mov ax, [activeSection]

	ret

AnalyzeSectionTable endp


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

SetTimer proc stdcall uses ax cx dx timerFlagPtr: ptr word
	
	mov bx, [timerFlagPtr]
    mov cx, 0Fh
    mov dx, 4240h
    mov ax, 8300h
    int 15h
    ret

SetTimer endp

ResetTimer proc stdcall uses ax

    mov ax, 8301h
    int 15h
    ret

ResetTimer endp

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