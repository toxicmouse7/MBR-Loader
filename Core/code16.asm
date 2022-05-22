InitMasterInterruptController proc baseVectorNumber:word

    mov dx, MASTER8259A
    
    ; начало инициализации контроллера (ICW1)
    mov al, 11h
    out dx, al

    inc dx

    ; базовый номер векторов (ICW2)
    ;mov al, ah
    mov al, byte ptr [baseVectorNumber]
    out dx, al
    
    ; битовая маска линий, на которых "висят" ведомые контроллеры (ICW3)
    mov al, 4
    out dx, al
    
    ; режим специальной полной вложенности (ICW4)
    mov al, 11h
    out dx, al

    ret

InitMasterInterruptController endp



InitSlaveInterruptController proc baseVectorNumber:word

    mov dx, SLAVE8259A
    
    ; начало инициализации контроллера (ICW1)
    mov al, 11h
    out dx, al
    
    inc dx

    ; базовый номер векторов (ICW2)
    ;mov al, ah
    mov al, byte ptr [baseVectorNumber]
    out dx, al
    
    ; битовая маска линий, на которых "висят" ведомые контроллеры (ICW3)
    mov al, 4
    out dx, al
    
    ; режим обычной полной вложенности (ICW4)
    mov al, 1
    out dx, al

    ret

InitSlaveInterruptController endp