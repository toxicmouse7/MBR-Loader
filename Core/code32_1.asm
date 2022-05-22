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