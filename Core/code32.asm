InitPageTableEntry proc baseTable:dword, indexEntry:dword, address:dword, U_S:dword, R_W:dword

    mov eax, [indexEntry]
    lea eax, [4 * eax]
    add eax, [baseTable]
    
    mov ecx, [address]
    and ecx, 0FFFFF000h
    mov [eax], ecx
    
    mov ecx, U_S
    and ecx, 1
    shl ecx, 2
    or [eax], ecx
    
    mov ecx, R_W
    and ecx, 1
    shl ecx, 1
    or [eax], ecx
    
    ; P = 1
    or dword ptr [eax], 1
    
    ret

InitPageTableEntry endp

InitAllPageTable proc baseTable:dword, startPhysAddress:dword, U_S:dword, R_W:dword

    local i:dword
    local currentPhysAddress:dword
    mov [i], 0
    
    mov eax, [startPhysAddress]
    mov [currentPhysAddress], eax
    
    .while [i] < 1024
    
        invoke InitPageTableEntry, baseTable, [i], [currentPhysAddress], U_S, R_W
        add [currentPhysAddress], 1000h
        inc [i]
    .endw

    ret

InitAllPageTable endp

memcpy proc uses ebx dst:dword, src:dword, srcSize:dword

    local i:dword
    
    mov [i], 0
    mov ecx, [srcSize]
    .while [i] < ecx
        mov eax, [i]
        add eax, [src]
        mov bl, [eax]
        mov eax, [i]
        add eax, [dst]
        mov [eax], bl
        inc [i]
    .endw
    
    ret

memcpy endp

PrintString proc uses ebx esi stringPointer: ptr dword

    mov esi, [stringPointer]
    mov ebx, [cursor]

@@:
	lodsb
	
	cmp al, 0
	je @f

	mov byte ptr es:[2*ebx], al
    mov byte ptr es:[2*ebx+1], 1Eh
    
    inc ebx
	
    jmp @b
@@:

	ret

PrintString endp

PrintSymbol proc uses eax ebx symbol: byte

    mov al, [symbol]
    mov ebx, [cursor]

    mov byte ptr es:[2*ebx], al
    mov byte ptr es:[2*ebx+1], 1Eh

    ret

PrintSymbol endp

SaveInterruptedTask proc uses eax taskQueue: ptr TSQueue

    local ts: TaskState

    mov eax, [cursor]
    mov [ts].cursor, eax

    mov [ts].tEAX, eax
    mov [ts].tEBX, ebx
    mov [ts].tECX, ecx
    mov [ts].tEDX, edx
    mov [ts].tESI, esi
    mov [ts].tEDI, edi

    mov eax, cr3
    mov [ts].tCR3, eax

    mov eax, [ebp + 12]
    mov [ts].tEIP, eax

    mov al, byte ptr [ebp + 16]
    mov [ts].tCS, al

    mov eax, [ebp + 20]
    mov [ts].tEFLAGS, eax

    mov eax, [ebp + 24]
    mov [ts].tESP, eax

    mov al, byte ptr [ebp + 28]
    mov [ts].tSS, al

    invoke PushTask, [taskQueue], addr [ts]

    ret

SaveInterruptedTask endp

CreateTask proc taskQueue: ptr TSQueue, newEIP: dword, newESP: dword

    local ts: TaskState

    mov [ts].cursor, 0

    mov [ts].tEAX, eax
    mov [ts].tEBX, ebx
    mov [ts].tECX, ecx
    mov [ts].tEDX, edx
    mov [ts].tESI, esi
    mov [ts].tEDI, edi

    mov eax, cr3
    mov [ts].tCR3, eax

    mov eax, [newEIP]
    mov [ts].tEIP, eax

    mov al, byte ptr [ebp + 24]
    mov [ts].tCS, al

    mov eax, [ebp + 28]
    mov [ts].tEFLAGS, eax

    mov eax, [newESP]
    mov [ts].tESP, eax

    mov al, byte ptr [ebp + 36]
    mov [ts].tSS, al

    invoke PushTask, [taskQueue], addr [ts]

    ret

CreateTask endp

SwitchTask proc taskQueue: ptr TSQueue

    mov ebx, [taskQueue]
    mov eax, [ebx].TSQueue.tasksBegin

    .if eax == [ebx].TSQueue.tasksEnd
        ret
    .endif

    invoke PopTask, [taskQueue]

    mov eax, [ebx].TSQueue.popedTask.TaskState.tEIP
    mov [ebp + 12], eax

    movzx eax, byte ptr [ebx].TSQueue.popedTask.TaskState.tCS
    mov [ebp + 16], eax

    mov eax, [ebx].TSQueue.popedTask.TaskState.tEFLAGS
    mov [ebp + 20], eax

    mov eax, [ebx].TSQueue.popedTask.TaskState.tESP
    mov [ebp + 24], eax

    movzx eax, byte ptr [ebx].TSQueue.popedTask.TaskState.tSS
    mov [ebp + 28], eax

    mov eax, [ebx].TSQueue.popedTask.TaskState.cursor
    mov [cursor], eax

    mov eax, [ebx].TSQueue.popedTask.TaskState.tCR3
    mov cr3, eax
    mov eax, [ebx].TSQueue.popedTask.TaskState.tEAX
    mov ecx, [ebx].TSQueue.popedTask.TaskState.tECX
    mov edx, [ebx].TSQueue.popedTask.TaskState.tEDX
    mov esi, [ebx].TSQueue.popedTask.TaskState.tESI
    mov edi, [ebx].TSQueue.popedTask.TaskState.tEDI
    mov ebx, [ebx].TSQueue.popedTask.TaskState.tEBX

    ret

SwitchTask endp

GotoXY proc uses eax edx X: dword, Y: dword

    .if [X] < 80 && [Y] < 25
        .if [Y] == 0
                mov eax, [X]
                mov [cursor], eax
            .else
                push eax
                xor edx, edx
                mov eax, 80
                mul ebx
                mov [cursor], eax
                pop eax
                add [cursor], eax
            .endif
    .endif

    ret

GotoXY endp

; ******************    SYSCALLS    ******************

PrintStringSyscall:
    push eax
    mov ax, 18h
    mov es, ax
    call PrintString

    iretd

PrintSymbolSyscall:
    push eax
    mov ax, 18h
    mov es, ax
    call PrintSymbol

    iretd   

GotoXYSyscall:
    invoke GotoXY, eax, ebx
    iretd

RunTaskSyscall:
    invoke CreateTask, offset globalTSQueue, eax, ebx
    iretd

; ******************    INTERRUPT HANDLERS  ******************

KeyboardHandler:
    pushad

    mov ax, 18h
    mov es, ax

    xor eax, eax
    in al, 60h
    dec al
    mov ah, al
    and ah, 80h
    jnz clear_request

    ; преобразуем позиционный код в ASCII по таблице
    and al, 7Fh
    push edi
    mov edi, offset ASCII
    add edi, eax
    mov al, [edi]
    pop edi

    ; выводим символы на экран один за другим
    mov edi, [sysCursor]
    mov es:[2*edi], al
    inc [sysCursor]

    cmp [sysCursor], 24 * 80
    jb Ack
    mov [sysCursor], 80 * 2

Ack:
    in al, 061h
    or al, 80
    out 061h, al
    xor al, 80
    out 061h, al

clear_request:
    call SendEOI
    popad
    iretd

TimerHandler:
    inc [TPLT]
    .if [TPLT] == 10
        mov [TPLT], 0
        invoke SaveInterruptedTask, offset globalTSQueue
        invoke SwitchTask, offset globalTSQueue
    .endif
    call SendEOI
    iretd

InterruptStub:
    pushad
    call SendEOI
    popad
    iretd

SendEOI:
; сброс заявки в контроллере прерываний: посылка End-Of-Interrupt
    push eax
    mov al, 20h
    out MASTER8259A, al   ; в ведущий (Master) контроллер
    out SLAVE8259A, al   ; в ведомый (Slave) контроллер.
    pop eax
    ret
