.686P
.model flat, stdcall
option casemap:none

include intel.inc

include const.inc

include task_queue.inc

assume fs:nothing

c32 segment use32 para

include code32.inc

org BASE_VA_MAIN_PMODE_CODE ; 80001400h
main_pmode_code_start:

    include code32.inc

    mov eax, BASE_PA_PD
    mov dword ptr [eax], 0

    lgdt fword ptr [GDTR]
    lidt fword ptr [IDTR]

    ; обновляем теневую часть регистра es
    mov ax, 18h
    mov es, ax

    mov esp, BASE_VA_RING0_STACK

    invoke InitTSQueue, offset globalTSQueue

    ; разрешение немаскируемых прерываний (NMI)
    in  al, 70h
    and al, 7Fh
    out 70h, al
    ; разрешение маскируемых прерываний
    sti

    mov ax, 30h
    ltr ax

    mov eax, offset globalTss
    mov [eax].TSS.esp0, BASE_VA_RING0_STACK     ; вершина стека для нулевого кольца
    mov [eax].TSS.ss0, 10h                      ; селектор стека для нулевого кольца

    invoke InitPageTableEntry, BASE_VA_RING0 + BASE_PA_PD, 45, BASE_PA_TABLE_FF, 1, 1
    invoke InitAllPageTable, BASE_VA_RING0 + BASE_PA_TABLE_FF, BASE_RING3_ENTRY, 1, 1

    invoke InitPageTableEntry, BASE_VA_RING0 + BASE_PA_PD, 42, BASE_PA_TABLE_SF, 1, 1
    invoke InitAllPageTable, BASE_VA_RING0 + BASE_PA_TABLE_SF, BASE_RING3_ENTRY + 1000h, 1, 1

    invoke InitPageTableEntry, BASE_VA_RING0 + BASE_PA_PD, 0, BASE_PA_TABLE_USER, 1, 1
    invoke InitAllPageTable, BASE_VA_RING0 + BASE_PA_TABLE_USER, BASE_RING3_ENTRY + 2000h, 1, 1

    ; при переходе в ring3 обнуляются все сегментные регистры,
    ; в которых загружены селекторы для дескрипторов с DPL=0
    ; поэтому загружаем в ds селектор сегмента данных с DPL=3
    mov ax, 28h + 3
    mov ds, ax
    
    ; формируем стек для перехода в ring3 с помощью iretd
    push dword ptr 28h + 3              ; ss
    push dword ptr BASE_VA_RING3_STACK  ; esp
    pushfd                              ; eflags
    push dword ptr 20h + 3              ; cs
;    push BASE_VA_1_FUNC                ; eip
;    push BASE_VA_2_FUNC                ; eip
    push BASE_VA_RING3                ; eip
    iretd

    include task_queue.asm
    include code32.asm

globalTss       TSS     <>
globalTSQueue   TSQueue <>

sysCursor dd 80 * 2
cursor dd 0
TPLT dd 0

ASCII db 0,'1234567890-+',0,0,'QWERTYUIOP[]',0,0,'ASDFGHJKL;',"'`",0,0,'ZXCVBNM,./',0,'*',0,' ',0, 0,0,0,0,0,0,0,0,0,0, 0,0, '789-456+1230.', 0,0

DefineVA macro off
    exitm <(BASE_VA_MAIN_PMODE_CODE + (off - main_pmode_code_start))>
endm

; Global Descriptor Table
GDT:
    dd 0, 0
    DefineUsualCodeSegmentDescriptor 0, 0FFFFFh, 0          ; код  (селектор = 8h)
    DefineUsualDataSegmentDescriptor 0, 0FFFFFh, 0          ; данные (селектор = 10h)
    DefineUsualDataSegmentDescriptor 800B8000h, 0FFFFFh, 0  ; видеобуфер (селектор = 18h)
    DefineUsualCodeSegmentDescriptor 0, 0FFFFFh, 3  ; код (селектор = 20h)
    DefineUsualDataSegmentDescriptor 0, 0FFFFFh, 3  ; данные (селектор = 28h)
    DefineTssDescriptor DefineVA(globalTss), sizeof(TSS) - 1, 0         ; TSS (селектор = 30h)

GDT_size equ $ - GDT
GDTR:
    dw (GDT_size - 1) and 0FFFFh
    dd GDT


; Interrupt Descriptor Table
IDT:
    ;dd 14 dup (0, 0)
    ;dd DefineInterruptGate 08h, DefineVA(PrintStringSyscall), 0
    ;dd (32 - 14 - 1) dup (0, 0)
    dd 32 dup (0, 0)
    DefineInterruptGate 08h, DefineVA(TimerHandler), 0       ; 0x20 (IRQ 0 - системный таймер)
    DefineInterruptGate 08h, DefineVA(KeyboardHandler), 0    ; 0x21 (IRQ 1 - клавиатура)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x22 (IRQ 2 - ведомый контроллер прерываний)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x23 (IRQ 3 - COM2)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x24 (IRQ 4 - COM1)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x25 (IRQ 5 - LPT2)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x26 (IRQ 6 - FDD)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x27 (IRQ 7 - LPT1)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x28 (IRQ 8)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x29 (IRQ 9)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2A (IRQ 10)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2B (IRQ 11)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2C (IRQ 12 - PS/2 mouse)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2D (IRQ 13)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2E (IRQ 14)
    DefineInterruptGate 08h, DefineVA(InterruptStub), 0      ; 0x2F (IRQ 15)
    DefineInterruptGate 08h, DefineVA(PrintSymbolSyscall), 3 ; 0x30 (PrintSymbol)
    DefineInterruptGate 08h, DefineVA(PrintStringSyscall), 3 ; 0x31 (PrintString)
    DefineInterruptGate 08h, DefineVA(GotoXYSyscall), 3      ; 0x32 (GotoXY)
    DefineInterruptGate 08h, DefineVA(RunTaskSyscall), 3      ; 0x33 (RunTask)

IDT_size equ $ - IDT
IDTR:
    dw (IDT_size - 1) and 0FFFFh
    dd IDT

c32 ends

end