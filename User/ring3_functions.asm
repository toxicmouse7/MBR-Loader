PrintSymbol proc uses eax symbol: byte

    mov al, [symbol]
    
    int 30h

    ret

PrintSymbol endp

PrintString proc uses eax stringPointer: ptr dword

    mov eax, [stringPointer]
    
    int 31h

    ret

PrintString endp

GotoXY proc uses eax ebx x: dword, y: dword

    mov eax, [x]
    mov ebx, [y]

    int 32h

    ret

GotoXY endp

RunTask proc uses eax entryPoint: ptr dword, stack: ptr dword

    mov eax, [entryPoint]
    mov ebx, [stack]
    int 33h

    ret

RunTask endp